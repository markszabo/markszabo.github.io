---
layout: post
title: "How to configure WAN1 (Ethernet #4) as LAN on a Dream Router 7"
tags: tech
---

We [just built our house in Tokyo]({% post_url 2025-11-01-house-handover %}) and [in a recent post I wrote about how I set up our home network using Ubiquiti gear]({% post_url 2025-11-15-home-network %}). The central piece is a [Dream Router 7](https://store.ui.com/us/en/products/udr7), which comes with two WAN ports: WAN1 (2.5 GbE RJ45) and WAN2 (10G SPF+). Our internet is connected to WAN2, and wanted to use WAN1 as a LAN port. This post is about how to configure this.

<!--break-->

I was looking at the config options, but there is no way to re-designate or remove WAN1. Then I found [this forum post](https://community.ui.com/questions/How-can-I-redesignate-Ethernet-port-4-as-LAN-instead-of-WAN-Dream-Router-7-SOLVED/1e8aa5cd-6ecc-4ea4-a3cb-b52df6fdebd4) which described the solution. In the end, these are the steps I went through:

1. Connect the router to the internet via WAN2 (10G SPF+)
2. Go through the setup and stay connected to the router's network
3. Access the config page of the router via [http://192.168.0.1](http://192.168.0.1). Don't use the app, as that needs internet and we will take that away
4. Go to the WAN2 config and unassign the port. This will cut the internet connectivity of the router (and thus put the entire network offline). Ensure you stay connected to the network despite it not offering internet access.
5. Go to the WAN1 config and change the port to the SPF+ port.

Now the original WAN1 port (Ethernet #4) can be used as a LAN port.
