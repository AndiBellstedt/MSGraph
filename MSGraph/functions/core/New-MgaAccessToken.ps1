function New-MgaAccessToken {
    <#
    .SYNOPSIS
        Creates an access token for contacting the specified application endpoint

    .DESCRIPTION
        Creates an access token for contacting the specified application endpoint

    .PARAMETER MailboxName
        The email address of the mailbox to access

    .PARAMETER Credential
        The credentials to use to authenticate the request.
        Using this avoids the need to visually interact with the logon screen.
        Only works for accounts that have once logged in visually, but can be used from any machine.

    .PARAMETER ClientId
        The ID of the client to connect with.
        This is the ID of the registered application.

    .PARAMETER RedirectUrl
        Some weird vodoo. Leave it as it is, unless you know better

    .PARAMETER Refresh
        Try to do a refresh login dialag, which may possibly avoid entering password again.

    .PARAMETER Register
        Registers the token, so all subsequent calls to Exchange Online reuse it by default.

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
        [PSCredential]
        $Credential,

        [System.Guid]
        $ClientId = (Get-PSFConfigValue -FullName MSGraph.Tenant.Application.ClientID -NotNull),

        [string]
        $RedirectUrl = (Get-PSFConfigValue -FullName MSGraph.Tenant.Application.RedirectUrl -Fallback "urn:ietf:wg:oauth:2.0:oob"),

        [switch]
        $Refresh,

        [Parameter(ParameterSetName='Register')]
        [switch]
        $Register,

        [Parameter(ParameterSetName='Register')]
        [switch]
        $PassThru
    )

    # variable definitions
    $resourceUri = "https://graph.microsoft.com"
    $baselineTimestamp = [datetime]"1970-01-01Z00:00:00"
    $endpointUri = "https://login.windows.net/common/oauth2"
    $endpointUriAuthorize = "$($endpointUri)/authorize"
    $endpointUriToken = "$($endpointUri)/token "

    # Creating http client for logon
    $httpClient = New-HttpClient

    if (-not $Credential) {
        # Request an authorization code with web form
        # Info https://docs.microsoft.com/en-us/azure/active-directory/develop/v1-protocols-oauth-code#request-an-authorization-code
        Write-PSFMessage -Level Verbose -Message "Authentication is done by code. Query authentication from login form." -Tag "Authorization"

        $queryHash = [ordered]@{
            resource      = [System.Web.HttpUtility]::UrlEncode($resourceUri)
            client_id     = "$($ClientId)"
            response_type = "code"
            redirect_uri  = [System.Web.HttpUtility]::UrlEncode($redirectUrl)
        }
        if($Refresh) { $queryHash.Add("prompt","refresh_session") }
        $phase1auth = Show-OAuthWindow -Url ($endpointUriAuthorize + (Convert-UriQueryFromHash $queryHash))

        # build authorization string with authentication code from web form auth
        $queryHash = [ordered]@{
            resource     = [System.Web.HttpUtility]::UrlEncode($resourceUri)
            client_id    = "$($ClientId)"
            grant_type   = "authorization_code"
            code         = "$($phase1auth.code)"
            redirect_uri = "$($redirectUrl)"
        }
        $authorizationPostRequest = Convert-UriQueryFromHash $queryHash -NoQuestionmark
    }
    else {
        # build authorization string with plain text credentials
        # Info https://docs.microsoft.com/en-us/azure/active-directory/develop/v1-oauth2-client-creds-grant-flow#request-an-access-token
        Write-PSFMessage -Level Verbose -Message "Authentication is done by specified credentials. (No TwoFactor-Authentication supported!)" -Tag "Authorization"

        $queryHash = [ordered]@{
            resource   = [System.Web.HttpUtility]::UrlEncode($resourceUri)
            client_id  = $ClientId
            grant_type = "password"
            username   = $Credential.UserName
            password   = $Credential.GetNetworkCredential().password
        }
        $authorizationPostRequest = Convert-UriQueryFromHash $queryHash -NoQuestionmark
    }

    # Request an access token
    $content = New-Object System.Net.Http.StringContent($authorizationPostRequest, [System.Text.Encoding]::UTF8, "application/x-www-form-urlencoded")
    $clientResult = $httpClient.PostAsync([Uri]($endpointUriToken), $content)
    if($clientResult.Result.StatusCode -eq [System.Net.HttpStatusCode]"OK") {
        Write-PSFMessage -Level Verbose -Message "AccessToken granted. $($clientResult.Result.StatusCode.value__) ($($clientResult.Result.StatusCode)) $($clientResult.Result.ReasonPhrase)" -Tag "Authorization"
    }
    else {
        Stop-PSFFunction -Message "Request for AccessToken failed. $($clientResult.Result.StatusCode.value__) ($($clientResult.Result.StatusCode)) $($clientResult.Result.ReasonPhrase)" -Tag "Authorization" -EnableException $true
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
        Credential     = $Credential
        ClientId       = $ClientId
        Resource       = $resourceUri
        AppRedirectUrl = $RedirectUrl
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

    if($resultObject.IsValid) {
        if ($Register) {
            $script:msgraph_Token = $resultObject
            if($PassThru) { $resultObject }
        }
        else {
            $resultObject
        }
    }
    else {
        Stop-PSFFunction -Message "Token failure. Acquired token is not valid" -EnableException -Tag "Authorization"
    }
}