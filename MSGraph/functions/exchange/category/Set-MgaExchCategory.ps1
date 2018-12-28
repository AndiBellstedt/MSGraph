function Set-MgaExchCategory {
    <#
    .SYNOPSIS
        Set a category in Exchange Online using the graph api.

    .DESCRIPTION
        Set a category in Exchange Online using the graph api.

    .PARAMETER Color
        The color for the category.

        Tab completion is available on this parameter for the list of the 25 predefined colors.

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
        https://docs.microsoft.com/en-us/graph/api/outlookcategory-update?view=graph-rest-1.0

    .EXAMPLE
        PS C:\> Set-MgaExchCategory -Name "Important stuff" -Color Black

        Set color "black" on existing category "Important stuff" in the mailbox of the user connected to through a token.

    .EXAMPLE
        PS C:\> Get-MgaExchCategory -Name "Important stuff" | Set-MgaExchCategory -Color "Blue"

        Set color  "blue" on existing category "Important stuff" in the mailbox of the user connected to through a token.

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([MSGraph.Exchange.Category.OutlookCategory])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [Alias('Name', 'DisplayName', 'Category')]
        [MSGraph.Exchange.Category.CategoryParameter[]]
        $InputObject,

<# Currently not available as writeable property on microsoft graph version 1.0 and beta
        [Parameter(Mandatory = $false)]
        [string]
        $NewName,
#>
        [Parameter(Mandatory = $false)]
        [Alias('ColorName')]
        [MSGraph.Exchange.Category.ColorName]
        $Color,

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
            #region checking input object type and query message if required
            if ($categoryItem.TypeName -like "System.String") {
                $categoryItem = Resolve-MailObjectFromString -Object $categoryItem -User $User -Token $Token -FunctionName $MyInvocation.MyCommand
                if (-not $categoryItem) { continue }
            }

            $User = Resolve-UserInMailObject -Object $categoryItem -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
            #endregion checking input object type and query message if required

            #region prepare rest call to create data
            $bodyJSON = @{}
            $boundParameters = @()
            if ($NewName) {
                $boundParameters = $boundParameters + "NewName"
                $bodyJSON.Add("displayName", $NewName)
            }
            if ($Color) {
                $boundParameters = $boundParameters + "Color"
                [String]$colorValue = [MSGraph.Exchange.Category.OutlookCategory]::Parse($Color)
                $bodyJSON.Add("color", $colorValue.ToLower())
            } 
            $bodyJSON = $bodyJSON | ConvertTo-Json

            $invokeParam = @{
                "Field"        = "outlook/masterCategories/$($categoryItem.Id)"
                "Body"         = $bodyJSON
                "Token"        = $Token
                "User"         = $User
                "FunctionName" = $MyInvocation.MyCommand
            }
            #endregion prepare rest call to create data
            Write-PSFMessage -Level Verbose -Message "Set property '$([string]::Join("', '", $boundParameters))' on category '$($categoryItem)'" -Tag "SetData"

            # set data
            if ($pscmdlet.ShouldProcess($categoryItem, "Set property '$([string]::Join("', '", $boundParameters))'")) {
                $data = Invoke-MgaPatchMethod @invokeParam
            }

            #region output data
            if ($PassThru) {
                foreach ($output in $data) {
                    if ($output.User) { $User = $output.User }
                    $categoryObject = [MSGraph.Exchange.Category.OutlookCategory]::new( $output.id, $output.displayName, $output.color, $User, $output)
                    $categoryObject
                }
            }
            #endregion output data
        }
    }

    end {
    }
}