# Changelog
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