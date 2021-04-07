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

    .PARAMETER ShowLoginWindow
        Force to show login window with account selection again.

    .PARAMETER Register
        Registers the token, so all subsequent calls to Exchange Online reuse it by default.

    .PARAMETER PassThru
        Outputs the token to the console, even when the register switch is set

    .PARAMETER IdentityPlatformVersion
        Specifies the endpoint version of the logon platform (Microsoft identity platform) where to connect for logon.
        Use 2.0 if you want to login with a Microsoft Account.

        For more information goto https://docs.microsoft.com/en-us/azure/active-directory/develop/about-microsoft-identity-platform

    .PARAMETER Tenant
        The entry point to sign into.
        The allowed values are common, organizations, consumers.

    .PARAMETER Permission
        Only applies if IdentityPlatformVersion version 2.0 is used.
        Specify the requested permission in the token.

    .PARAMETER ResourceUri
        The App ID URI of the target web API (secured resource).
        It may be https://graph.microsoft.com

    .EXAMPLE
        PS C:\> New-MgaAccessToken -Register

        For best usage and convinience, mostly, this is what you want to use.

        Requires an interactive session with a user handling the web UI.
        For addition the aquired token will be registered in the module as default value to use with all the commands.

    .EXAMPLE
        PS C:\> $token = New-MgaAccessToken

        Requires an interactive session with a user handling the web UI.

    .EXAMPLE
        PS C:\> $token = New-MgaAccessToken -Credential $cred

        Generates a token with the credentials specified in $cred.
        This is not supported for personal accounts (Micrsoft Accounts).

    .EXAMPLE
        PS C:\> New-MgaAccessToken -Register -ShowLoginWindow -ClientId '4a6acbac-d325-47a3-b59b-d2e9e05a37c1' -RedirectUrl 'urn:ietf:wg:oauth:2.0:oob' -IdentityPlatformVersion '2.0'

        Requires an interactive session with a user handling the web UI.
        Always prompt for account selection windows.
        Connecting against Azure Application with ID '4a6acbac-d325-47a3-b59b-d2e9e05a37c1'.
        Specifies RedirectUrl 'urn:ietf:wg:oauth:2.0:oob' (default value for interactive apps).
        Use Authentication Plattform 1.0, which only allows AzureAD business accounts to logon.

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding(DefaultParameterSetName = "LoginWithWebForm")]
    [Alias('Connect-MgaGraph')]
    param (
        [Parameter(ParameterSetName = 'LoginWithCredentialObject')]
        [PSCredential]
        $Credential,

        [System.Guid]
        $ClientId = (Get-PSFConfigValue -FullName MSGraph.Tenant.Application.ClientID -NotNull),

        [string]
        $RedirectUrl = (Get-PSFConfigValue -FullName MSGraph.Tenant.Application.RedirectUrl -Fallback "urn:ietf:wg:oauth:2.0:oob"),

        [Parameter(ParameterSetName = 'LoginWithWebForm')]
        [Alias('Force')]
        [switch]
        $ShowLoginWindow,

        [ValidateSet('1.0', '2.0')]
        [string]
        $IdentityPlatformVersion = (Get-PSFConfigValue -FullName MSGraph.Tenant.Authentiation.IdentityPlatformVersion -Fallback '2.0'),

        [String[]]
        $Permission,

        [String]
        $ResourceUri = (Get-PSFConfigValue -FullName MSGraph.Tenant.ApiConnection -Fallback 'https://graph.microsoft.com'),

        [ValidateSet('common', 'organizations', 'consumers')]
        [String]
        $Tenant = 'common',

        [switch]
        $Register,

        [switch]
        $PassThru
    )
    begin {
        $baselineTimestamp = [datetime]"1970-01-01Z00:00:00"
        $endpointBaseUri = (Get-PSFConfigValue -FullName MSGraph.Tenant.Authentiation.Endpoint -Fallback 'https://login.microsoftonline.com')

        if ($IdentityPlatformVersion -like '1.0' -and $Permission) {
            Write-PSFMessage -Level Warning -Message "Individual pemissions are not supported in combination with IdentityPlatformVersion 1.0. Specified Permission ($([String]::Join(", ", $Permission))) in parameter will be ignored" -Tag "ParameterSetHandling"
            $Permission = ""
        } elseif ($IdentityPlatformVersion -like '2.0' -and (-not $Permission)) {
            $Permission = @("Mail.ReadWrite.Shared")
        }
    }

    process {
        # variable definitions
        switch ($IdentityPlatformVersion) {
            '1.0' { $endpointUri = "$($endpointBaseUri)/$($Tenant)/oauth2" }
            '2.0' {
                if ($Credential -and $Tenant -notlike "organizations") {
                    $endpointUri = "$($endpointBaseUri)/organizations/oauth2/V2.0"
                } else {
                    $endpointUri = "$($endpointBaseUri)/$($Tenant)/oauth2/V2.0"
                }
            }
        }

        $endpointUriAuthorize = "$($endpointUri)/authorize"
        $endpointUriToken = "$($endpointUri)/token"
        Write-PSFMessage -Level Verbose -Message "Start authentication against endpoint $($endpointUri). (Identity platform version $($IdentityPlatformVersion))" -Tag "Authorization"
        Write-PSFMessage -Level VeryVerbose -Message "Try to get token for usage of application ClientID: $($ClientId) to interact with ResourceAPI: $($ResourceUri)" -Tag "Authorization"

        if ($IdentityPlatformVersion -like '2.0') {
            [array]$scopes = "offline_access", "openid" # offline_access to get refreshtoken
            foreach ($permissionItem in $Permission) {
                $scopes = $scopes + "$($resourceUri)/$($permissionItem)"
            }
            $scope = [string]::Join(" ", $scopes)
            Remove-Variable -Name scopes -Force -WhatIf:$false -Confirm:$false -Verbose:$false -Debug:$false
            Write-PSFMessage -Level VeryVerbose -Message "Using scope: $($scope)" -Tag "Authorization"
        }

        #region Request an authorization code (login procedure)
        if (-not $Credential) {
            # build authorization string with web form
            # Info https://docs.microsoft.com/en-us/azure/active-directory/develop/v1-protocols-oauth-code#request-an-authorization-code
            Write-PSFMessage -Level Verbose -Message "Authentication is done by code. Query authentication from login form." -Tag "Authorization"

            $queryHash = [ordered]@{
                client_id     = "$($ClientId)"
                response_type = "code"
                redirect_uri  = [System.Web.HttpUtility]::UrlEncode($redirectUrl)
            }
            switch ($IdentityPlatformVersion) {
                '1.0' {
                    $queryHash.Add("resource", [System.Web.HttpUtility]::UrlEncode($resourceUri)) # optional, but recommended
                    if ($ShowLoginWindow) { $queryHash.Add("prompt", "select_account") }
                }

                '2.0' {
                    $queryHash.Add("scope", [uri]::EscapeDataString($scope))
                    if ($ShowLoginWindow) { $queryHash.Add("prompt", "login") }
                }
            }

            # Show login windows (web form)
            $phase1auth = Show-OAuthWindow -Url ($endpointUriAuthorize + (Convert-UriQueryFromHash $queryHash))
            if (-not $phase1auth.code) {
                $msg = "Authentication failed. Unable to obtain AccessToken.`n$($phase1auth.error_description)"
                if ($phase1auth.error) { $msg = $phase1auth.error.ToUpperInvariant() + " - " + $msg }
                Stop-PSFFunction -Message $msg -Tag "Authorization" -EnableException $true -Exception ([System.Management.Automation.RuntimeException]::new($msg))
            }

            # build authorization string with authentication code from web form auth
            $tokenQueryHash = [ordered]@{
                client_id    = "$($ClientId)"
                grant_type   = "authorization_code"
                code         = "$($phase1auth.code)"
                redirect_uri = "$($redirectUrl)"
            }
            switch ($IdentityPlatformVersion) {
                '1.0' { $tokenQueryHash.Add("resource", [System.Web.HttpUtility]::UrlEncode($resourceUri)) }
                '2.0' { $tokenQueryHash.Add("scope", [uri]::EscapeDataString($scope)) }
            }
            $authorizationPostRequest = Convert-UriQueryFromHash $tokenQueryHash -NoQuestionmark
        } else {
            # build authorization string with plain text credentials
            # Info https://docs.microsoft.com/en-us/azure/active-directory/develop/v1-oauth2-client-creds-grant-flow#request-an-access-token
            Write-PSFMessage -Level Verbose -Message "Authentication is done by specified credentials. (No TwoFactor-Authentication supported!)" -Tag "Authorization"

            $tokenQueryHash = [ordered]@{
                grant_type = "password"
                username   = $Credential.UserName
                password   = $Credential.GetNetworkCredential().password
                client_id  = $ClientId
            }
            switch ($IdentityPlatformVersion) {
                '1.0' { $tokenQueryHash.Add("resource", [System.Web.HttpUtility]::UrlEncode($resourceUri)) }
                '2.0' { $tokenQueryHash.Add("scope", [uri]::EscapeDataString($scope)) }
            }

            $authorizationPostRequest = Convert-UriQueryFromHash $tokenQueryHash -NoQuestionmark
        }
        #endregion Request an authorization code  (login procedure)

        # Request an access token
        $content = New-Object System.Net.Http.StringContent($authorizationPostRequest, [System.Text.Encoding]::UTF8, "application/x-www-form-urlencoded")
        $httpClient = New-HttpClient
        $clientResult = $httpClient.PostAsync([Uri]($endpointUriToken), $content)
        $jsonResponse = ConvertFrom-Json -InputObject $clientResult.Result.Content.ReadAsStringAsync().Result -ErrorAction Ignore
        if ($clientResult.Result.StatusCode -eq [System.Net.HttpStatusCode]"OK") {
            Write-PSFMessage -Level Verbose -Message "AccessToken granted. $($clientResult.Result.StatusCode.value__) ($($clientResult.Result.StatusCode)) $($clientResult.Result.ReasonPhrase)" -Tag "Authorization"
        } else {
            $httpClient.CancelPendingRequests()
            $msg = "Request for AccessToken failed. $($clientResult.Result.StatusCode.value__) ($($clientResult.Result.StatusCode)) $($clientResult.Result.ReasonPhrase) `n$($jsonResponse.error_description)"
            Stop-PSFFunction -Message $msg -Tag "Authorization" -EnableException $true -Exception ([System.Management.Automation.RuntimeException]::new($msg))
        }

        # Build output object
        $resultObject = New-Object -TypeName MSGraph.Core.AzureAccessToken -Property @{
            IdentityPlatformVersion = $IdentityPlatformVersion
            TokenType               = $jsonResponse.token_type
            AccessToken             = $null
            RefreshToken            = $null
            IDToken                 = $null
            Credential              = $Credential
            ClientId                = $ClientId
            Resource                = $resourceUri
            AppRedirectUrl          = $RedirectUrl
        }
        switch ($IdentityPlatformVersion) {
            '1.0' {
                $resultObject.Scope = $jsonResponse.scope -split " "
                $resultObject.ValidUntilUtc = $baselineTimestamp.AddSeconds($jsonResponse.expires_on).ToUniversalTime()
                $resultObject.ValidFromUtc = $baselineTimestamp.AddSeconds($jsonResponse.not_before).ToUniversalTime()
                $resultObject.ValidUntil = $baselineTimestamp.AddSeconds($jsonResponse.expires_on).ToLocalTime().AddHours( [int]$baselineTimestamp.AddSeconds($jsonResponse.expires_on).ToLocalTime().IsDaylightSavingTime() )
                $resultObject.ValidFrom = $baselineTimestamp.AddSeconds($jsonResponse.not_before).ToLocalTime().AddHours( [int]$baselineTimestamp.AddSeconds($jsonResponse.not_before).ToLocalTime().IsDaylightSavingTime() )
            }
            '2.0' {
                $resultObject.Scope = $jsonResponse.scope.Replace("$ResourceUri/", '') -split " "
                $resultObject.ValidUntilUtc = (Get-Date).AddSeconds($jsonResponse.expires_in).ToUniversalTime()
                $resultObject.ValidFromUtc = (Get-Date).ToUniversalTime()
                $resultObject.ValidUntil = (Get-Date).AddSeconds($jsonResponse.expires_in).ToLocalTime()
                $resultObject.ValidFrom = (Get-Date).ToLocalTime()
            }
        }

        # Insert token data into output object. done as secure string to prevent text output of tokens
        if ($jsonResponse.psobject.Properties.name -contains "refresh_token") { $resultObject.RefreshToken = ($jsonResponse.refresh_token | ConvertTo-SecureString -AsPlainText -Force) }
        if ($jsonResponse.psobject.Properties.name -contains "id_token") {
            $resultObject.IDToken = ($jsonResponse.id_token | ConvertTo-SecureString -AsPlainText -Force)
            $resultObject.AccessTokenInfo = ConvertFrom-JWTtoken -Token $jsonResponse.id_token
        }
        if ($jsonResponse.psobject.Properties.name -contains "access_token") {
            $resultObject.AccessToken = ($jsonResponse.access_token | ConvertTo-SecureString -AsPlainText -Force)
            if ($jsonResponse.access_token.Contains(".") -and $jsonResponse.access_token.StartsWith("eyJ")) {
                $resultObject.AccessTokenInfo = ConvertFrom-JWTtoken -Token $jsonResponse.access_token
            }
        }

        # Getting validity period out of AccessToken information
        if ($resultObject.AccessTokenInfo -and $resultObject.AccessTokenInfo.TenantID.ToString() -notlike "9188040d-6c67-4c5b-b112-36a304b66dad") {
            $resultObject.ValidUntilUtc = $resultObject.AccessTokenInfo.ExpirationTime.ToUniversalTime()
            $resultObject.ValidFromUtc = $resultObject.AccessTokenInfo.NotBefore.ToUniversalTime()
            $resultObject.ValidUntil = $resultObject.AccessTokenInfo.ExpirationTime.ToLocalTime().AddHours( [int]$resultObject.AccessTokenInfo.ExpirationTime.ToLocalTime().IsDaylightSavingTime() )
            $resultObject.ValidFrom = $resultObject.AccessTokenInfo.NotBefore.ToLocalTime().AddHours( [int]$resultObject.AccessTokenInfo.NotBefore.ToLocalTime().IsDaylightSavingTime() )
        }

        # Checking if token is valid
        # ToDo implement "validating token information" -> https://docs.microsoft.com/en-us/azure/active-directory/develop/access-tokens#validating-tokens
        if ($resultObject.IsValid) {
            if ($Register) {
                $script:msgraph_Token = $resultObject
                if ($PassThru) { $resultObject }
            } else {
                $resultObject
            }
        } else {
            Stop-PSFFunction -Message "Token failure. Acquired token is not valid" -EnableException $true -Tag "Authorization"
        }
    }
}
