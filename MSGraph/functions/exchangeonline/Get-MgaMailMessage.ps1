function Get-MgaMailMessage
{
<#
	.SYNOPSIS
		Retrieves messages from a email folder from Exchange Online using the graph Api.
	
	.DESCRIPTION
		Retrieves messages from a email folder from Exchange Online using the graph Api.
	
	.PARAMETER FolderName
		The display name of the folder to search.
		Defaults to the inbox.
	
	.PARAMETER User
		The user-account to access. Defaults to the main user connected as.
		Can be any primary email name of any user the connected token has access to.
	
	.PARAMETER Token
		The token representing an established connection to the Microsoft Graph Api.
		Can be created by using New-EORAccessToken.
		Can be omitted if a connection has been registered using the -Register parameter on New-EORAccessToken.
	
	.EXAMPLE
		PS C:\> Get-MgaMailMessage
	
		Return all emails in the inbox of the user connected to through a token
#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('DisplayName')]
		[string[]]
		$FolderName = 'Inbox',
		
		[string]
		$User = 'me',
		
		$Token
	)
	
	process
	{
		foreach ($folder in $FolderName)
		{
			Write-PSFMessage -Level Verbose -Message "Searching $folder"
			Invoke-MgaGetMethod -Field "mailFolders('$($folder)')/messages" -User $User -Token $Token
		}
	}
}