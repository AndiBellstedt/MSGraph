function New-MgaExchCategory {
    <#
    .SYNOPSIS
        Creates a new category in Exchange Online using the graph api.

    .DESCRIPTION
        Creates a new category in Exchange Online using the graph api.

    .PARAMETER Name
        The category name.

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

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .NOTES
        For addiontional information about Microsoft Graph API go to:
        https://docs.microsoft.com/en-us/graph/api/outlookuser-post-mastercategories?view=graph-rest-1.0

    .EXAMPLE
        PS C:\> New-MgaExchCategory -Name "Important stuff"

        Creates a category "Important stuff" in the mailbox of the user connected to through a token.
        The new category will creates without color mapping.

    .EXAMPLE
        PS C:\> Get-MgaExchCategory -Name "Important stuff" -Color "Blue"

        Creates a blue colored category "Important stuff" in the mailbox of the user connected to through a token.

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([MSGraph.Exchange.Category.OutlookCategory])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [Alias('DisplayName', 'Category', 'InputObject')]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, Position = 1)]
        [Alias('ColorName')]
        [MSGraph.Exchange.Category.ColorName]
        $Color,

        [string]
        $User,

        [MSGraph.Core.AzureAccessToken]
        $Token
    )
    begin {
        $requiredPermission = "MailboxSettings.ReadWrite"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand

        if($Color) {
            [String]$colorValue = [MSGraph.Exchange.Category.OutlookCategory]::Parse($Color)
        }
        else {
            [String]$colorValue = [MSGraph.Exchange.Category.ColorKey]::None
        }
    }

    process {
        foreach ($categoryName in $Name) {
            Write-PSFMessage -Level Verbose -Message "Create new category '$($categoryName)'" -Tag "CreateData"

            #region prepare rest call to create data
            $bodyJSON = @{
                displayName = $categoryName
                color = $colorValue
            } | ConvertTo-Json

            $invokeParam = @{
                "Field"        = "outlook/masterCategories"
                "Body"         = $bodyJSON
                "Token"        = $Token
                "User"         = $User
                "FunctionName" = $MyInvocation.MyCommand
            }
            #endregion prepare rest call to create data

            # create data
            if ($pscmdlet.ShouldProcess($categoryName, "Create")) {
                $data = Invoke-MgaRestMethodPost @invokeParam
            }

            #region output data
            foreach ($output in $data) {
                if($output.User) { $User = $output.User }
                $categoryObject = [MSGraph.Exchange.Category.OutlookCategory]::new( $output.id, $output.displayName, $output.color, $User, $output)
                $categoryObject
            }
            #endregion output data
        }
    }

    end {
    }
}