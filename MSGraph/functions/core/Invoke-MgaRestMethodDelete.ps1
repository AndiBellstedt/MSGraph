function Invoke-MgaRestMethodDelete {
    <#
    .SYNOPSIS
        Performs a REST DELETE against the graph API

    .DESCRIPTION
        Performs a REST DELETE against the graph API.
        Primarily used for internal commands.

    .PARAMETER Field
        The api child item under the username in the url of the api call.
        If this didn't make sense to you, you probably shouldn't be using this command ;)

    .PARAMETER User
        The user to execute this under. Defaults to the user the token belongs to.

    .PARAMETER Body
        JSON date as string to send as body on the REST call

    .PARAMETER ContentType
        Nature of the data in the body of an entity. Required.

    .PARAMETER ApiConnection
        The URI for the Microsoft Graph connection

    .PARAMETER ApiVersion
        The version used for queries in Microsoft Graph connection

    .PARAMETER Token
        The access token to use to connect.

    .PARAMETER Force
        If specified the user will not prompted on confirmation.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.


    .EXAMPLE
        PS C:\> Invoke-MgaRestMethodDelete -Field "mailFolders/$($id)"

        Delete a mailfolder with the id stored in variable $id.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [Alias('Invoke-MgaDeleteMethod')]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Field,

        [string]
        $User,

        [String]
        $Body,

        [ValidateSet("application/json")]
        [String]
        $ContentType = "application/json",

        [String]
        $ApiConnection = (Get-PSFConfigValue -FullName 'MSGraph.Tenant.ApiConnection' -Fallback 'https://graph.microsoft.com'),

        [string]
        $ApiVersion = (Get-PSFConfigValue -FullName 'MSGraph.Tenant.ApiVersion' -Fallback 'v1.0'),

        [MSGraph.Core.AzureAccessToken]
        $Token,

        [switch]
        $Force,

        [string]
        $FunctionName = $MyInvocation.MyCommand
    )

    # tokek check
    $Token = Invoke-TokenLifetimeValidation -Token $Token -FunctionName $FunctionName

    if (-not $User) { $User = $Token.UserprincipalName }
    $restUri = "$($ApiConnection)/$($ApiVersion)/$(Resolve-UserString -User $User)/$($Field)"

    Write-PSFMessage -Tag "RestData" -Level VeryVerbose -Message "Invoking REST DELETE to uri: $($restUri)"
    Write-PSFMessage -Tag "RestData" -Level Debug -Message "REST body data: $($Body)"

    Clear-Variable -Name data -Force -WhatIf:$false -Confirm:$false -Verbose:$false -ErrorAction Ignore
    $invokeParam = @{
        Method  = "DELETE"
        Uri     = $restUri
        Body    = $Body
        Headers = @{
            "Authorization" = "Bearer $( [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token.AccessToken)) )"
            "Content-Type"  = "application/json"
        }
    }

    if ($Force) { $doAction = $true } else { $doAction = $pscmdlet.ShouldProcess($restUri, "Invoke DELETE") }
    if ($doAction) {
        $data = Invoke-RestMethod @invokeParam -ErrorVariable "restError" -Verbose:$false -UseBasicParsing
    }

    if ($restError) {
        Stop-PSFFunction -Tag "RestData" -Message $parseError[0].Exception.Message -Exception $parseError[0].Exception -EnableException $false -Category ConnectionError -FunctionName $FunctionName
        return
    }

    if ($data) {
        $data | Add-Member -MemberType NoteProperty -Name 'User' -Value $User -Force
        $data
    }
}