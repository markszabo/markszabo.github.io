---
layout: post
title: "istio-proxy 'NR filter_chain_not_found' / upstream connect error or disconnect/reset before headers. reset reason: connection termination"
tags: tech
---

I deployed a vendor's software on kubernetes and the website showed this error message:

```
upstream connect error or disconnect/reset before headers. reset reason: connection termination
```

Looking at the `istio-proxy` sidecar logs on the Pod I could see an error message:

```bash
kubectl logs -c istio-proxy app-ui-543875cf14-a2b33
[2023-08-09T06:06:22.268Z] "- - -" 0 NR filter_chain_not_found - "-" 0 0 0 - "-" "-" "-" "-" "-" - - 10.20.223.206:8080 10.20.221.213:42304 - -
```

<!--break-->

The app was setup like this: the request hit the istio ingress, which forwarded the request to the `app-gateway` Service. The `app-gateway` Pod then routed the request to the approriate Service (acting essentially as a reverse proxy).

The `app-gateway` Pod could reach `app-ui` via `curl` just fine:

```bash
kubectl exec -it app-gateway-78954c5f7b-5pwt5 -- curl 'http://app-ui:8080'
<!DOCTYPE html>
<html lang="en">
  <head>
...
```

The issue turned out to be this: when `app-gateway` forwarded the request, it didn't rewrite the `Host` header. This is not an issue on normal kubernetes deployments, but istio's envoy sidecar checks the Host header and as that didn't match the Pod (the hostname only had a `VirtualService` entry pointing to `app-gateway`), it didn't forward the request.

Setting the `Host` header manually resulted in the original error message:

```bash
kubectl exec -it app-gateway-78954c5f7b-5pwt5 -- curl --header 'Host: my-app.example.com' 'http://app-ui:8080'
upstream connect error or disconnect/reset before headers. reset reason: connection termination
```

Solution: gateway needed to rewrite the `Host` header to match the destination hostname, in this case: `http://app-ui:8080`. One this was done, it started to work as expected.
