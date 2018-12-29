function Get-MgaAccessTokenRegistered {
    <#
    .SYNOPSIS
        Output the registered access token

    .DESCRIPTION
        Output the registered access token

    .EXAMPLE
        PS C:\> Get-MgaRegisteredAccessToken

        Output the registered access token
    #>
    [CmdletBinding()]
    [Alias('Get-MgaRegisteredAccessToken')]
    param ()

    if ($script:msgraph_Token) {
        $script:msgraph_Token
    } else {
        Write-PSFMessage -Level Host -Message "No access token registered."
    }
}