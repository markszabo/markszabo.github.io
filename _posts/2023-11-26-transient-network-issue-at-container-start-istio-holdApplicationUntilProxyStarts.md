---
layout: post
title: "Transient network issue at container start when using istio (solution: holdApplicationUntilProxyStarts)"
tags: tech
---

I was setting up an app on a kubernetes cluster that had istio configured as a service mesh, and I run into an issue: as the application starts, it attempts to communicate to another service over the network (doesn't matter if it's an external service or something running on the same cluster), and it fails.
However when I `kubectl exec` into the container, I can successfully reach the same service.
What's going on and how to solve it?

<!--break-->

The issue comes from how istio sidecars work.
Istio injects an `initContainer` and a regular `container` to each Pod.
The former obtains the certificate, and the latter intercepts network calls from the application container(s), wraps them in mTLS and send them to the destination's sidecar.

`initContainers` start in the order defined in the yaml, and one has to finish before the next can start. Regular `containers` on the other hand start in paralell, all at the same time.

This is where the issue comes from: if our application container starts sending network calls before the istio sidecar container is ready to handle them, these calls will fail.
And if the application can't handle this failure gracefully, then the whole container can fail.
This should lead to a failing health check, and kubernetes restarting the Pod.
However when the Pod restarts, all of its containers get restarted, so it will likely go into the same failure.

## The solution

**Set the `proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'` annotation on the Pod**

For example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
  annotations:
    proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'
spec:
  containers:
  - name: main
    image: my-app:1.14.2
```

Or on a `Deployment`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
  labels:
    app: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
      annotations:
        proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'
    spec:
      containers:
      - name: main
        image: my-app:1.14.2
```

Setting this annotation overrides the [default ProxyConfig](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#ProxyConfig) defined in the istio config (override logic desscribed [here](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#ProxyConfig:~:text=This%20can%20also%20be%20configured%20on%20a%20per%2Dworkload%20basis%20by%20configuring%20the%20proxy.istio.io/config%20annotation%20on%20the%20pod.%20For%20example%3A)). The [docs](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#:~:text=Boolean%20flag%20for%20enabling/disabling%20the%20holdApplicationUntilProxyStarts%20behavior.%20This%20feature%20adds%20hooks%20to%20delay%20application%20startup%20until%20the%20pod%20proxy%20is%20ready%20to%20accept%20traffic%2C%20mitigating%20some%20startup%20race%20conditions.%20Default%20value%20is%20%E2%80%98false%E2%80%99.) define the `holdApplicationUntilProxyStarts` setting as: 

> Boolean flag for enabling/disabling the holdApplicationUntilProxyStarts behavior. This feature adds hooks to delay application startup until the pod proxy is ready to accept traffic, mitigating some startup race conditions. Default value is ‘false’.

This is exactly the solution to our problem.

## Future

The upcoming [ambient mesh](https://istio.io/v1.15/blog/2022/introducing-ambient-mesh/) setup will get rid of sidecars, which will likely eliminate this issue altogether.
However at the time of writing this (November 2023) [ambient mesh is still in alpha](https://istio.io/latest/docs/ops/ambient/getting-started/) and not recommended for production deployments, so it might be a while until it becomes widespread.

Also kubernetes released [first-class support for sidecars recently](https://kubernetes.io/blog/2023/08/25/native-sidecar-containers/) (in alpha still) which [istio already supports](https://istio.io/latest/blog/2023/native-sidecars/).
This change allows the istio `initContainer` to stay alive for the entire lifetime of the Pod, also likely solving this issue.

Until one of these become stable however, the best course of action is likely to add that annotation (or configure this behavior for the entire mesh).
