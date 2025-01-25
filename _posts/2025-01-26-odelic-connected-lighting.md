---
layout: post
title: "Odelic Connected Lighting"
tags: tech japan housing
---

We are building a house, and I recently [looked into smart lighting and light switches]({% post_url 2024-07-28-smart-lights-overview %}) concluding that the best option for us was likely Panasonic's Advance Series Link Plus, which later [I did a deep-dive on]({% post_url 2024-11-10-panasonic-advance-series-link-plus %}). Then I took a look at [Koizumi's TRee system]({% post_url 2025-01-25-tree-koizumi-smart-lights %}), and now to finish up my investigation into Japanese smart lighting systems, I will share what I learned about [Odelic's Connected Lighting](https://www.odelic.co.jp/products/connectedlighting/home/).

<!--break-->

## The system

Unlike Panasonic's and Koizumi's setup, Odelic's Connected Lighting doesn't offer switches in the traditional sense (something that starts/stops the flow of electricity), instead the lights are meant to be  connected to power at all times and then remote controllers are used to turn them on or off (a bit similar to Phillips Hue). They do make some switch-like remote controllers though:

![Switch-looking controller with a joystick for brightness and color control (source: www.odelic.co.jp)](/assets/2025-01-26-odelic-connected-lighting/switch.png#lb)

Both the switches and the controllers use Bluetooth (presumably BLE).

The [FAQ](https://www.odelic.co.jp/products/connectedlighting/qa/) still recommends to have a real light switch as it is required for pairing or when the remote runs out of battery:

> Q.3 Bluetooth(無線)制御だからスイッチは 不要ですか？
>
> A.3 必ず壁スイッチを設置してください。 初回接続設定(器具登録)をおこなう時に、壁スイッチが必ず必要です。コントローラー(リモコン・タブレット・スマートフォン)の電池切れや故障の際の点灯に必要です。

I talked about why I prefer a system with real smart switches [in my first post on the topic]({% post_url 2024-07-28-smart-lights-overview %}), but due to that preference, these controllers won't change my choice for Panasonic's smart switches.

## Light options: excellent

Many of their lights are available in smart version and everything is part of this single system. Also they mark it very clearly in their catalog and in the showroom which light is smart. Moreover since the light itself is smart, almost all of them allow adjustment of not only the brightness but also the color temperature or color (full RGB range).

![My photo taken in the showroom showing some bracket lights and their connected version](/assets/2025-01-26-odelic-connected-lighting/lights.png#lb)

## Control options: mixed

Despite the system running on Bluetooth, the control options could be improved. 

### Remote controllers

The physical remote controllers seem to be working well (at least in the showroom they were fine, I didn't have the opportunity to do the pairing process though). Also they are available in multiple form-factors, which is pretty nice:

![The various controller options (source: www.odelic.co.jp)](/assets/2025-01-26-odelic-connected-lighting/controllers.png#lb)

I personally like the idea of having that joystick in the middle of the switch to control the brightness and color, while the top/bottom of the switch turns it on/off.

The touchless switch is pretty interesting too and worked as expected in the showroom:

![Touchless switch - just hold your hand in front of it](/assets/2025-01-26-odelic-connected-lighting/touchless-switch.jpg#lb)

These definitely feel like the main way how the designers thought about people using the system.

### Motion sensors

Odelic offers a few [motion sensors that also communicate via Bluetooth](https://www.odelic.co.jp/products/2019special/bluetooth_sensor/) so they can control the lights. I couldn't find these in the showroom, so I'm not sure how well they work.

### Smart phone

The site [lists controlling from smart phone](https://www.odelic.co.jp/products/connectedlighting/app/) with linking to both an [Android](https://play.google.com/store/apps/details?id=jp.co.odelic.smt.remote10&hl=en) and an [iOS](https://apps.apple.com/jp/app/connected-lighting-for-home%E7%B0%A1%E6%98%93%E7%89%88/id1169981880) app and highlighting the following feautres:

> お手持ちのスマートフォンをリモコンとして、調光・調色ができます。
>
> 5シーンまで登録設定ができます。
>
> 就寝前、お目覚め時のあかりをタイマー設定ができます。

Translation:

> You can use your smartphone as a remote control to adjust the brightness and color.
>
> Up to five scenes can be registered.
>
> You can set a timer for the lights before you go to sleep and when you wake up.

However their [FAQ](https://www.odelic.co.jp/products/connectedlighting/qa/) says the Connected lighting doesn't use the Internet, so it cannot be controlled from outside the home:

> Q.8 外出先から防犯のためにON/OFFしたいのですが、可能ですか？
>
> A.8 コネクテッドライティングはインターネットを使用していないため、外出先からの操作はできません。

So the app likely works with local Bluetooth only. I wonder if this could be a problem in bigger homes.

Also both apps have terrible ratings. Currently the Android app has 1.5 stars, and the iOS app has 1.7 starts (both out of 5, but 1 being the lowest it means most people gave it a 1).

### Voice control

Remember that there is no hub so the lights are not connected to the internet? This pretty much rules out any of the usual voice controls (Google Home, Alexa, etc.) (or so I thought, see later). Instead Odelic [made their own voice control device](https://www.odelic.co.jp/products/voicecontrol/):

![Bluetooth Voice Remote Controller - Good Design(?) (source: www.odelic.co.jp)](/assets/2025-01-26-odelic-connected-lighting/voice-control.png#lb)

I didn't have a chance to try it, but I found this official demo video:

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/mI3334lkeMo?si=o_g39Hg8qifvzMhm" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

Despite the video looking like someone's highschool project, the device looks pretty good. I wonder how well it really works in real life, and whether it works locally or connects to some server. Also there is no mention of supporting any language other than Japanese.

### Smart speaker control

Wait, doesn't the FAQ say that the lights don't connect to the internet so they can only be changed locally? Odelic came up with [a solution to make it work with smart speakers](https://www.odelic.co.jp/products/2019special/smart_speaker_control/): they will sell you a tablet to bridge the gap.

![Want smart speaker support? Buy our tablet (source: www.odelic.co.jp)](/assets/2025-01-26-odelic-connected-lighting/tablet.png#lb)

I tried this tablet in the showroom and it was a simple Lenovo tablet with a custom app running on it (though the tablet might not be the same than the one they are selling). I couldn't find the tablet from Odelic directly, but on [Rakuten](https://item.rakuten.co.jp/esco/rc913/) and [Amazon](https://www.amazon.co.jp/ODELIC-%E3%82%AA%E3%83%BC%E3%83%87%E3%83%AA%E3%83%83%E3%82%AF-CONNECTED-LIGHTING%E5%B0%82%E7%94%A8-Bluetooth%E5%AF%BE%E5%BF%9C/dp/B01IGQWPAC) it is being sold for around 57,000 yen.

There are actually 3 apps for the tablet: for home, for shop, and for office:

![The 3 types of apps - unclear if all come with the tablet, or only one](/assets/2025-01-26-odelic-connected-lighting/apps.png#lb)

The tablet in the showroom had the Home version, and it felt pretty utilitarian (lot of details, not much design or animations). Here is a photo of it that I took:

![My photo of the tablet in the showroom](/assets/2025-01-26-odelic-connected-lighting/showroom-tablet.png#lb)

The buttons worked as advertised, but there was no Google Home to test that integration with.

### ECHONET Lite and Home Assistant support

I couldn't find anything to this extent. Considering that without the tablet the lights are Bluetooth-only, I don't expect ECHONET Lite support. Though the tablet seem to be pulling data from other ECHONET Lite devices, so they might add support for it in the future.

I also couldn't find Home Assistant support yet, even though that could work via Bluetooth as well.

## Conclusion

We really loved the design of the Odelic lights, so we will likely get a few from them (and all of those will be the Connected Lighting version). I wish their software support would be better, and I'm hoping I can connect them to Home Assistant somehow, as without that we would need to buy their overprice remote controllers or tablet.

One more thing: the [Odelic showroom](https://www.odelic.co.jp/showroom/reserve.html) was great! It's a bit out of the way, but they had many lights (and the full fleet of smart controllers), the staff was helpful and ready to answer our questions, and they even had a playroom for kids.
