function ConvertFrom-Base64StringWithNoPadding( [string]$Data ) {
    <#
    .SYNOPSIS
        Helper function build valid Base64 strings from JWT access tokens

    .DESCRIPTION
        Helper function build valid Base64 strings from JWT access tokens

    .PARAMETER Data
        The Token to convert

    .EXAMPLE
        PS C:\> ConvertFrom-Base64StringWithNoPadding -Data $data

        build valid base64 string the content from variable $data
    #>
    $Data = $Data.Replace('-', '+').Replace('_', '/')
    switch ($Data.Length % 4) {
        0 { break }
        2 { $Data += '==' }
        3 { $Data += '=' }
        default { throw New-Object ArgumentException('data') }
    }
    [System.Convert]::FromBase64String($Data)
}