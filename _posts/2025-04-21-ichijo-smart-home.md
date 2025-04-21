---
layout: post
title: "Ichijo's smart home options"
tags: tech japan housing
---

We are building a house in Tokyo with [Ichijo 一条工務店](https://www.ichijo.co.jp/). In previous apartments I always had a limited smart home setup, so now that we got to design the whole house, I wanted to consider every available options and add them if they make sense. I'll review what we ended up adding to our design in this post.

<!--break-->

*I will share prices in this post, but those of course change with time. For reference: we signed the pre-contract with Ichijo in January 2024, and finalized the design in March 2025. Prices mentioned do not include the consumption tax, but prices on screenshots from the Ichijo catalog do.*

## HEMS

Smart home is still waiting for a breakthrough, before it becomes an essential element of all homes around the world. Sure, tech-savy people are building amazing things, but we are still far from a plug-and-play solution that provides enough value for the average user. The Japanese government and companies are taking another approach: instead of selling it as a convenience feature, they are selling it as a way to manage energy and save money.

Meet HEMS. From [the website of the Ministry of Environment](https://www.env.go.jp/earth/ondanka/kateico2tokei/energy/detail/04/):

> HEMS stands for Home Energy Management System. It is a system that supports comfort and energy conservation in the home by displaying energy usage on dedicated monitors, computers, smartphones, and similar devices. It encourages the optimal operation of air conditioning, lighting, and home appliances. The national government has also included the promotion of energy management using HEMS in its policy plans.

As smart devices are made by different manufacturers, interoperability is usually difficult. That's where HEMS's government support comes handy: it [comes with a standardized protocol, ECHONET Lite](https://echonet.jp/about/hems/), that all device has to support.

### ECHONET Lite

[ECHONET Lite](https://ja.wikipedia.org/wiki/ECHONET_Lite) was developed by the ECHONET Consortium that consist of major Japanese companies making these devices. It is called Lite, as it is a rework of the earlier ECHONET standard, that was too prescriptive (including the physical and data link layers) which prevented its wider adoption.

ECHONET Lite usually works over UDP/IP sending packets to port 3610. The messages are either multicast (e.g. an air conditioner announcing that it has been turned on) or unicast (someone setting the air conditioner to a specific temperature). While [other transmission methods like Bluetooth are also supported](https://echonet.jp/features_en/), all devices I've seen use either WiFi or Ethernet.

The protocol doesn't have any authentication, authorization, or encryption, so anyone on the same network can interact with the devices. This is likely to allow low-power devices to use the protocol. Thus authentication needs to be implemented on a lower layer, e.g. by using a dedicated wifi network that's firewalled from the rest of the network.

The nice thing is that this protocol is entirely local: even if the device can't connect to the internet, it can still be controlled by sending it ECHONET Lite messages.

The [ECHONET Lite website has a search](https://echonet.jp/product_en/echonet_lite_specification/) to check if a specific device received the ECHONET Lite certification. Useful, as sometimes the promotional materials only mention supporting HEMS.

ECHONET Lite also has two integrations with [Home Assistant](https://www.home-assistant.io/):

* <https://github.com/scottyphillips/echonetlite_homeassistant> - I tried this and works well
* <https://github.com/banban525/echonetlite2mqtt> - I haven't tried this

Both repositories has recent activities, though the first says that the original author no longer works on this project, but will accept PRs.

## Cloud HEMS (クラウドHEMS) - 150,000 yen

This is the main HEMS option from Ichijo, and without this they don't allow their other HEMS options. This is actually new: for houses that are completed before June 2025, a previous HEMS option was used (that didn't have the cloud component). The cloud piece means that this integrates with [Mitsubishi's MyMU app](https://www.mitsubishielectric.co.jp/home/mymu/me-enel.html), which allows local and remote monitoring and control of the connected devices.

So what can be connected?

### EcoEye distribution board (included with the Cloud HEMS option)

[**EcoEye**](https://www.kawamura.co.jp/ecoeye/about/) is a distribution board with per-circuit measurement made by Kawamura Electric. This is the center of home energy management.

I guess the main use of this is to see which devices use a lot of electricity, and then try to run those at an optimal schedule. I originally didn't plan to add this, but since it is included with the Cloud HEMS, we'll have it, then see if it ends up being useful.

### Floor heating adapter (included with the Cloud HEMS option)

This gets installed on the back of the floor heating control panel and enables per-area temperature control and on/off setting.

I expect that this might be useful as a way to automatically lower the temperature in the living room during the night, or to turn up the heating when we are coming back from a longer trip.

### EcoCute water heater adapter (included with the Cloud HEMS option)

This [let's you refill the bath even when you are away](https://www.mitsubishielectric.co.jp/home/ecocute/function/remote.html#section01_01) (assuming the tub stopper/plug is closed, or if you have a bathtub where it can be operated remotely). It also allows to control the amount of hot water in the tank, and let's you turn off heating the water while you are away for a few days.

I can see this very useful for times when going on a trip, as it will let us turn on the water heating before we come back.

Moreover [it can](https://www.mitsubishielectric.co.jp/home/ecocute/function/ez.html) check the weather forecast for the next day and wait for the free electricity from the solar panels to reheat the water. This is something that I had in mind myself, since we tend to use hot water mainly in the evening, so delaying the reheat until the solar panels are working can likely save quite a bit of electricity. So I'm looking forward to this feature.

The specific features depend on whether Mitsubishi or Chofu Seisakusho made the EcoCute, but the documents I saw weren't very clear on the difference. We are getting one from Mitsubishi, so I guess it will have most things (since they made the backend as well).

### 24h ventilation system (ロスガード) adapter (7,700 yen)

This let's you turn the ventilation system on and off, and switch the mode (e.g. activate night mode). Also to send a push notification when the filter needs to be replaced. It also shows the temperature and humidity of the incoming and outgoing air.

If you have the うるケア version (which includes the central humidifier), then this adapter also enables turning the humidifier on and off.

I expect that we will likely automate turning on the night mode each evening, and might set up something for the humidifier setting too, based on the incoming air's humidity. Overall looking forward to this, as the ventilation system can be quite noisy at night, so having a way to remotely enable night mode or even turn it off for an hour or so sounds useful.

### Air conditioners (included with the ACs)

Air conditioners in general are a great device to connect to any HEMS system. Thus all high-grade and many medium-grade AC options include the WiFi adapter. Based on earlier good experience, we went with Daikin ACs and both their high-grade (AX series), and mid-grade (CX series) had the adapter included. I wanted to get high-grade ACs due to their energy efficiency and how well they work, but the inside unit of Daikin AX is too big, so we decided to go with CX for the kids rooms, and kept the AXs for the main bedroom and the living room.

### Alarm system (防犯警報装置器) (not sure)

Ichijo offers a house alarm system that adds opening sensors to all windows, and a central device that makes a loud noise when a window is opened. To open a window without triggering the alarm, one has to turn off the sensor first (by a switch on the sensor).

We decided not to get this system, simply as we didn't see the point of it. If someone breaks the window, the sensor won't trigger (as the window frame didn't open). So for a bulgar to trigger the sensor, they would either need to pick the window lock from the outside (highly unlikely), or we would need to close the window without locking it AND remember to turn on the sensor. This is also highly unlikely. On the other hand, we would likely often forget to de-active the sensor, which could wake the kid(s).

But if someone has the alarm, and adds the HEMS connector, then they will be able to get an intruder alert on their phone, reset the alarm (as the normal system needs you to turn it off on the main unit, until then it keeps making the noise, I believe), and turn the speakers on/off.

## Non-HEMS smart options

There are devices that connect to the internet, but are not part of the Cloud HEMS offering.

### Panasonic Advanced Series Link Plus switches (350,000 yen for all switches we chose)

I [looked into smart lighting and light switches]({% post_url 2024-07-28-smart-lights-overview %}) concluding that the best option for us was likely Panasonic's Advance Series Link Plus, which later [I did a deep-dive on]({% post_url 2024-11-10-panasonic-advance-series-link-plus %}), and we decided to add them. In the end, all of our switches are Link Plus, except:

* switches in the toilet: for an energy efficiency certification these had to be motion sensors
* bath light and air-circulator: the architect recommended a timer switch for the circulator, which comes with a switch for the light built-in, so went with that
* switch for the EV charger (as the Link Plus switches can't handle the amps required)

For the first 2 I asked them to pull an extra earth wire to the switch, so that they might be replaced by Link Plus switches in the future.

These are not part of Ichijo's HEMS offering, but Panasonic's hub supports Echonet LITE.

### Outside security camera with LAN (47,800 yen)

[VL-CX500X-H](https://www2.panasonic.biz/jp/densetsu/doorphone/products/vl-cx500x/) security camera from Panasonic. I like the small, boxy design. I considered installing cameras myself after we move in, but I didn't feel like drilling holes into our brand new house, so the convenience of having it installed by Ichijo won. Also this way they take care of the wiring too, both the power and the ethernet.

### Intercom upgrade MT91 (28,000 yen)

This changes the intercom to another Panasonic model which will send you a push notification when someone is ringing the bell. However according to [this blog](https://yokohama-3floor-house.com/2020/09/24/post-1227/) the notification takes about 10 seconds, so by the time you respond, the delivery person usually left already.

The reason we got this is that this also enables connectivity with the security camera, and the intercom will show the camera feed when it detects movement. This can act as a pre-notification before someone rings the doorbell, if we are near the intercom. Also the intercom has an SD card slot where the camera recordings can be stored, which is nice too.

### E-entry entrance door, interphone plan (60,000 yen for the door, 21,000 yen for the interphone connection)

E-entry entrance door has a radio receiver, so you can keep the key in your pocket and the door can be unlocked with the press of a button (like how many cars work). 

![Ichijo's radio key options - separate button and handle-integrated button (price as of January 2024)](/assets/2025-04-21-ichijo-smart-home/radio-key.png#lb)

Due to the shape of our house, we are  getting a sliding entrance door, which only allowed e-entry with the unlock button separate from the handle (別体型). The version that includes the button in the handle can directly connect to the WiFi, but the separate can't. So we added the interphone plan (ｲﾝﾀｰﾎﾝﾌﾟﾗﾝ), which connects the door to the interphone. Since the interphone is connected to the internet, this means that the door can be opened and closed remotely (useful if someone gets home but forgot their keys). I believe this option required the intercom upgrade to work, or maybe it works without, but then the door can only be opened from the intercom (and not from online).

This feature was important for us, as sometimes we forget something, run back to get it, then wonder if we locked the door or not. With this setup, we will be able to check it remotely and even lock the door if we forgot.

### Electric honeycomb shades (10,000 yen per shade)

Ichijo offers honeycomb shades for their windows, and one can upgrade them to be operated by a small motor (instead of manually). These come with IR remote controllers, and no built-in smart functionality, so I plan to add an IR blaster to each room to control these automatically (e.g. lower them when the sun goes down, raise them when the morning alarm goes off).

### Miele dishwasher

We [are getting a custom kitchen]({% post_url 2025-04-12-custom-kitchen-with-ichijo %}) from [WoodOne](https://www.woodone.co.jp/), which will include [this large, front-open dishwasher from Miele](https://www.miele.co.jp/domestic/dishwashers-2510.htm?mat=12514180&name=G_7604_C_SCU_AutoDos). This comes with Miele's own [mobile app](https://www.miele.co.jp/domestic/miele-app-4253.htm) and also has two HomeAssistant integrations: [home-assistant-miele](https://github.com/HomeAssistant-Mods/home-assistant-miele) and [astrandb/miele](https://github.com/astrandb/miele).

I don't yet have any plans on how to use this, but let's see.


## Summary

So these are the smart home options that we decided to add to our house. I will post a follow-up write-up after we moved in and configured all of these, but that will likely be next year.
