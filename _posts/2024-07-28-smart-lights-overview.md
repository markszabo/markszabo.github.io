---
layout: post
title: "Smart lighting options in Japan"
tags: tech japan housing
---

We are in the process of building our house, and I want to use this opportunity to add some smart home solutions. Right now my focus is on ensuring that the things that come with the house are capable of "being smart" (controlled with automation). Big part of this is lighting, and in this post I'll review what I learned about smart lighting options available in Japan.

<!--break-->

# Our goals

Our requirements for the smart light setup:

1. Works with [Home Assistant](https://www.home-assistant.io/) - I used it in the past and really liked it
2. Reliable - I want to limit the times I have to reconnect/re-pair devices
3. No batteries - again, low maintenance as much as possible
4. Lights need to work even if all the smart home is broken. I don't want to end up in a dark house just because an update went wrong and I need to rebuild/restore the config (also I especially don't want my family in this situation). There has to be an intuitive fall-back that works (e.g. turn light on-off-on to bring it back to full brightness)
5. Should be intuitive and should enhance the experience for everyone including when we have guests over
6. Should not make us stupid. We have relatives who have automatic light in the toilet at home, so they often forget to turn off the light when they are at our place. Especially for our small kids, the home is where they learn how a house works, so making sure they know what a light switch is, is important.

# Japan-specific rules

After reading many reddit and facebook posts, the general consensus seems to be the following:

1. only certified electricians are allowed to do any work on the electric network that requires the breaker to be turned off. So e.g. a regular person can change a lightbulb or install a new lamp, but can't rewire a switch. The main issue with this being illegal is that if there is a fire, the insurance company might claim that it happened due to the unlicensed electrician work and refuse to pay. (But there are some people that say that the risk of this is pretty minimal unless the fire was from the electric device.) One workaround to this is to get the electrician's license, which (to my surprise) some foreigners [actually do just for the sake of doing work on their own homes](https://www.youtube.com/watch?v=vTruug7JLqg).
2. most electricians refuse to install smart switches imported from abroad if they have not been certified in Japan. This includes not only random stuff from Aliexpress, but also reputable, widely used brands from the US or Europe (e.g. Inovelli)

I have heard these mentioned at multiple threads, so this seems to be the general consensus, but I did not check the relevant laws in detail, so it might be incorrect.

There is one more condition, specific to our home: we plan on applying for some government subsidies for building an energy efficient house, and this means that all lights have to be energy efficient. Since we are working with a big builder, [Ichijo](https://www.ichijo.co.jp/), they said that this means that we have to get all lights from them and can't bring our own or buy lights elsewhere (even if the other lights would fulfill the energy efficiency requirements, the builder just doesn't want to handle the additional paperwork). So initially we have to get all lights from them, but we can change them later.

# Options

So what smart lighting options do exist? There are generally two approaches:

* smart bulbs
* smart switches

## Smart bulbs

Many company from IKEA to Philips offer smart light bulbs that connect to some network (e.g. Zigbee or Wifi) and can be controlled remotely. They often offer brightness and color or color temperature controls too.

They are pretty cheap starting from around [1,000 yen for a dimmable IKEA LED bulb](https://www.ikea.com/jp/en/p/tradfri-led-bulb-e26-810-lumen-smart-wireless-dimmable-warm-white-globe-30541515/) to [9,000 yen for a full RGB Philips Hue bulb](https://www.amazon.co.jp/Philips-%E3%83%95%E3%82%A3%E3%83%AA%E3%83%83%E3%83%97%E3%82%B9%E3%83%92%E3%83%A5%E3%83%BC-%E3%82%B9%E3%83%9E%E3%83%BC%E3%83%88%E3%83%A9%E3%82%A4%E3%83%88-%E3%83%95%E3%83%AB%E3%82%AB%E3%83%A9%E3%83%BC100W-Bluetooth/dp/B09JS5DN5Q/) (both of these work with Zigbee).

These systems require the bulbs to be powered on at all times, and the use of additional buttons as switches (IKEA and Philips both sell these buttons). And this is where the main issue comes in. We have two options for what to do with the traditional switches in this setup:

1. Leave them as-is (they can cut the power to the bulbs). This is good as a fall-back if the smart lights disconnect or if HomeAssistant is down (most lights will go back to full brightness if you turn them on-off-on quickly), but they present an issue: if someone turns off a light with the switch, there is no way for an automation to turn it back on.
2. Remove the old switches and connect the lights to power permanently. This is an issue when there is any problem with the smart system, and also one needs to turn the breaker off when switching light bulbs. This operation should be done by an electrician and one would need to undo them before selling the house.

Both of these options come with compromise that I don't like.

## Smart switches

The other approach is to use smart switches: these can be operated manually (you press them, they turn the light on/off), and also remotely. Some of them are capable of dimming the lights, and they do this by sending less electricity to the bulbs (so not all lights will be compatible with them).

Normally a live wire is connected to the switch, then from the switch to the light, then the light to the neutral. When the switch is on, it connects the 2 wires and current will flow to the light. When the switch is off, the wires are disconnected, so no current is flowing and the light stays dark. However this presents a problem: when no current is flowing, the switch also doesn't have power to operate. There are two main ways to solve this:

* **2-wire type switches**: these are connected like regular switches (one side to the live wire, one to the light), but even when they are off, they let through a small amount of current. This makes it possible for them to operate, and the small current should still leave the lights dark. However this depends on the light, and some might make some humming noise or produce a bit of light. These switches can be used to directly replace existing, dumb switches without additional wiring.
* **3-wire type switches**: the switch gets an additional wire, a neutral. So now it can create two circuits: (live - switch - neutral) for the switch's operation and the usual (live - switch - light - neutral) for running the light. This means that when the light is off, there is no current flowing through the light. But it needs the extra neutral wire at the switch that dumb switches don't usually have.

Since we are building our house from scratch, we can easily bring neutral wires to the switches, so we will go with the 3-wire type switches.

The smart switch approach can't adjust the color of the lights, so e.g. you can't make your lights [follow the circadian rhythm](https://github.com/basnijholt/adaptive-lighting) (make the lights warm white at night).

From [this blog post](https://ameblo.jp/08s3013b/entry-12641354640.html) I found 3 options available in Japan:

* [Panasonic's Advanced Series Link Plus](https://sumai.panasonic.jp/wiring/switch_concent/series/advnace.html) - these use Bluetooth, and can be controlled directly from your phone (within Bluetooth range) and they come with an [optional hub](https://www2.panasonic.biz/jp/densetsu/haisen/switch_concent/advance/lineup/linkplus/wireless_adapter/) that let's you control them over WiFi. The hub [supports the Echonet Lite protocol](https://echonet.jp/introduce_en/gz-000755/) and [echonetlite_homeassistant supports the hub](https://github.com/scottyphillips/echonetlite_homeassistant#:~:text=Panasonic-,Link%20Plus%20WTY2001,-GeneralLighting%2C%20Lighting%20system). This is my preferred option, and I will go into more details later.
* [Odelic Connected Lighting](https://www.odelic.co.jp/products/connected_switch/) - I like that their regular switches have a joystick-like circular button in the middle to control brightness and color temperature, and the switch is a bit cheaper than Panasonic ([starting from 15,000 yen](https://www.odelic.co.jp/webcatalog/dpm/vol_197/index.html#target/page_no=1058)). However if I understand correctly these switches only work with their own lights, as they keep the lights powered on at all times and then communicate via bluetooth from the switch to the light. Not a bad design, but since we have to get our lights from the builder, this won't work for us (also the vendor lock in is an issue, e.g. if this company goes out of business or stops making these smart lights, we can't get lights from an other company)
* [Koizumi TRee](https://www.koizumi-lt.co.jp/product/jyutaku/tree/) - I didn't look into it deeply as their [simple switch is 20,800 yen](https://webcatalog.koizumi-lt.co.jp/kensaku/item/detail/id/4544440000) and [the hub is 45,000 yen](https://www.lightstyle.jp/?cn=100026&shc=10092114) making them more expensive than Panasonic. But since their reference wiring diagram only has item numbers for the switches and not for the lights, I'd assume it works with any light (similar to Panasonic's system). Also the website clearly mentions EchonetLite support, which is a plus.

So I prefer the Panasonic one, but that's pricey: a [simple switch retails for 16,000 yen](https://www2.panasonic.biz/jp/densetsu/haisen/switch_concent/advance/lineup/linkplus/2wire_handle/) and the one with dimmer [goes for 21,000 yen](https://www2.panasonic.biz/jp/densetsu/haisen/switch_concent/advance/lineup/linkplus/2wire_rotary/) (around 10x more than the price of a "dumb" switch). And one also needs the [hub (無線アダプタ) for 34,000 yen](https://www2.panasonic.biz/jp/densetsu/haisen/switch_concent/advance/lineup/linkplus/wireless_adapter/) and potentially [repeaters every 30m for another 26,000 yen each](https://www2.panasonic.biz/jp/densetsu/haisen/switch_concent/advance/lineup/linkplus/wireless_repeater/). A quick calculations shows that just the switches in our new house would be around 400-500,000 yen.

In comparison, [Inovelli's 2-1 Switch is only $50](https://inovelli.com/products/zigbee-matter-blue-series-smart-2-1-on-off-dimmer-switch) (7,000-8,000 yen) and [Xiaomi Mijia BLE switches are around 2,000 yen from Aliexpress](https://ja.aliexpress.com/item/4000810935841.html). But these would either need me to get an electrician license, find an electrician who is willing to install them, or risk issues with insurance.

Benefit of the Advanced Series (other than being the only option): the switches look sleek, are intuitive to use for humans (great for guests), have [2-wire](https://www2.panasonic.biz/jp/densetsu/haisen/switch_concent/advance/lineup/linkplus/2wire_handle/) and also [3-wire](https://www2.panasonic.biz/jp/densetsu/haisen/switch_concent/advance/lineup/linkplus/3wire_handle/) types, and our builder (Ichijo) said that they are willing to install it, so we can have them ready by the time we move in (and potentially save on the cost of the original switches and the installation).

## Conclusion

Considering the pros and cons of both options, I'm leaning towards the smart switches option with additionally having some of our lights smart too for color control. At these lights we only need a regular smart switch (not the dimmer one), which saves a bit on the switch.
