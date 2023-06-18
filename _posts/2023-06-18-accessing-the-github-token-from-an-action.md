---
layout: post
title: Accessing the Github token from a Github action
tags: tech
---

For each Github action workflow, Github creates a unique Github token. This can accessed a either via the  `GITHUB_TOKEN` secret (`{% raw %}${{ secrets.GITHUB_TOKEN }}{% endraw %}`) or via the `github` context (`{% raw %}${{ github.token }}{% endraw %}`).
The [docs](https://docs.github.com/en/actions/security-guides/automatic-token-authentication#using-the-github_token-in-a-workflow) also note that 

> An action can access the GITHUB_TOKEN through the github.token context even if the workflow does not explicitly pass the GITHUB_TOKEN to the action.

However the docs fall short of showing how to do it, and it took me a while to figure it out, so I'm sharing it here.

<!--break-->

The solution is to use an input and set its default value to `github.token`. In composite actions, one can also use the `github` context directly, however it can not be used when passing environment variables in a non-composite action.

```yaml
name: 'Test github context access'
inputs:
  gh-token:
    description: "A GitHub PAT used to add the comment to the PR"
    default: ${{ github.token }}
runs:
  using: "composite"
  steps:
    - name: Get all issues for this repository
      shell: bash
      run: |
        curl -L \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${{ inputs.gh-token }}" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/${{ github.repository }}/issues
```

See this in action [here](https://github.com/markszabo/markszabo.github.io/pull/1).

This also works for other values in the [github context](https://docs.github.com/en/actions/learn-github-actions/contexts#github-context) like `github.repository`, `github.sha`, `github.event_name`, etc. 