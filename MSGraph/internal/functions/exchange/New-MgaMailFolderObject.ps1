function New-MgaMailFolderObject {
    <#
    .SYNOPSIS
        Create new FolderObject

    .DESCRIPTION
        Create new FolderObject
        Helper function used for internal commands.

    .PARAMETER RestData
        The RestData object containing the data for the new message object.

    .PARAMETER ParentFolder
        If known/ existing, the parent folder object of the folder object to create.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.

    .EXAMPLE
        PS C:\> New-MgaMailFolderObject -RestData $output

        Create a MSGraph.Exchange.Mail.Folder object from data in variable $output
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [OutputType([MSGraph.Exchange.Mail.Folder])]
    [CmdletBinding()]
    param (
        $RestData,

        [MSGraph.Exchange.Mail.Folder]
        $ParentFolder,

        [String]
        $FunctionName
    )

    $hash = @{
        Id               = $RestData.Id
        DisplayName      = $RestData.DisplayName
        ParentFolderId   = $RestData.ParentFolderId
        ChildFolderCount = $RestData.ChildFolderCount
        UnreadItemCount  = $RestData.UnreadItemCount
        TotalItemCount   = $RestData.TotalItemCount
        User             = $RestData.User
        HierarchyLevel   = $level
    }
    if ($parentFolder) { $hash.Add("ParentFolder", $parentFolder) }
    $OutputObject = New-Object -TypeName MSGraph.Exchange.Mail.Folder -Property $hash
    $OutputObject

}