---
layout: post
title: How to download the latest release from a Github repository
tags: tech
---

We often want to download the latest release of an application from Github, however it [used to be hard without knowing the latest version](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8). But now we can do the followings:

* `https://github.com/<user>/<repo>/releases/latest` takes you to the latest release page, e.g. [https://github.com/Azure/kubelogin/releases/latest](https://github.com/Azure/kubelogin/releases/latest)
* `https://github.com/<user>/<repo>/releases/latest/download/<filename>` gets you a binary from the latest release, e.g. [https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip](https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip)
