function Get-MgaExchCategory {
    <#
    .SYNOPSIS
        Retrieves categories in Exchange Online using the graph api.

    .DESCRIPTION
        Retrieves categories in Exchange Online using the graph api.

    .PARAMETER InputObject
        Carrier object for Pipeline input.Accepts CategoryObjects and strings.

    .PARAMETER Id
        The Id to filter by.
        (Client Side filtering)

    .PARAMETER Name
        The name to filter by.
        (Client Side filtering)

    .PARAMETER Color
        The color to filter by.
        (Client Side filtering)

        Tab completion is available on this parameter for the list of the 25 predefined colors.

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER ResultSize
        The user to execute this under. Defaults to the user the token belongs to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .EXAMPLE
        PS C:\> Get-MgaExchCategory

        Return all categories of the user connected to through a token.

    .EXAMPLE
        PS C:\> Get-MgaExchCategory -Id "89101089-690d-4263-9470-b674e709a996"

        Return the category with the specified Id of the user connected to through a token.

    .EXAMPLE
        PS C:\> Get-MgaExchCategory -Name "*category"

        Return all categories with names like "*category" of the user connected to through a token.

    .EXAMPLE
        PS C:\> Get-MgaExchCategory -Color "Blue"

        Return all categories with names like "*category" of the user connected to through a token.

    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Default')]
    [OutputType([MSGraph.Exchange.Category.OutlookCategory])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, ParameterSetName = 'ByInputOBject')]
        [Alias('Category')]
        [MSGraph.Exchange.Category.CategoryParameter[]]
        $InputObject,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ById')]
        [Alias('IdFilter', 'FilterId')]
        [guid[]]
        $Id,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ByName')]
        [Alias('NameFilter', 'FilterName')]
        [string[]]
        $Name,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ByColor')]
        [Alias('ColorFilter', 'FilterColor')]
        [MSGraph.Exchange.Category.ColorName[]]
        $Color,

        [string]
        $User,

        [Int64]
        $ResultSize = (Get-PSFConfigValue -FullName 'MSGraph.Query.ResultSize' -Fallback 100),

        [MSGraph.Core.AzureAccessToken]
        $Token
    )
    begin {
        $requiredPermission = "MailboxSettings.Read"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand
    }

    process {
        #region query data
        $invokeParam = @{
            "Token"        = $Token
            "User"         = $User
            "ResultSize"   = $ResultSize
            "FunctionName" = $MyInvocation.MyCommand
        }

        $data = @()
        if ($PSCmdlet.ParameterSetName -like 'ByInputOBject') {
            foreach ($categoryItem in $InputObject) {
                #region checking input object type and query message if required
                if ($categoryItem.TypeName -like "System.String") {
                    $categoryItem = Resolve-MailObjectFromString -Object $categoryItem -User $User -Token $Token -FunctionName $MyInvocation.MyCommand
                    if (-not $categoryItem) { continue }
                }

                $User = Resolve-UserInMailObject -Object $categoryItem -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
                #endregion checking input object type and query message if required

                $invokeParam.Add("Field","outlook/masterCategories/$($categoryItem.Id)")
                Write-PSFMessage -Level Verbose -Message "Get refresh on category '$($categoryItem)'" -Tag "QueryData"
                $data = $data + (Invoke-MgaGetMethod @invokeParam)
                $invokeParam.Remove("Field")
            }
        }
        else {
            $invokeParam.Add("Field","outlook/masterCategories")
            Write-PSFMessage -Level Verbose -Message "Getting available categories" -Tag "QueryData"
            $data = $data + (Invoke-MgaGetMethod @invokeParam)
        }
        #endregion query data

        #region filter data
        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $data = foreach ($filter in $Id) {
                    Write-PSFMessage -Level VeryVerbose -Message "Filtering on id '$($filter)'." -Tag "FilterData"
                    $data | Where-Object Id -like $filter.Guid
                }
            }
            'ByName' {
                $data = foreach ($filter in $Name) {
                    Write-PSFMessage -Level VeryVerbose -Message "Filtering on name '$($filter)'." -Tag "FilterData"
                    $data | Where-Object displayname -like $filter
                }
            }
            'ByColor' {
                $data = foreach ($filter in $Color) {
                    Write-PSFMessage -Level VeryVerbose -Message "Filtering on color '$($filter)'." -Tag "FilterData"
                    $data | Where-Object Color -like ([MSGraph.Exchange.Category.OutlookCategory]::Parse($filter))
                }
            }
            Default {}
        }
        #endregion filter data

        #region output data
        Write-PSFMessage -Level VeryVerbose -Message "Output $( ($data | Measure-Object).Count ) objects." -Tag "OutputData"
        foreach ($output in $data) {
            if($output.User) { $User = $output.User }
            $categoryObject = [MSGraph.Exchange.Category.OutlookCategory]::new( $output.id, $output.displayName, $output.color, $User, $output)
            Write-PSFMessage -Level Debug -Message "Output new object '$($categoryObject)'." -Tag "OutputData"
            $categoryObject
        }
        #endregion output data
    }

    end {
    }
}