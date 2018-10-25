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

    .PARAMETER ResultSize
        The user to execute this under. Defaults to the user the token belongs to.

    .PARAMETER Token
        The access token to use to connect.

    .EXAMPLE
        PS C:\> Invoke-MgaGetMethod -Field 'mailFolders' -Token $Token -User $User

        Retrieves a list of email folders for the user $User, using the token stored in $Token
    #>
    [CmdletBinding()]
    param (
        [string[]]
        $Field,

        [string]
        $User = "me",

        [Int64]
        $ResultSize = (Get-PSFConfigValue -FullName 'MSGraph.Query.ResultSize' -Fallback 100),

        $Token
    )
    if (-not $Token) { $Token = $script:msgraph_Token }
    if (-not $Token) { Stop-PSFFunction -Message "Not connected! Use New-MgaAccessToken to create a Token and either register it or specifs it" -EnableException $true -Category AuthenticationError -Cmdlet $PSCmdlet }
    if ( (-not $Token.IsValid) -or ($Token.PercentRemaining -lt 15) ) {
        # if token is invalid or less then 15 percent of lifetime -> go and refresh the token
        $paramsTokenRefresh = @{
            Token = $Token
            PassThru = $true
        }
        if ($script:msgraph_Token.AccessTokenInfo.Payload -eq $Token.AccessTokenInfo.Payload) { $paramsTokenRefresh.Add("Register", $true) }
        if ($Token.Credential) { $paramsTokenRefresh.Add("Credential", $Token.Credential) }
        $Token = Update-MgaAccessToken @paramsTokenRefresh
    }
    if ($ResultSize -eq 0) { $ResultSize = [Int64]::MaxValue }

    [Int64]$i = 0
    $restLink = "https://graph.microsoft.com/v1.0/$(Resolve-UserString -User $User)/$($Field)"
    do {
        $data = Invoke-RestMethod -Method Get -UseBasicParsing -Uri $restLink -Headers @{
            "Authorization" = "Bearer $( [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token.AccessToken)) )"
            "Prefer"        = "outlook.timezone=`"$((Get-Timezone).Id)`""
        }
        $data.Value
        $i = $i + $data.Value.Count
        if($i -lt $ResultSize ) {
            $restLink = $data.'@odata.nextLink'
        }
        else {
            $restLink = ""
            Write-PSFMessage -Level Warning -Message "Too many items. Reaching maximum ResultSize before finishing query. You may want to increase the ResultSize. Current ResultSize: $($ResultSize)" -Tag "GetData" -FunctionName $PSCmdlet
        }
    }
    while ($restLink)
}