---
layout: post
title: Using LastPass on login forms with more than 2 inputs
date: 2021-05-10 17:55:00 +09:00
tags: tech
---

LastPass generally handles common login pages with a username and password well, but it breaks on login forms that have more than those two fields. But there is a solution.

## The problem

Here is the site I'll use as an example: the login page of the SMBC bank: [https://direct.smbc.co.jp/aib/aibgsjsw5001.jsp]

![](/assets/2021-05-10-using-lastpass-on-login-forms-with-more-than-2-inputs/problem.png)

The first line gives 2 options for identifying your user: either specify your bank account number (branch code and account number) or use your contractor number. I'm using the first one, so let's focus on that. The problem is that the branch code and the account numbers are two separate text boxes, thus when I fill them out and login, then LastPass will only save one of them as username.

## Edit the Form Fields

There is a feature of LastPass that solves this issue. Go to edit the login entry. On the bottom left there is a wrench icon, click that:

![](/assets/2021-05-10-using-lastpass-on-login-forms-with-more-than-2-inputs/lp1.png)

This will bring up a window like this (this already has two extra form fields added by me):

![](/assets/2021-05-10-using-lastpass-on-login-forms-with-more-than-2-inputs/lp2.png)

Here you can add any number of form fields to be filled in when filling in the login form. For each element you can specify:

![](/assets/2021-05-10-using-lastpass-on-login-forms-with-more-than-2-inputs/lp3.png)

* Field name: use the name attribute of the input html tag (e.g. for `<input type="tel" name="S_ACCNT_NO" id="S_ACCNT_NO" maxlength="7" tabindex="2">` use `S_ACCNT_NO`)
* Field type: I guess this is used to match the input type, although selecting Text for the above input (`type='tel'`) works
* Field value: whatever you want to be filled in (e.g. branch code, account number)

Save it and enjoy the fields being filled with the right input.
