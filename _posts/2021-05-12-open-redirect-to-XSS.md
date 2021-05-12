---
layout: post
title: Open-redirect to XSS
tags: security
---

[Open redirects](https://cheatsheetseries.owasp.org/cheatsheets/Unvalidated_Redirects_and_Forwards_Cheat_Sheet.html) are generally treated as a low risk issue, due to the limited impact (more convincing phishing). However in certain cases a simple open redirect vulnerability can lead to reflected XSS, which I'll talk about in this post.

Redirecting in a browser can happen in two ways:

1. The browser gets a [30x HTTP response code](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#3xx_redirection) (e.g. `302 Found`) with the destination of the redirect in the [`Location` header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Location)
2. The JavaScript running on a site does the redirect by e.g. `window.location.href='https://example.com'` or
 `window.location.assign('https://example.com');` or `window.location.replace('https://example.com');`

If an open redirect vulnerability exist with the second type of redirect, it might be an XSS as well using the [`javascript:` pseudo-protocol](https://stackoverflow.com/questions/2321469/when-do-i-need-to-specify-the-javascript-protocol). E.g. the following JavaScript code will pop up an alert:

```
url = "javascript:alert(document.domain)"; // coming from the user in real life
window.location.href= url;
```

[Demo](https://jsfiddle.net/MarkSzs/zedqtk75/2/)

Another great thing about this is that no redirect happens, so the injected JavaScript executes in the context of the current page (see `document.domain` from the `alert`), so it has access to the site the same way a normal XSS has.

## Catch 1: Redirect doesn't happen immediately

Consider the following JavaScript  code:

```
url = ""; // coming from the user

if(!url.startsWith("https://example.com")) {
	window.location.href = "https://example.com";
}

window.location.href= url;
```

If the url doesn't start with `https://example.com`, then we redirect to the main page; otherwise redirect to the url. However the  redirect only happens after the JavaScript finished running, so the same attack still works: [Demo](https://jsfiddle.net/MarkSzs/ts5ghokx/1/).

## Catch 2: Bypassing hostname checks

Sometimes to prevent open redirect the app checks if the URL points to a trusted hostname. Considering the [numerous filter bypass techniques](https://book.hacktricks.xyz/pentesting-web/open-redirect) the general recommendation is to use a URL parser and check directly for the hostname, instead of trying to do some regex matching.

For example consider the following php code:

```
<?php

$url = $_GET["u"];

if(parse_url($url, PHP_URL_HOST) === "example.com" ) {
    echo "<script>window.location.href = '" . htmlspecialchars($url, ENT_QUOTES) . "';</script>";
} else {
    echo "<script>window.location.href = 'https://example.com';</script>";
}
```

[Demo](https://3v4l.org/PU24n).

This takes the URL from a GET parameter, parses it using the [built-in `parse_url()` function](https://www.php.net/manual/en/function.parse-url.php) and redirects the user to it if the hostname is `example.com`. Otherwise the user is sent to the hardcoded main page.

So on first look this doesn't even look like an open redirect. However `parse_url()` accepts anything for protocol, as long as the string looks like a URL. So `javascript://example.com/path` will be parsed into the hostname of `example.com`. However when this is injected, everything after `javascript:` is interpreted as JavaScript, namely: `//example.com/path`, which is entirely a comment in JavaScript. Fortunately we can inject a URL encoded new-line (`%0a`) to end the comment and add arbitrary JavaScript code:

```
javascript://example.com/path%0aalert(document.domain)
```

This affects other URL parsers, for example Golang (based on [gobyexample.com](https://gobyexample.com/url-parsing)):

```
package main

import (
	"fmt"
	"net/url"
)

func main() {
	s := "javascript://example.com/path%0aalert(document.domain)"
	u, err := url.Parse(s)
	if err != nil {
		panic(err)
	}
	fmt.Println(u.Host)
}
```

[Demo](https://play.golang.org/p/M6vu7UBcryx)

Or Java (based on [this thread](https://stackoverflow.com/questions/9607903/get-domain-name-from-given-url)):

```
import java.net.URI;

public class Main
{
	public static void main(String[] args) {
	    try {
    	    URI uri = new URI("javascript://example.com/path%0aalert(document.domain)");
	    	System.out.println(uri.getHost());
	    } catch(Exception e) {
	        System.out.println(e);
	    }
	}
}
```


[Demo](https://onlinegdb.com/r2z9XNmJ_)
