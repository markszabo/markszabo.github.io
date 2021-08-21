---
layout: post
title: How to setup Azure AD authentication with AWS EKS kubernetes clusters
tags: tech
---

I recently worked on setting up [Azure Active Directory (AAD from now)](https://azure.microsoft.com/en-us/services/active-directory/) authentication with kubernetes clusters running on [AWS EKS (Amazon Elastic Kubernetes Service)](https://aws.amazon.com/eks/). The goal was to let users of the kubernetes cluster authenticate using their AAD identities, and assing permissions using the usernames and also AAD groups. Here is how I did it.

<!--break-->

We will use OIDC-based authentication, as [it's supported by kubernetes](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens) and AAD as well.

## Setup an AAD Enterprise Application

To use OIDC with AAD, we need an enterprise application. There is [a soon-to-be-deprecated Azure client for kubectl](https://github.com/kubernetes/client-go/tree/master/plugin/pkg/client/auth/azure), which describes setting up two applications, however it is doable with only one as well (we are still looking into whether this is secure though and I also [opened an issue asking it](https://github.com/kubernetes/client-go/issues/1003)). 

Create an AAD Enterprise Application, then create the corresponding App Registration. In the App Registration config, under Authentication enable the `Allow public client flows` option. If you want groups to be part of the OIDC token, under `API permissions` setup the permissions to access group information, and under `Token configuration` click `Add groups claim`. Select `Group ID` as [there is a catch here](https://docs.microsoft.com/en-us/azure/active-directory/hybrid/how-to-connect-fed-group-claims#group-claims-for-applications-migrating-from-ad-fs-and-other-identity-providers):

> The supported formats for group claims are:
> 
> * Azure Active Directory Group ObjectId (Available for all groups)
> * sAMAccountName (Available for groups synchronized from Active Directory)
> * NetbiosDomain\sAMAccountName (Available for groups synchronized from Active Directory)
> * DNSDomainName\sAMAccountName (Available for groups synchronized from Active Directory)
> * On Premises Group Security Identifier (Available for groups synchronized from Active Directory)

So what happens with the groups created on AAD, if you select e.g. `sAMAccountName`? They just don't show up at all in the claim (this took me a while to figure out). GroupIDs look something like `093fc0e2-1d6e-4a1b-9bf8-effa0196f1f7` ([source](https://docs.microsoft.com/en-us/powershell/module/azuread/get-azureadgroup?view=azureadps-2.0#example-1--get-all-groups)), so they are not really descriptive (especially when used in `RoleBindings`). On the other hand AAD group names can be changed and also [not guaranteed to be unique](https://morgansimonsen.com/2016/06/28/azure-ad-allows-duplicate-group-names/), so not using them for authorization likely prevent a set of priviledge escalation vulnerabilites. 

Go to the App Registration `Overview` page and copy the value of the `Application (client) ID` and the `Directory (tenant) ID`. We will need these in the next step.

## Configure EKS

EKS being a managed kubernetes platform, we can't directly pass parameters to the API server ([like](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#configuring-the-api-server) `--oidc-issuer-url`), however luckily [EKS provides a way to configure these on the management console](https://docs.amazonaws.cn/en_us/eks/latest/userguide/authenticate-oidc-identity-provider.html). You only need to do one of the next two.

### Manual configuration

1. Go to [EKS and choose Clusters](https://us-east-2.console.aws.amazon.com/eks/home?region=us-east-2#/clusters)
2. Select your cluster 
3. In the middle of the page select `Configuration`
4. Select `Authentication`
5. Click `Associate Identity Provider`
6. Fill out like this:
  - Issuer URL: `https://sts.windows.net/[Directory (tenant) ID from the previous step]/` (e.g. https://sts.windows.net/b9a84eb8-a888-4f41-bb75-43447e36486a/)
  - Client ID: [Application (client) ID from the previous step]
  - Username claim: `upn`
  - Groups claim: `groups`
  - Username prefix: `aad:` (optional, will be added as a prefix to user identities and used in k8s RBAC)
  - Groups prefix: `aad:` (same as the username prefix, but used for groups)
7. Save and wait until it gets applied

### Configure via Terraform

The AWS terraform module support configuring this via the [aws_eks_identity_provider_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_identity_provider_config) like this:

```tf
resource "aws_eks_identity_provider_config" "example" {

  cluster_name = aws_eks_cluster.example.name

  oidc {
    identity_provider_config_name = "AzureAD" # display name that will show up on the AWS console
    client_id                     = "[Application (client) ID from the previous step]"
    issuer_url                    = "https://sts.windows.net/[Directory (tenant) ID from the previous step]/"
    username_claim                = "upn"
    username_prefix               = "aad:"
    groups_claim                  = "groups"
    groups_prefix                 = "aad:"
  }

  timeouts {
    create = "2h" # optional, but it timed out for me with the default
    delete = "2h" # optional, but it timed out for me with the default
  }
}
```

This finishes the cluster setup.

## Configure the clients

Now we need to setup kubectl to authenticate via AAD. I looked into 3 different options:

1. [int128/kubelogin](https://github.com/int128/kubelogin): very user-friendly as it opens the browser to perform the authentication, but 3rd-party software means additional risk. Also requires sharing the client secret with all the clients, which is more additional risk.
2. `kubectl` [azure plugin](https://github.com/kubernetes/client-go/tree/master/plugin/pkg/client/auth/azure): works well, already part of `kubectl`, however [going to be deprecated and removed in the near future](https://github.com/kubernetes/client-go/blob/master/plugin/pkg/client/auth/azure/azure.go#:~:text=the%20azure%20auth%20plugin%20is%20deprecated)
3. [Azure/kubelogin](https://github.com/Azure/kubelogin): recommended replacement for option #2, maintained by Microsoft

Thus I will use option #3.

### Install Azure/kubelogin

Follow the installation instructions from [https://github.com/Azure/kubelogin](https://github.com/Azure/kubelogin):

#### Install using homebrew:

```bash
brew install Azure/kubelogin/kubelogin
```

#### Install directly from Github

```bash
wget https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip
unzip kubelogin-linux-amd64.zip -d kubelogin
mv kubelogin/bin/linux_amd64/kubelogin /usr/local/bin/
rm -r kubelogin*
```

### Configure kubectl

Configure the cluster:

```bash
kubectl config set-cluster "$CLUSTER_NAME" --server="$CLUSTER_ADDRESS"
kubectl config set "clusters.$CLUSTER_NAME.certificate-authority-data" $CLUSTER_CA_DATA
```

Configure the authentication (`AAD_CLIENT_ID` is the application (client) ID from the previous step, `AAD_TENANT_ID` is the directory (tenant) ID from the previous step. Only the ID, don't need the full URL):

```bash
kubectl config set-credentials "azure-user" \
  --exec-api-version=client.authentication.k8s.io/v1beta1 \
  --exec-command=kubelogin \
  --exec-arg=get-token \
  --exec-arg=--environment \
  --exec-arg=AzurePublicCloud \
  --exec-arg=--server-id \
  --exec-arg=$AAD_CLIENT_ID \
  --exec-arg=--client-id \
  --exec-arg=$AAD_CLIENT_ID \
  --exec-arg=--tenant-id \
  --exec-arg=$AAD_TENANT_ID
``` 

Configure a context with these and activate it:

```bash
kubectl config set-context "$CLUSTER_NAME" --cluster="$CLUSTER_NAME" --user=azure-user
kubectl config use-context "$CLUSTER_NAME"
```

### Usage

Once kubectl is configured, run a `kubectl` command, e.g.:

```bash
kubectl get pods
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code B7D3SVXHV to authenticate.
```

Open the link, enter the code, complete the authentication. Close the tab when told to do so. Return to the terminal. You'll likely see a message like this:

```bash
Error from server (Forbidden): pods is forbidden: User "aad:my_user@company.com" cannot list resource "pods" in API group "" in the namespace "default"
```

This means authentication was successful, but your user is not authorized to perform the requested action. 

### Authorization

Now that the authentication works, we can setup `(Cluster)RoleBindings` using these usernames and groups (observe the `aad:` prefix on both the usernames and groups. Change it if you used something else in the EKS config):

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: team-admin-access
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: aad:my_user@company.com
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: aad:other_user@company.com
# TODO (teammembers) add your email here if you need access
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: everyone-view-access
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: aad:093fc0e2-1d6e-4a1b-9bf8-effa0196f1f7
  # corresponds to the 'All Engineers' group # optional note for future readers 
  # ref: https://portal.azure.com/#blade/Microsoft_AAD_IAM/GroupDetailsMenuBlade/Overview/groupId/093fc0e2-1d6e-4a1b-9bf8-effa0196f1f7

```
