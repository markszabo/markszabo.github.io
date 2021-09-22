---
layout: post
title: Multi-cluster multi-primary istio on AWS EKS
tags: tech
---

Recently I was working on setting up istio in a multi-cluster setup following the [Install Multi-Primary on different networks](https://istio.io/latest/docs/setup/install/multicluster/multi-primary_multi-network/) guide on EKS clusters. Everything seemed to work (no errors in logs), until I reached the [verification step](https://istio.io/latest/docs/setup/install/multicluster/verify/), where requests didn't go to the other mesh: in `CLUSTER1` I always got a response from `Hello version: v1, instance: helloworld-v1-86f77cd7bd-cpxhv`, while in `CLUSTER2` always from `Hello version: v2, instance: helloworld-v2-758dd55874-6x4t8`.

<!--break-->

This turns out to be [a known problem with EKS](https://github.com/istio/istio/issues/29359) and [comes down to the fact that EKS loadbalancers use hostnames instead of IP addresses](https://github.com/istio/istio/issues/29359#issuecomment-738234802), which are not supported by istio.

Workaround: manually resolve the IP and add it to `istio` ConfigMap (namespace: `istio-system`).

### 1. Figure out the eastwestgateway's hostname

```bash
➜  kubectl get service -n istio-system --context=${CLUSTER1} istio-eastwestgateway -o yaml
```

at the bottom look for the status section like:

```yaml
...
status:
  loadBalancer:
    ingress:
    - hostname: a5e21e07fd1a64a518ab6c02b4dfb9f5-826145575.us-west-2.elb.amazonaws.com
```

Also take a note of the `topology.istio.io/network` label, e.g. `network1`. We will use it when configuring the ConfigMap in the other cluster.

### 2. Figure out the corresponding IP address

```bash
➜  dig +short a5e21e07fd1a64a518ab6c02b4dfb9f5-826145575.us-west-2.elb.amazonaws.com
1.2.3.4
1.2.3.5
```

### 3. Update the istio ConfigMap in the other cluster

First get the existing ConfigMap:

```bash
➜  kubectl get configmaps -n istio-system istio -o yaml --context=${CLUSTER2} > istio_configmap_cluster2.yaml
```

Look for `data.meshNetworks`, e.g.:

```yaml
apiVersion: v1
data:
  mesh: |-
    defaultConfig:
      discoveryAddress: istiod.istio-system.svc:15012
      meshId: mesh
      proxyMetadata: {}
      tracing:
        zipkin:
          address: zipkin.istio-system:9411
    enablePrometheusMerge: true
    rootNamespace: istio-system
    trustDomain: cluster.local
  meshNetworks: 'networks: {}'
kind: ConfigMap
...
```

Extend `data.meshNetworks` with the information from the previos steps:

```yaml
apiVersion: v1
data:
  mesh: |-
    defaultConfig:
      discoveryAddress: istiod.istio-system.svc:15012
      meshId: mesh
      proxyMetadata: {}
      tracing:
        zipkin:
          address: zipkin.istio-system:9411
    enablePrometheusMerge: true
    rootNamespace: istio-system
    trustDomain: cluster.local
  meshNetworks: |-
      networks:
        network1:
          endpoints:
            - fromRegistry: cluster1
          gateways:
            - address: 1.2.3.4
              port: 15443
            - address: 1.2.3.5
              port: 15443
kind: ConfigMap
...
```

Save the file, apply the changes:


```bash
➜  kubectl apply --context=${CLUSTER2} -f istio_configmap_cluster2.yaml
```

### 4. Repeat the same for the other cluster

## Warnings

- according to [this comment](https://github.com/istio/istio/issues/29359#issuecomment-738234802) we should list all networks in all clusters (even the cluster's own network)
- hardcoding the IP like this will break if the ELB gets a new IP. In the [thread](https://github.com/istio/istio/issues/29359) there is a great discussion whether this will happen or not
    - one [possible solution](https://github.com/istio/istio/issues/29359#issuecomment-896730470) to this is to have a CronJob that periodically updates the IPs
