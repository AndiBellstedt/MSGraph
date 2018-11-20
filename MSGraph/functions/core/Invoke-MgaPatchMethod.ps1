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
        The hashtable send as body on the REST call

    .PARAMETER ContentType
        Nature of the data in the body of an entity. Required.

    .PARAMETER Token
        The access token to use to connect.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.

    .EXAMPLE
        PS C:\> Invoke-MgaPatchMethod -Field "messages/$($id)" -Body @{"isRead" = $true} -Token $Token

        Retrieves a list of email folders for the user $User, using the token stored in $Token
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [string[]]
        $Field,

        [string]
        $User,

        [System.Collections.Hashtable]
        $Body,

        [ValidateSet("application/json")]
        [String]
        $ContentType = "application/json",

        #[MSGraph.Core.AzureAccessToken]
        $Token,

        [string]
        $FunctionName = $MyInvocation.MyCommand
    )

    $Token = Resolve-Token -Token $Token -FunctionName $FunctionName
    if(-not $User) { $User = $Token.UserprincipalName }

    $restLink = "https://graph.microsoft.com/v1.0/$(Resolve-UserString -User $User)/$($Field)"

    Write-PSFMessage -Level Verbose -Message "PATCH REST data: $($restLink)" -Tag "RestData"
    Clear-Variable -Name data -Force -WhatIf:$false -Confirm:$false -Verbose:$false -ErrorAction Ignore
    $data = Invoke-RestMethod -ErrorVariable restError -Verbose:$false -Method Patch -UseBasicParsing -Uri $restLink -Body ($Body | ConvertTo-Json) -Headers @{
        "Authorization" = "Bearer $( [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token.AccessToken)) )"
        "Content-Type"  = "application/json"
    }
    if($restError) {
        Stop-PSFFunction -Message $restError -EnableException $false -Category ConnectionError -Tag "RestData"
        return
    }

    Write-PSFMessage -Level Verbose -Message "Single item retrived. Outputting data." -Tag "RestData"
    $data | Add-Member -MemberType NoteProperty -Name 'User' -Value $User -Force

    $data
}