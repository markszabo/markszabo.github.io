---
layout: post
title: Terraform's kubernetes_secret giving 'Error: Provider produced inconsistent result after apply'
tags: tech
---

I'm creating a new `kubernetes_secret` via Terraform for an existing service account like this:

```json
resource "kubernetes_secret" "my_service_account_token" {
  metadata {
    name = "my-service-account-token"
    namespace = "example"
    annotations = {
      "kubernetes.io/service-account.name" = "my-service-account"
    }
  }
  type = "kubernetes.io/service-account-token"
}
```

so that then I can use this token elsewhere like: `kubernetes_secret.my_service_account_token.data["token"]`. However applying this gave the following error:

```bash
╷
│ Error: Provider produced inconsistent result after apply
│ 
│ When applying changes to
│ module.my_module.kubernetes_secret.my_service_account_token,
│ provider
│ "provider[\"registry.terraform.io/hashicorp/kubernetes\"].kubernetes"
│ produced an unexpected new value: Root resource was present, but now
│ absent.
│ 
│ This is a bug in the provider, which should be reported in the provider's
│ own issue tracker.
╵
```

Turns out if the service account referenced in the `kubernetes.io/service-account.name` annotation doesn't exist, then kubernetes will delete this secret immediately. This makes terraform confused, when it creates the secret successfully and then tries to read it back, but it's no longer there.

Solution: make sure the service account exist before applying this resource.
