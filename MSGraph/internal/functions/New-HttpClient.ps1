function New-HttpClient
{
<#
	.SYNOPSIS
		Generates a HTTP Client for use with the Exchange Online Rest Api.
	
	.DESCRIPTION
		Generates a HTTP Client for use with the Exchange Online Rest Api.
	
	.PARAMETER MailboxName
		The mailbox to connect with.
	
	.EXAMPLE
		PS C:\> New-HttpClient -MailboxName 'foo@contoso.onmicrosoft.com'
	
		Creates a Http Client for connecting as 'foo@contoso.onmicrosoft.com'
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $false)]
		[string]
		$MailboxName
	)
	process
	{
		$handler = New-Object System.Net.Http.HttpClientHandler
		$handler.CookieContainer = New-Object System.Net.CookieContainer
		$handler.AllowAutoRedirect = $true
		$httpClient = New-Object System.Net.Http.HttpClient($handler)
		
		$header = New-Object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json")
		$httpClient.DefaultRequestHeaders.Accept.Add($header)
		$httpClient.Timeout = New-Object System.TimeSpan(0, 0, 90)
		$httpClient.DefaultRequestHeaders.TransferEncodingChunked = $false
        if($MailboxName) {
            if (-not $httpClient.DefaultRequestHeaders.Contains("X-AnchorMailbox"))
            {
                $httpClient.DefaultRequestHeaders.Add("X-AnchorMailbox", $MailboxName)
                Write-Verbose "mailbox specified - $MailboxName" -Verbose
            }
        }
		$header = New-Object System.Net.Http.Headers.ProductInfoHeaderValue("RestClient", "1.1")
		$httpClient.DefaultRequestHeaders.UserAgent.Add($header)
		
		return $httpClient
	}
}