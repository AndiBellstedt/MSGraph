function Get-MgaExchCategory {
    <#
    .SYNOPSIS
        Retrieves categories in Exchange Online using the graph api.

    .DESCRIPTION
        Retrieves categories in Exchange Online using the graph api.

    .PARAMETER Id
        The Id to filter by.
        (Client Side filtering)

    .PARAMETER Name
        The name to filter by.
        (Client Side filtering)

    .PARAMETER Color
        The color to filter by.
        (Client Side filtering)

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
        PS C:\> Get-MgaMailCategories

        Return all categories of the user connected to through a token.

    .EXAMPLE
        PS C:\> Get-MgaMailCategories -Id "89101089-690d-4263-9470-b674e709a996"

        Return the category with the specified Id of the user connected to through a token.

    .EXAMPLE
        PS C:\> Get-MgaMailCategories -Name "*category"

        Return all categories with names like "*category" of the user connected to through a token.

    .EXAMPLE
        PS C:\> Get-MgaMailCategories -Color "Blue"

        Return all categories with names like "*category" of the user connected to through a token.

    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Default')]
    #[OutputType([MSGraph.Exchange.Category])]
    param (
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
            "Field"        = "outlook/masterCategories"
            "Token"        = $Token
            "User"         = $User
            "ResultSize"   = $ResultSize
            "FunctionName" = $MyInvocation.MyCommand
        }

        Write-PSFMessage -Level Verbose -Message "Getting available categories" -Tag "QueryData"
        $data = Invoke-MgaGetMethod @invokeParam 
        #endregion query data

        #region filter data
        switch ($PSCmdlet.ParameterSetName) {
            'ById' { 
                $data = foreach ($filter in $Id) {
                    $data | Where-Object Id -like $filter.Guid
                }
            }
            'ByName' {
                $data = foreach ($filter in $Name) {
                    $data | Where-Object displayname -like $filter
                }
            }
            'ByColor' {
                $data = foreach ($filter in $Color) {
                    $data | Where-Object Color -like ([MSGraph.Exchange.Category.OutlookCategory]::Parse($filter))
                }
            }
            Default {}
        }
        #endregion filter data

        #region output data
        foreach ($output in $data) {
            if($output.User) { $User = $output.User }
            $categoryObject = [MSGraph.Exchange.Category.OutlookCategory]::new( $output.id, $output.displayName, $output.color, $User, $output)
            $categoryObject
        }
        #endregion output data
    }

    end {
    }
}