function New-HttpClient {
    <#
    .SYNOPSIS
        Generates a HTTP Client.

    .DESCRIPTION
        Generates a HTTP Client for use with web services (REST Api).

    .PARAMETER UserAgentName
        The name of the UserAgent.

    .PARAMETER UserAgentVersion
        The Version of the UserAgent.

    .PARAMETER HeaderType
        Data language in the header.

    .EXAMPLE
        PS C:\> New-HttpClient

        Creates a Http Client with default values

    .EXAMPLE
        PS C:\> New-HttpClient -UserAgentName "PowerShellRestClient" -userAgentVersion "1.1"

        Creates a Http Client with UserAgent "PowerShellRestClient" as name and Version 1.1.

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param (
        [Alias('UserAgent')]
        [String]
        $UserAgentName = (Get-PSFConfigValue -FullName MSGraph.WebClient.UserAgentName -Fallback "PowerShellRestClient"),

        [Alias('Version')]
        [String]
        $userAgentVersion = (Get-PSFConfigValue -FullName MSGraph.WebClient.UserAgentVersion -Fallback "1.1"),

        [String]
        $HeaderType = "application/json"
    )

    process {
        $header = New-Object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue($HeaderType)
        $userAgent = New-Object System.Net.Http.Headers.ProductInfoHeaderValue($UserAgentName, $userAgentVersion)

        $handler = New-Object System.Net.Http.HttpClientHandler
        $handler.CookieContainer = New-Object System.Net.CookieContainer
        $handler.AllowAutoRedirect = $true

        $httpClient = New-Object System.Net.Http.HttpClient($handler)
        $httpClient.Timeout = New-Object System.TimeSpan(0, 0, 90)
        $httpClient.DefaultRequestHeaders.TransferEncodingChunked = $false
        $httpClient.DefaultRequestHeaders.Accept.Add($header)
        $httpClient.DefaultRequestHeaders.UserAgent.Add($userAgent)

        return $httpClient
    }
}