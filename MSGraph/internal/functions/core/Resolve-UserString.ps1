function Resolve-UserString {
    <#
    .SYNOPSIS
        Converts usernames or email addresses into the user targeting segment of the Rest Api call url.

    .DESCRIPTION
        Converts usernames or email addresses into the user targeting segment of the Rest Api call url.

    .PARAMETER User
        The user to convert

    .PARAMETER ContextData
        Specifies, that the user string should be resolved to a @odata.context field
        Different output is needed on context URLs.

    .EXAMPLE
        PS C:\> Resolve-UserString -User $User

        Resolves $User into a legitimate user targeting string element.

        .EXAMPLE
        PS C:\> Resolve-UserString -User $User -ContextData

        Resolves $User into a legitimate user string for a @odata.context element.
    #>
    [OutputType([System.String])]
    [CmdletBinding()]
    param (
        [string]
        $User,

        [switch]
        $ContextData
    )

    if ($User -eq 'me' -or (-not $User)) {
        return 'me'
    }

    if($ContextData) {
        if ($User -like "users('*") {
            return $User
        } else {
            $userEscaped = [uri]::EscapeDataString($User)
            return "users('$($userEscaped)')"
        }
    } else {
        if ($User -like "users/*") {
            return $User
        } else {
            return "users/$($User)"
        }
    }
}