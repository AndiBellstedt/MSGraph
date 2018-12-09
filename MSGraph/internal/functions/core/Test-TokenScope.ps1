function Test-TokenScope {
    <#
    .SYNOPSIS
        Test for scopes existence on a Token

    .DESCRIPTION
        Test for existence on scopes (permussions) in a Token
        Helper function used for internal commands.

    .PARAMETER Token
        The Token to test.

    .PARAMETER Scope
        The scope(s) the check for existence.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.
        (Just used for logging reasons)

    .EXAMPLE
        PS C:\> Test-TokenScope -User $Token -Scope "Mail.Read"

        Test if the specified Token contains scope "Mail.Read"
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [MSGraph.Core.AzureAccessToken]
        $Token,

        [Parameter(Mandatory = $true)]
        [string[]]
        $Scope,

        [String]
        $FunctionName = $MyInvocation.MyCommand
    )

    begin {
        $Status = $false
    }

    process {
        $Token = Resolve-Token -Token $Token -FunctionName $MyInvocation.MyCommand
        
        Write-PSFMessage -Level VeryVerbose -Message "Validating token scope ($([String]::Join(", ",$Token.Scope))) against specified scope(s) ($([String]::Join(", ",$Scope)))" -Tag "Authenication" -FunctionName $FunctionName
        foreach ($scopeName in $Scope) {
            foreach ($tokenScope in $Token.Scope) {
                if($tokenScope -like "$scopeName*") {
                    Write-PSFMessage -Level Debug -Message "Token has appropriate scope ($($scopeName))" -Tag "Authenication" -FunctionName $FunctionName
                    $Status = $true
                }
            }
        }
    }

    end {
        $Status
    }
}