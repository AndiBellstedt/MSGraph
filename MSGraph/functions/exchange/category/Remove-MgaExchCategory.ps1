function Remove-MgaExchCategory {
    <#
    .SYNOPSIS
        Remove a category in Exchange Online using the graph api.

    .DESCRIPTION
        Remove a category in Exchange Online using the graph api.

    .PARAMETER Force
        Suppress any confirmation request and enforce removing.

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .PARAMETER PassThru
        Outputs the modified category to the console.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .NOTES
        For addiontional information about Microsoft Graph API go to:
        https://docs.microsoft.com/en-us/graph/api/outlookcategory-delete?view=graph-rest-1.0

    .EXAMPLE
        PS C:\> Remove-MgaExchCategory -Name "Important stuff"

        Remove existing category "Important stuff" in the mailbox of the user connected to through a token.

    .EXAMPLE
        PS C:\> Get-MgaExchCategory -Name "Important stuff" | Remove-MgaExchCategory -Force

        Remove existing category "Important stuff" WITHOUT CONFIRMATION in the mailbox of the user connected to through a token.

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([MSGraph.Exchange.Category.OutlookCategory])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [Alias('Name', 'DisplayName', 'Category')]
        [MSGraph.Exchange.Category.CategoryParameter[]]
        $InputObject,

        [switch]
        $Force,

        [string]
        $User,

        [MSGraph.Core.AzureAccessToken]
        $Token,

        [switch]
        $PassThru
    )
    begin {
        $requiredPermission = "MailboxSettings.ReadWrite"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand
    }

    process {
        foreach ($categoryItem in $InputObject) {
            Write-PSFMessage -Level Verbose -Message "Working on removal of category '$($categoryItem)'" -Tag "QueryData"

            #region checking input object type and query message if required
            if ($categoryItem.TypeName -like "System.String") {
                $categoryItem = Resolve-MailObjectFromString -Object $categoryItem -User $User -Token $Token -FunctionName $MyInvocation.MyCommand
                if (-not $categoryItem) { continue }
            }

            $User = Resolve-UserInMailObject -Object $categoryItem -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
            #endregion checking input object type and query message if required

            #region prepare rest call to create data

            $invokeParam = @{
                "Field"        = "outlook/masterCategories/$($categoryItem.Id)"
                "Token"        = $Token
                "User"         = $User
                "Confirm"      = $false
                "FunctionName" = $MyInvocation.MyCommand
            }
            #endregion prepare rest call to create data

            # set data
            if ($Force) {
                $proceed = $true
            }
            else {
                $proceed = $pscmdlet.ShouldProcess($categoryItem.Name, "Delete")
            }
            if ($proceed) {
                Write-PSFMessage -Level Verbose -Message "Delete category '$($categoryItem)'." -Tag "RemoveData"
                Invoke-MgaDeleteMethod @invokeParam
            }

            #region output data
            if ($PassThru) { $categoryItem.InputObject }
            #endregion output data
        }
    }

    end {
    }
}