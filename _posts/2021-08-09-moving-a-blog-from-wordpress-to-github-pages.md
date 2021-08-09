---
layout: post
title: Moving a blog from Wordpress to Github pages
tags: tech
---

This blog is hosted on Github pages, which I end up liking a lot, so I decided to move my other blog (originally hosted on Wordpress) too. I was already planning to update the domain of that blog, so I took the opportunity to do both at the same time. Here are the steps I did.

<!--break-->

The original, self-hosted Wordpress blog was on [https://japan.szabo-simon.hu](https://japan.szabo-simon.hu), that I wanted to move to [https://hu.szabo.jp](https://hu.szabo.jp). So first I setup a new Github pages repo with that domain and the basic style files.

Then I followed this guide to get the posts and Wordpress-hosted images over: [https://www.deadlyfingers.net/code/migrating-from-wordpress-to-github-pages](https://www.deadlyfingers.net/code/migrating-from-wordpress-to-github-pages). I kept the posts html, and didn't convert them to md, as html worked already.

### Migrating Google Photos

I had a lot of photos sourced from Google Photos public albums (one album per post) added to the post using [this addon](https://wordpress.org/plugins/embed-google-photos-album-easily/). Getting them over was a bit tricky and I ended up writing a script for it, then run it in a docker container:

```
docker run --rm -v $(pwd):/srv -u 0:0 -it wernight/phantomjs /bin/bash
```

I had to install https://github.com/lefuturiste/google-photos-album-crawler like this:

```
apt update
apt install npm -y
cd /root
mdkir abc
cd abc
npm install scrape-google-photos
```

Then run this script:

```
cd /srv/_posts/
for file in $(find -type f -name '*.html'); do
  echo "> Working with $file"; 
  if (grep -Po '\[embed-google-photos-album link="([^"]*)"[^\]]*\]' $file); then
    # Add gallery
    sed -i 's/status: publish/status: publish\ngallery: true/' $file
    link=$(grep -Po '\[embed-google-photos-album link="([^"]*)"[^\]]*\]' $file | grep -Po 'https://photos.app.goo.gl/[^"]+')
    echo "Google album link $link"
    mkdir /srv/assets/$file
    var=1
    for photo in $(/root/abc/node_modules/scrape-google-photos/index.js $link | grep -Po "https://lh3.googleusercontent.com[^']+"); do
      echo $photo
      wget -O /srv/assets/$file/$var.jpg $photo=w1920-h1080
      var=$((var + 1))
    done
  fi
done
```

This added `gallery: true` tag to the posts, grabbed all images from the albums and placed them into separate folders under `assets/` named the same as the posts. The `gallery: true` tag was already configured to make jekyll pick up the images from the folder named the same as the post.

Somehow this resulted in a lot of duplicate photos, so I had to remove them ([code from SO](https://superuser.com/a/386209/768525)):

```
declare -A arr
shopt -s globstar
arr=()

for file in **; do
  [[ -f "$file" ]] || continue
   
  read cksm _ < <(md5sum "$file")
  if ((arr[$cksm]++)); then 
    rm $file
  fi
done
```

### Re-embed YouTube videos

Then I had to fix embedded YouTube videos, as they ended up being something like:

```
<p><!-- wp:embed {"url":"https://www.youtube.com/watch?v=U0CL-ZSuCrQ","type":"video","providerNameSlug":"youtube","responsive":true,"className":"wp-embed-aspect-16-9 wp-has-aspect-ratio"} --></p>
<figure class="wp-block-embed is-type-video is-provider-youtube wp-block-embed-youtube wp-embed-aspect-16-9 wp-has-aspect-ratio">
<div class="wp-block-embed__wrapper">
https://www.youtube.com/watch?v=U0CL-ZSuCrQ
</div>
</figure>
<p><!-- /wp:embed --></p>
```

Sometimes the YouTube URL was like [https://youtu.be/Dd7FeNkoVjI](https://youtu.be/Dd7FeNkoVjI), which had to be handled too. So I did a global search and replace (with VS Code's built-in tool) from 

```
<div class="wp-block-embed__wrapper">\n(?:https://www.youtube.com/watch\?v=(\S+)|https://youtu.be/(\S+))\n</div>
```
 
to

```
<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/$1$2" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
```

### Make links relative

Next was all the links between posts, which were all absolute (like [https://japan.szabo-simon.hu/2021/05/04/biwaichi-biciklivel-a-biwa-to-korul/](https://japan.szabo-simon.hu/2021/05/04/biwaichi-biciklivel-a-biwa-to-korul/)) and as I was updating the domain, I had to update these too. I decided to use this opportunity to also make them relative (e.g. [/2021/05/04/biwaichi-biciklivel-a-biwa-to-korul/](/2021/05/04/biwaichi-biciklivel-a-biwa-to-korul/)) with this regex search and replace:

```
https://japan.szabo-simon.hu([^"]+/)"
```

to

```
$1"
```

### Setup redirect to keep old links working

Last step was to add an automatic redirect to the old site via `.htaccess` in the site's root:

```
Redirect 301 / https://hu.szabo.jp/
```

This keeps the path on redirect, and since the export tool saved the paths for the posts, all the old links still work.
