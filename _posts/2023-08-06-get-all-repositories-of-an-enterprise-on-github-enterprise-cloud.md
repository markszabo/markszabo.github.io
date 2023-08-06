---
layout: post
title: How to get all repositories of an enterprise on GitHub Enterprise Cloud
tags: tech
---

Github Enterprise Cloud is an enterprise version of GitHub.com "designed for large businesses or teams who collaborate on GitHub.com"([source](https://docs.github.com/en/enterprise-cloud@latest/admin/overview/about-github-enterprise-cloud)).
There is a strong emphasis on security, which extends to strong limits on programmatic access, especially to enterprise-wide resources, so getting all organizations or all repositories of the enterprise becomes nontrivial.
This guide will describe how to do these.

<!--break-->

# Goal

The goal is to get all current and future organizations and repositories that belong to the enterprise. It needs to handle new organizations added without additional configuration.

So on a high level: we need an identity with enough permissions to access these, then use that identity to call an API. [Github has a REST API](https://docs.github.com/en/enterprise-cloud@latest/rest/overview/about-githubs-apis?apiVersion=2022-11-28) that looks like it could work.

# What doesn't work

While the docs mention [the use-case of machine accounts](https://docs.github.com/en/enterprise-cloud@latest/get-started/learning-about-github/types-of-github-accounts#:~:text=Tip%3A%20Personal%20accounts%20are%20intended%20for%20humans%2C%20but%20you%20can%20create%20accounts%20to%20automate%20activity%20on%20GitHub%20Enterprise%20Cloud.%20This%20type%20of%20account%20is%20called%20a%20machine%20user.%20For%20example%2C%20you%20can%20create%20a%20machine%20user%20account%20to%20automate%20continuous%20integration%20(CI)%20workflows.) these use licenses, so it is generally recommended [to use Github Apps instead](https://josh-ops.com/posts/github-apps/). However Github Apps can [only be installed on either repositories or organizations](https://docs.github.com/en/enterprise-cloud@latest/apps/using-github-apps/installing-your-own-github-app), so while this could work, it would need to be installed on all new orgs manually (there doesn't seem to be any API that would install Github apps). So we have to using machine accounts.

Authenticating with a machine account's username and password is [not supported](https://docs.github.com/en/enterprise-cloud@latest/rest/overview/authenticating-to-the-rest-api?apiVersion=2022-11-28#authenticating-with-username-and-password), so we have to use tokens.

There are two types of tokens:
* `Fine-grained personal access tokens`: these are [scoped to a single organization](https://docs.github.com/en/enterprise-cloud@latest/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#:~:text=Each%20token%20can%20only%20access%20resources%20owned%20by%20a%20single%20user%20or%20organization.), so won't work for us
* `Personal access tokens (classic)`: these are [can access the entire enterprise](https://docs.github.com/en/enterprise-cloud@latest/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#:~:text=Only%20personal%20access%20tokens%20(classic)%20can%20access%20enterprises), so generating them for a machine account that has sufficient permissions coud work. However there is a problem if some orgs in the enterprise enforce SAML single sign-on (SSO) for authentication: [one needs to authorize the token for each of these orgs manually](https://docs.github.com/en/enterprise-cloud@latest/rest/overview/authenticating-to-the-rest-api?apiVersion=2022-11-28#authenticating-with-username-and-password:~:text=If%20you%20use%20a%20personal%20access%20token%20(classic)%20to%20access%20an%20organization%20that%20enforces%20SAML%20single%20sign%2Don%20(SSO)%20for%20authentication%2C%20you%20will%20need%20to%20authorize%20your%20token%20after%20creation.). This again doesn't fit our use-case.

# GraphQL to the rescue

So all of the above is based on the REST API docs, but Gihub also has a GraphQL API with different controls on the token. One can get all orgs of an enterprise using this query:

```json
query {
    enterprise(slug: "NAME_OF_THE_ENTERPRISE") {
        organizations(first: 100) {
            nodes {
                login
            }
        }
    }
}
```

Unfortunately this doesn't work with Github Apps, however it works with any user of the enterprise and it returns all organizations, including the ones the user is not a member of. 

To try it generate a classic PAT for your account with the following scopes:

* read:enterprise
* read:org
* repo:status
* public_repo

(Some of these are only required for getting the repos too, so if you only need the list of orgs, try removing some of them). Authorize the token for just one organization (again this might only be necessary for getting the repos), then run:

```bash
curl -H "Authorization: bearer $PAT" -X POST -d " \
 { \
   \"query\": \"query {enterprise(slug:\\\"NAME_OF_THE_ENTERPRISE\\\") {organizations(first: 100) {nodes { login } } } }\" \
 } \
" https://api.github.com/graphql
```

Going one step further, we can also query all the repositories within the org:

```json
query {
    enterprise(slug: "NAME_OF_THE_ENTERPRISE") {
        organizations(first: 100) {
            nodes {
                login,
                repositories(first: 100) {
                    nodes {
                        name
                    }
                }
            }
        }
    }
}
```

Or with curl:

```bash
curl -H "Authorization: bearer $PAT" -X POST -d " \
 { \
   \"query\": \"query {enterprise(slug:\\\"NAME_OF_THE_ENTERPRISE\\\") {organizations(first: 100) {nodes { login, repositories(first: 100){nodes{name}}  } } } }\" \
 } \
" https://api.github.com/graphql
```

The interesting thing is that even if the PAT is only authorized for a single organization, this will return repositories for all organizations (assuming the user has permissions to see them). This means that running this with a machine user that is enterprise admin should return all repositories.

## Final hurdle: pagination

