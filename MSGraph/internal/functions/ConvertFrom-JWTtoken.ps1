function ConvertFrom-JWTtoken {
    <#
    .SYNOPSIS
        Converts access tokens to readable objects

    .DESCRIPTION
        Converts access tokens to readable objects

    .PARAMETER Token
        The Token to convert

    .EXAMPLE
        PS C:\> ConvertFrom-JWTtoken -Token $Token

        Converts the content from variable $token to an object
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Token
    )

    # Validate as per https://tools.ietf.org/html/rfc7519 - Access and ID tokens are fine, Refresh tokens will not work
    if ((-not $Token.Contains(".")) -or (-not $Token.StartsWith("eyJ"))) {
        Stop-PSFFunction -Message "Invalid data or not an access token" -EnableException -Tag JWT
    }

    # Split the token in its parts
    $tokenParts = $Token.Split(".")

    # Work on header
    $tokenHeader = [System.Text.Encoding]::UTF8.GetString( (ConvertFrom-Base64StringWithNoPadding $tokenParts[0]) ) #| ConvertFrom-Json

    # Work on payload
    $tokenPayload = [System.Text.Encoding]::UTF8.GetString( (ConvertFrom-Base64StringWithNoPadding $tokenParts[1]) ) #| ConvertFrom-Json

    # Work on signature
    $tokenSignature = ConvertFrom-Base64StringWithNoPadding $tokenParts[2]
    
    # Output
    $resultObject = New-Object MSGraph.Core.JWTAccessTokenInfo -Property @{
        Header    = $tokenHeader
        Payload   = $tokenPayload
        Signature = $tokenSignature
    }

    #$output
    $resultObject 
}