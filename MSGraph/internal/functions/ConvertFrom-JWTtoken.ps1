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
    $tokenHeader = [System.Text.Encoding]::UTF8.GetString( (ConvertFrom-Base64StringWithNoPadding $tokenParts[0]) )
    $tokenHeaderJSON = $tokenHeader | ConvertFrom-Json

    # Work on payload
    $tokenPayload = [System.Text.Encoding]::UTF8.GetString( (ConvertFrom-Base64StringWithNoPadding $tokenParts[1]) )
    $tokenPayloadJSON = $tokenPayload | ConvertFrom-Json

    # Work on signature
    $tokenSignature = ConvertFrom-Base64StringWithNoPadding $tokenParts[2]

    # Output
    $resultObject = New-Object MSGraph.Core.JWTAccessTokenInfo -Property @{
        Header               = $tokenHeader
        Payload              = $tokenPayload
        Signature            = $tokenSignature
        Algorithm            = $tokenHeaderJSON.alg
        Type                 = $tokenHeaderJSON.typ
        ApplicationID        = $tokenPayloadJSON.appid
        ApplicationName      = $tokenPayloadJSON.app_displayname
        Audience             = $tokenPayloadJSON.aud
        AuthenticationMethod = $tokenPayloadJSON.amr
        ExpirationTime       = ([datetime]"1970-01-01Z00:00:00").AddSeconds($tokenPayloadJSON.exp).ToUniversalTime()
        GivenName            = $tokenPayloadJSON.given_name
        IssuedAt             = ([datetime]"1970-01-01Z00:00:00").AddSeconds($tokenPayloadJSON.iat).ToUniversalTime()
        Name                 = $tokenPayloadJSON.name
        NotBefore            = ([datetime]"1970-01-01Z00:00:00").AddSeconds($tokenPayloadJSON.nbf).ToUniversalTime()
        OID                  = $tokenPayloadJSON.oid
        Plattform            = $tokenPayloadJSON.platf
        Scope                = $tokenPayloadJSON.scp
        SID                  = $tokenPayloadJSON.onprem_sid
        SourceIPAddr         = $tokenPayloadJSON.ipaddr
        SureName             = $tokenPayloadJSON.family_name
        TenantID             = $tokenPayloadJSON.tid
        UniqueName           = $tokenPayloadJSON.unique_name
        UPN                  = $tokenPayloadJSON.upn
        Version              = $tokenPayloadJSON.ver
    }

    #$output
    $resultObject
}