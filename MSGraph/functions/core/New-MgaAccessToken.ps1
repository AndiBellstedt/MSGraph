function New-MgaAccessToken
{
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
	
	.PARAMETER Register
		Registers the token, so all subsequent calls to Exchange Online reuse it by default.
	
	.EXAMPLE
		PS C:\> New-MgaAccessToken -MailboxName 'max.musterman@contoso.com'
	
		Registers an application to run under 'max.mustermann@contoso.com'.
		Requires an interactive session with a user handling the web UI.
	
	.EXAMPLE
		PS C:\> New-MgaAccessToken -MailboxName 'max.musterman@contoso.com' -Credential $cred
	
		Generates a token to a session as max.mustermann@contoso.com under the credentials specified in $cred.
#>	
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$MailboxName,
		
		[PSCredential]
		$Credential,
		
		[System.Guid]
		$ClientId = "1d236c67-7e0b-42bc-88fd-d0b70a3df50a",
		
		[string]
		$RedirectUrl = "urn:ietf:wg:oauth:2.0:oob",
		
		[switch]
		$Register
	)
	
	$resourceUrl = "graph.microsoft.com"
	$prompt = "refresh_session"
	
	$httpClient = New-HttpClient -MailboxName $MailboxName
	$redirectUrl = [System.Web.HttpUtility]::UrlEncode($redirectUrl)
	
	if (-not $Credential)
	{
		$phase1auth = Show-OAuthWindow -Url "https://login.microsoftonline.com/common/oauth2/authorize?resource=https%3A%2F%2F$($resourceURL)&client_id=$($ClientId)&response_type=code&redirect_uri=$($redirectUrl)&prompt=$($prompt)"
		$authorizationPostRequest = "resource=https%3A%2F%2F$($resourceUrl)&client_id=$($ClientId)&grant_type=authorization_code&code=$($phase1auth.code)&redirect_uri=$($redirectUrl)"
	}
	else
	{
		$userName = $Credential.UserName
		$password = $Credential.GetNetworkCredential().password
		$authorizationPostRequest = "resource=https%3A%2F%2F$($resourceUrl)&client_id=$($ClientId)&grant_type=password&username=$($username)&password=$($password)"
	}
	
	$content = New-Object System.Net.Http.StringContent($authorizationPostRequest, [System.Text.Encoding]::UTF8, "application/x-www-form-urlencoded")
	$clientResult = $httpClient.PostAsync([Uri]("https://login.windows.net/common/oauth2/token"), $content)
	$jsonResponse = ConvertFrom-Json -InputObject $clientResult.Result.Content.ReadAsStringAsync().Result
	$baselineTimestamp = [datetime]"1970-01-01Z00:00:00"
	
	$resultObject = New-Object MSGraph.Core.AzureAccessToken -Property @{
		TokenType  = $jsonResponse.token_type
		MailboxName = $MailboxName
		Scope	   = $jsonResponse.scope -split " "
		ValidUntilUtc = $baselineTimestamp.AddSeconds($jsonResponse.expires_on).ToUniversalTime()
		ValidFromUtc = $baselineTimestamp.AddSeconds($jsonResponse.not_before).ToUniversalTime()
		ValidUntil = New-Object DateTime($baselineTimestamp.AddSeconds($jsonResponse.expires_on).Ticks)
		ValidFrom  = New-Object DateTime($baselineTimestamp.AddSeconds($jsonResponse.not_before).Ticks)
		AccessToken = $null
		RefreshToken = $null
		IDToken    = $null
		Credential = $Credential
		ClientId   = $ClientId
	}
	if ($jsonResponse.access_token) { $resultObject.AccessToken = ($jsonResponse.access_token | ConvertTo-SecureString -AsPlainText -Force) }
	if ($jsonResponse.refresh_token) { $resultObject.RefreshToken = ($jsonResponse.refresh_token | ConvertTo-SecureString -AsPlainText -Force) }
	if ($jsonResponse.id_token) { $resultObject.IDToken = ($jsonResponse.id_token | ConvertTo-SecureString -AsPlainText -Force) }
	if ((Get-Date).IsDaylightSavingTime())
	{
		#$resultObject.ValidUntilUtc = $resultObject.ValidUntilUtc.AddHours(1)
		#$resultObject.ValidFromUtc = $resultObject.ValidFromUtc.AddHours(1)
		
		$resultObject.ValidUntil = $resultObject.ValidUntil.AddHours(1)
		$resultObject.ValidFrom = $resultObject.ValidFrom.AddHours(1)
	}
	if ($resultObject.IsValid -and $Register)
	{
		$script:msgraph_Token = $resultObject
	}
	else { $resultObject }
}