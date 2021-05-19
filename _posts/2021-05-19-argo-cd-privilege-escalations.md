---
layout: post
title: Argo CD Privilege Escalations
date: 2021-05-19 15:30:00 +09:00
tags: security
---

Consider a multi-team GitOps setup with [Argo CD](https://argoproj.github.io/argo-cd/): each team has their own repository that holds the team's Kubernetes yaml files that Argo CD deploys to a shared cluster. Inside the cluster, teams are separated into their own namespaces, and Argo CD only deploys resources to the namespace that belongs to the given team.

Let's see how this setup can be misconfigured to allow deploying to other team's namespaces or to the cluster level!

<!--break-->

First we need to understand how Argo CD manages permissions (in the context of what can be deployed from a given repository), and for that we need to look into the `Application` and `AppProject` Kubernetes objects used by Argo CD.

## Argo CD Application

> The Application CRD is the Kubernetes resource object representing a deployed application instance in an environment ([source](https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#applications))

For example ([source](https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#applications)):

{% highlight yaml %}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: my-project
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: guestbook
{% endhighlight %}

This object instructs Argo to grab the `HEAD` of `https://github.com/argoproj/argocd-example-apps.git`, go into the `guestbook` folder, take all `yaml` files from there and deploy them to the `https://kubernetes.default.svc` cluster into the `guestbook` namespace. (The namespace defined here is just the default one, the `yaml` files can override it.)

Let's take a note of the `project: my-project` declaration too, which specifies the Argo CD `AppProject` this `Application` is part of, which will be very imprtoant for the permissions.

Since this `Application` itself is a Kubernetes object, the folder it deploys from can contain other `Applications` or `AppProjects` ([see](https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#app-of-apps)), which is often used to delege deployment and deploy applications from multiple repos, e.g. from separate repos of each team.

The `Application` object itself always goes to the `argocd` namespace in the cluster where Argo CD is deployed. (Though this namespace can be renamed.)

## Argo CD AppProject


> The AppProject CRD is the Kubernetes resource object representing a logical grouping of applications. ([source](https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#projects))

For example ([based on](https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#projects)):

{% highlight yaml %}
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: my-project
  namespace: argocd
spec:
  description: Example Project
  sourceRepos:
  - https://github.com/argoproj/argocd-example-apps.git
  - https://github.com/argoproj/other-example-app.git
  destinations:
  - namespace: guestbook
    server: https://kubernetes.default.svc
  # Deny all cluster-scoped resources from being created, except for Namespace
  clusterResourceWhitelist:
  - group: ''
    kind: Namespace
  # Allow all namespaced-scoped resources to be created, except for ResourceQuota, NetworkPolicy
  namespaceResourceBlacklist:
  - group: ''
    kind: ResourceQuota
  - group: ''
    kind: NetworkPolicy
{% endhighlight %}

For most attributes `"*"` can be used too to indicate everything (e.g. deploy from any source repo, deploy to any namespace or server, allow or deny all resources).

Most of the attributes are defining the permissions for the apps that belong to this project. Any `Application` deployed to the cluster can use any of the existing projects, and the projects can not restrict this (e.g. you can't say that only `Applications`, whos yaml file is in `https://github.com/argoproj/argocd-example-apps.git` may use the `my-project` project). Restrictions can only be applied to the resources deployed by the apps.

`sourceRepos` define the list of repositories the `Applications` of this `AppProject` can deploy from (so the possible values for `spec.source.repoURL` of `Application`). Wildcards are supported, but when used as part of a string, [the `*` stops at `/`](https://github.com/argoproj/argo-cd/issues/3759) (e.g. `https://github.com/proj/*` will match `https://github.com/proj/app` but not `https://github.com/proj/app/module`). For this usecase [`**` was added](https://github.com/argoproj/argo-cd/pull/4085), though I haven't tested that. `"*"` works as elsewhere and matches everything.

`destinations` define the list of namespaces and clusters resources can be deployed to, matching the `Application`'s `spec.destination`. Keep in mind that defining a namespace here doesn't prevent [non-namespaced resources](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/#not-all-objects-are-in-a-namespace) to be deployed to the defined server.

Kubernetes has namespaced and [non-namespaced (or cluster) resources](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/#not-all-objects-are-in-a-namespace) and `AppProject` defines permissions for the two category separately (similarly to [Role and ClusterRole](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole)):

* `clusterResourceWhitelist` or `clusterResourceBlacklist` specifies which non-namespaced objects can be deployed (`Blacklist` forbids the listed objects, but allows everything else. `Whitelist` allows the listed, forbids everything else.)
* `namespaceResourceWhitelist` or `namespaceResourceBlacklist` specifies which namespaced objects can be deployed

What happens if neither black- nor whitelist is defined for an object type? For namespace resources the default is to allow all, while for cluster resources the default is to deny all (though [there used to be a bug allowing both](https://github.com/argoproj/argo-cd/issues/5540)). Not defined or defined as an empty array behaves the same (last time I checked), so if you want to forbid everything, then instead of setting `Whitelist` to an empty array, set `Blacklist` to `"*"`, e.g.:

{% highlight yaml %}
  namespaceResourceBlacklist:
  - group: "*"
    kind: "*"
{% endhighlight %}

This can get tricky (e.g. what happens if both whitelist and blacklist is defined), so I recommend looking at the source code of Argo CD: the <a href="https://github.com/argoproj/argo-cd/blob/master/pkg/apis/application/v1alpha1/types.go#:~:text=func%20(proj%20AppProject)%20IsGroupKindPermitted(">IsGroupKindPermitted function handles this logic</a>.

The `AppProject` object itself always goes to the `argocd` namespace in the cluster where Argo CD is deployed.

## Privilege escalations

With all of this out of the way, lets look into potential issues in this. The goal is to deploy to a place we shouldn't be able to deploy to, for example:

* deploy a `ClusterRoleBinding` that gives us `cluster-admin` 👑
* deploy a `RoleBinding` that gives us `admin` over an other namespace 🤘
* deploy a `Pod` that uses someone elses's resources 👌

### AppProject with too permissive `[cluster|namespace]Resource[White|Black]list` configuration

Generally namespace resources are yours if you can deploy to the namespace. If your user has limited access via `kubectl`, you can still deploy a `RoleBinding` to the namespace to give you `admin` over the namespace, but that will still be limited to your own namespace. However if the `clusterResource[White|Black]lists` are not properly configured, that can give you `cluster-admin` over the entire cluster.

For example consider a project with this configuration:

{% highlight yaml %}
...
clusterResourceBlacklist:
- group: ''
  kind: Namespace
namespaceResourceBlacklist:
- group: ''
  kind: ResourceQuota
- group: ''
  kind: NetworkPolicy
{% endhighlight %}

This will allow `RoleBinding`s into the namespace, but also `ClusterRoleBinding`s to the cluster.

### AppProject with wildcard sourceRepos

If an other team's AppProject is defined like this:

{% highlight yaml %}
...
metadata:
  name: other-team-project
  namespace: argocd
spec:
  description: Example Project
  sourceRepos:
  - "*"
  destinations:
  - namespace: other-team
    server: https://kubernetes.default.svc
...
{% endhighlight %}

Then we can use it to deploy to their namespace by simple setting our `Application`'s project to `other-team-project` while using yaml files from our own repo:

{% highlight yaml %}
...
spec:
  project: other-team-project
  source:
    repoURL: https://github.com/my-team/my-team-apps.git
    targetRevision: HEAD
    path: manifest/gotta-pwn-em-all
  destination:
    server: https://kubernetes.default.svc
    namespace: other-team
{% endhighlight %}

Whether we can get admin, or if we can only deploy Pods to the other team's namespace depends on the `[cluster|namespace]Resource[White|Black]list` configuration for the project.

The same is possible if the `sourceRepos` are not fully wildcard, but they match our repo, e.g. `- https://github.com/**` or `- https://github.com/*/*` or `- https://github.com/our-org/*` would work with a repo of `https://github.com/our-org/my-team.git`.

### AppProject with wildcard destination

If you can use a project with a wildcard destination (either because it's your own project, or because the `sourceRepos` also has wildcard), like this:

{% highlight yaml %}
...
metadata:
  name: my-project
  namespace: argocd
spec:
  description: Example Project
  sourceRepos:
  - https://github.com/my-team/my-team-apps.git
  destinations:
  - namespace: "*"
    server: https://kubernetes.default.svc
...
{% endhighlight %}

This allows to deploy to any other namespace in the cluster, but directly doing so will be limited by the `[cluster|namespace]Resource[White|Black]list` configuration for the project. However if the cluster also stores the Argo CD `Application` and `AppProject` objects, then using those, one can deploy a new, super-permissive `AppProject` and use that to deploy anything. Moreover these can be deployed to any cluster managed by Argo CD, not only the cluster the original project could deploy to.

[Click here for the complete walk through of this excercise.](/2021/05/19/argo-cd-privesc-walkthrough/)

### The default AppProject

> Every application belongs to a single project. If unspecified, an application belongs to the default project, which is created automatically and by default, permits deployments from any source repo, to any cluster, and all resource Kinds. The default project can be modified, but not deleted. When initially created, it's specification is configured to be the most permissive:

{% highlight yaml %}
spec:
  sourceRepos:
  - '*'
  destinations:
  - namespace: '*'
    server: '*'
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
{% endhighlight %}

([Source: Argo Docs](https://argoproj.github.io/argo-cd/user-guide/projects/#the-default-project))

I think at this point I don't need to explain why this can lead to problems. Any `Application` can use the `default` project and if the project isn't changed, than the app can deploy anything to anywhere. Sweet!

<details>
<summary>Here is how to fix this</summary>

Since the docs are clear that this project can't be deleted, the only way to fix it is to redefine with restricted permissions, e.g.

{% highlight yaml %}
# Every application belongs to a single project. If unspecified, an application belongs
# to the default project, which is created automatically and by default, permits deployments
# from any source repo, to any cluster, and all resource Kinds.
# https://argoproj.github.io/argo-cd/user-guide/projects/#the-default-project
# As this can be used for privilege escalation, the project has to be restricted
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: default
spec:
  description: DO NOT USE! - Argo CD's default project
  sourceRepos: []
  destinations: []
{% endhighlight %}

</details>

## kubectl commands to help find these misconfigurations

Run these commands against the cluster that has the `AppProject` files, e.g.:

{% highlight bash %}
kubectl config use-context infra
{% endhighlight %}

I'm using the `--all-namespaces` flag, but if you know the namespace where `AppProject`s are deployed (e.g. `argocd`), then you can use `-n argocd` instead.

#### Only `clusterResourceBlacklist` is defined without `clusterResourceWhitelist`

{% highlight bash %}
kubectl get AppProject --all-namespaces -o json | jq -r '.items[] | select(.spec.clusterResourceBlacklist != null) | select(.spec.clusterResourceWhitelist == null) | {name: .metadata.name, clusterResourceBlacklist: .spec.clusterResourceBlacklist}'
{% endhighlight %}

Of course if this returns `"*"` that's fine, but if it tries to list all the bad things, then you should take an other look.

#### Wildcard `sourceRepos`

Only for `"*"`:

{% highlight bash %}
kubectl get AppProject --all-namespaces -o json | jq -r '.items[] | select([.spec.sourceRepos[] == "*"] | any) | {name: .metadata.name, sourceRepos: .spec.sourceRepos}'
{% endhighlight %}

Any URL that contains `*` (e.g. `https://github.com/ourorg/*`):

{% highlight bash %}
kubectl get AppProject --all-namespaces -o json | jq -r '.items[] | select(.spec.sourceRepos[] | test("\\*")) | {name: .metadata.name, sourceRepos: .spec.sourceRepos}'
{% endhighlight %}

([jq pattern matching from SO](https://stackoverflow.com/questions/25649960/how-to-select-items-in-jq-based-on-value-in-array))

#### Wildcard `destinations`

`namespace` is `*`:

{% highlight bash %}
kubectl get AppProject --all-namespaces -o json | jq -r '.items[] | select([.spec.destinations[] | .namespace == "*"] | any) | {name: .metadata.name, destinations: .spec.destinations}'
{% endhighlight %}

`namespace`, `server` or `name` is `*` (`name` is sometimes used instead of `server`):

{% highlight bash %}
kubectl get AppProject --all-namespaces -o json | jq -r '.items[] | select([.spec.destinations[] | .namespace == "*" or .server == "*" or .name == "*"] | any) | {name: .metadata.name, destinations: .spec.destinations}'
{% endhighlight %}

## Example yaml files to use for demonstration

### Give me cluster-admin! (Full admin over the entire cluster)

{% highlight yaml %}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gotta-pwn-em-all
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

### Admin on the cluster (almost as good as cluster-admin)

{% highlight yaml %}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gotta-pwn-em-all
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
  - kind: User
    name: oidc:johnsmith
  - kind: Group
    name: oidc:security-team
{% endhighlight %}

### Admin within a namespace

{% highlight yaml %}
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gotta-pwn-em-all
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: admin
subjects:
  - kind: User
    name: oidc:johnsmith
  - kind: Group
    name: oidc:security-team
{% endhighlight %}

### Aggregate to view

If you can't create a `RoleBinding`, but have `view` role already, try adding a new `Role` or `ClusterRole` that [aggregates to](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) `view`:

{% highlight yaml %}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: gotta-pwn-em-all
  labels:
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
{% endhighlight %}


{% highlight yaml %}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: gotta-pwn-em-all
  labels:
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
{% endhighlight %}

Only use this in a testing environment, as this effectively gives everyone with view role full admin access to the namespace or cluster!
