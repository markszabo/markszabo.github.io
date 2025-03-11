---
layout: post
title: "Using e-Tax from a non-supported browser"
tags: japan money tax
---

Japan's online tax filing system, [e-Tax](https://www.e-tax.nta.go.jp/), only supports a [handful of operating systems and browsers](https://www.e-tax.nta.go.jp/e-taxsoftweb/e-taxsoftweb1.htm):

* Windows 10 or 11 with either Microsoft Edge or Google Chrome
* MacOS 12-15 with Safari

(Moreover officially the operating system has to be set to Japanese, though I don't think they check this one.)

<!--break-->

If you are coming from a non-supported configuration, then e-Tax refuses to start at all and simply displays an error message.

![You shall not pass](/assets/2025-03-11-etax-browser-check-bypass/01-unsupported-browser.png#lb)

This is an issue. I use a Chromebook as my daily driver, which is entirely unsupported, together with any Linux box. Moreover on MacOS one has to use Safari and can't use Chrome, even though the latter has better website translation feature.

Fortunately the check happens only once in the beginning of the flow, and it is done entirely on the client side. This means that it is fairly easy to bypass it and make the site believe that it is running in a supported environment.

**WARNING**: doing so goes against the intentions of the website developers and means that you will be using a setup that wasn't tested. While modern browsers behave almost the same (and especially Chrome on Windows is very similar to Chrome on other platforms) there can still be cases that won't work as expected. Proceed at your own risk.

When one clicks on the start button, the following happens:
1. The site checks if the browser is supported
2. If not, the message is shown. If yes, the flow starts

To bypass the check, we will stop between these two steps and change the result to say that the browser is supported. To do this we need to:

1. Go to the site that displays the error message
2. Right click on the site, select `Inspect` to open the DevTools
3. Go to the `Sources` tab
4. Press `Ctrl + F` to open the search
5. Search for `browser`. It should find a code snippet like this:

  ![We will put a breakpoint here](/assets/2025-03-11-etax-browser-check-bypass/02-breakpoint.png#lb)
  
  The full line is
  
  ```javascript
  let returninfo = termnalInfomationCheckOS_myNumberLinkage(qrCodeReadingFlag, osType, recommendedOsAsEtax, recommendedBrowserAsEtax);
  ```
6. Click on the line number to place a breakpoint here. This  will make the browser stop the execution whenever this line is to be executed.
7. On the site, press the button again
8. The breakpoint will be hit and the execution will pause
9. Switch over to the `Console` tab. Now we can see the values of the variables and we can also change them. From the code, we can see that the variable `returninfo` is the one holding the information about whether the browser is supported or not. Currently `returninfo.errcode` is `-1`. Let's set it to `0` (success) by running `returninfo.errcode = 0;` in the console

  ![Updating the variable](/assets/2025-03-11-etax-browser-check-bypass/03-update-the-variables.png#lb)
  
10. Continue the execution with the ▶️ button (might be in the top middle of the grayed-out page)
11. The flow should start as if the browser is a supported one
