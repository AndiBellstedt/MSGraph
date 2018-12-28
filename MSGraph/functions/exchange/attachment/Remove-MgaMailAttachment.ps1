function Remove-MgaMailAttachment {
    <#
    .SYNOPSIS
        Remove attachment(s) from a email message(s) in Exchange Online using the graph api.

    .DESCRIPTION
        Remove attachment(s) from a email message(s) in Exchange Online using the graph api.

    .PARAMETER Message
        Carrier object for Pipeline input.
        This can be the id of the message or a message object passed in.

    .PARAMETER Name
        The name of the attachment to delete.

    .PARAMETER Force
        Suppress any confirmation request and enforce removing attachment on any kind of message.

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .PARAMETER PassThru
        Outputs the object to the console.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .NOTES
        For addiontional information about Microsoft Graph API go to:
        https://docs.microsoft.com/en-us/graph/api/attachment-delete?view=graph-rest-1.0

    .EXAMPLE
        PS C:\> Get-MgaMailMessage -Folder Drafts | Remove-MgaMailAttachment

        Delete attachment(s) from all mails in drafts folder of the user connected to through a token.

    .EXAMPLE
        PS C:\> Get-MgaMailMessage -Folder Drafts | Remove-MgaMailAttachment -Name "MyName*"

        Delete attachment(s) with name MyName* from all mails in drafts folder of the user connected to through a token.

    .EXAMPLE
        PS C:\> Get-MgaMailMessage -Folder Drafts | Remove-MgaMailAttachment -IncludeInlineAttachment

        Delete also "inline" attachments, like pictures in html mails from all emails in drafts folder of the user connected to through a token.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', DefaultParameterSetName = 'MessageInputObject')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'MessageInput', Position = 0)]
        [Alias('Mail', 'MailMessage', 'MessageId', 'MailId')]
        [MSGraph.Exchange.Mail.MessageParameter[]]
        $Message,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'AttachmentInput', Position = 0)]
        [Alias('Attachments', 'AttachmentId', 'AttachmentObject')]
        [MSGraph.Exchange.Attachment.AttachmentParameter[]]
        $Attachment,

        [Parameter(ParameterSetName = 'MessageInput', Position = 1)]
        [Alias('Filter', 'NameFilter')]
        [string]
        $Name = "*",

        [switch]
        $IncludeInlineAttachment,

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
        if ($PSCmdlet.ParameterSetName -like 'MessageInput') {
            $Attachment = @()
            foreach ($messageItem in $Message) {
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

                $getAttachmentParam = @{
                    "Message" = $messageItem
                    "Name"    = $Name
                    "User"    = $User
                    "Token"   = $Token
                }
                if ($IncludeInlineAttachment) { $getAttachmentParam.Add("IncludeInlineAttachment", $true) }
                $output = (Get-MgaMailAttachment @getAttachmentParam | Where-Object { $_.name -like $Name })
                if ($output) { 
                    foreach ($outputItem in $output) {
                        $Attachment = $Attachment + [MSGraph.Exchange.Attachment.AttachmentParameter]$outputItem
                    }
                }
            }
            if (-not $Attachment) {
                Write-PSFMessage -Level Important -Message "Nothing found to delete." -Tag "QueryData"
            }
        }

        foreach ($attachmentItem in $Attachment) {
            Write-PSFMessage -Level Debug -Message "Deleting attachment '$($attachmentItem)' from message '$($attachmentItem.InputObject.ParentObject.Name)' by parameterset $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

            # prepare parameters for rest call
            $invokeParam = @{
                "Field"        = "messages/$($attachmentItem.InputObject.ParentObject.Id)/attachments/$($attachmentItem.id)"
                "Token"        = $Token
                "User"         = $User
                "Confirm"      = $false
                "FunctionName" = $MyInvocation.MyCommand
            }

            # remove attachment
            if ($Force) {
                $proceed = $true
            }
            else {
                $proceed = $pscmdlet.ShouldProcess("Message '$($attachmentItem.InputObject.ParentObject.Name)'", "Delete attachment '$($attachmentItem)'")
            }
            if ($proceed) {
                Write-PSFMessage -Level Verbose -Message "Delete attachment '$($attachmentItem)' from message '$($attachmentItem.InputObject.ParentObject.Name)'" -Tag "RemoveData"
                Invoke-MgaDeleteMethod @invokeParam
            }

            #region passthru data
            if ($PassThru) { $attachmentItem.InputObject }
            #endregion passthru data
        }
    }

    end {
    }
}