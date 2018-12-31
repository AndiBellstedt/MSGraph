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
        $msg = "Invalid data or not an access token. $($Token)"
        Stop-PSFFunction -Message $msg -Tag "JWT" -EnableException $true -Exception ([System.Management.Automation.RuntimeException]::new($msg))
    }

    # Split the token in its parts
    $tokenParts = $Token.Split(".")

    # Work on header
    $tokenHeader = [System.Text.Encoding]::UTF8.GetString( (ConvertFrom-Base64StringWithNoPadding $tokenParts[0]) )
    $tokenHeaderJSON = $tokenHeader | ConvertFrom-Json

    # Work on payload
    $tokenPayload = [System.Text.Encoding]::UTF8.GetString( (ConvertFrom-Base64StringWithNoPadding $tokenParts[1]) )
    $tokenPayloadJSON = $tokenPayload | ConvertFrom-Json

    # Work on signature
    $tokenSignature = ConvertFrom-Base64StringWithNoPadding $tokenParts[2]

    # Output
    $resultObject = New-Object MSGraph.Core.JWTAccessTokenInfo

    $resultObject.Header = $tokenHeader
    $resultObject.Payload = $tokenPayload
    $resultObject.Signature = $tokenSignature
    $resultObject.Algorithm = $tokenHeaderJSON.alg
    $resultObject.Type = $tokenHeaderJSON.typ
    if ($tokenPayloadJSON.appid) { $resultObject.ApplicationID = $tokenPayloadJSON.appid }
    $resultObject.ApplicationName = $tokenPayloadJSON.app_displayname
    $resultObject.Audience = $tokenPayloadJSON.aud
    $resultObject.AuthenticationMethod = $tokenPayloadJSON.amr
    $resultObject.ExpirationTime = ([datetime]"1970-01-01Z00:00:00").AddSeconds($tokenPayloadJSON.exp).ToUniversalTime()
    $resultObject.GivenName = $tokenPayloadJSON.given_name
    $resultObject.IssuedAt = ([datetime]"1970-01-01Z00:00:00").AddSeconds($tokenPayloadJSON.iat).ToUniversalTime()
    $resultObject.Name = $tokenPayloadJSON.name
    $resultObject.NotBefore = ([datetime]"1970-01-01Z00:00:00").AddSeconds($tokenPayloadJSON.nbf).ToUniversalTime()
    if ($tokenPayloadJSON.oid) { $resultObject.OID = $tokenPayloadJSON.oid }
    $resultObject.Plattform = $tokenPayloadJSON.platf
    $resultObject.Scope = $tokenPayloadJSON.scp
    $resultObject.SID = $tokenPayloadJSON.onprem_sid
    $resultObject.SourceIPAddr = $tokenPayloadJSON.ipaddr
    $resultObject.SureName = $tokenPayloadJSON.family_name
    $resultObject.TenantID = $tokenPayloadJSON.tid
    $resultObject.UniqueName = $tokenPayloadJSON.unique_name
    $resultObject.UPN = $tokenPayloadJSON.upn
    $resultObject.Version = $tokenPayloadJSON.ver

    #$output
    $resultObject
}