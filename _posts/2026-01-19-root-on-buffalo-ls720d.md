---
layout: post
title: "How to get root access to a Buffalo LS720D NAS"
tags: tech
---

I recently got myself a Buffalo LS720D NAS, [thanks to furusato nozei](https://www.furusato-tax.jp/product/detail/23100/5775685). I looked into how to get root access to it, and it seems like an older method still works now.

<!--break-->

The exact model is Buffalo LS720DE4E (LS720D) running the currently latest firmware (2.02-0.13).

The steps are simple:

1. Download [acp_commander.jar](https://github.com/1000001101000/acp-commander/blob/master/acp_commander.jar) from [this fork](https://github.com/1000001101000/acp-commander/) (this is [more maintained than the original](https://github.com/Stonie/acp-commander/issues/2#issuecomment-557159353))

2. Run the jar to get a shell:

  ```shell
  java -jar acp_commander.jar -t <IP of the NAS> -m <MAC of the NAS> -pw <admin web password> -s
  ```

  It gives you a root shell:
  
  ```shell
  Welcome to ACP Commander v0.6 (2021), the tool for Buffalo stock firmware control!

  Using MAC: <redacted>
  Enter commands to device, enter 'exit' to leave
  />id
  uid=0(root) gid=0(root) groups=0(root)
  />ls -la /mnt/array1
  total 8
  drwxr-xr-x 10 root root  196 Jan 17 13:23 .
  drwxrwxrwx 12 root root 4096 Jan 16 11:21 ..
  drwxrwxrwx  4 root root   63 Jan 17 13:24 backup
  drwxrwxrwx 14 root root 4096 Jan 17 13:51 photos
  drwxrwxrwx  2 root root    6 Jan  5 16:48 share
  />
  ```

According to other guides, the MAC address is optional, but I got `SocketTimeoutException` without specifying that.

Persistent root access is more difficult. [This blogpost](https://qiita.com/tsukasa-koizumi/items/38a34e2440ddd577ae6d) describes the steps of enabling the ssh service and adding your ssh public key to the trusted keys, but it concludes that on restart all the system files (including ssh config) get reverted, so you have to redo it. It recommends placing a script doing the ssh setup into a folder on the NAS, then running that via the java call after a restart.

I have seen some other guides that would patch the update to include these changes, but then you can't easily update to newer firmware versions. So for now I'm okay to use this method to get a shell if I need to.
