function Invoke-MgaGetMethod {
    <#
    .SYNOPSIS
        Performs a rest GET against the graph API

    .DESCRIPTION
        Performs a rest GET against the graph API.
        Primarily used for internal commands.

    .PARAMETER Field
        The api child item under the username in the url of the api call.
        If this didn't make sense to you, you probably shouldn't be using this command ;)

    .PARAMETER User
        The user to execute this under. Defaults to the user the token belongs to.

    .PARAMETER Delta
        Indicates that the query is intend to be a delta query, so a delta-link property is added to the output-object ('@odata.deltaLink').

    .PARAMETER DeltaLink
        Specifies the uri to query for delta objects on a query.

    .PARAMETER ResultSize
        The user to execute this under. Defaults to the user the token belongs to.

    .PARAMETER Token
        The access token to use to connect.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.

    .EXAMPLE
        PS C:\> Invoke-MgaGetMethod -Field 'mailFolders' -Token $Token -User $User

        Retrieves a list of email folders for the user $User, using the token stored in $Token
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [ValidateNotNullOrEmpty()]
        [string]
        $Field,

        [string]
        $User,

        [Parameter(ParameterSetName = 'Default')]
        [switch]
        $Delta,

        [Parameter(ParameterSetName = 'DeltaLink')]
        [string]
        $DeltaLink,

        [Int64]
        $ResultSize = (Get-PSFConfigValue -FullName 'MSGraph.Query.ResultSize' -Fallback 100),

        [MSGraph.Core.AzureAccessToken]
        $Token,

        [string]
        $FunctionName = $MyInvocation.MyCommand
    )

    #region variable definition
    $Token = Resolve-Token -Token $Token -FunctionName $FunctionName
    if($PSCmdlet.ParameterSetName -like "DeltaLink") {
        Write-PSFMessage -Level VeryVerbose -Message "ParameterSet $($PSCmdlet.ParameterSetName) - constructing delta query" -Tag "ParameterSetHandling"
        $restUri = $DeltaLink
        $Delta = $true
        $User = ([uri]$restUri).AbsolutePath.split('/')[2]
    }
    else {
        if(-not $User) { $User = $Token.UserprincipalName }
        $restUri = "https://graph.microsoft.com/v1.0/$(Resolve-UserString -User $User)/$($Field)"
        if($Delta) { $restUri = $restUri + "/delta" }
    }
    if ($ResultSize -eq 0) { $ResultSize = [Int64]::MaxValue }
    #if ($ResultSize -le 10 -and $restUri -notmatch '\$top=') { $restUri = $restUri + "?`$top=$($ResultSize)" }
    [Int64]$i = 0
    [Int64]$overResult = 0
    $tooManyItems = $false
    $output = @()
    #endregion variable definition

    #region query data
    do {
        Write-PSFMessage -Tag "RestData" -Level VeryVerbose -Message "Get REST data: $($restUri)"

        Clear-Variable -Name data -Force -WhatIf:$false -Confirm:$false -Verbose:$false -ErrorAction Ignore
        $invokeParam = @{
            Method          = "Get"
            Uri             = $restUri
            Headers         = @{
                "Authorization" = "Bearer $( [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token.AccessToken)) )"
                "Content-Type"  = "application/json"
            }
        }
        $data = Invoke-RestMethod @invokeParam -ErrorVariable "restError" -Verbose:$false -UseBasicParsing
        if($restError) {
            Stop-PSFFunction -Tag "RestData" -Message $parseError[0].Exception -Exception $parseError[0].Exception -EnableException $false -Category ConnectionError -FunctionName $FunctionName
            return
        }

        if("Value" -in $data.psobject.Properties.Name) {
            # Multi object with value property returned by api call
            [array]$value = $data.Value
            Write-PSFMessage -Tag "RestData" -Level VeryVerbose -Message "Retrieving $($value.Count) records from query"
            $i = $i + $value.Count
            if($i -lt $ResultSize) {
                $restUri = $data.'@odata.nextLink'
            }
            else {
                $restUri = ""
                $tooManyItems = $true
                $overResult = $ResultSize - ($i - $value.Count)
                Write-PSFMessage -Tag "ResultSize" -Level Verbose -Message "Resultsize ($ResultSize) exeeded. Output $($overResult) object(s) in record set."
            }
        }
        else {
            # Multi object with value property returned by api call
            Write-PSFMessage -Tag "RestData" -Level VeryVerbose -Message "Single item retrived. Outputting data."
            [array]$value = $data
            $restUri = ""
        }

        if((-not $tooManyItems) -or ($overResult -gt 0)) {
            # check if resultsize is reached
            if($overResult -gt 0) {
                $output = $output + $Value[0..($overResult-1)]
            }
            else {
                $output = $output + $Value
            }
        }
    }
    while ($restUri)
    #endregion query data

    #region output data
    $output | Add-Member -MemberType NoteProperty -Name 'User' -Value $User -Force
    if($Delta) {
        if('@odata.deltaLink' -in $data.psobject.Properties.Name) {
            $output | Add-Member -MemberType NoteProperty -Name '@odata.deltaLink' -Value $data.'@odata.deltaLink' -PassThru
        }
        else {
            $output | Add-Member -MemberType NoteProperty -Name '@odata.deltaLink' -Value $data.'@odata.nextLink' -PassThru
        }
    }
    else {
        $output
    }

    if($tooManyItems) {
        # write information to console if resultsize exceeds
        if($Delta) {
            Write-PSFMessage -Tag "GetData" -Level Host -Message "Reaching maximum ResultSize before finishing delta query. Next delta query will continue on pending objects. Current ResultSize: $($ResultSize)" -FunctionName $FunctionName
        }
        else {
            Write-PSFMessage -Tag "GetData" -Level Warning -Message "Too many items. Reaching maximum ResultSize before finishing query. You may want to increase the ResultSize. Current ResultSize: $($ResultSize)" -FunctionName $FunctionName
        }
    }
    #endregion output data
}