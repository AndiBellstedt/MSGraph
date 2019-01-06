function New-MgaMailFolderObject {
    <#
    .SYNOPSIS
        Create new FolderObject

    .DESCRIPTION
        Create new FolderObject
        Helper function used for internal commands.

    .PARAMETER RestData
        The RestData object containing the data for the new message object.

    .PARAMETER Level
        The hierarchy level of the folder.
        1 means the folder is a root folder.

    .PARAMETER ParentFolder
        If known/ existing, the parent folder object of the folder object to create.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.

    .EXAMPLE
        PS C:\> New-MgaMailFolderObject -RestData $output -Level $Level -ParentFolder $ParentFolder -FunctionName $MyInvocation.MyCommand

        Create a MSGraph.Exchange.Mail.Folder object from data in variable $output
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [OutputType([MSGraph.Exchange.Mail.Folder])]
    [CmdletBinding()]
    param (
        $RestData,

        [MSGraph.Exchange.Mail.FolderParameter]
        $ParentFolder,

        [int]
        $Level,

        [String]
        $FunctionName
    )

    if ((-not $Level) -and $ParentFolder) {
        $Level = $ParentFolder.InputObject.HierarchyLevel + 1
    } elseif ((-not $Level) -and (-not $ParentFolder)) {
        $Level = 1
    }

    $hash = @{
        Id               = $RestData.Id
        DisplayName      = $RestData.DisplayName
        ParentFolderId   = $RestData.ParentFolderId
        ChildFolderCount = $RestData.ChildFolderCount
        UnreadItemCount  = $RestData.UnreadItemCount
        TotalItemCount   = $RestData.TotalItemCount
        User             = $RestData.User
        HierarchyLevel   = $Level
    }

    if ($ParentFolder) { $hash.Add("ParentFolder", $ParentFolder.InputObject) }

    $OutputObject = New-Object -TypeName MSGraph.Exchange.Mail.Folder -Property $hash

    $OutputObject
}