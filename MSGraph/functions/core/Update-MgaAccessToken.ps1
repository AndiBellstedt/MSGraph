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
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [MSGraph.Core.AzureAccessToken]
        $Token,

        [Parameter(ParameterSetName = 'Register')]
        [switch]
        $Register,

        [Parameter(ParameterSetName = 'Register')]
        [switch]
        $PassThru
    )

    begin {
        $endpointBaseUri = (Get-PSFConfigValue -FullName MSGraph.Tenant.Authentiation.Endpoint -Fallback 'https://login.microsoftonline.com')
        $baselineTimestamp = [datetime]"1970-01-01Z00:00:00"
    }

    process {
        $Token = Resolve-Token -Token $Token -FunctionName $MyInvocation.MyCommand

        $Credential = $Token.Credential
        $ClientId = $Token.ClientId #$Token.AccessTokenInfo.ApplicationID.Guid
        $RedirectUrl = $Token.AppRedirectUrl.ToString()
        $ResourceUri = $Token.Resource.ToString().TrimEnd('/')
        $Permission = ($Token.Scope | Where-Object { $_ -notin "offline_access", "openid", "profile", "email" })
        $IdentityPlatformVersion = $Token.IdentityPlatformVersion

        if (-not $Token.IsValid) {
            Write-PSFMessage -Level Warning -Message "Token lifetime already expired and can't be newed. New authentication is required. Calling New-MgaAccessToken..." -Tag "Authorization"

            $paramsNewToken = @{
                PassThru                = "True"
                ClientId                = $ClientId
                RedirectUrl             = $RedirectUrl
                ResourceUri             = $ResourceUri
                Permission              = $Permission
                IdentityPlatformVersion = $IdentityPlatformVersion
            }
            if ($Credential) { $paramsNewToken.Add("Credential", $Credential ) }
            if ($Register -or ($script:msgraph_Token.AccessTokenInfo.Payload -eq $Token.AccessTokenInfo.Payload) ) { $paramsNewToken.Add("Register", $true) }
            if (Test-PSFParameterBinding -ParameterName Verbose) { $paramsNewToken.Add("Verbose", $true) }

            $resultObject = New-MgaAccessToken @paramsNewToken
            if ($PassThru) { return $resultObject } else { return }
        }

        Write-PSFMessage -Level Verbose -Message "Start token refresh for application $( if($Token.AppName){$Token.AppName}else{$ClientId} ). (Identity platform version $($IdentityPlatformVersion))" -Tag "Authorization"

        switch ($IdentityPlatformVersion) {
            '1.0' { $endpointUriToken = "$($endpointBaseUri)/common/oauth2/token" }
            '2.0' {
                if ($token.Credential) {
                    $endpointUriToken = "$($endpointBaseUri)/organizations/oauth2/V2.0/token"
                } else {
                    $endpointUriToken = "$($endpointBaseUri)/common/oauth2/V2.0/token"
                }

                [array]$scopes = "offline_access", "openid"
                foreach ($permissionItem in $Permission) {
                    $scopes = $scopes + "$($resourceUri)/$($permissionItem)"
                }
                $scope = [string]::Join(" ", $scopes)
                Remove-Variable -Name scopes -Force -WhatIf:$false -Confirm:$false -Verbose:$false -Debug:$false
                Write-PSFMessage -Level VeryVerbose -Message "Using scope: $($scope)" -Tag "Authorization"
            }
        }

        $queryHash = [ordered]@{
            grant_type    = "refresh_token"
            client_id     = $ClientId
            refresh_token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Token.RefreshToken))
        }
        switch ($IdentityPlatformVersion) {
            '1.0' { $queryHash.Add("resource", [System.Web.HttpUtility]::UrlEncode($resourceUri)) }
            '2.0' {
                $queryHash.Add("scope", [uri]::EscapeDataString($scope))
                $queryHash.Add("redirect_uri", [System.Web.HttpUtility]::UrlEncode($redirectUrl))
            }
        }
        $authorizationPostRequest = Convert-UriQueryFromHash $queryHash -NoQuestionmark

        $content = New-Object System.Net.Http.StringContent($authorizationPostRequest, [System.Text.Encoding]::UTF8, "application/x-www-form-urlencoded")
        $httpClient = New-HttpClient
        $clientResult = $httpClient.PostAsync([Uri]$endpointUriToken, $content)
        $jsonResponse = ConvertFrom-Json -InputObject $clientResult.Result.Content.ReadAsStringAsync().Result -ErrorAction Ignore
        if ($clientResult.Result.StatusCode -eq [System.Net.HttpStatusCode]"OK") {
            Write-PSFMessage -Level Verbose -Message "AccessToken renewal successful. $($clientResult.Result.StatusCode.value__) ($($clientResult.Result.StatusCode)) $($clientResult.Result.ReasonPhrase)" -Tag "Authorization"
        }
        else {
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
                $resultObject.ValidUntil = $baselineTimestamp.AddSeconds($jsonResponse.expires_on).ToLocalTime()
                $resultObject.ValidFrom = $baselineTimestamp.AddSeconds($jsonResponse.not_before).ToLocalTime()
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
            $resultObject.ValidUntil = $resultObject.AccessTokenInfo.ExpirationTime.ToLocalTime()
            $resultObject.ValidFrom = $resultObject.AccessTokenInfo.NotBefore.ToLocalTime()
        }

        # Checking if token is valid
        # ToDo implement "validating token information" -> https://docs.microsoft.com/en-us/azure/active-directory/develop/access-tokens#validating-tokens
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
            Stop-PSFFunction -Message "Token failure. Acquired token is not valid" -EnableException $true -Tag "Authorization"
        }
    }

    end {
    }
}