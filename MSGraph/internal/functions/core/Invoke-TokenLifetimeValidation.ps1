function Invoke-TokenLifetimeValidation {
    <#
    .SYNOPSIS
        Validates the lifetime of a token object

    .DESCRIPTION
        Validates the lifetime of a token object and invoke update-token process, if needed.
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
        $FunctionName = $MyInvocation.MyCommand
    )

    process {
        $Token = Resolve-Token -Token $Token -FunctionName $FunctionName

        if ( (-not $Token.IsValid) -or ($Token.PercentRemaining -lt 15) ) {
            # if token is invalid or less then 15 percent of lifetime -> go and refresh the token
            Write-PSFMessage -Level Verbose -Message "Token lifetime is less then 15%. Initiate token refresh. Time remaining $($Token.TimeRemaining)" -Tag "Authentication" -FunctionName $FunctionName
            $paramsTokenRefresh = @{
                Token    = $Token
                PassThru = $true
            }
            if ($script:msgraph_Token.AccessTokenInfo.Payload -eq $Token.AccessTokenInfo.Payload) { $paramsTokenRefresh.Add("Register", $true) }
            if ($Token.Credential) { $paramsTokenRefresh.Add("Credential", $Token.Credential) }
            $Token = Update-MgaAccessToken @paramsTokenRefresh
        }
        else {
            Write-PSFMessage -Level Verbose -Message "Valid token for user $($Token.UserprincipalName) - Time remaining $($Token.TimeRemaining)" -Tag "Authentication" -FunctionName $FunctionName
        }

        $Token
    }
}