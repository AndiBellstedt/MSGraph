function Update-MgaAccessToken {
    <#
    .SYNOPSIS
        Updates an existing access token

    .DESCRIPTION
        Updates an existing access token for contacting the specified application endpoint as long
        as the token is still valid. Otherwise, a new access is called through New-MgaAccessToken.

    .PARAMETER Token
        The token object to renew.

    .PARAMETER Register
        Registers the renewed token, so all subsequent calls to Exchange Online reuse it by default.

    .PARAMETER PassThru
        Outputs the token to the console, even when the register switch is set

    .EXAMPLE
        PS C:\> New-MgaAccessToken -MailboxName 'max.musterman@contoso.com'

        Registers an application to run under 'max.mustermann@contoso.com'.
        Requires an interactive session with a user handling the web UI.

    .EXAMPLE
        PS C:\> New-MgaAccessToken -MailboxName 'max.musterman@contoso.com' -Credential $cred

        Generates a token to a session as max.mustermann@contoso.com under the credentials specified in $cred.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        #[MSGraph.Core.AzureAccessToken]
        $Token,

        [Parameter(ParameterSetName='Register')]
        [switch]
        $Register,

        [Parameter(ParameterSetName='Register')]
        [switch]
        $PassThru
    )

    begin {
    }

    process {
        if (-not $Token) {
            $Token = $script:msgraph_Token
            $Register = $true
        }
        if (-not $Token) { Stop-PSFFunction -Message "Not connected! Use New-MgaAccessToken to create a Token and either register it or specifs it." -EnableException $true -Category AuthenticationError -Cmdlet $PSCmdlet }

        if (-not $Token.IsValid) {
            Write-PSFMessage -Level Warning -Message "Token lifetime already expired and can't be newed. New authentication is required. Calling New-MgaAccessToken..." -Tag "Authorization"
            $paramsNewToken = @{
                ClientId = $Token.AccessTokenInfo.ApplicationID.Guid
                RedirectUrl = $Token.AppRedirectUrl
            }
            if ($Token.Credential) { $paramsNewToken.Add("Credential", $Token.Credential ) }
            if ($Register -or ($script:msgraph_Token.AccessTokenInfo.Payload -eq $Token.AccessTokenInfo.Payload) ) { $paramsNewToken.Add("Register", $true) }
            $resultObject = New-MgaAccessToken -PassThru @paramsNewToken
            if ($PassThru) { return $resultObject } else { return }
        }

        $resourceUri = "https://graph.microsoft.com"
        $endpointUri = "https://login.windows.net/common/oauth2"
        $endpointUriToken = "$($endpointUri)/token "

        $baselineTimestamp = [datetime]"1970-01-01Z00:00:00"
        $httpClient = New-HttpClient

        $queryHash = [ordered]@{
            grant_type    = "refresh_token"
            resource      = [System.Web.HttpUtility]::UrlEncode($resourceUri)
            client_id     = $Token.ClientId.Guid
            refresh_token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Token.RefreshToken))
        }
        $authorizationPostRequest = Convert-UriQueryFromHash $queryHash -NoQuestionmark


        $content = New-Object System.Net.Http.StringContent($authorizationPostRequest, [System.Text.Encoding]::UTF8, "application/x-www-form-urlencoded")
        $clientResult = $httpClient.PostAsync([Uri]$endpointUriToken, $content)
        if ($clientResult.Result.StatusCode -eq [System.Net.HttpStatusCode]"OK") {
            Write-PSFMessage -Level Verbose -Message "AccessToken renewal successful. $($clientResult.Result.StatusCode.value__) ($($clientResult.Result.StatusCode)) $($clientResult.Result.ReasonPhrase)" -Tag "Authorization"
        }
        else {
            Stop-PSFFunction -Message "Failed to renew AccessToken! $($clientResult.Result.StatusCode.value__) ($($clientResult.Result.StatusCode)) $($clientResult.Result.ReasonPhrase)" -Tag "Authorization" -EnableException $true
        }
        $jsonResponse = ConvertFrom-Json -InputObject $clientResult.Result.Content.ReadAsStringAsync().Result

        # Build output object
        $resultObject = New-Object MSGraph.Core.AzureAccessToken -Property @{
            TokenType      = $jsonResponse.token_type
            Scope          = $jsonResponse.scope -split " "
            ValidUntilUtc  = $baselineTimestamp.AddSeconds($jsonResponse.expires_on).ToUniversalTime()
            ValidFromUtc   = $baselineTimestamp.AddSeconds($jsonResponse.not_before).ToUniversalTime()
            ValidUntil     = New-Object DateTime($baselineTimestamp.AddSeconds($jsonResponse.expires_on).Ticks)
            ValidFrom      = New-Object DateTime($baselineTimestamp.AddSeconds($jsonResponse.not_before).Ticks)
            AccessToken    = $null
            RefreshToken   = $null
            IDToken        = $null
            Credential     = $Token.Credential
            ClientId       = $Token.ClientId.Guid
            Resource       = $Token.Resource.ToString()
            AppRedirectUrl = $Token.AppRedirectUrl.ToString()
        }
        # Insert token data into output object. done as secure string to prevent text output of tokens
        if ($jsonResponse.psobject.Properties.name -contains "refresh_token") { $resultObject.RefreshToken = ($jsonResponse.refresh_token | ConvertTo-SecureString -AsPlainText -Force) }
        if ($jsonResponse.psobject.Properties.name -contains "id_token") { $resultObject.IDToken = ($jsonResponse.id_token | ConvertTo-SecureString -AsPlainText -Force) }
        if ($jsonResponse.psobject.Properties.name -contains "access_token") {
            $resultObject.AccessToken = ($jsonResponse.access_token | ConvertTo-SecureString -AsPlainText -Force)
            $resultObject.AccessTokenInfo = ConvertFrom-JWTtoken -Token $jsonResponse.access_token
        }
        if ((Get-Date).IsDaylightSavingTime()) {
            $resultObject.ValidUntil = $resultObject.ValidUntil.AddHours(1)
            $resultObject.ValidFrom = $resultObject.ValidFrom.AddHours(1)
        }

        if ($resultObject.IsValid) {
            if ($Register) {
                $script:msgraph_Token = $resultObject
                if ($PassThru) { $resultObject }
            }
            else {
                $resultObject
            }
        }
        else {
            Stop-PSFFunction -Message "Token failure. Acquired token is not valid" -EnableException -Tag "Authorization"
        }
    }

    end {
    }
}