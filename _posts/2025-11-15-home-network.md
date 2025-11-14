---
layout: post
title: "Home network setup for our new house"
tags: housing japan tech
---

We [just built our house in Tokyo]({% post_url 2025-11-01-house-handover %}) and [in a recent post I wrote about how we got internet]({% post_url 2025-11-13-internet %}). In this post I will share how I set up the network within the house.

<!--break-->

## Constraints

Ichijo houses have floor heating in all rooms. This has a heat reflective layer made of metal (looks a bit like aluminium foil), which partially blocks the radio waves. So many online blogs recommend having one WiFi access point per floor or setting up a mesh WiFi system.

We got the Nuro 10G internet package which promises up to 10 Gbps speeds. Even though this is the maximum and not guaranteed speed, I wanted to have a network that can use as much of the internet speed as available. This also helps future-proof the setup to some extent, should a faster internet connection become available.

Both my wife and I use Macbooks for work, so WiFi is preferred over wired internet for the most part.

We [got every home appliance connected to the internet that we could]({% post_url 2025-04-21-ichijo-smart-home %}), and some of these connect via Ethernet, so these need wired connectivity.

## During the design of the house

While designing the house, we could choose the location of the information box (情報ボックス). This is where the optic fiber from Nuro ends, and where all the ethernet cables start. In mansions I lived before, this  was always at the entrance, which caused issues with the WiFi in the furthest rooms of the apartment. We asked to put the information box into my office on the second floor (between the LDK and the bathroom), which is sort of in the middle of the house.

Ichijo uses Cat5e ethernet cables normally, and [we asked them to use Cat6A instead for an extra 53,400 yen]({% post_url 2025-05-04-cost-of-our-ichijo-house %}). Cat5e only supports [speeds up to 1 Gbps](https://en.wikipedia.org/wiki/Category_5_cable), while [Cat6A can do up to 10 Gbps](https://en.wikipedia.org/wiki/Category_6_cable). Ichijo also doesn't use conduits, so upgrading these in the future is costly, so I asked to go with the best they could offer.

## The setup

I had issues with cheap WiFi access points in the past, so I decided to get a high quality solution. Based on a friend's recommendation, I went with [Ubiquiti](https://ui.com/). They are on the higher end of home networking, but have excellent software support.

This is the design I came up with:

![The network design](/assets/2025-11-15-home-network/design.png#lb)

The fiber optics connects to the ONU, provided by Nuro (the ISP). This has a 10 Gbps Ethernet port.

Ubiquiti setups need a [cloud gateway](https://ui.com/jp/en/cloud-gateways) next. To simplify the setup I wanted to get one with [built-in WiFi](https://jp.store.ui.com/jp/en/category/cloud-gateways-wifi-integrated), and decided to go with the [Dream Router 7](https://jp.store.ui.com/jp/en/category/cloud-gateways-wifi-integrated/products/udr7) as it offered a good set of features. (I did consider having a separate WiFi AP instead, but then I run into issues with many ports only offering 1 Gbps speed, so decided to keep it within the same device.)

The Dream Router's 10 Gbps port is however an SFP+ port and not an Ethernet one, so I had to get a [converter](https://jp.store.ui.com/jp/ja/category/accessories-modules-fiber/collections/accessories-pro-direct-attach-cables/products/uacc-cm-rj45-mg?variant=uacc-cm-rj45-mg&c=JP). With this I got the 10 Gbps connection into the Dream Router.

The Dream Router only has 4 Ethernet ports, but I have 5 smart home devices and 2 home servers, so I needed more ports. To solve this I added an 8 port switch, the [Lite 8 PoE](https://jp.store.ui.com/jp/ja/category/all-switching/products/usw-lite-8-poe). I also have all the Ethernet cables going to the bedrooms, but we won't use all of those initially, so I decided to not connect them for now. (The switch was already pretty expensive.)

Then I needed a WiFi access point for the first floor, and went with a simple [U7 Lite](https://jp.store.ui.com/jp/ja/category/all-wifi/products/u7-lite). This is powered via Power-over-Ethernet. The Dream Router has a port that can drive this, so connected the AP there and placed it into the middle room of the first floor. I was thinking a lot about how to fix it to the ceiling, but then decided to just use double-side tape for now. If it falls off, I will fix it properly, but it's pretty light.

Overall this was my shopping list:

| Model                | Purpose                                 | Price   |
| -------------------- | --------------------------------------- | ------- |
| [Dream Router 7](https://jp.store.ui.com/jp/ja/category/all-cloud-gateways/products/udr7)       | Cloud Gateway with WiFi 7 (main router) | ¥50,300 |
| [SFP+ to RJ45 Adapter](https://jp.store.ui.com/jp/ja/category/accessories-modules-fiber/collections/accessories-pro-direct-attach-cables/products/uacc-cm-rj45-mg?variant=uacc-cm-rj45-mg&c=JP) | To connect the ONU to the router        | ¥11,700 |
| [Lite 8 PoE](https://jp.store.ui.com/jp/ja/category/all-switching/products/usw-lite-8-poe)           | 8 port switch                           | ¥18,900 |
| [U7 Lite](https://jp.store.ui.com/jp/ja/category/all-wifi/products/u7-lite)              | WiFi 7 Access Point                     | ¥17,800 |

After adding a few cables, the total price was 100,743 yen. Pretty pricey, but hopefully should last a decade or so.

After setting it all up, the information box looked like this:

![Black box on the right is the ONU, egg in the middle is the Dream Router, switch is on the top. The black box with red dot on the left is Ichijo's 4G modem that the solar panel connects to](/assets/2025-11-15-home-network/infobox.jpg#lb)

*Side note*: the information box came with a 4G modem that Ichijo connected to the solar panel. Ichijo told me that this is used to monitor the solar panel (I can do it via their app, but also they also do it). I can connect this to my home network (as long as it can reach the internet), but some of their customers don't have internet at home, so they just give this to everyone. The SIM has a 10 year contract, and after that they ask people to connect to their own network. I checked, but the 4G modem doesn't offer full internet access. It is probably limited to accessing Ichijo's servers or might need some proxy config, I didn't look into it.

## Speed test

The Dream Router has a built-in functionality to do a speed test which reports 3.0-3.5 Gbps download and 1.4-2.4 Gbps upload speeds. Not exactly 10 Gbps, but still super fast.

Testing the speed on the WiFi gave me 800 Mbps down, 350 Mbps up on both floors, which is very good.

There is a potential issue: my office is next to the kitchen, and we covered that wall with a metal plate so that magnetic tools (hooks, shelves, etc.) can be attached to it. This seems to block some of the radio waves. If this becomes an issue, then I will need to add another WiFi AP in the living room (there is an Ethernet port behind the TV, so I can use that), and with that we will have full coverage of the second floor.
