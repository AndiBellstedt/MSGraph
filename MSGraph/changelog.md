# Changelog
# 1.2.8.1
- New: Command New-MgaMailFolder
- New: command Move-MgaMailFolder
- New: command Remove-MgaMailFolder
- Upd: example documentation on command Update-MgaAccessToken
- Upd: internal code refactoring for better object checking on message and folder functions

# 1.2.8.0
- New: Command Rename-MgaMailFolder
    - allows to rename a folder
- New: Command Copy-MgaMailMessage
    - copy a mail to another folder
- Upd: Command Get-MgaMailFolder
    - Bugfix (clientside) filtering, that filter only applies to direct queried objects and not invokes on the subfolders (if additionally queried)

# 1.2.7.1
- New: Token scope validation on commands
    - Mga-commands inspect token scope information to check if they are able to run against the api. If Identity Platform Version 2.0 is use, a new token will be aquired, with the appropriate scopes to run.
        - Get-MgaMailAttachment
        - Get-MgaMailFolder
        - Get-MgaMailMessage
        - Move-MgaMailMessage
        - Set-MgaMailMessage
- Upd: Command New-MgaAccessToken
    - Add error handling on authentication errors

## 1.2.7.0
- Upd: Command New-MgaAccessToken
    - BREAKING CHANGE: rename switch "Refresh" to "ShowLoginWindows"
    - Implement logon against Identity Platform Version 2.0, to allow logon with Microsoft Account
    - Add Parameter "IdentityPlatformVersion" for choosing which endpoint to use for authentication
    - Add Parameter "Permission" to specify the requested permission in the token (this only apply to identity platform version 2.0)
    - Add documentation and examples
- Upd: Command Update-MgaAccessToken 
    - Implement refresh for Identity Platform Version 2.0, to allow refresh with Microsoft Account

## 1.2.6.1 (2018-12-06)
- Upd: Rename ParameterClasses
    - [MSGraph.Exchange.Mail.MailFolderParameter] -> [MSGraph.Exchange.Mail.FolderParameter]
    - [MSGraph.Exchange.Mail.MailMessageOrMailFolderParameter] -> [MSGraph.Exchange.Mail.MessageOrFolderParameter]
    - [MSGraph.Exchange.Mail.MailMessageParameter] -> [MSGraph.Exchange.Mail.MessageParameter]
- Upd: Code refactoring to support ParameterClasses on input parameter for commands
    - Move-MgaMailMessage
    - Set-MgaMailMessage

## 1.2.6 (2018-11-27)
- Upd: Command Get-MgaMailFolder
    - Implement parametersets with pipeable input parameter "Name".
    - Implement parameter "IncludeChildFolders" for query subfolders from within a folder
    - Implement parameter "Recurse" to query whole folder structure from a folder
    - Add properties on output object
    - Grouped output on PatentPath name for folder objects on Format-Table
    - Add tab completion on "Name" parameter for well known folders
- Upd: Code refactoring
    - Moving properties from type-system to c# classes
- New: Invent ParameterClasses for enabling convinient Pipeline input on parameters. Currently available parameterclasses:
    - [MSGraph.Exchange.Mail.MailFolderParameter]
    - [MSGraph.Exchange.Mail.MailMessageOrMailFolderParameter]

## 1.2.5 (2018-11-24)
- New: Command Move-MgaMailMessage
- Upd: Command Update-MgaMailMessage
    - Rename command to *Set-MgaMailMessage*
    - Add alias *Update-MgaMailMessage* on *Set-MgaMailMessage*
- Fix: some minor bugfixes and code refactoring

## 1.2.2 (2018-11-18)
- New: Classes for output from cmdlets for better support on pipeline
    - Get-MgaMailAttachment -> [MSGraph.Exchange.Mail.Attachment]
    - Get-MgaMailFolder -> [MSGraph.Exchange.Mail.Folder]
    - Get-MgaMailMessage -> [MSGraph.Exchange.Mail.Message]
- New: Optimized output on Format-Table and Format-List for
    - [MSGraph.Exchange.Mail.Folder]
    - [MSGraph.Exchange.Mail.Message]
- Upd: Command Get-MgaMailMessage
    - add pipeline support with "Get-MgaMailFolder" and "Get-MgaMailMessages"
    - Implement the ability to do "delta queries" on messages by specifing "-Delta" switch
    - Implement "-Subject" parameter to filter output (client-side filtering). Just for convinience
- Upd: Command Invoke-MgaGetMethod
    - bugfixing, optimizing runtime and implement delta query availability
- Fix: Bugfix property "PercentRemaining" on [MSGraph.Core.AzureAccessToken] objects

## 1.2.0 (2018-10-25)
 
 - New: Command Get-MgaMailAttachment
 - New: Command Export-MgaMailAttachment
 - New: Command Get-MgaRegisteredAccessToken
 - New: Command Register-MgaAccessToken
 - New: Command Update-MgaAccessToken
 - Upd: Overhaul module structure to the latest PSFramework reference architecture