---
layout: post
title: "Testing the Panasonic Advance Series Link Plus smart light switches"
tags: tech japan housing
---

We are building a house, and I recently [looked into smart lighting and light switches]({% post_url 2024-07-28-smart-lights-overview %}) concluding that the best option for us is likely Panasonic's [Advance Series Link Plus](https://www2.panasonic.biz/jp/densetsu/haisen/switch_concent/advance/lineup/linkplus/) switches (アドバンスシリーズ リンクプラス). I got my hands on two of the switches and in this post I'll share what I learned from testing them out.

<!--break-->

## Getting the switches

As in the previous post it became clear, smart switches are expensive. So before dropping the price of 2 iPhones on this, I wanted to make sure that it will work as I expect it to. We called the Tokyo Panasonic Showroom and asked if they had this line up, but they told us that none of the showrooms in Tokyo had any light switches. I also checked in Yodobashi Camera's website and while they sell them, they also don't have them in any of there stores in Tokyo.

So the only option I had left was to buy some of the switches, set them up at home and see how well they work. So that's what I did. I bought these specific models:

* [WTY2401W](https://www14.arrow.mew.co.jp/scvb/a2A/opnItemList?s_hinban_key=WTY2401W&search_kbn=0) - [single switch, 3-4 wire](https://www2.panasonic.biz/jp/densetsu/haisen/switch_concent/advance/lineup/linkplus/3wire_handle/) (this takes a ground wire to the switch, while they also have a 2 wire option which doesn't)
* [WTY22473W](https://www14.arrow.mew.co.jp/scvb/a2A/opnItemList?s_hinban_key=WTY22473W&search_kbn=0) - [dimmer switch, 2 wire](https://www2.panasonic.biz/jp/densetsu/haisen/switch_concent/advance/lineup/linkplus/2wire_rotary/) (there was no 3-4 wire option)
* [WTY2001](https://www14.arrow.mew.co.jp/scvb/a2A/opnItemList?s_hinban_key=WTY2001&search_kbn=0) - [Link Plus Wireless Adapter](https://www2.panasonic.biz/jp/densetsu/haisen/switch_concent/advance/lineup/linkplus/wireless_adapter/) (リンクプラス用無線アダプタ). The switches themselves only have bluetooth, so to connect them to the internet (and HomeAssistant), we need this adapter (but the switches and the adapter actually communicate over 920MHz radio not Bluetooth AFAIK). 

I also bought two lights, switch plates (in matte gray and white, the two colors we are considering), and two tupperware boxes as frames.

![Stuff I started with](/assets/2024-11-10-panasonic-advance-series-link-plus/1-start.jpg#lb)

## The physical setup

So first I had to prepare the box. I ended up using my soldering kit to cut a hole in the top of the box.

![Cutting a hole in the top of the box](/assets/2024-11-10-panasonic-advance-series-link-plus/2-preparing-the-box.jpg#lb)

Once the box was ready, I had to figure out which wire was the ground and the phase. First I marked the socket to ensure I will always plug it back the same way, then used [this voltage detector](https://www.amazon.co.jp/dp/B0B292F21Q) to find  the wire with the phase, and marked that too.

Then I looked up the wiring diagram for the switch and connected the wires accordingly (there was a small button inside the switch and pressing that with a screw driver the wire slid in easily).

![Looking up the wiring diagram](/assets/2024-11-10-panasonic-advance-series-link-plus/3-connection.jpg#lb)

![Pressing the hidden button with a screw driver](/assets/2024-11-10-panasonic-advance-series-link-plus/4-connecting.jpg#lb)

Attached the switch plates, and I was done:

![The assembled switches](/assets/2024-11-10-panasonic-advance-series-link-plus/5-full-setup.jpg#lb)

## Connecting the smart

Once the wiring was done, I had to connect the switches to the phone and then to the wireless adapter.[スイッチアプリ](https://play.google.com/store/apps/details?id=com.panasonic.jp.ls.pbu.linkplus&hl=en) is the app to do this. The app is really designed with a single workflow in mind: electricians build the house, connect all switches, then handover the setup to the owner of the house. Adding additional switches later is not really possible. Moreover somehow the switches connect to each other, and the phone only connects to one of them, which further complicated setting it up.

After a few hours of fight I got it to work. I don't really have any advice, other than if you want to add any additional device, it is better to reset the app and the switches, and just add everything from the beginning all at once, as that seem to be the main/only supported flow.

There was one more surprise: I was setting up the Link Plus Wireless Adapter (リンクプラス用無線アダプタ), but it didn't want to connect to the WiFi. Moreover the setup never asked me for the WiFi password, it just told me that the adapter failed to connect to the network. I had the [user manual](https://www2.panasonic.biz/ideacontout/2023/04/11/2023041100220037.PDF) in front of me, but still it took me a while to find the issue:

![Not so wireless](/assets/2024-11-10-panasonic-advance-series-link-plus/6-not-so-wireless.jpg#lb)

So the wireless adapter needs wired connection to the LAN, it is only wireless on the other side (towards the switches). Once I plugged in the LAN cord, it showed up on the network. It had a site on port 80 where one could turn the switches on/off and even update the software on the switches. The update required pressing a button on the adapter, but otherwise there was no authentication, so anyone on the network could reach it.

Later this website went away, but the adapter was still reachable via the EchonetLite protocol, which also lacks any authentication. (I really need to set up a separate guest wifi, or move all IoT stuff to a  dedicated network.)

## Home Assistant setup

I use [Home Assistant](https://www.home-assistant.io/) as my smart home platform. The Link Plus Adapter speaks the EchonetLite protocol (which is heavily used in Japan). Luckily there is a community-developed module to connect EchonetLite devices to Home Assistant named [echonetlite_homeassistant](https://github.com/scottyphillips/echonetlite_homeassistant). (There is also [echonetlite2mqtt](https://github.com/banban525/echonetlite2mqtt) in case the first doesn't work.)

After adding this using [HACS](https://www.hacs.xyz/) and pointing it to the IP of the adapter it worked (it could have done discovery too, but I had the IP handy). Without any auth both switches showed up in Home  Assistant:

![Home Assistant Dashboard - 照明1 and 照明2 are the switches, the rest is about the adapter](/assets/2024-11-10-panasonic-advance-series-link-plus/7-ha-dashboard.jpg#lb)

## Testing the dimmer switch

So after the setup worked, I wanted to see what is the delay between Home Assistant and the actual switch. Here is my testing with the dimmer switch:

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/wY3IgIuArD8?si=G6Qibxdiro4dyXmX" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

Overall I found it to be very responsive.

It supports going from being off to going to a specific brightness (e.g. if it was 100% when turned off, then I can turn it on at 10% brightness), however it turns on first as usual (with the previous brightness) then adjusts it quickly. In practice there is a short fade-in effect when turning on anyway, which makes this issue less noticeable, so I don't think it would be an issue in real life. (The use-case I'm thinking here is that when the light turns on in the middle of the night it should go to low brightness automatically.)

For the dimmer switch I used a simple, dimmable LED bulb (the cheapest I could get from Amazon).

## Testing a smart bulb

The dimmer works well, but it doesn't allow changing the color. Also it's more expensive than the normal switch, so I was thinking of adding a smart bulb to the normal smart switch and controlling the brightness and color based on time of day (or via additional smart buttons). To test this I connected a ZigBee bulb from IKEA to the switch. (I have a CONBEE II adapter with Phoscon-GW running alongside Home Assistant.) 

The bulb adds a slight delay when turning on, but otherwise works well.

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/64OXW3BYHvA?si=bB-gjt1KiP2POgmx" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

When turning on, the bulb immediately shows up in Home Assistant, so we can trigger on that even and adjust the brightness. However when turning off it takes a while until Home Assistant realizes that the bulb is off, so when turning off and on quickly, the automation won't trigger on either off or on event (as Home Assistant misses them both). I think I could work around this by triggering on the switch turning on and off, as that even is registered immediately.

Here is a test of triggering on the ON event: the light was at 100% when it was turned off, and I configured an automation that when the light bulb is turned on, set its brightness to 1%:

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/2kDgjVxkLUM?si=MzersZHA5JM1SaqU" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

It is almost instant with a very short flash.

## Conclusion

Despite the user un-friendliness of the setup, overall I really like the switches. They connected to Home Assistant without issues and they are pretty responsive (both to update their state and also to respond to action). The dimmer switch is nice for places where a physical dimmer makes sense (my wife already said that she would like that in a few places), but for everywhere else we'll likely go with the normal switch and make the lights smart to control brightness and color.

In the bedrooms we will have the common ceiling light that come with an infrared remote controller (for brightness and color). With the smart switch I think I can automate sending the IR signal after the light is turned on (to have it default to low brightness during the night, and full brightness during the day).
