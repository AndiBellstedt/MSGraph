function Get-MgaMailFolder {
    <#
    .SYNOPSIS
        Searches mail folders in Exchange Online

    .DESCRIPTION
        Searches mail folders in Exchange Online

    .PARAMETER Name
        The name of the folder(S) to query.

    .PARAMETER IncludeChildFolders
        Output all subfolders on queried folder(s).

    .PARAMETER Recurse
        Iterates through the whole folder structure and query all subfolders.

    .PARAMETER Filter
        The name to filter by.
        (Client Side filtering)

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER ResultSize
        The user to execute this under.
        Defaults to the user the token belongs to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-EORAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-EORAccessToken.

    .EXAMPLE
        PS C:\> Get-MgaMailFolder

        Returns all folders in the mailbox of the connected user.

    .EXAMPLE
        PS C:\> Get-MgaMailFolder -Filter Inbox -User "max.master@contoso.onmicrosoft.com" -Token $Token

        Retrieves the inbox folder of the "max.master@contoso.onmicrosoft.com" mailbox, using the connection token stored in $Token.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([MSGraph.Exchange.Mail.Folder])]
    param (
        [Parameter(ParameterSetName = 'ByFolderName', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true, Position = 0)]
        [Alias('FolderName', 'InputObject', 'DisplayName', 'Id')]
        [MSGraph.Exchange.Mail.MailFolderParameter[]]
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
        if ($Recurse) { $IncludeChildFolders = $true }

        function invoke-internalMgaGetMethod ($invokeParam, [int]$level, [MSGraph.Exchange.Mail.Folder]$parentFolder) {
            $folderData = Invoke-MgaGetMethod @invokeParam | Where-Object displayName -Like $Filter
            foreach ($folderOutput in $folderData) {
                $hash = @{
                    Id                  = $folderOutput.Id
                    DisplayName         = $folderOutput.DisplayName
                    ParentFolderId      = $folderOutput.ParentFolderId
                    ChildFolderCount    = $folderOutput.ChildFolderCount
                    UnreadItemCount     = $folderOutput.UnreadItemCount
                    TotalItemCount      = $folderOutput.TotalItemCount
                    User                = $folderOutput.User
                    HierarchyLevel      = $level
                }
                if($parentFolder) { $hash.Add("ParentFolder", $parentFolder) }
                $folderOutputObject = New-Object -TypeName MSGraph.Exchange.Mail.Folder -Property $hash
                $folderOutputObject
            }
        }

        function get-childfolders ($output, $level, $invokeParam){
            $FoldersWithChilds = $output | Where-Object ChildFolderCount -gt 0
            $childFolders = @()

            do {
                $level = $level + 1
                foreach ($folderItem in $FoldersWithChilds) {
                    if($folderItem.ChildFolderCount -gt 0) {
                        Write-PSFMessage -Level VeryVerbose -Message "Getting childfolders for folder '$($folderItem.Name)'" -Tag "ParameterSetHandling"
                        $invokeParam.Field = "mailFolders/$($folderItem.Id)/childFolders"
                        $childFolderOutput = invoke-internalMgaGetMethod -invokeParam $invokeParam -level $level -parentFolder $folderItem
                        
                        $FoldersWithChilds = $childFolderOutput | Where-Object ChildFolderCount -gt 0
                        $childFolders = $childFolders + $childFolderOutput
                    }
                }
            } while ($Recurse -and $FoldersWithChilds)

            $childFolders
        }
    }

    process {
        Write-PSFMessage -Level VeryVerbose -Message "Gettings folder(s) by parameter set $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"
        switch ($PSCmdlet.ParameterSetName) {
            "Default" {
                $level = 1
                $invokeParam = @{
                    "Field"        = 'mailFolders'
                    "Token"        = $Token
                    "User"         = Resolve-UserString -User $User
                    "ResultSize"   = $ResultSize
                    "FunctionName" = $MyInvocation.MyCommand
                }

                $output = invoke-internalMgaGetMethod -invokeParam $invokeParam -level $level

                if ($output -and $IncludeChildFolders) {
                    $childFolders = $output | Where-Object ChildFolderCount -gt 0 | ForEach-Object {
                        get-childfolders -output $_ -level $level -invokeParam $invokeParam
                    }
                    if($childFolders) {
                        [array]$output = [array]$output + $childFolders
                    }
                }
                $output
            }
            "ByFolderName" {
                foreach ($folder in $Name) {
                    $level = 1
                    Write-PSFMessage -Level VeryVerbose -Message "Getting folder '$( if($folder.Name){$folder.Name}else{$folder.Id} )'" -Tag "ParameterSetHandling"
                    $invokeParam = @{
                        "Field"        = "mailFolders/$($folder.Id)"
                        "Token"        = $Token
                        "User"         = Resolve-UserString -User $User
                        "ResultSize"   = $ResultSize
                        "FunctionName" = $MyInvocation.MyCommand
                    }

                    $output = invoke-internalMgaGetMethod -invokeParam $invokeParam -level $level

                    if ($output -and $IncludeChildFolders) {
                        $childFolders = get-childfolders -output $output -level $level -invokeParam $invokeParam
                        if($childFolders) {
                            [array]$output = [array]$output + $childFolders
                        }
                    }
                    $output
                }

            }
            Default { stop-PSFMessage -Message "Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistage." -EnableException $true -Category "ParameterSetHandling" -FunctionName $MyInvocation.MyCommand }
        }
    }

    end {
    }
}