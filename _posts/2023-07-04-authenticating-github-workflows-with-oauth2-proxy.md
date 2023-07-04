---
layout: post
title: Authenticating Github workflows with oauth2-proxy
tags: tech
---

[oauth2-proxy](https://github.com/oauth2-proxy/oauth2-proxy) is often used to handle user authentication for apps, however non-human users (e.g. CI workflows) are often unable to complete the OIDC flow.
In this post I will show how to configure oauth2-proxy to trust Github's OIDC provider and use that JWT to authenticate workflows and give them access to the app behind the proxy.

<!--break-->

# 1. Figure out the JWT issuer URL

We are using [the Github OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect) feature that allows workflows to obtain a Github-signed JWT.
The [Github docs](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#:~:text=The%20issuer%20of%20the%20OIDC%20token) say that this is `https://token.actions.githubusercontent.com` for github.com, and `https://HOSTNAME/_services/token` for [Github Enterprise](https://docs.github.com/en/enterprise-server@3.9/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#:~:text=The%20issuer%20of%20the%20OIDC%20token).

To limit the scope of the token to this specific use-case, we also need to pick an audience. 
This should be a unique, non-secret value. 
I will pick `szabo-jp-example-app`.

# 2. Configure the oauth2-proxy

[Oauth2-proxy supports skipping the OIDC flow if a JWT is passed in a header](https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview#:~:text=instead%20of%20stderr-,%2D%2Dextra%2Djwt%2Dissuers,-string). 
To configure this we need to add the following two config options:

```bash
--skip-jwt-bearer-tokens=true
--extra-jwt-issuers="https://token.actions.githubusercontent.com=szabo-jp-example-app"
```

The `--extra-jwt-issuers` config flag holds a list of `issuer=audience` pairs.
When using a different issuer, make sure it has `$ISSUER/.well-known/openid-configuration` or `$ISSUER/.well-known/jwks.json`, e.g. github.com has [the former](https://token.actions.githubusercontent.com/.well-known/openid-configuration).

# 3. Configure the Github action workflow to obtain and use the JWT

```yaml
name: Test Github JWT with oauth2-proxy
on:
  push
# permission can be added at job level or workflow level    
permissions:
  id-token: write # This is required for requesting the JWT
  contents: read  # This is required for actions/checkout, that this example actually doesn't use, but real code probably will
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - name: Test
      run: |
        GH_JWT=$(curl -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=szabo-jp-example-app" | jq -j -c '.value')
        curl -v -H "Authorization: Bearer $GH_JWT" https://your-app-behind-oauth2-proxy.example.com/
```

The workflow [needs](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#adding-permissions-settings) the `id-token: write` permissions, and once this is set, you can [call the endpoint that returns the JWT](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#updating-your-actions-for-oidc).

Make sure to pass the same audience to the call that you configured with the oauth2-proxy!

The response is a json, so we use `jq` to get only the value.
Note the use of `-j` which avoids [quoting the token value](https://github.com/jqlang/jq/issues/1735#issuecomment-520650243) (a pretty hard to debug issue, as Github filters the token value in workflow logs).
If this fails, make sure `jq` is installed on the runner.

Once the JWT is obtained, we can pass it to the oauth2-proxy via the `Authorization: Bearer` header.

# 4. Debugging

If it's not working, check the oauth2-proxy logs. You might find a message like

```
[2023/07/04 07:07:27] [jwt_session.go:51] Error retrieving session from token in Authorization header: no valid bearer token found in authorization header
[2023/07/04 07:07:27] [oauthproxy.go:866] No valid authentication in request. Initiating login.
```

I found that it's the easiest to check the [project's source](https://github.com/oauth2-proxy/oauth2-proxy/blob/master/pkg/middleware/jwt_session.go) to see why a certain error is returned.

If everything is working you should see a log message like this:

```
127.0.0.6 - 3e98af6c-2d10-4b53-fa52-7a7a89f6b824 - repo:markszabo/markszabo.github.io:ref:refs/heads/testing-github-jwt [2023/07/04 07:07:56] your-app-behind-oauth2-proxy.example.com GET / "/debug" HTTP/1.1 "curl/7.81.0" 200 3306 0.055
```

# 5. Identity of the workflow

When the `--pass-user-headers` config option is set, oauth2-proxy passes the authenticated user's identity in the headers `X-Forwarded-User`, `X-Forwarded-Groups`, `X-Forwarded-Email` and `X-Forwarded-Preferred-Username`.
But now that we are skipping the OIDC flow, what value do these headers get?

The log output earlier already hinted at it:

```
X-Forwarded-Email: repo:markszabo/markszabo.github.io:ref:refs/heads/testing-github-jwt
X-Forwarded-User: repo:markszabo/markszabo.github.io:ref:refs/heads/testing-github-jwt
```

The value is the `sub` [subject claim](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#updating-your-actions-for-oidc:~:text=Defines%20the%20subject%20claim%20that%20is%20to%20be%20validated%20by%20the%20cloud%20provider.%20This%20setting%20is%20essential%20for%20making%20sure%20that%20access%20tokens%20are%20only%20allocated%20in%20a%20predictable%20way.) from the JWT, which in case of the Github JWT has the following format: `repo:ORG/REPO:ref:GITHUB_REF`.
`GITHUB_REF` [usually holds the branch name, but not always](https://docs.github.com/en/actions/learn-github-actions/contexts#:~:text=GitHub%20Actions.%22-,github.ref,-string).

When configuring authorization in your app based on these headers, make sure to include the trailing colon. 
For example `strings.HasPrefix(authHeaderVakue, "repo:markszabo/markszabo.github.io")` will also match other repositories, e.g. `markszabo/markszabo.github.io-other-repo`, so use `strings.HasPrefix(authHeaderVakue, "repo:markszabo/markszabo.github.io:")` to avoid this.
