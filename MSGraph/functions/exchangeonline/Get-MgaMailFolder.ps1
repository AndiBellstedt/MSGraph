function Get-MgaMailFolder {
    <#
    .SYNOPSIS
        Searches mail folders in Exchange Online
    
    .DESCRIPTION
        Searches mail folders in Exchange Online
    
    .PARAMETER Filter
        The name to filter by
        (Client Side filtering)
    
    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.
    
    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-EORAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-EORAccessToken.
    
    .EXAMPLE
        PS C:\> Get-MgaMailFolder
    
        Returns all folders in the mailbox of the connected user.
    
    .EXAMPLE
        PS C:\> Get-MgaMailFolder -Filter Inbox -User "max.mustermann@contoso.onmicrosoft.com" -Token $Token
    
        Retrieves the inbox folder of the "max.mustermann@contoso.onmicrosoft.com" mailbox, using the connection token stored in $Token.
    #>
    [CmdletBinding()]
    param (
        [string]
        $Filter = "*",
        
        [string]
        $User = 'me',
        
        $Token
    )
    Invoke-MgaGetMethod -Field 'mailFolders' -Token $Token -User (Resolve-UserString -User $User) | Where-Object displayName -Like $Filter
}