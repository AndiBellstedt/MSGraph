function Move-MgaMailFolder {
    <#
    .SYNOPSIS
        Move folder(s) to another folder

    .DESCRIPTION
        Move folder(s) to another folder in Exchange Online using the graph api.

    .PARAMETER Folder
        Carrier object for Pipeline input. Accepts folders and strings.

    .PARAMETER DestinationFolder
        The destination folder where to move the folder to.

        Tab completion is available on this parameter for a list of well known folders.

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .PARAMETER PassThru
        Outputs the token to the console

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational folders will be displayed that explain what would happen if the command were to run.

    .EXAMPLE
        PS C:\> Move-MgaMailFolder -Folder $folder -DestinationFolder $destinationFolder

        Moves the folder(s) in variable $folder to the folder in the variable $destinationFolder.
        also possible:
        PS C:\> $folder | Move-MgaMailFolder -DestinationFolder $destinationFolder

        The variable $folder can be represent:
        PS C:\> $folder = Get-MgaMailFolder -Name "MyFolder"

        The variable $destinationFolder can be represent:
        PS C:\> $destinationFolder = Get-MgaMailFolder -Name "Archive"

    .EXAMPLE
        PS C:\> Move-MgaMailFolder -Id $folder.id -DestinationFolder $destinationFolder.id

        Moves folders into the folder $destinationFolder.

        The variable $folder can be represent:
        PS C:\> $folder = Get-MgaMailFolder -Name "MyFolder"

        The variable $destinationFolder can be represent:
        PS C:\> $destinationFolder = Get-MgaMailFolder -Name "Archive"

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Default')]
    [Alias()]
    [OutputType([MSGraph.Exchange.Mail.Folder])]
    param (
        [Parameter(Mandatory=$true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('InputObject', 'FolderId', 'Id')]
        [MSGraph.Exchange.Mail.FolderParameter[]]
        $Folder,

        [Parameter(Mandatory = $true, Position = 1)]
        [Alias('DestinationObject', 'DestinationFolderId')]
        [MSGraph.Exchange.Mail.FolderParameter]
        $DestinationFolder,

        [string]
        $User,

        [MSGraph.Core.AzureAccessToken]
        $Token,

        [switch]
        $PassThru
    )
    begin {
        $requiredPermission = "Mail.ReadWrite"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand

        #region checking DestinationFolder and query folder if required
        if ($DestinationFolder.TypeName -like "System.String") {
            $DestinationFolder = Resolve-MailObjectFromString -Object $DestinationFolder -User $User -Token $Token -FunctionName $MyInvocation.MyCommand
            if(-not $DestinationFolder) { throw }
        }

        $User = Resolve-UserInMailObject -Object $DestinationFolder -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
        #endregion checking DestinationFolder and query folder if required

        $bodyJSON = @{
            destinationId = $DestinationFolder.Id
        } | ConvertTo-Json
    }

    process {
        Write-PSFMessage -Level Debug -Message "Gettings folder(s) by parameterset $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

        foreach ($folderItem in $Folder) {
            #region checking input object type and query folder if required
            if ($folderItem.TypeName -like "System.String") {
                $folderItem = Resolve-MailObjectFromString -Object $folderItem -User $User -Token $Token -FunctionName $MyInvocation.MyCommand
                if(-not $folderItem) { continue }
            }

            $User = Resolve-UserInMailObject -Object $folderItem -User $User -FunctionName $MyInvocation.MyCommand
            #endregion checking input object type and query message if required

            if ($pscmdlet.ShouldProcess("Folder '$($folderItem)'", "Move to '$($DestinationFolder)'")) {
                Write-PSFMessage -Tag "FolderUpdate" -Level Verbose -Message "Move folder '$($folderItem)' into folder '$($DestinationFolder)'"
                $invokeParam = @{
                    "Field"        = "mailFolders/$($folderItem.Id)/move"
                    "User"         = $User
                    "Body"         = $bodyJSON
                    "ContentType"  = "application/json"
                    "Token"        = $Token
                    "FunctionName" = $MyInvocation.MyCommand
                }
                $output = Invoke-MgaPostMethod @invokeParam
                if ($PassThru) {
                    New-MgaMailFolderObject -RestData $output -ParentFolder $DestinationFolder.InputObject -FunctionName $MyInvocation.MyCommand
                }
            }
        }
    }

}