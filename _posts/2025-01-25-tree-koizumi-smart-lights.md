---
layout: post
title: "TRee: Koizumi's smart light system"
tags: tech japan housing
---

We are building a house, and I recently [looked into smart lighting and light switches]({% post_url 2024-07-28-smart-lights-overview %}) concluding that the best option for us was likely Panasonic's Advance Series Link Plus, which later [I did a deep-dive on]({% post_url 2024-11-10-panasonic-advance-series-link-plus %}). Then we started looking at the actual lights to see what fits with our design, and found Panasonic's offerings underwhelming. This made us look at other manufacturers, namely Koizumi and Odelic. They both have smart lights, so I will share what I learned about each, started with Koizumi.

<!--break-->

## The system: TRee

Koizumi's smart lighting solution is called [TRee](https://www.koizumi-lt.co.jp/product/jyutaku/tree/) (good luck trying to search it). It's a pretty usual system: smart switches, smart lights, and hubs. They have a wired and a wireless setup each with their own set of switches (which doesn't seem to be cross-compatible due to the different connection to the hub).

In the wired setup the hub is called Smart Adapter (スマートアダプタ, AE49233E):

![The wired setup from https://www.koizumi-lt.co.jp/product/jyutaku/tree/](/assets/2025-01-25-tree-koizumi-smart-lights/wired.png#lb)

In the wireless setup the hub is called Smart Bridge (スマートブリッジ, AE50264E), and despite its wireless nature, it still needs an Ethernet cable to connect to the network (similar to Panasonic's solution).

![The wireless setup from https://www.koizumi-lt.co.jp/product/jyutaku/tree/](/assets/2025-01-25-tree-koizumi-smart-lights/wireless.png#lb)

I asked Koizumi what the difference is between these two systems, and they said there is no difference:

> スマートブリッジ（AE50264E）とスマートアダプタ（AE49233E)は TReeシステムを使用する上で違いはございません

## Wireless switches

### Light Controller ライトコントローラ

These look like regular switches, but all of them are touch type (which made us not even consider them as we want real switches).

![The 3 types of Light Controllers. They are also available in black](/assets/2025-01-25-tree-koizumi-smart-lights/light-controllers.png#lb)

* [AE50267E](https://www.lightstyle.jp/?cn=100026&shc=10106146): white, on/off (same in black: [AE50270E](https://www.lightstyle.jp/?cn=100026&shc=10106149))
* [AE50268E](https://www.lightstyle.jp/?cn=100026&shc=10106147): white, dimmable (same in black: [AE50271E](https://www.lightstyle.jp/?cn=100026&shc=10106150))
* [AE50269E](https://www.lightstyle.jp/?cn=100026&shc=10106148): white, dimmable (same in black: [AE50272E](https://www.lightstyle.jp/?cn=100026&shc=10106151))

### Memory Light Controller メモリーライトコントローラ 

These look even less like switches.

![The Memory Light Controller](/assets/2025-01-25-tree-koizumi-smart-lights/memory-light-controllers.png#lb)

[AE50265E](https://webcatalog.koizumi-lt.co.jp/kensaku/item/detail/id/5092730000) ([shop](https://www.lightstyle.jp/?cn=100026&shc=10106144)) (same in black: [AE50266E](https://www.lightstyle.jp/?cn=100026&shc=10106145))

## Wired switches

### Smart Switch スマートスイッチ

Seems like it’s only available in a single version: white and one button: [AE49235E](https://webcatalog.koizumi-lt.co.jp/kensaku/item/detail/id/4544440000)

![The Smart Switch](/assets/2025-01-25-tree-koizumi-smart-lights/smart-switch.jpg#lb)

### Memory Light Controller メモリーライトコントローラ 

Multi-button panel like the other memory light controller. Only one option [AE49236E](https://webcatalog.koizumi-lt.co.jp/kensaku/item/detail/id/4544450000#!cursor=13116128&view=list).

![The wired Memory Light Controller](/assets/2025-01-25-tree-koizumi-smart-lights/wired-memory-light-controller.jpg#lb)

## Smart lights

They have many smart lights, so I'll just pick one example, a spot light meant to be on rails ([AS56297](https://webcatalog.koizumi-lt.co.jp/kensaku/item/detail?itemid=AS56297)):

![AS56297 スポットライト](/assets/2025-01-25-tree-koizumi-smart-lights/spotlight.jpg#lb)

The interesting thing is that the light itself seem to have Bluetooth and allows adjusting not just the brightness but also the color temperature. I wonder if this is compatible with one of the dimmer switches (out of the 2 light controllers). The first says 調光タイプ(逆位相制御方式), which is the usual dimmer switch (and thus likely incompatible with smart lights like this), but the other type says [Fit調色タイプ](https://www.koizumi-lt.co.jp/product/jyutaku/fitcolor/) which might be a more likely to work with some lights, although this specific light doesn't mention Fit調色 on its page.

## ECHONET Lite and Home Assistant support

TRee's website says that [the system support ECHONET Lite](https://www.koizumi-lt.co.jp/product/jyutaku/tree/hems.html) and the [echonetlite_homeassistant](https://github.com/scottyphillips/echonetlite_homeassistant) lists the smart bridge (AE50264E) as a supported device.

## Asking Koizumi support

Unfortunately the [Koizumi showroom](https://www.koizumi-lt.co.jp/showroom/tokyo.html) is mainly aimed at companies, and is only open on weekdays, so I couldn't visit. But they have an [online form for product questions](https://www.koizumi-lt.co.jp/form/seihin/) that I submitted. Here are my questions and their answers:

|Topic|Japanese|English|
|---|---|---|
|Hubs|スマートブリッジ（AE50264E）とスマートアダプタ（AE49233E)にはどのような違いがありますか？採用する場合はどちらも必要か、それともどちらか一つで良いでしょうか？|What’s the difference between スマートブリッジ (AE50264E) and スマートアダプタ (AE49233E)? Do we need both or is one of them enough?|
||スマートブリッジ（AE50264E）とスマートアダプタ（AE49233E)はTReeシステムを使用する上で違いはございません。<br>但し、スマートブリッジ（AE50264E）は「ライトコントローラ」と無線接続を行う必要が有るので、「ライトコントローラ」の近くに設置頂く必要がございます。|There is no difference between the Smart Bridge (AE50264E) and the Smart Adapter (AE49233E) when using the TRee system. <br>However, the Smart Bridge (AE50264E) needs to connect wirelessly to the "Light Controller", so it needs to be installed near the "Light Controller".|
|Smart switch|スマートスイッチ (AE49235E) は、他社製の照明と互換性があり連動しますか？また、スマートスイッチは「ライトコントローラー」とどのように違いますか？スマートスイッチには、ダイヤルスイッチやダブルスイッチなどの選択肢もありますか？|Is the スマートスイッチ (AE49235E) compatible with lights made by other companies? How is this switch different from ライトコントローラ? Is it available in any other form (e.g. dimmable, double) or color?|
||スマートスイッチ (AE49235E)は、弊社の適合する照明器具としか使用出来ず、他社製照明器具との適合確認は行っておりません。スマートスイッチ (AE49235E)は、照明器具のON/OFFしか出来ません。|The Smart Switch (AE49235E) can only be used with lighting fixtures that are compatible with our company, and we have not confirmed compatibility with lighting fixtures made by other companies. The Smart Switch (AE49235E) can only turn lighting fixtures on and off.|
|Light controller|ライトコントローラ (AE50267E, AE50268E, AE50269E) は、他社製の照明と互換性があり、連動しますか？また、スイッチのボタンはすべて「タッチ式」で、それ以外はないのでしょうか？|Are the ライトコントローラ (AE50267E, AE50268E, AE50269E) compatible with lights made by other companies? Do they have a non-touch version with a normal button?|
||ライトコントローラ (AE50267E, AE50268E, AE50269E) も、弊社の適合する照明器具としか使用出来ず、他社製照明器具との適合確認は行っておりません。全て操作はタッチ式になります。|The light controllers (AE50267E, AE50268E, AE50269E) can only be used with lighting fixtures that are compatible with our company, and we have not confirmed compatibility with lighting fixtures made by other companies. All operations are touch-type.|
|Memory light controller|メモリーライトコントローラ (AE50265E) は、他社製の照明と互換性があり、連動しますか？|Are the メモリーライトコントローラ (AE50265E) compatible with lights made by other companies?|
||メモリーライトコントローラ (AE50265E) も、弊社の適合する照明器具としか使用出来ず、他社製照明器具との適合確認は行っておりません。|The Memory Light Controller (AE50265E) can only be used with lighting fixtures that are compatible with our company, and we have not confirmed compatibility with lighting fixtures made by other manufacturers.|
|Smart lights|御社のスマートライトは、他社製のスイッチ（Panasonicのスイッチなど）と連動しますか？例えば、他社製の照明スイッチに接続されたダクトレールに、Koizumiのスポットライト（AS56297）を設置した場合、TReeアプリやGooglehomeを使って照明の調整が可能ですか？|Are the smart lights compatible with switches made by other companies? E.g. if I add  AS56297 (duck rail spot light) to a rail that’s connected to a normal light switch made by another company, can I use the TRee app and Google Home to adjust the brightness and color of the light?|
||スポットライト（AS56297）は、通常のON/OFFスイッチにしか組合せ出来ませんが、ON/OFFスイッチであれば他メーカーのスイッチでも問題ございません。別売のBluetooth対応スマートブリッジ【AE54355E】と「TRee plus」で設定頂く事で、Googlehomeで音声操作頂く事が可能です。|The spotlight (AS56297) can only be paired with a regular ON/OFF switch, but other manufacturers' ON/OFF switches are also fine. By setting up the separately sold Bluetooth-enabled smart bridge [AE54355E] and "TRee plus", you can control it with your voice using Google Home.|
|When the WiFi or hub is down|スマートブリッジやWifiが動かない時でも、スマートスイッチ、ライトコントローラー、 メモリーライトコントローラは、普通のスイッチとして、照明をつけたり消したりできますか？|Do the スマートスイッチ, ライトコントローラ, メモリーライトコントローラ still work if the hub or WiFi is not working? Will pressing the button turn on/off the light?|
||スマートブリッジやWiFiが動かない場合でも、スマートスイッチ・ライトコントローラ・メモリライトコントローラで手動操作は可能です。|Even if the Smart Bridge or WiFi doesn't work, you can still operate it manually using the Smart Switch, Light Controller, and Memory Light Controller.|

### Deprecation notice

At the end of their email they added this additional note:

> なお、スマートブリッジ（AE50264E）ライトコントローラ (AE50267E, AE50268E, AE50269E)メモリーライトコントローラ (AE50265E)につきましては、すべて生産完了品になります。
>
> 現行製品はBluetooth対応器具となっており、それぞれの後継品は下記となります。
>
> * スマートブリッジ（AE50264E）→【AE54355E】
> * ライトコントローラ (AE50267E）→【AE54345E】（AE50268E）→【AE54344E】（AE50269E) →【AE54343E】
> * メモリーライトコントローラ（AE50265E）→【AE54341E】
>
> になります。
>
> Bluetooth版TReeシステムにつきましては、以下URL　WEBカタログ内の、「照明制御システム（ツリー）Bluetooth対応　ライトコントローラー　2023年10月 価格改訂版」をご確認いただきますようお願いいたします。
>
> URL：https://www.koizumi-lt.co.jp/product/webcatalog/index.html

Translated:

> Please note that the Smart Bridge (AE50264E), Light Controller (AE50267E, AE50268E, AE50269E), and Memory Light Controller (AE50265E) are all discontinued products.
>
> The current products are Bluetooth-compatible devices, and their successors are as follows.
>
> * Smart Bridge (AE50264E) → [AE54355E]
> * Light Controller (AE50267E) → [AE54345E] (AE50268E) → [AE54344E] (AE50269E) → [AE54343E]
> * Memory Light Controller (AE50265E) → [AE54341E]
>
> For details about the Bluetooth version of the TRee system, please see the "Lighting Control System (Tree) Bluetooth-Compatible Light Controller October 2023 Price Revised Edition" in the web catalog at the following URL.
>
> URL: https://www.koizumi-lt.co.jp/product/webcatalog/index.html

## My conclusion

For us having physical buttons (non touch types) was important, which already disqualified most of the Koizumi's offerings.

Moreover their system is a overcomplicated:

* wired and wireless being supported in parallel
* [old system using zigbee](https://www.koizumi-lt.co.jp/support/question/faq_tree_zigbee.html) while the [new is using bluetooth](https://www.koizumi-lt.co.jp/support/question/faq_tree.html)
* even their [own main marketing page](https://www.koizumi-lt.co.jp/product/jyutaku/tree/) is showing model numbers that customer service is saying are discontinued

which combined with their higher price point than Panasonic and no clear benefit that I could see mean that I would recommend Panasonic's Advance Series Link Plus to most people and I won't be looking deeper into Koizumi's smart switches. 

We might still choose some smart lights from Koizumi and use their hub to control them remotely (which they confirmed should work with switches from another company), but we won't be using their smart switches.
