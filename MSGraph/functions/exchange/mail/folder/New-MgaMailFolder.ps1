function New-MgaMailFolder {
    <#
    .SYNOPSIS
        Creates a folder in Exchange Online using the graph api.

    .DESCRIPTION
        Creates a new folder in Exchange Online using the graph api.

    .PARAMETER Name
        The name to be set as new name.

    .PARAMETER ParentFolder
        The folder where the new folder should be created in. Do not specify to create
        a folder on the root level.

        Possible values are a valid folder Id or a Mga folder object passed in.
        Tab completion is available on this parameter for a list of well known folders.


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

    .EXAMPLE
        PS C:\> New-MgaMailFolder -Name 'MyFolder'

        Creates a new folder named "MyFolder" on the root level of the mailbox

    .EXAMPLE
        PS C:\> New-MgaMailFolder -Name 'MyFolder' -ParentFolder $folder

        Creates a new folder named "MyFolder" inside the folder passed in with the variable $folder

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Default')]
    [OutputType([MSGraph.Exchange.Mail.Folder])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FolderName', 'DisplayName')]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, Position = 1)]
        [Alias('Parent', 'ParentFolderId')]
        [MSGraph.Exchange.Mail.FolderParameter[]]
        $ParentFolder,

        [string]
        $User,

        [MSGraph.Core.AzureAccessToken]
        $Token
    )
    begin {
        $requiredPermission = "Mail.ReadWrite"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand

        #region checking input object type and query folder if required
        if ($ParentFolder.TypeName -like "System.String") {
            $ParentFolder = Resolve-MailObjectFromString -Object $ParentFolder -User $User -Token $Token -FunctionName $MyInvocation.MyCommand
            if(-not $ParentFolder) { throw }
        }

        if ($ParentFolder) {
            $User = Resolve-UserInMailObject -Object $ParentFolder -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
        }
        #endregion checking input object type and query message if required
    }

    process {
        Write-PSFMessage -Level Debug -Message "Gettings folder(s) by parameterset $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

        foreach ($NameItem in $Name) {
            if ($pscmdlet.ShouldProcess($NameItem, "New")) {
                $msg = "Creating subfolder '$($NameItem)'"
                if($ParentFolder) { $msg = $msg + " in '$($ParentFolder)'"}
                Write-PSFMessage -Tag "FolderCreation" -Level Verbose -Message $msg

                $bodyJSON = @{
                    displayName = $NameItem
                } | ConvertTo-Json

                $invokeParam = @{
                    "User"         = $User
                    "Body"         = $bodyJSON
                    "ContentType"  = "application/json"
                    "Token"        = $Token
                    "FunctionName" = $MyInvocation.MyCommand
                }
                if($ParentFolder.Id) {
                    $invokeParam.Add("Field", "mailFolders/$($ParentFolder.Id)/childFolders")
                }
                else {
                    $invokeParam.Add("Field", "mailFolders")
                }

                $output = Invoke-MgaRestMethodPost @invokeParam
                New-MgaMailFolderObject -RestData $output -ParentFolder $ParentFolder.InputObject -FunctionName $MyInvocation.MyCommand
            }
        }
    }

    end {
    }
}