﻿function Invoke-MgaDeleteMethod {
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

    .PARAMETER Token
        The access token to use to connect.

    .PARAMETER Force 
        If specified the user will not prompted on confirmation.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.

    .EXAMPLE
        PS C:\> Invoke-MgaDeleteMethod -Field "mailFolders/$($id)"

        Delete a mailfolder with the id stored in variable $id.
    #>
    [CmdletBinding(ConfirmImpact='High', SupportsShouldProcess=$true)]
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
    $restUri = "https://graph.microsoft.com/v1.0/$(Resolve-UserString -User $User)/$($Field)"

    Write-PSFMessage -Tag "RestData" -Level VeryVerbose -Message "Invoking REST DELETE to uri: $($restUri)"
    Write-PSFMessage -Tag "RestData" -Level Debug -Message "REST body data: $($Body)"

    Clear-Variable -Name data -Force -WhatIf:$false -Confirm:$false -Verbose:$false -ErrorAction Ignore
    $invokeParam = @{
        Method          = "DELETE"
        Uri             = $restUri
        Body            = $Body
        Headers         = @{
            "Authorization" = "Bearer $( [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token.AccessToken)) )"
            "Content-Type"  = "application/json"
        }
    }

    if($Force) { $doAction = $true } else { $doAction = $pscmdlet.ShouldProcess($restUri, "Invoke DELETE") }
    if ($doAction) {
        $data = Invoke-RestMethod @invokeParam -ErrorVariable "restError" -Verbose:$false -UseBasicParsing
    }

    if ($restError) {
        Stop-PSFFunction -Tag "RestData" -Message $parseError[0].Exception.Message -Exception $parseError[0].Exception -EnableException $false -Category ConnectionError -FunctionName $FunctionName
        return
    }

    $data | Add-Member -MemberType NoteProperty -Name 'User' -Value $User -Force
    $data
}