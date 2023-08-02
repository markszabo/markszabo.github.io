---
layout: post
title: Using vault-plugin-secrets-artifactory to generate short-lived Artifactory tokens with a non-admin user
tags: tech security
---

How to use the [HashiCorp Vault Secrets Plugin for Artifactory](https://github.com/jfrog/vault-plugin-secrets-artifactory) to create short-lived Artifactory tokens scoped to a specific user, without the need for an admin token.
The main usecase for this is CI workflows (e.g. Github actions) that can authenticate to vault (e.g. [Github's workflow OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)) and need access to Artifactory.

<!--break-->

[vault-plugin-secrets-artifactory](https://github.com/jfrog/vault-plugin-secrets-artifactory)'s README mentions that it works with non-admin users, but falls short on detailing how to use it in practice. This guide will go through this.

# 1. Install the plugin

Install the vault plugin following [these instructions](https://github.com/jfrog/vault-plugin-secrets-artifactory#installation). This only has to be done once per vault instance.

# 2. Get an Artifactory Identity Token

Login with the Artifactory user that you will use, and generate an Identity Token. **Important**: don't use the API Key, as it lets you configure the vault backend, but when you try to generate a token it fails with this error:

```bash
$ vault read artifactory/token/test
Error reading artifactory/token/test: Error making API request.

URL: GET http://vault:8200/v1/artifactory/token/test
Code: 500. Errors:

* 1 error occurred:
        * could not get the sytem version: HTTP response 401
```

Also note the username (email address) as we will need it in the next steps.

# 3. Create the backend in vault

Create the artifactory backend in vault by 

```bash
vault secrets enable artifactory -path=artifactory
```

or via terraform:

```hcl
resource "vault_mount" "artifactory" {
  path        = "artifactory"
  type        = "artifactory"
  description = "To create Artifactory tokens"
}
```

# 4. Configure the backend with the Artifactory token

Use your artifactory's URL and the Artifactory Identity Token from the earlier step:

```bash
vault write artifactory/config/admin \
    url=https://artifactory.example.org \
    access_token=$TOKEN
```

or the same via terraform:

```hcl
resource "vault_generic_endpoint" "config" {
  path = "${vault_mount.artifactory.path}/config/admin"

  # Prevents resource from being recreated each time the token is rotated
  lifecycle {
    ignore_changes = [data_json]
  }

  data_json = <<-EOT
{
  "url": "${local.artifactory_host}",
  "access_token": "${var.initial_artifactory_token}"
}
EOT
}
```

The docs recommend [rotating the token so that only vault knowns it](https://github.com/jfrog/vault-plugin-secrets-artifactory#vault:~:text=OPTIONAL%2C%20but%20recommended%3A%20Rotate%20the%20admin%20token%2C%20so%20that%20only%20Vault%20knows%20it.), but that didn't work for me with non-admin tokens.

# 5. Create a role

Configure a role (an identity the Artifactory plugin can issue tokens for). Use the username for the user that the token belongs to.

```bash
vault write artifactory/roles/test \
    username="my-user@example.com" \
    scope="applied-permissions/user" \
    default_ttl=1h max_ttl=3h
```

or the same with terraform:

```hcl
resource "vault_generic_endpoint" "test_role" {
  path = "${vault_mount.artifactory.path}/roles/test"

  data_json = <<-EOT
{
  "username": "${var.artifactory_username}",
  "scope": "applied-permissions/user",
  "default_ttl": "1h",
  "max_ttl": "3h"
}
EOT

  depends_on = [vault_generic_endpoint.config]
}
```

# Get a short-lived Artifactory token

Assuming authenticated to vault, one can obtain a short-lived Artifactory token for this role by:

```bash
vault read artifactory/token/test
```

See [output format here](https://github.com/jfrog/vault-plugin-secrets-artifactory#vault:~:text=Example%20output%20(token%20truncated)%3A).

Alternatively with `curl` and `jq`:

```bash
ARTIFACTORY_TOKEN=$(curl \
      -H "X-Vault-Token: $VAULT_TOKEN" \
      -X GET \
      "${VAULT_URL}/v1/artifactory/token/test" | jq -j -c '.data.access_token')
```

# Github action

If using Github actions, it is recommended to setup a `jwt` backend in vault to trust [Github's OIDC issuer](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect), and configure a vault role that the workflow can to read the artifactory token path.

To set this all up in terraform:

```hcl
resource "vault_jwt_auth_backend" "github" {
  path = "github"
  type = "jwt"

  bound_issuer       = "https://token.actions.githubusercontent.com"
  oidc_discovery_url = "https://token.actions.githubusercontent.com"
}

resource "vault_policy" "access-policy" {
  name = "test-artifactory-token"

  policy = <<EOT
path "${vault_mount.artifactory.path}/token/test" {
  capabilities = ["read"]
}
EOT
}

resource "vault_jwt_auth_backend_role" "access-role" {
  backend        = vault_jwt_auth_backend.github.path
  role_name      = "artifactory-access-role"
  token_policies = [vault_policy.access-policy.name]

  bound_claims = {
    "iss" : "https://token.actions.githubusercontent.com",
    "repository" : var.repository #e.g. octo-org/octo-repo
  }
  bound_claims_type = "glob"
  user_claim        = "aud"
  role_type         = "jwt"
}
```

Once it's setup, add the `id-token: write` [permission](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#adding-permissions-settings) to your workflow and then do:

```yaml
- name: Get Artifactory token
  uses: hashicorp/vault-action@v2
  with:
    method: jwt
    url: ${{ env.VAULT_URL }}
    path: github # if followed the setup above
    role: artifactory-access-role # if followed the setup above
    secrets: |
      artifactory/token/test access_token | ARTIFACTORY_TOKEN
```

In subsequent steps you can use `$ARTIFACTORY_TOKEN` or `${{ env.ARTIFACTORY_TOKEN }}` to get the token. Don't worry, the `hashicorp/vault-action` marks the value as sensitive, so it won't show up in the workflow logs.

# Deleting the artifactory vault backend

When trying to delete the artifactory vault backend (either manually via the vault cli, on the web UI or via `terraform destroy`) it often gives this error:

```bash
│ Error: error deleting from Vault: Error making API request.
│ 
│ URL: DELETE https://vault:8200/v1/sys/mounts/artifactory
│ Code: 400. Errors:
│ 
│ * failed to revoke "artifactory/token/test/pugsqUqIsLfj4pJaWgraLAr4.mpllx" (1 / 1): failed to revoke entry: resp: &logical.Response{Secret:<nil>, Auth:<nil>, Data:map[string]interface {}{"error":"backend not configured"}, Redirect:"", Warnings:[]string(nil), WrapInfo:(*wrapping.ResponseWrapInfo)(nil), Headers:map[string][]string(nil)} err: %!w(<nil>)
│
```

My understanding is that this fails as there are tokens generated by the backend that are still valid, and vault tries to revoke them but fails (likely because the setup token is not an admin). Running the following commands seem to resolve the issue:

```
vault lease revoke -force -prefix artifactory
vault token revoke artifactory/token/test/pugsqUqIsLfj4pJaWgraLAr4.mpllx
```
