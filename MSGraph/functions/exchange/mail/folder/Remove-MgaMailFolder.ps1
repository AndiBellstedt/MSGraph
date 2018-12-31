function Remove-MgaMailFolder {
    <#
    .SYNOPSIS
        Remove folder(s) in Exchange Online using the graph api.

    .DESCRIPTION
        Remove folder(s) in Exchange Online using the graph api.

        ATTENTION! The command does what it is name to!
        The folder will not be moved to 'deletedObjects', it will be deleted.

    .PARAMETER Folder
        The folder to be removed.
        This can be a name of the folder, it can be the Id of the folder or it can be a folder object passed in.

        Tab completion is available on this parameter for a list of well known folders.

    .PARAMETER Force
        If specified the user will not prompted on confirmation.

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
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .EXAMPLE
        PS C:\> Remove-MgaMailFolder -Name 'MyFolder'

        Removes folder named "MyFolder".
        The folder has to be on the root level of the mailbox to be specified by individual name.

    .EXAMPLE
        PS C:\> Remove-MgaMailFolder -Name $folder

        Removes folder represented by the variable $folder.
        You will be prompted for confirmation.

        The variable $folder can be represent:
        PS C:\> $folder = Get-MgaMailFolder -Folder "MyFolder"

    .EXAMPLE
        PS C:\> $folder | Remove-MgaMailFolder -Force

        Removes folder represented by the variable $folder.
        ATTENTION, There will be NO prompt for confirmation!

        The variable $folder can be represent:
        PS C:\> $folder = Get-MgaMailFolder -Folder "MyFolder"

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([MSGraph.Exchange.Mail.Folder])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FolderName', 'FolderId', 'InputObject', 'DisplayName', 'Name', 'Id')]
        [MSGraph.Exchange.Mail.FolderParameter[]]
        $Folder,

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
        $requiredPermission = "Mail.ReadWrite"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand
    }

    process {
        Write-PSFMessage -Level Debug -Message "Gettings folder(s) by parameterset $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

        foreach ($folderItem in $Folder) {
            #region checking input object type and query folder if required
            if ($folderItem.TypeName -like "System.String") {
                if (($folderItem.IsWellKnownName -and $folderItem.Id -like "recoverableitemsdeletions") -or $folderItem.name -like "recoverableitemsdeletions") {
                    Write-PSFMessage -Level Important -Message "Can not delete well known folder 'recoverableitemsdeletions'. Continue without action on folder."
                    continue
                }
                $folderItem = Resolve-MailObjectFromString -Object $folderItem -User $User -Token $Token -FunctionName $MyInvocation.MyCommand
                if (-not $folderItem) { continue }
            }

            $User = Resolve-UserInMailObject -Object $folderItem -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
            #endregion checking input object type and query message if required

            if ($Force) { $doAction = $true } else { $doAction = $pscmdlet.ShouldProcess($folderItem, "Remove (ATTENTION! Folder will not be moved to 'deletedObjects')") }
            if ($doAction) {
                Write-PSFMessage -Tag "FolderRemove" -Level Verbose -Message "Remove folder '$($folderItem)'"
                $invokeParam = @{
                    "Field"        = "mailFolders/$($folderItem.Id)"
                    "User"         = $User
                    "Body"         = ""
                    "ContentType"  = "application/json"
                    "Token"        = $Token
                    "Force"        = $true
                    "FunctionName" = $MyInvocation.MyCommand
                }
                $null = Invoke-MgaRestMethodDelete @invokeParam
                if ($PassThru) {
                    $folderItem.InputObject
                }
            }
        }
    }

    end {
    }
}