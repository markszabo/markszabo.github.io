---
layout: post
title: How to use the vault terraform provider locally and in a Github action ci workflow at the same time
tags: tech
---

In one of my the projects I manage vault resources via terraform. 
The main terraform pipeline runs in a Github action workflow and uses [Github's JWT to connect to vault](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault).
Meanwhile user authentication is done using [vault's OIDC auth method](https://developer.hashicorp.com/vault/tutorials/auth-methods/oidc-auth).

This post will show how to setup the [vault terraform provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs#provider-arguments) so that it uses the Github signed JWT when running in CI, and OIDC authentication when running locally.

<!--break-->

First lets see the provider setup for the two use case separately.

## The CI setup

To authenticate to vault using the Github provided JWT, we can use the [`auth_login_jwt` configuration block](https://registry.terraform.io/providers/hashicorp/vault/latest/docs#jwt):

```hcl
provider "vault" {
  address = local.vault_dev_url
  auth_login_jwt {
    namespace = "ns_my_project_dev"
    mount     = "jwt"
    role      = "full-access"
    jwt       = var.github_jwt
  }
}
```

This assumes we have the [jwt backend](https://developer.hashicorp.com/vault/api-docs/auth/jwt#jwt-oidc-auth-method-api) configured to trust Github and the JWT is authorized to assume the role named `full-access`.

The jwt is obtained in the Github workflow and passed to terraform like this:

```yaml
    - name: Get Github JWT for terraform
      run: |
        GH_JWT=$(curl -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$ACTIONS_ID_TOKEN_REQUEST_URL" | jq -j -c '.value')
        echo TF_VAR_github_jwt=$GH_JWT >> $GITHUB_ENV
```

The `ACTIONS_ID_TOKEN_REQUEST_TOKEN` and `ACTIONS_ID_TOKEN_REQUEST_URL` are [automatically configured](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#updating-your-actions-for-oidc) if the workflow has the `id-token: write` [permission](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#adding-permissions-settings).

## The local setup

Terraform provides an [`auth_login_oidc` config block](https://registry.terraform.io/providers/hashicorp/vault/latest/docs#oidc), however it didn't fit my use case.
We use vault enterprise with namespaces.
The `oidc` auth provider used for user authentication is configured in the root namespace, but most user only have access to their assigned namespaces (e.g. `ns_my_project_dev`).

So I will first run the vault cli to login and obtain a short lived token, then pass that token to terraform:

```shell
export TF_VAR_vault_dev_token=$(VAULT_ADDR=https://vault-dev.example.com vault login -token-only -method=oidc -path=oidc)
```

The token is then used to configure the terraform provider:

```hcl
provider "vault" {
  address = local.vault_dev_url
  
  token            = var.vault_dev_token
  namespace        = "ns_my_project_dev"
  skip_child_token = true
}
```

`skip_child_token` was necessary as I'm not allowed to create child tokens in the root namespace, and the default behavior of terraform is to do just that.

There is an additional benefit of running vault cli to obtain the token, and then using that to configure the provider instead of using the `auth_login_oidc` config block in the provider directly: the token grants access to multiple namespaces, and with this setup we can use it for all of them without having to complete the OIDC flow multiple times.

## Putting it all together

Now that we have the provider config for both use-cases, let's put it together:

```hcl
provider "vault" {
  address = local.vault_dev_url
  dynamic "auth_login_jwt" { # Github OIDC token is used for auth in the CI
    for_each = var.vault_dev_token == null ? [true] : []

    content {
      namespace = "ns_my_project_dev"
      mount     = "jwt"
      role      = "full-access"
      jwt       = var.github_jwt
    }
  }
  token            = var.vault_dev_token # Token is used for auth when running locally
  namespace        = var.vault_dev_token == null ? null : "ns_my_project_dev"
  skip_child_token = true
}
```

with the following variables:

```hcl
variable "vault_dev_token" {
  type        = string
  description = "Used when running tf locally"
  default     = null
}

variable "github_jwt" {
  type        = string
  description = "Used to authenticate to vault when running tf in CI"
  default     = ""
}
```

Depending on whether the `vault_dev_token` variable is set or not, this setup will result in one of the config  shown earlier.

Similar tricks with [dynamic config blocks](https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks), and the use of [the null value](https://developer.hashicorp.com/terraform/language/expressions/types#null) should make other setups possible with different auth methods, and likely even with other providers.
