---
layout: post
title: 'Kubernetes: cannot get path "//.well-known/openid-configuration"'
tags: tech
date: 2021-05-24 16:00:00 +09:00
---

I've been [playing with using kubernetes service account JWTs to authenticate Pods](/2021/05/24/authentication-using-k8s-service-account-jwts/). To get the cert for checking the JWT signature, I needed to hit the `https://kubernetes.default.svc/.well-known/openid-configuration` endpoint, however as the URL was coming from a config file it ended up being `https://kubernetes.default.svc//.well-known/openid-configuration` (mind the double `//`). This worked well locally where everything runs under the powerful default service account, but when deployed I got an error saying:

<!--break-->

```
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {

  },
  "status": "Failure",
  "message": "forbidden: User \"system:serviceaccount:my-namespace:my-service-account\" cannot get path \"//.well-known/openid-configuration\"",
  "reason": "Forbidden",
  "details": {

  },
  "code": 403
}
```

The solution was to remove the second `/`, and hitting `https://kubernetes.default.svc/.well-known/openid-configuration` worked like a charm.

Googleing the error didn't bring up anything useful, so I'm sharing it here in the hopes of saving others the debugging time.
