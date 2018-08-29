function Resolve-UserString
{
<#
	.SYNOPSIS
		Converts usernames or email addresses into the user targeting segment of the Rest Api call url.
	
	.DESCRIPTION
		Converts usernames or email addresses into the user targeting segment of the Rest Api call url.
	
	.PARAMETER User
		The user to convert
	
	.EXAMPLE
		PS C:\> Resolve-UserString -User $User
	
		Resolves $User into a legitimate user targeting string element.
#>
	[OutputType([System.String])]
	[CmdletBinding()]
	param (
		[string]
		$User
	)
	
	if ($User -eq 'me') { return 'me' }
	elseif ($User -like "users/*") { return $User }
	else { return "users/$($User)" }
}