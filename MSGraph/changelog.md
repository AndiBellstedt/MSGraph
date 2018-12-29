# Changelog
# 1.2.8.5
- Upd: Rename commands for consistent command name pattern. Put old names as aliases, for backward compatibility
    - Invoke-MgaDeleteMethod --> Invoke-MgaRestMethodDelete
    - Invoke-MgaGetMethod --> Invoke-MgaRestMethodGet
    - Invoke-MgaPatchMethod --> Invoke-MgaRestMethodPatch
    - Invoke-MgaPostMethod --> Invoke-MgaRestMethodPost
    - Get-MgaRegisteredAccessToken --> Get-MgaAccessTokenRegistered
    - Add-MgaMailForwardMessage --> Add-MgaMailMessageForward
    - Add-MgaMailReplyMessage --> Add-MgaMailForwardReply
- Upd: module folder structure update

# 1.2.8.4
- New: command Get-MgaExchCategory
    - Query categories within exchange mailbox
    - Convinient object output including "translated" colors to readable ColorNames
    - Filter possibilities to get specific output
    - Tab completion on Color parameter
- New: Command New-MgaExchCategory
    - Create new categories within exchange mailbox
    - Tab completion on Color parameter
- New: Command Set-MgaExchCategory
    - Modify categories within exchange mailbox
    - Tab completion on Color parameter
- New: Command Remove-MgaExchCategory
- Upd: module folder structure
    - For better clarity, moving function files into more granular subfolder structure
- Upd: WellKnownFolder Enum
    - Add "AllItems" to Enum

# 1.2.8.3
- New: Command Add-MgaMailAttachment
- New: Command Add-MgaMailReplyMessage
- New: Command Add-MgaMailForwardMessage
- New: object types Attachments:
    - [MSGraph.Exchange.Attachment.ItemAttachment]
    - [MSGraph.Exchange.Attachment.ReferenceAttachment]
    - [MSGraph.Exchange.Attachment.Attachment] -> as base object
    - new format types.ps1xml for attachment types 
- Upd: object type [MSGraph.Exchange.Mail.Attachment]
    - rename to [MSGraph.Exchange.Attachment.FileAttachment]
    - add properties to the class, for convinience
- Upd: Command New-MgaMailMessage, Send-MgaMailMessage, Set-MgaMailMessage
    - Update parameter "ToRecipients" -> add parameter alias names "To" and "Reciepients"
    - some internal code refactoring
- Upd: Command Send-MgaMailMessage
    - Add parameter set, to send new mail directly from command without need to use New-MgaMailMessage before Send-MgaMailMessage
- Upd: command Get-MgaMailAttachment
    - add same inputobject check as other MgaMail commands
    - change output logic -> outputs different types of attachment including type specific properties
        - [MSGraph.Exchange.Attachment.FileAttachment]
        - [MSGraph.Exchange.Attachment.ItemAttachment]
        - [MSGraph.Exchange.Attachment.ReferenceAttachment]
        - [MSGraph.Exchange.Attachment.Attachment]
        - additinal properties on all object (ParentObject, AttachmentType)
- Upd: command Export-MgaMailAttachment
    - Implement export options on different attachment types
- Upd: Command Invoke-MgaGetMethod, Invoke-MgaDeleteMethod, Invoke-MgaPatchMethod, Invoke-MgaPostMethod
    - new parameters for config values used for api connection and version
- Fix: command Get-MgaMailMessage
    - query message objects from MicrosoftAccounts via ID didn't return the message object, because of wrong ID checking. Fixed, messages are returned correct, now.
- Fix: internal command New-MgaMailMessageObject
    - fixing address conversion error, when name field is the same then address field

# 1.2.8.2
- New: Command New-MgaMailFolder
- New: Command Move-MgaMailFolder
- New: Command Remove-MgaMailFolder
- New: Command Remove-MgaMailMessage
- New: Command New-MgaMailMessage
- New: Command Send-MgaMailMessage
- Upd: command Update-MgaAccessToken
    - example documentation on
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