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
        (Just used for logging reasons)

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
        if (-not $Token) { 
            Write-PSFMessage -Level Debug -Message "No token on parameter in command. Getting registered token." -Tag "Authentication" -FunctionName $FunctionName
            $Token = $script:msgraph_Token
        }

        if ($Token) {
            $Token
        }
        else {
            Stop-PSFFunction -Message "Not connected! Use New-MgaAccessToken to create a Token and either register it or specifs it" -EnableException $true -Category AuthenticationError -FunctionName $FunctionName
        }
    }
}