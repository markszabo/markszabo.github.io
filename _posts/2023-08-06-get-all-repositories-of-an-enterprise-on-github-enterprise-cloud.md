---
layout: post
title: How to get all repositories of an enterprise on GitHub Enterprise Cloud
tags: tech
---

Github Enterprise Cloud is an enterprise version of GitHub.com "designed for large businesses or teams who collaborate on GitHub.com"([source](https://docs.github.com/en/enterprise-cloud@latest/admin/overview/about-github-enterprise-cloud)).
There is a strong emphasis on security, which extends to strong limits on programmatic access, especially to enterprise-wide resources, so getting all organizations or all repositories of the enterprise becomes non-trivial.
This guide will describe how to do just these.

<!--break-->

# Goal

The goal is to get all current and future organizations and repositories that belong to the enterprise. It needs to handle new organizations added without additional configuration.

So on a high level: we need an identity with enough permissions to access these resources, then use that identity to call an API. [Github has a REST API](https://docs.github.com/en/enterprise-cloud@latest/rest/overview/about-githubs-apis?apiVersion=2022-11-28) that looks like it could work.

# What doesn't work

While the docs mention [the use-case of machine accounts](https://docs.github.com/en/enterprise-cloud@latest/get-started/learning-about-github/types-of-github-accounts#:~:text=Tip%3A%20Personal%20accounts%20are%20intended%20for%20humans%2C%20but%20you%20can%20create%20accounts%20to%20automate%20activity%20on%20GitHub%20Enterprise%20Cloud.%20This%20type%20of%20account%20is%20called%20a%20machine%20user.%20For%20example%2C%20you%20can%20create%20a%20machine%20user%20account%20to%20automate%20continuous%20integration%20(CI)%20workflows.) these use licenses, so it is generally recommended [to use Github Apps instead](https://josh-ops.com/posts/github-apps/). However Github Apps can [only be installed either on repositories or on organizations](https://docs.github.com/en/enterprise-cloud@latest/apps/using-github-apps/installing-your-own-github-app), so while this could work, it would need to be installed on all new orgs manually (there doesn't seem to be any API that would install Github apps). So we have to use machine accounts.

Authenticating with a machine account's username and password is [not supported](https://docs.github.com/en/enterprise-cloud@latest/rest/overview/authenticating-to-the-rest-api?apiVersion=2022-11-28#authenticating-with-username-and-password), so we have to use tokens.

There are two types of tokens:
* `Fine-grained personal access tokens`: these are [scoped to a single organization](https://docs.github.com/en/enterprise-cloud@latest/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#:~:text=Each%20token%20can%20only%20access%20resources%20owned%20by%20a%20single%20user%20or%20organization.), so won't work for us
* `Personal access tokens (classic)`: these are [can access the entire enterprise](https://docs.github.com/en/enterprise-cloud@latest/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#:~:text=Only%20personal%20access%20tokens%20(classic)%20can%20access%20enterprises), so generating them for a machine account that has sufficient permissions coud work. However there is a problem if orgs in the enterprise enforce SAML single sign-on (SSO) for authentication: [one needs to authorize the token for each of these orgs manually](https://docs.github.com/en/enterprise-cloud@latest/rest/overview/authenticating-to-the-rest-api?apiVersion=2022-11-28#authenticating-with-username-and-password:~:text=If%20you%20use%20a%20personal%20access%20token%20(classic)%20to%20access%20an%20organization%20that%20enforces%20SAML%20single%20sign%2Don%20(SSO)%20for%20authentication%2C%20you%20will%20need%20to%20authorize%20your%20token%20after%20creation.). This again doesn't fit our use-case.

# GraphQL to the rescue

So all of the above is based on the REST API docs, but Gihub also has a GraphQL API with different controls on the token. One can get all orgs of an enterprise using this query:

```graphql
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

* `read:enterprise`
* `read:org`
* `repo:status`
* `public_repo`

(Some of these are only required for getting the repos too, so if you only need the list of orgs, you won't need all of them). Authorize the token for just one organization (again this might only be necessary for getting the repos), then run:

```bash
curl -H "Authorization: bearer $PAT" -X POST -d " \
 { \
   \"query\": \"query {enterprise(slug:\\\"NAME_OF_THE_ENTERPRISE\\\") {organizations(first: 100) {nodes { login } } } }\" \
 } \
" https://api.github.com/graphql
```

Going one step further, we can also query all the repositories within the org:

```graphql
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

Or the same with curl:

```bash
curl -H "Authorization: bearer $PAT" -X POST -d " \
 { \
   \"query\": \"query {enterprise(slug:\\\"NAME_OF_THE_ENTERPRISE\\\") {organizations(first: 100) {nodes { login, repositories(first: 100){nodes{name}}  } } } }\" \
 } \
" https://api.github.com/graphql
```

The interesting thing is that even if the PAT is only authorized for a single organization, this will return repositories for all organizations (assuming the user has permissions to see them). This means that running this with a machine user that is enterprise admin should return all repositories.

**Sidenote**: if you want the repository name to include the org (so `octo-org/octo-repo` instead of `octo-repo`), use `nameWithOwner` instead of `name`. Of course you can also reconstruct it from the org `login` and the repo `name`.

## Final hurdle: pagination

The above query works, however it only returns the first 100 organizations, and the first 100 repositories for each of those organizations. (This is a limitation of the GitHub GraphQL API so setting it to a higher number won't work.) This might be an acceptable limitation for some usecases, but if there is a chance of having more than 100 orgs or more than 100 repositories in an org, then we need to handle pagination.

[This guide](https://til.simonwillison.net/github/graphql-pagination-python) describes how to paginate through the GitHub GraphQL API with Python, so applying it to our GraphQL calls I put together this script:

```python
import os

import yaml
from python_graphql_client import GraphqlClient

GH_PAT = os.environ["GH_PAT"]

client = GraphqlClient(endpoint="https://api.github.com/graphql")

# Pagination based on
# https://til.simonwillison.net/github/graphql-pagination-python
def get_orgs_query(after=None):
    return """
    query {
        enterprise(slug: "NAME_OF_THE_ENTERPRISE") {
            organizations(first: 100, after:AFTER) {
                nodes {
                    login
                }
                pageInfo {
                    hasNextPage
                    endCursor
                }
            }
        }
    }
    """.replace(
        "AFTER", f'"{after}"' if after else "null"
    )


def get_repos_query(org_name, after=None):
    return """
    query {
        organization(login: "ORGNAME") {
            repositories(first: 100, after:AFTER) {
                nodes {
                    name
                }
                pageInfo {
                    hasNextPage
                    endCursor
                }
            }
      }
    }
    """.replace(
        "ORGNAME", org_name
    ).replace(
        "AFTER", f'"{after}"' if after else "null"
    )


organizations = []
hasNextPage = True
afterCursor = None

print("Getting organizations")

while hasNextPage:
    data = client.execute(
        query=get_orgs_query(afterCursor),
        headers={"Authorization": f"Bearer {GH_PAT}"},
    )
    if (
        "enterprise" in data["data"]
        and "organizations" in data["data"]["enterprise"]
        and "nodes" in data["data"]["enterprise"]["organizations"]
    ):
        for org in data["data"]["enterprise"]["organizations"]["nodes"]:
            organizations.append({"name": org["login"], "repositories": []})
    else:
        print("Response missing expected field. Got:")
        print(data)
    hasNextPage = data["data"]["enterprise"]["organizations"]["pageInfo"]["hasNextPage"]
    afterCursor = data["data"]["enterprise"]["organizations"]["pageInfo"]["endCursor"]

print("Got organizations: ")
print(organizations)
print("-----------------------------")

for org in organizations:
    print("Getting repos for org: " + org["name"])
    hasNextPage = True
    afterCursor = None
    while hasNextPage:
        data = client.execute(
            query=get_repos_query(org["name"], afterCursor),
            headers={"Authorization": f"Bearer {GH_PAT}"},
        )
        if (
            "organization" in data["data"]
            and "repositories" in data["data"]["organization"]
            and "nodes" in data["data"]["organization"]["repositories"]
        ):
            for repo in data["data"]["organization"]["repositories"]["nodes"]:
                org["repositories"].append(repo["nameWithOwner"])
        else:
            print("Response missing expected field. Got:")
            print(data)
        hasNextPage = data["data"]["organization"]["repositories"]["pageInfo"][
            "hasNextPage"
        ]
        afterCursor = data["data"]["organization"]["repositories"]["pageInfo"][
            "endCursor"
        ]

print("-----------------------------")
print("Organizations and repositories collected:")
print(yaml.dump(organizations)) # or print(json.dumps(organizations, indent=4))
```

Installing the dependencies:

```bash
pip3 install python-graphql-client pyyaml
```

Now you have it, a programmatic way to get all current and future orgs and repositories of the enterprise. TLDR steps once again:

* Create a machine account with enterprise admin priviledges (so that it can see all orgs and repositories)
* Create a Classic Personal Access Token for the account with the following scopes:
    * `read:enterprise`
    * `read:org`
    * `repo:status`
    * `public_repo`
* Authorize the PAT for at least one organization
* Run the above python script using the PAT
