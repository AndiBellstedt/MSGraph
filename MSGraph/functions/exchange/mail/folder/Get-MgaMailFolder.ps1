function Get-MgaMailFolder {
    <#
    .SYNOPSIS
        Get mail folder(s) in Exchange Online

    .DESCRIPTION
        Get mail folder(s) with metadata from Exchange Online via Microsoft Graph API

    .PARAMETER Name
        The name of the folder(S) to query.

    .PARAMETER IncludeChildFolders
        Output all subfolders on queried folder(s).

    .PARAMETER Recurse
        Iterates through the whole folder structure and query all subfolders.

    .PARAMETER Filter
        The name to filter by.
        (Client Side filtering)

        Try to avoid, when filtering on single name, use parameter -Name instead of -Filter.

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER ResultSize
        The user to execute this under.
        Defaults to the user the token belongs to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .EXAMPLE
        PS C:\> Get-MgaMailFolder

        Returns all folders in the mailbox of the connected user.

    .EXAMPLE
        PS C:\> Get-MgaMailFolder -Name Inbox

        Returns the "wellknown" inbox folder in the mailbox of the connected user.
        The wellknown folders can be specified by tab completion.

    .EXAMPLE
        PS C:\> Get-MgaMailFolder -Name Inbox -IncludeChildFolders

        Returns inbox and the next level of subfolders in the inbox of the connected user.

    .EXAMPLE
        PS C:\> Get-MgaMailFolder -Name Inbox -Recurse

        Returns inbox and the all subfolders underneath the inbox of the connected user.
        This one is like the "-Recurse" switch on the dir/Get-ChildItem command.

    .EXAMPLE
        PS C:\> Get-MgaMailFolder -Filter "My*" -User "max.master@contoso.onmicrosoft.com" -Token $Token

        Retrieves all folders where name starts with My in the mailbox of "max.master@contoso.onmicrosoft.com", using the connection token stored in $Token.

    .EXAMPLE
        PS C:\> Get-MgaMailFolder -ResultSize 5

        Retrieves only the first 5 folders in the mailbox of the connected user.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([MSGraph.Exchange.Mail.Folder])]
    param (
        [Parameter(ParameterSetName = 'ByFolderName', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true, Position = 0)]
        [Alias('FolderName', 'InputObject', 'DisplayName', 'Id')]
        [MSGraph.Exchange.Mail.FolderParameter[]]
        $Name,

        [switch]
        $IncludeChildFolders,

        [switch]
        $Recurse,

        [string]
        $Filter = "*",

        [string]
        $User,

        [Int64]
        $ResultSize = (Get-PSFConfigValue -FullName 'MSGraph.Query.ResultSize' -Fallback 100),

        [MSGraph.Core.AzureAccessToken]
        $Token
    )

    begin {
        $requiredPermission = "Mail.Read"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand

        if ($Recurse) { $IncludeChildFolders = $true }

        #region helper subfunctions
        function invoke-internalMgaGetMethod ($invokeParam, [int]$level, [MSGraph.Exchange.Mail.Folder]$parentFolder, [String]$FunctionName) {
            # Subfunction for query objects and creating valid new objects from the query result
            $folderData = Invoke-MgaRestMethodGet @invokeParam
            foreach ($folderOutput in $folderData) {
                New-MgaMailFolderObject -RestData $folderOutput -ParentFolder $parentFolder -Level $level #-FunctionName $FunctionName
            }
        }

        function get-childfolder ($output, [int]$level, $invokeParam) {
            $FoldersWithChilds = $output | Where-Object ChildFolderCount -gt 0
            $childFolders = @()

            do {
                $level = $level + 1
                foreach ($folderItem in $FoldersWithChilds) {
                    if ($folderItem.ChildFolderCount -gt 0) {
                        Write-PSFMessage -Level VeryVerbose -Message "Getting childfolders for folder '$($folderItem.Name)'" -Tag "QueryData"
                        $invokeParam.Field = "mailFolders/$($folderItem.Id)/childFolders"
                        $childFolderOutput = invoke-internalMgaGetMethod -invokeParam $invokeParam -level $level -parentFolder $folderItem -FunctionName $MyInvocation.MyCommand

                        $FoldersWithChilds = $childFolderOutput | Where-Object ChildFolderCount -gt 0
                        $childFolders = $childFolders + $childFolderOutput
                    }
                }
            } while ($Recurse -and $FoldersWithChilds)

            $childFolders
        }
        #endregion helper subfunctions
    }

    process {
        Write-PSFMessage -Level VeryVerbose -Message "Gettings folder(s) by parameterset $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"
        switch ($PSCmdlet.ParameterSetName) {
            "Default" {
                $baseLevel = 1
                $invokeParam = @{
                    "Field"        = 'mailFolders'
                    "Token"        = $Token
                    "User"         = Resolve-UserString -User $User
                    "ResultSize"   = $ResultSize
                    "FunctionName" = $MyInvocation.MyCommand
                }

                $output = invoke-internalMgaGetMethod -invokeParam $invokeParam -level $baseLevel -FunctionName $MyInvocation.MyCommand  | Where-Object displayName -Like $Filter

                if ($output -and $IncludeChildFolders) {
                    $childFolders = $output | Where-Object ChildFolderCount -gt 0 | ForEach-Object {
                        get-childfolder -output $_ -level $baseLevel -invokeParam $invokeParam
                    }
                    if ($childFolders) {
                        [array]$output = [array]$output + $childFolders
                    }
                }

                if (-not $output) {
                    Stop-PSFFunction -Message "Unexpected error. Could not query root folders from user '$($User)'." -Tag "QueryData" -EnableException $true
                }
            }

            "ByFolderName" {
                foreach ($folder in $Name) {
                    $baseLevel = 1
                    Write-PSFMessage -Level VeryVerbose -Message "Getting folder '$( if($folder.Name){$folder.Name}else{$folder.Id} )'" -Tag "ParameterSetHandling"
                    $invokeParam = @{
                        "Token"        = $Token
                        "User"         = Resolve-UserString -User $User
                        "ResultSize"   = $ResultSize
                        "FunctionName" = $MyInvocation.MyCommand
                    }
                    if ($folder.id) {
                        $invokeParam.add("Field", "mailFolders/$($folder.Id)")
                    } else {
                        $invokeParam.add("Field", "mailFolders?`$filter=DisplayName eq '$($folder.Name)'")
                    }

                    $output = invoke-internalMgaGetMethod -invokeParam $invokeParam -level $baseLevel -FunctionName $MyInvocation.MyCommand | Where-Object displayName -Like $Filter

                    if ($output -and $IncludeChildFolders) {
                        $childFolders = get-childfolder -output $output -level $baseLevel -invokeParam $invokeParam
                        if ($childFolders) {
                            [array]$output = [array]$output + $childFolders
                        }
                    }

                    if (-not $output) {
                        Write-PSFMessage -Level Warning -Message "Folder '$($folder)' not found." -Tag "QueryData"
                    }
                }
            }

            Default { Stop-PSFFunction -Message "Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistake." -EnableException $true -Category MetadataError -FunctionName $MyInvocation.MyCommand }
        }

        $output
    }

    end {
    }
}