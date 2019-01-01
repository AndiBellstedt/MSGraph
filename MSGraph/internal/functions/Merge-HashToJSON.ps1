function Merge-HashToJson {
    <#
    .SYNOPSIS
        Merge a hashtable(s) object to a JSON data string(s)

    .DESCRIPTION
        Merge a hashtable(s) object to a JSON data string(s)
        Accepts [hashtable] object(s) as well as [System.Collections.Specialized.OrderedDictionary] object(s)

        Helper function used for internal commands.

    .PARAMETER Hashtable
        The hashtable to convert to json

    .PARAMETER OrderedHashtable
        A hash created by [ordered]@{} to convert to json

    .EXAMPLE
        PS C:\> Merge-HashToJson $hash

        Creates a json string from content in variable $hash.
        This is the recommend usage

        Variable $hash can be:
            $hash = @{ content = "this is a regular hashtable" }
        or
            $hash = [ordered]@{ content = "this is a ordered hashtable" }

    .EXAMPLE
        PS C:\> Merge-HashToJson -Hashtable $hash

        Creates a json string from content in variable $hash.
        Variable $hash has to be a regular hashtable:
            $hash = @{ content = "this is a regular hashtable" }

    .EXAMPLE
        PS C:\> Merge-HashToJson -OrderedHashtable $hash

        Creates a json string from content in variable $hash.
        Variable $hash has to be a ordered hashtable:
            $hash = @{ content = "this is a regular hashtable" }

    #>
    #[CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = "OrderedHash")]
    [CmdletBinding(ConfirmImpact = 'Low')]
    [OutputType([String])]
    param (
        [Parameter(ParameterSetName = "HashTable", Position = 0, Mandatory = $true)]
        [hashtable[]]
        $Hashtable,

        [Parameter(ParameterSetName = "OrderedHash", Position = 0, Mandatory = $true)]
        [System.Collections.Specialized.OrderedDictionary[]]
        $OrderedHashtable
    )

    begin {
    }

    process {
        if ($PSCmdlet.ParameterSetName -like "OrderedHash") {
            $Hashtable = [ordered]@{}
            $Hashtable = $OrderedHashtable
        }

        Write-PSFMessage -Level Debug -Message "Merge hashtable with key(s) ('$([string]::Join("', '", $Hashtable.Keys))') by parameterset $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"
        foreach ($hash in $Hashtable) {
            $JsonParts = @()

            foreach ($key in $hash.Keys) {
                $JsonParts = $JsonParts + """$($key)"" : $($hash[$key])"
            }
            $json = "{`n" + ([string]::Join(",`n", $JsonParts)) + "`n}"

            $json
        }
    }

    end {
    }
}
