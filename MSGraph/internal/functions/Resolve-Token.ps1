function Resolve-Token {
    <#
    .SYNOPSIS
        Test for specified Token, or receives registered token

    .DESCRIPTION
        Test for specified Token, or receives registered token.
        Helper function used for internal commands.

    .PARAMETER Token
        The Token to test and receive


    .PARAMETER FunctionName
        Name of the higher function which is calling this function.

    .EXAMPLE
        PS C:\> Resolve-Token -User $Token

        Test Token for lifetime, or receives registered token from script variable
    #>
    [OutputType([MSGraph.Core.AzureAccessToken])]
    [CmdletBinding()]
    param (
        [MSGraph.Core.AzureAccessToken]
        $Token,

        [String]
        $FunctionName
    )

    if (-not $Token) { $Token = $script:msgraph_Token }
    if (-not $Token) {
        Stop-PSFFunction -Message "Not connected! Use New-MgaAccessToken to create a Token and either register it or specifs it" -EnableException $true -Category AuthenticationError -FunctionName $FunctionName
    }
    if ( (-not $Token.IsValid) -or ($Token.PercentRemaining -lt 15) ) {
        # if token is invalid or less then 15 percent of lifetime -> go and refresh the token
        $paramsTokenRefresh = @{
            Token    = $Token
            PassThru = $true
        }
        if ($script:msgraph_Token.AccessTokenInfo.Payload -eq $Token.AccessTokenInfo.Payload) { $paramsTokenRefresh.Add("Register", $true) }
        if ($Token.Credential) { $paramsTokenRefresh.Add("Credential", $Token.Credential) }
        $Token = Update-MgaAccessToken @paramsTokenRefresh
    }
    else {
        Write-PSFMessage -Level Verbose -Message "Valid token for user $($Token.UserprincipalName) - Time remaining $($Token.TimeRemaining)" -Tag "Authentication"
    }

    $Token
}