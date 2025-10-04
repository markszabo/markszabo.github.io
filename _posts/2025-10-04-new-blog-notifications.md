---
layout: post
title: "New notifications system on this blog"
tags: tech
---

I'm hosting this blog on GitHub Pages, but wanted to give readers the option to subscribe to new posts. I recently changed how this is done, and I will cover it in this post.

<!--break-->

## RSS

For tech-savy people, it was easy to offer an RSS feed: <https://szabo.jp/atom.xml>. I'm not sure if this came with Jekyll (the engine) or had to be configured, but was easy.

However I also wanted e-mail notifications.

## The easy way: use another service

First I decided to use a third-party service to manage the subscriptions and notifications: [follow.it](https://follow.it/). This was very easy for me to setup: just point it to the RSS feed I already had.

However recently I check the email they were sending out, and it had ads in it. Moreover instead of linking to my site directly, they were first linking to their own site (with more ads) and then that would link to my actual post. I see why they do this (they need money to run their service), but this wasn't providing the experience I wanted. So I decided to build my own.

![The link from the email included a lot of ads](/assets/2025-10-04-new-blog-notifications/old-email.png#lb)

## Building my own

I have an old-style (Apache, PHP, MySQL) webhosting that comes with some of my domains, so I decided to use that. With the help of ChatGPT I could easily put together the php site to manage the subscriptions, and send out the notifications on new posts. Then I used Claude to further refine it and published it on [https://github.com/markszabo/newsletter.szabo.jp](https://github.com/markszabo/newsletter.szabo.jp).

On a high-level it works like this: the site handles subscriptions (confirmation, unsubscribe functionality) using a table in a MySQL database. When the deploy workflow of this site runs, it triggers the `?action=send-digest` API. This looks at the RSS feed, checks if the last post was within 24 hours (to avoid resending an email if I simply modify an older post) and then sends the email for it to the confirmed subscriptions in the database. This does have the limitation of only a single post per 24 hours, and that I can't edit a post within the first 24 hours, but I can live with those.

If you are interested, you can see the code at [https://github.com/markszabo/newsletter.szabo.jp](https://github.com/markszabo/newsletter.szabo.jp) or sign-up on [https://newsletter.szabo.jp/](https://newsletter.szabo.jp/).

If you are already a subscriber, I migrated your email to the new system already, so no action is required.
