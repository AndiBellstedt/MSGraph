function Test-MgaMailObjectId {
    <#
    .SYNOPSIS
        Test for valid object ID length on folders or message objects

    .DESCRIPTION
        Validates the length of an Id for objects in Exchange Online
        Helper function used for internal commands.

    .PARAMETER Id
        The Id to test.

    .PARAMETER Type
        The expected type of the object

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.
        (Just used for logging reasons)

    .EXAMPLE
        PS C:\> Test-MgaMailObjectId -Id $Id -Scope Folder

        Test if the specified $Id is a folder
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Id,

        [Parameter(Mandatory = $true)]
        [validateset("Folder","Message")]
        [string]
        $Type,

        [String]
        $FunctionName = $MyInvocation.MyCommand
    )

    begin {
        $status = $false
    }

    process {
        $Token = Resolve-Token -Token $Token -FunctionName $MyInvocation.MyCommand

        Write-PSFMessage -Level Debug -Message "Validating Id '$($Id)' for $($Type) length" -Tag "ValidateObjectId" -FunctionName $FunctionName
        switch ($Type) {
            "Folder" { if ($Id.Length -eq 120 -or $Id.Length -eq 104) { $status = $true } }
            "Message" { if ($Id.Length -eq 152 -or $Id.Length -eq 136) { $status = $true } }
        }
    }

    end {
        if ($status) { Write-PSFMessage -Level Debug -Message "Id has appropriate length ($($Id.Length)) to be a $($Type)." -Tag "ValidateObjectId" -FunctionName $FunctionName }
        $status
    }
}