---
layout: post
title: The security of KeyCloak used as an identity proxy
tags: security
---

Recently I was involved in a project where KeyCloak was used as an identity proxy: the target app was configured to use KeyCloak as an SSO, but KeyCloak delegated the authentication further to an other IdP. So on login to the target app, the app would redirect the user to KeyCloak, which would further redirect to the IdP's login page. Upon authenticating there, the IdP redirected back to KeyCloak, which redirected to the target app. This double-redirect flow happened very fast so it was mostly transparent to the user.

My task was to review the security of this setup and I managed to find a few interesting bugs.

<!--break-->

# Full account takeover

So in KeyCloak users are allowed to change their email address, but they need to verify it. However since KeyCloak was using the IdP to login users, this requirement didn't make sense and was turned off. So any user could change their email address on their profile page without any sort of verification:

![Profile page of a user](/assets/2021-07-05-keycloak-security-checks/userconfig.png#lb)

Since the target app was configured to use this email address for authenticating the user, this meant that any user could takeover anyone else's account. Sweet.

**The fix**: configure KeyCloak to send the username instead of the email address to the target app, as the username can't be changed.

# Leaking SAML private keys in logs and export

Detailed logging with `Include Representation` was enabled for Admin Events:

![Configuration for Admin Events (/auth/admin/master/console/#/realms/target/events-settings)](/assets/2021-07-05-keycloak-security-checks/event_config.png#lb)

This meant that on editing the SAML client config, the private key got logged:

![Full SAML config with the private key. Oops.](/assets/2021-07-05-keycloak-security-checks/event.png#lb)

As this key is used to sign the SSO request from the target app, someone with this key can impersonate any user to the target app without every having to interact with KeyCloak.

As logs will be shipped out of the system and available to people without access to the system, this was especially alarming.

The same key is part of the exported configuration, and is also visible on the UI, so limiting admin access is crucial.

**The fix:** as a potential quick-fix disable detailed logging, but that will impact the usefulness of logs.

# Impersonation as a service

This is not really a bug, more of a feature of KeyCloak: admins can impersonate any user by clicking a button:

![Impersonate button.](/assets/2021-07-05-keycloak-security-checks/impersonation.png#lb)

This is something to keep in mind and at least setup some alerting for it, if it happens. Keep in mind though that an admin can still reset the users' password or view the SAML private keys, so [disabling impersonation](https://www.keycloak.org/docs/latest/server_admin/index.html#_per_realm_admin_permissions) is not the only thing you need to worry about if you are concerned about privileged attackers. But it's a good start.
