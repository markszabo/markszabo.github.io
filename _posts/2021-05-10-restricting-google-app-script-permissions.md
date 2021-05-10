---
layout: post
title: Restricting Google App Script permissions
date: 2021-05-10 18:30:00 +09:00
---

> Google Apps Script is a rapid application development platform that makes it fast and easy to create business applications that integrate with Google Workspace. You write code in modern JavaScript and have access to built-in libraries for favorite Google Workspace applications like Gmail, Calendar, Drive, and more. (https://developers.google.com/apps-script/overview)

Google Apps Script provide an easy way to automate repetitive tasks in the Google ecosystem (e.g. Drive). It is somewhat similar to macros in Microsoft Office. An App Script will ask for permissions before it can interact with any document of the user, and by default these permissions are unnecessarily wide. This write up is meant to help restricting these permissions.

## Script types

**Standalone**

> A standalone script is any script that is not bound to a Google Sheets, Docs, Slides, or Forms file or Google Sites. These scripts appear among your files in Google Drive. (https://developers.google.com/apps-script/guides/standalone)

**Container-bound Scripts**

> A script is bound to a Google Sheets, Docs, Slides, or Forms file if it was created from that document rather than as a standalone script. The file a bound script is attached to is referred to as a "container". Bound scripts generally behave like standalone scripts except that they do not appear in Google Drive, they cannot be detached from the file they are bound to, and they gain a few special privileges over the parent file. (https://developers.google.com/apps-script/guides/bound)

For most use-cases Container-bound Scripts are a better fit.

## Permissions the script asks for

> Apps Script determines the authorization scopes (like access your Google Sheets files or Gmail) automatically, based on a scan of the code. Code that is commented out can still generate an authorization request. If a script needs authorization, you'll see one of the authorization dialogs shown here when it is run. Scripts that you have previously authorized also ask for additional authorization if a code change adds new services. [https://developers.google.com/apps-script/guides/services/authorization]

When authorizing a script it will ask access to all documents in the user's Drive, even if the script is bound to a single document and only interacting with that document:

![](assets/2021-05-10-restricting-google-app-script-permissions/originalpermissions.png)

Once it's authorized, it can access other documents from the user's Drive by e.g.:

```
var ss = SpreadsheetApp.openById("15MDqa36NGq2nsLuQKT62lKWS-v7yLMf6UXQT-l7yDDs");
Logger.log(ss.getName());
```

This is not optimal, as the script should only be asking for the permissions it needs.

## Solution 1: `@OnlyCurrentDoc`
Include the following comment in the beginning of your script:

```
/**
 * @OnlyCurrentDoc
 */
```

From: [https://developers.google.com/apps-script/guides/services/authorization#manual_authorization_scopes_for_sheets_docs_slides_and_forms]

## Solution 2: Define the permissions manually

Google tries to guess the permissions your script needs, but you can override that and define the permissions manually by editing the manifest file.

> The Apps Script editor hides manifest files by default in order to protect your Apps Script project settings. Follow these steps to make a hidden project manifest visible in the Apps Script editor:
>
> 1. Open the script project in the Apps Script editor.
> 2. Select View > Show project manifest.
>
> [https://developers.google.com/apps-script/concepts/manifests]

And add the following line to the the json (for a script that should only interact with the spreadsheet it is bound to):

```
"oauthScopes": ["https://www.googleapis.com/auth/spreadsheets.currentonly"]
```

Either of these options will restrict the scope to the single document and in turn change the authorization screen to:


![](assets/2021-05-10-restricting-google-app-script-permissions/newpermissions.png)

If you need more permissions (e.g. access to an other file), this seems like a good place to start: [https://stackoverflow.com/a/57564752/8590802]

## Permissions on changing the scripts

Slightly unrelated security note: for bound scripts the permissions are the same as the file they are bound to:  

> All container-bound scripts use the same owner, viewer, and editor access list defined for the container file. The container owner takes ownership of a new script project regardless of who created it. Only users who have permission to edit a container can run its bound script. Collaborators who have only view access cannot open the script editor, although if they make a copy of the parent file, they become the owner of the copy and will be able to see and run a copy of the script." [https://developers.google.com/apps-script/guides/bound#access_to_bound_scripts]

So only give edit access to the file to people you trust, and don't store anything sensitive in the script's code.
