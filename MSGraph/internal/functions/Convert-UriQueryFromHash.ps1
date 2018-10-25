function Convert-UriQueryFromHash {
    <#
    .SYNOPSIS
        Converts hashtables to a string for REST api calls.

    .DESCRIPTION
        Converts hashtables to a string for REST api calls.

    .PARAMETER hash
        The hashtable to convert to a string

    .PARAMETER NoQuestionmark
        Supress the ? as the first character in the output string

    .EXAMPLE
        PS C:\> Convert-UriQueryFromHash -Hash @{ username = "user"; password = "password"}

        Converts the specified hashtable to the following string:
        ?password=password&username=user

    .EXAMPLE
        PS C:\> Convert-UriQueryFromHash -Hash @{ username = "user"; password = "password"} -NoQuestionmark

        Converts the specified hashtable to the following string:
        password=password&username=user
        #>
    [OutputType([System.String])]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [System.Collections.Hashtable]
        $Hash,

        [switch]
        $NoQuestionmark
    )

    begin {
    }

    process {
        $elements = foreach ($key in $Hash.Keys) {
            $key + "=" + $Hash[$key]
        }
        $elementString = [string]::Join("&", $elements)

        if($NoQuestionMark) {
            "$elementString"
        }
        else {
            "?$elementString"
        }
    }

    end {
    }
}