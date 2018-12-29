function Invoke-MgaPatchMethod {
    <#
    .SYNOPSIS
        Performs a REST PATCH against the graph API

    .DESCRIPTION
        Performs a REST PATCH against the graph API.
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

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.

    .EXAMPLE
        PS C:\> Invoke-MgaPatchMethod -Field "messages/$($id)" -Body '{ "isRead": true }' -Token $Token

        Set a message as readed.
        The token stored in $Token is used for the api call.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
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

        [string]
        $FunctionName = $MyInvocation.MyCommand
    )

    # tokek check
    $Token = Invoke-TokenLifetimeValidation -Token $Token -FunctionName $FunctionName

    if (-not $User) { $User = $Token.UserprincipalName }
    $restUri = "$($ApiConnection)/$($ApiVersion)/$(Resolve-UserString -User $User)/$($Field)"

    Write-PSFMessage -Tag "RestData" -Level VeryVerbose -Message "Invoking REST PATCH to uri: $($restUri)"
    Write-PSFMessage -Tag "RestData" -Level Debug -Message "REST body data: $($Body)"

    Clear-Variable -Name data -Force -WhatIf:$false -Confirm:$false -Verbose:$false -ErrorAction Ignore
    $invokeParam = @{
        Method  = "Patch"
        Uri     = $restUri
        Body    = $Body
        Headers = @{
            "Authorization" = "Bearer $( [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token.AccessToken)) )"
            "Content-Type"  = "application/json"
        }
    }
    $data = Invoke-RestMethod @invokeParam -ErrorVariable "restError" -Verbose:$false -UseBasicParsing

    if ($restError) {
        Stop-PSFFunction -Tag "RestData" -Message $parseError[0].Exception -Exception $parseError[0].Exception -EnableException $false -Category ConnectionError -FunctionName $FunctionName
        return
    }

    if ($data) {
        $data | Add-Member -MemberType NoteProperty -Name 'User' -Value $User -Force
        $data
    }
}