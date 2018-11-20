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
        [string[]]
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

        #[MSGraph.Core.AzureAccessToken]
        $Token,

        [string]
        $FunctionName = $MyInvocation.MyCommand
    )
    $Token = Resolve-Token -Token $Token -FunctionName $FunctionName

    if($PSCmdlet.ParameterSetName -like "DeltaLink") {
        Write-PSFMessage -Level Verbose -Message "ParameterSet $($PSCmdlet.ParameterSetName) - constructing delta query" -Tag "ParameterSetHandling"
        $restLink = $DeltaLink
        $Delta = $true
        $User = ([uri]$restLink).AbsolutePath.split('/')[2]
    }
    else {
        if(-not $User) { $User = $Token.UserprincipalName }
        $restLink = "https://graph.microsoft.com/v1.0/$(Resolve-UserString -User $User)/$($Field)"
        if($Delta) { $restLink = $restLink + "/delta" }
    }
    if ($ResultSize -eq 0) { $ResultSize = [Int64]::MaxValue }
    #if ($ResultSize -le 10 -and $restLink -notmatch '\$top=') { $restLink = $restLink + "?`$top=$($ResultSize)" }
    [Int64]$i = 0
    [Int64]$overResult = 0
    $tooManyItems = $false
    $output = @()

    do {
        Write-PSFMessage -Level Verbose -Message "Get REST data: $($restLink)" -Tag "RestData"
        Clear-Variable -Name data -Force -WhatIf:$false -Confirm:$false -Verbose:$false -ErrorAction Ignore
        $data = Invoke-RestMethod -ErrorVariable restError -Verbose:$false -Method Get -UseBasicParsing -Uri $restLink -Headers @{
            "Authorization" = "Bearer $( [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token.AccessToken)) )"
            "Prefer"        = "outlook.timezone=`"$((Get-Timezone).Id)`", odata.maxpagesize=$($ResultSize)"
        }
        if($restError) {
            Stop-PSFFunction -Message $restError -EnableException $false -Category ConnectionError -Tag "RestData"
            return
        }

        if("Value" -in $data.psobject.Properties.Name) {
            [array]$value = $data.Value
            Write-PSFMessage -Level Verbose -Message "Retrieving $($value.Count) records from query" -Tag "RestData"
            $i = $i + $value.Count
            if($i -lt $ResultSize) {
                $restLink = $data.'@odata.nextLink'
            }
            else {
                $restLink = ""
                $tooManyItems = $true
                $overResult = $ResultSize - ($i - $value.Count)
                Write-PSFMessage -Level Verbose -Message "Resultsize ($ResultSize) exeeded. Output $($overResult) object(s) in record set." -Tag "ResultSize"
            }
        }
        else {
            Write-PSFMessage -Level Verbose -Message "Single item retrived. Outputting data." -Tag "RestData"
            [array]$value = $data
            $restLink = ""
        }

        if((-not $tooManyItems) -or ($overResult -gt 0)) {
            if($overResult -gt 0) {
                $output = $output + $Value[0..($overResult-1)]
            }
            else {
                $output = $output + $Value
            }
        }
    }
    while ($restLink)

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
        if($Delta) {
            Write-PSFMessage -Level Host -Message "Reaching maximum ResultSize before finishing delta query. Next delta query will continue on pending objects. Current ResultSize: $($ResultSize)" -Tag "GetData" -FunctionName $FunctionName
        }
        else {
            Write-PSFMessage -Level Warning -Message "Too many items. Reaching maximum ResultSize before finishing query. You may want to increase the ResultSize. Current ResultSize: $($ResultSize)" -Tag "GetData" -FunctionName $FunctionName
        }
    }
}