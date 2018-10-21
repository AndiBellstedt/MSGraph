function Register-MgaAccessToken {
    <#
    .SYNOPSIS
        Registers an access token

    .DESCRIPTION
        Registers an access token, so all subsequent calls to Exchange Online reuse it by default.

    .PARAMETER Token
        The Token to register as default token for subsequent calls.

    .PARAMETER PassThru
        Outputs the token to the console

    .EXAMPLE
        PS C:\> Get-MgaRegisteredAccessToken

        Output the registered access token
    #>
    [CmdletBinding (SupportsShouldProcess=$false,
                    ConfirmImpact='Medium')]
    [OutputType([MSGraph.Core.AzureAccessToken])]
    param (
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,ValueFromRemainingArguments=$false)]
        [ValidateNotNullOrEmpty()]
        [MSGraph.Core.AzureAccessToken]
        $Token,

        [switch]
        $PassThru

    )

    $script:msgraph_Token = $Token
    if($PassThru) {
        $script:msgraph_Token
    }
}