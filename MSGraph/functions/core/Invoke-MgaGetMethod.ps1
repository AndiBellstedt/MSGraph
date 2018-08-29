function Invoke-MgaGetMethod
{
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
		
		$Token
	)
	
	if (-not $Token) { $Token = $script:msgraph_Token }
	if (-not $Token) { Stop-PSFFunction -Message "Not connected! Use New-EORAccessToken to create a Token and either register it or specifs it" -EnableException $true -Category AuthenticationError -Cmdlet $PSCmdlet }
	
	$restLink = "https://graph.microsoft.com/v1.0/$(Resolve-UserString -User $User)/$($Field)"
	do
	{
		$data = Invoke-RestMethod -Method Get -UseBasicParsing -Uri $restLink -Headers @{
			"Authorization" = "Bearer $($Token.AccessToken | ConvertFrom-SecureString)"
			"Prefer"	    = "outlook.timezone=`"$((Get-Timezone).Id)`""
		}
		$data.Value
		$restLink = $data.'@odata.nextLink'
	}
	while ($restLink)
}