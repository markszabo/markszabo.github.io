---
layout: post
title: "snyk test docker --fail-on= workaround"
tags: tech security
---

I'm running Snyk to scan docker images and break the build if they have high or critical vulnerabilities:

```bash
snyk test --severity-threshold=high --docker $IMAGE_NAME
```

However sometimes the upstream image has high or critical vulnerabilities (e.g. at the times of writing this, `debian`), so there is very little action one can take (other than moving to a different base image, which is usually not easy). Thus I only want to break the build if there are high or critical vulnerabilities AND they can be fixed by ugrading the base image.

<!--break-->

`snyk` CLI [has](https://docs.snyk.io/features/snyk-cli/guides-for-our-cli/cli-reference#:~:text=upgradable) the `--fail-on=all|upgradable|patchable` option that says

> Only fail when there are vulnerabilities that can be fixed.

which would be perfect, but it's broken for docker scans. Thus I had to come up with a workaround:

```bash
snyk test --severity-threshold=high --docker $IMAGE_NAME --json-file-output=/tmp/out.json || if cat /tmp/out.json | jq '.docker.baseImageRemediation.code' | grep -q "NO_REMEDIATION_AVAILABLE"; then return 0; else return 1; fi
```

This scans the image, saves the output to json. If the scan failed, then parses the json to look for the `.docker.baseImageRemediation.code` that will tell whether `NO_REMEDIATION_AVAILABLE` or `REMEDIATION_AVAILABLE`. And only fail the build if there is remediation available.
