---
layout: post
title: Authentication using kubernetes service account JWTs
tags: tech
date: 2021-05-24 18:00:00 +09:00
---

Permissions for a Pod in kubernetes are managed via [Service Accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/), and these come with a JWT issued by the cluster. If the Pods need to authenticate to an external service, it would be reasonable to use this JWT, so let's see how to get it and verify it.

<!--break-->

This JWT can also be used to call the Kubernetes API, as described very well in [this article](https://itnext.io/kubernetes-serviceaccounts-jwt-tokens-authentication-and-rbac-authorization-e769f3d85a28). I definitely recommend reading that, as I won't be going into so much detail on the ServiceAccount and RBAC part.

# Setup

Make sure you have a cluster (e.g. minikube) setup, and kubectl authenticated.

Create a new namespace and service account:

{% highlight bash %}
➜  kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: my-namespace
EOF
{% endhighlight %}

{% highlight bash %}
➜  kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  namespace: my-namespace
EOF
{% endhighlight %}

Start an image in the namespace with the service account and open bash into it. Then install curl and jq:

{% highlight bash %}
➜  kubectl run -it --rm --restart=Never ubuntu --image=ubuntu bash --namespace=my-namespace --serviceaccount=my-service-account
If you don't see a command prompt, try pressing enter.
root@ubuntu:/# apt update && apt install -y curl jq
{% endhighlight %}

# Get the token in a Pod

Now that we have the shell into a container, let's find the token. Based on the [docs](https://kubernetes.io/docs/tasks/run-application/access-api-from-pod/#without-using-a-proxy) all we have to do is:

{% highlight bash %}
# Point to the internal API server hostname
APISERVER=https://kubernetes.default.svc

# Path to ServiceAccount token
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount

# Read this Pod's namespace
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)

# Read the ServiceAccount bearer token
TOKEN=$(cat ${SERVICEACCOUNT}/token)

# Reference the internal certificate authority (CA)
CACERT=${SERVICEACCOUNT}/ca.crt

# Explore the API with TOKEN
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api
{% endhighlight %}

This is a great start, as it shows that the `/var/run/secrets/kubernetes.io/serviceaccount/token` file holds the JWT token, and the `/var/run/secrets/kubernetes.io/serviceaccount/ca.crt` holds the ca cert used by the Kubernetes API server.

# Getting the certificate to verify the JWT

Unfortunately the `ca.crt.` file is not the certificate used for the JWT. To get that, we need to hit the `/.well-known/openid-configuration` endpoint. Based on the previous example:

{% highlight bash %}
# Point to the internal API server hostname
APISERVER=https://kubernetes.default.svc

# Path to ServiceAccount token
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount

# Read this Pod's namespace
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)

# Read the ServiceAccount bearer token
TOKEN=$(cat ${SERVICEACCOUNT}/token)

# Reference the internal certificate authority (CA)
CACERT=${SERVICEACCOUNT}/ca.crt

# Explore the API with TOKEN
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/.well-known/openid-configuration | jq
{% endhighlight %}

`jq` is used only to pretty-print the json. This will return something like:

{% highlight json %}
{
  "issuer": "https://kubernetes.default.svc.cluster.local",
  "jwks_uri": "https://192.168.64.2:8443/openid/v1/jwks",
  "response_types_supported": [
    "id_token"
  ],
  "subject_types_supported": [
    "public"
  ],
  "id_token_signing_alg_values_supported": [
    "RS256"
  ]
}
{% endhighlight %}

The `jwks_uri` holds the [JSON Web Key Sets](https://auth0.com/docs/tokens/json-web-tokens/json-web-key-sets). Calling that URL with the same bearer token:

{% highlight bash %}
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET https://192.168.64.2:8443/openid/v1/jwks | jq
{% endhighlight %}

will return something like this:

{% highlight json %}
{
  "keys": [
    {
      "use": "sig",
      "kty": "RSA",
      "kid": "BPlcMy7AywKBfLhl67WEfBoRklvuovLWXk-y79NbOxc",
      "alg": "RS256",
      "n": "tqzzgxqEkP7yZDwWGPwrFjlf8Ga7KExEQzPaF2VdtnLn1Xec5C2EDfwgXkr5irttvL7_CtItKh8SKjMjwrYZcoIagebIC5mRX3r4mqnG4z501_XtaYNxFSsPfbQz1yjrxr-07d3AyNmO_vbRHftNg3XJTyH5koG3oNS1k5eFZb8mq_drnAJ3rDEs9DAkoCMrv43EXiAOGosnHSUWGobVMBvn53jsfekq-eksT3uRLamKWaisXxqPlkzaqLzY2dIimFfFFPe3Q3OJEFIDqimFZKTaQu3JoMR2V2rTI_vXVCcvmMN0UZtGarr_Zaqx7eR7x2i-7X8Hd-6pWpOjmJNc8w",
      "e": "AQAB"
    }
  ]
}
{% endhighlight %}

This can be parsed using a library like [https://github.com/MicahParks/keyfunc](https://github.com/MicahParks/keyfunc) and the result can then be passed to [https://github.com/square/go-jose](https://github.com/square/go-jose) to verify the token.

When calling the URLs make sure not to use double `/` (e.g. `https://kubernetes.default.svc//.well-known/openid-configuration`) as that [can lead to permission errors](/2021/05/24/k8s-cannot-get-path-.well-known-openid-configuration/).

# JWT content

The JWT has a payload, similar to:

{% highlight json %}
{
  "iss": "kubernetes/serviceaccount",
  "kubernetes.io/serviceaccount/namespace": "my-namespace",
  "kubernetes.io/serviceaccount/secret.name": "my-service-account-token-p95dr",
  "kubernetes.io/serviceaccount/service-account.name": "my-service-account",
  "kubernetes.io/serviceaccount/service-account.uid": "7bbebda6-5b05-4ae4-9b86-0d8145c077a5",
  "sub": "system:serviceaccount:my-namespace:my-service-account"
}
{% endhighlight %}

This contains both the namespace and the service account names, which can be used for authorization.

# Code example

[Live demo](https://play.golang.org/p/U9X74L5Rs1G) (tends to timeout due to imports, so you might need to run it multiple times)

{% highlight golang %}
package main

import (
	"crypto/rsa"
	"encoding/json"
	"fmt"
	"log"

	"github.com/MicahParks/keyfunc"
	gojose2 "gopkg.in/square/go-jose.v2"
)

func main() {
	// cat /var/run/secrets/kubernetes.io/serviceaccount/token
	jwt := "eyJhbGciOiJSUzI1NiIsImtpZCI6IkJQbGNNeTdBeXdLQmZMaGw2N1dFZkJvUmtsdnVvdkxXWGsteTc5TmJPeGMifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJteS1uYW1lc3BhY2UiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoibXktc2VydmljZS1hY2NvdW50LXRva2VuLXA5NWRyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6Im15LXNlcnZpY2UtYWNjb3VudCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjdiYmViZGE2LTViMDUtNGFlNC05Yjg2LTBkODE0NWMwNzdhNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpteS1uYW1lc3BhY2U6bXktc2VydmljZS1hY2NvdW50In0.dnvJE3LU7L8XxsIOwea3lUZAULdwAjV9_crHFLKBGNxEu70lk3MQmUbGTEFvawryArmxMa1bWF9wbK1GHEsNipDgWAmc0rmBYByP_ahlf9bI2EEzpaGU5s194csB_eG7kvfi1AHED_nkVTfvCjIJM-9oGICCjDJcoNOP1NAXICFmqvWfXl6SY3UoZvtzUOcH9-0hbARY3p6V5pPecW4Dm-yGub9PKZLJNzv7GxChM-uvBvHAt6o0UBIL4iSy6Bx2l91ojB-RSkm_oy0W9gKi9ZFQPgyvcvQnEfjoGdvNGlOEdFEdXvl-dP6iLBPnZ5xwhAk8lK0oOONWvQg6VDNd9w"

	// curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET https://192.168.64.2:8443/openid/v1/jwks
	jwksJSON := json.RawMessage(`{"keys":[{"use":"sig","kty":"RSA","kid":"BPlcMy7AywKBfLhl67WEfBoRklvuovLWXk-y79NbOxc","alg":"RS256","n":"tqzzgxqEkP7yZDwWGPwrFjlf8Ga7KExEQzPaF2VdtnLn1Xec5C2EDfwgXkr5irttvL7_CtItKh8SKjMjwrYZcoIagebIC5mRX3r4mqnG4z501_XtaYNxFSsPfbQz1yjrxr-07d3AyNmO_vbRHftNg3XJTyH5koG3oNS1k5eFZb8mq_drnAJ3rDEs9DAkoCMrv43EXiAOGosnHSUWGobVMBvn53jsfekq-eksT3uRLamKWaisXxqPlkzaqLzY2dIimFfFFPe3Q3OJEFIDqimFZKTaQu3JoMR2V2rTI_vXVCcvmMN0UZtGarr_Zaqx7eR7x2i-7X8Hd-6pWpOjmJNc8w","e":"AQAB"}]}`)

	// parse the jwks
	jwks, err := keyfunc.New(jwksJSON)
	if err != nil {
		log.Fatalf("Failed to create JWKS from JSON.\nError: %s", err.Error())
	}
	var pubKey *rsa.PublicKey
	for _, k := range jwks.Keys {
		pubKey, err = k.RSA()
		if err != nil {
			log.Fatalf("Failed to create JWKS from JSON.\nError: %s", err.Error())
		}
	}

	// validate the JWT
	object, err := gojose2.ParseSigned(jwt)
	if err != nil {
		log.Fatalf("Failed to create JWKS from JSON.\nError: %s", err.Error())
	}

	jwtContent, err := object.Verify(pubKey)
	if err != nil {
		log.Fatalf("Failed to create JWKS from JSON.\nError: %s", err.Error())
	}

	fmt.Printf("JWT verified, now do some authorization on the contents of it: %s", jwtContent)
}
{% endhighlight %}
