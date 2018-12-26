function Add-MgaMailAttachment {
    <#
    .SYNOPSIS
        Add attachment(s) to a draft message in Exchange Online using the graph api.

    .DESCRIPTION
        Add attachment(s) to a draft message in Exchange Online using the graph api.

        Currently, only file attachments are supportet.

    .PARAMETER Message
        Carrier object for Pipeline input.
        This can be the id of the message or a message object passed in.

    .PARAMETER File
        The path to the file to add as attachment.

    .PARAMETER Link
        The ReferenceAttachment (aka "modern attachment", aka OneDriveLink) to add to the message..

    .PARAMETER Item
        The Outlook item to add as attachment.

    .PARAMETER Force
        Enforce adding attachment, even when the message is not in draft mode.

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

    .NOTES
        For addiontional information about Microsoft Graph API go to:
        https://docs.microsoft.com/en-us/graph/api/message-post-attachments?view=graph-rest-1.0

    .EXAMPLE
        PS C:\> $mail | Add-MgaMailAttachment -Path "logfile.txt"

        Add "logfile.txt" as attachment to message(s) in the variable $mail,
        The variable $mails can be represent:
        PS C:\> $mails = Get-MgaMailMessage -Folder Drafts -ResultSize 1

    .EXAMPLE
        PS C:\> $mail | Add-MgaMailAttachment -Link $ReferenceAttachment

        Add a modern attachment as attachment (reference link) to message(s) in the variable $mail,
        The variable $mails can be represent:
        PS C:\> $mails = Get-MgaMailMessage -Folder Drafts -ResultSize 1

        The variable $ReferenceAttachment has to be a object [MSGraph.Exchange.Attachment.ReferenceAttachment]

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'FileAttachment')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [Alias('InputObject', 'Id', 'Mail', 'MailMessage', 'MessageId', 'MailId')]
        [MSGraph.Exchange.Mail.MessageParameter[]]
        $Message,

        [Parameter(Mandatory = $true, ParameterSetName = 'FileAttachment')]
        [Alias('Path', 'FileName', 'FilePath')]
        [string[]]
        $File,

        [Parameter(Mandatory = $true, ParameterSetName = 'ReferenceAttachment')]
        [Alias('ReferenceAttachment', 'LinkPath', 'Uri', 'Url')]
        [MSGraph.Exchange.Attachment.ReferenceAttachment[]]
        $Link,

        [Parameter(Mandatory = $true, ParameterSetName = 'ItemAttachment')]
        [Alias('Event', 'OutlookItem')]
        [psobject[]]
        $Item,

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

        switch ($PSCmdlet.ParameterSetName) {
            'FileAttachment' {
                $filesToAttach = @()
                foreach ($filePath in $File) {
                    try {
                        $fileItem = Get-ChildItem -Path $filePath -File -ErrorAction Stop
                        $fileItem | Add-Member -MemberType NoteProperty -Name contentBytes -Value ( [System.Convert]::ToBase64String( [System.IO.File]::ReadAllBytes($fileItem.FullName) ) )
                        $filesToAttach = $filesToAttach + $fileItem
                    }
                    catch {
                        Stop-PSFFunction -Message "Specified path is invalid or not a file. Please specify a valid file." -EnableException $true -Exception $errorvariable.Exception -Category InvalidData -Tag "Attachment"
                    }
                }
                $namesFileToAttach = "'$([string]::Join("', '",$filesToAttach.Name))'"
            }

            'ReferenceAttachment' {
                # ToDo implemented convinient parsing for referenceAttachments
                $namesFileToAttach = "'$([string]::Join("', '",$Link.Name))'"
            }

            'ItemAttachment' {
                # ToDo implemented adding item attachment
                Stop-PSFFunction -Message "adding item attachment is not implemented, yet."
                foreach ($itemObject in $Item) {
                }
            }

            Default { Stop-PSFMessage -Message "Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistake." -EnableException $true -Category "ParameterSetHandling" -FunctionName $MyInvocation.MyCommand }
        }
    }

    process {
        foreach ($messageItem in $Message) {
            Write-PSFMessage -Level Debug -Message "Adding attachment(s) $($namesFileToAttach) to message '$($messageItem)' by parameterset $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

            #region checking input object type and query message if required
            if ($messageItem.TypeName -like "System.String") {
                $messageItem = Resolve-MailObjectFromString -Object $messageItem -User $User -Token $Token -NoNameResolving -FunctionName $MyInvocation.MyCommand
                if (-not $messageItem) { continue }
            }

            if (-not $messageItem.InputObject.IsDraft -and (-not $Force)) {
                if ($PSCmdlet.ShouldContinue("The mesaage is not a draft message! Would you really like to add attachment(s) $($namesFileToAttach) to message '$($messageItem)'?", "$($messageItem) is not a draft message") ) {
                    Write-PSFMessage -Level Verbose -Message "Confirmation specified to add attachment(s) to non draft message '$($messageItem)'" -Tag "AddAttachmentEnforce"
                }
                else {
                    Write-PSFMessage -Level Important -Message "Abort adding attachment(s) to non draft message '$($messageItem)'" -Tag "AddAttachmentEnforce"
                    return
                }
            }

            $User = Resolve-UserInMailObject -Object $messageItem -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
            #endregion checking input object type and query message if required

            # prepare parameters for rest call
            $invokeParam = @{
                "Field"        = "messages/$($messageItem.Id)/attachments"
                "Token"        = $Token
                "User"         = $User
                "ApiVersion"   = "beta"
                "FunctionName" = $MyInvocation.MyCommand
            }

            $data = @()
            switch ($PSCmdlet.ParameterSetName) {
                'FileAttachment' {
                    foreach ($fileToAttach in $filesToAttach) {
                        # prepare REST Body
                        $bodyJSON = New-JsonAttachmentObject -Name $fileToAttach.Name -Size $fileToAttach.Length -IsInline $false -contentBytes $fileToAttach.contentBytes -FunctionName $MyInvocation.MyCommand
                        $invokeParam.Add("Body", $bodyJSON)

                        # add attachment
                        if ($pscmdlet.ShouldProcess("Message '$($messageItem)'", "Add FileAttachment '$($fileToAttach.FullName)'")) {
                            Write-PSFMessage -Level Verbose -Message "Add '$($fileToAttach.FullName)' to message '$($messageItem)'" -Tag "AddData"
                            $data = $data + (Invoke-MgaPostMethod @invokeParam)
                        }
                        $invokeParam.Remove("Body")
                    }
                }

                'ReferenceAttachment' {
                    foreach ($linkItem in $Link) {
                        # prepare REST Body
                        $bodyJSON = New-JsonAttachmentObject -SourceUrl $linkItem.SourceUrl -Name $linkItem.Name -ProviderType $linkItem.ProviderType -IsFolder $linkItem.IsFolder -Permission $linkItem.Permission -FunctionName $MyInvocation.MyCommand
                        $invokeParam.Add("Body", $bodyJSON)

                        # add attachment
                        if ($pscmdlet.ShouldProcess("Message '$($messageItem)'", "Add ReferenceAttachment '$($linkItem.Name)'")) {
                            Write-PSFMessage -Level Verbose -Message "Getting '$($linkItem.ToString())' as ReferenceAttachment to message '$($messageItem)'" -Tag "AddData"
                            $data = $data + (Invoke-MgaPostMethod @invokeParam)
                        }
                        $invokeParam.Remove("Body")
                    }
                }

                'ItemAttachment' {
                    # ToDo implemented adding item attachment
                    foreach ($itemObject in $Item) {
                    }
                }

                Default { stop-PSFMessage -Message "Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistake." -EnableException $true -Category "ParameterSetHandling" -FunctionName $MyInvocation.MyCommand }
            }

            #region output data
            foreach ($output in $data) {
                if ($PassThru) {
                    $AttachmentObject = New-MgaAttachmentObject -RestData $output -ParentObject $messageItem.InputObject -ApiVersion "beta" -ResultSize $ResultSize -User $User -Token $Token -FunctionName $MyInvocation.MyCommand
                    $AttachmentObject
                }
            }
            #endregion output data
        }
    }

    end {
    }
}