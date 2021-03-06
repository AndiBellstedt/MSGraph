﻿function Add-MgaMailMessageForward {
    <#
    .SYNOPSIS
        Forward message(s) in Exchange Online using the graph api.

    .DESCRIPTION
        Creates forward message(s) and save it as draft message(s).

        Alternatively, the command can directly forward a message by specifing recipient(s) and text
        The message is then saved in the Sent Items folder.

    .PARAMETER Message
        Carrier object for Pipeline input.
        This can be the id of the message or a message object passed in.

    .PARAMETER Comment
        The body of the message.

    .PARAMETER ToRecipients
        The To recipients for the message.

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
        https://docs.microsoft.com/en-us/graph/api/message-createforward?view=graph-rest-1.0
        https://docs.microsoft.com/en-us/graph/api/message-forward?view=graph-rest-1.0

    .EXAMPLE
        PS C:\> $mail | Add-MgaMailMessageForward

        Create forward message(s) and save it in the drafts folder for messages from variable $mail.
        also possible:
        PS C:\> Add-MgaMailMessageForward -Message $mail

        The variable $mail can be represent:
        PS C:\> $mail = Get-MgaMailMessage -Subject "Important mail"

    .EXAMPLE
        PS C:\> $mail | Add-MgaMailMessageForward -ToRecipients 'someone@something.org' -Comment 'For your information.'

        This one directly forwards message(s) from variable $mail. The message(s) is saved in the sendItems folder

        The variable $mail can be represent:
        PS C:\> $mail = Get-MgaMailMessage -Subject "Important mail"

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Default')]
    [Alias('Add-MgaMailForwardMessage')]
    [OutputType([MSGraph.Exchange.Mail.Message])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)] #, ParameterSetName = 'ByInputObject'
        [Alias('InputObject', 'MessageId', 'Id', 'Mail', 'MailId')]
        [MSGraph.Exchange.Mail.MessageParameter[]]
        $Message,

        [Parameter(Mandatory = $true, ParameterSetName = 'DirectReply')]
        [Alias('To', 'Recipients')]
        [string[]]
        $ToRecipients,

        [Parameter(Mandatory = $true, ParameterSetName = 'DirectReply')]
        [Alias('Body', 'Text', 'ReplyText')]
        [String]
        $Comment,

        [string]
        $User,

        [MSGraph.Core.AzureAccessToken]
        $Token,

        [Parameter(ParameterSetName = 'DirectReply')]
        [switch]
        $PassThru
    )
    begin {
        if ($PSCmdlet.ParameterSetName -like 'DirectReply') {
            $requiredPermission = "Mail.Send"
        } else {
            $requiredPermission = "Mail.ReadWrite"
        }
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand
    }

    process {
        Write-PSFMessage -Level Debug -Message "Working on parameter set $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

        foreach ($messageItem in $Message) {
            #region checking input object type and query message if required
            if ($messageItem.TypeName -like "System.String") {
                $messageItem = Resolve-MailObjectFromString -Object $messageItem -User $User -Token $Token -NoNameResolving -FunctionName $MyInvocation.MyCommand
                if (-not $messageItem) { continue }
            }

            $User = Resolve-UserInMailObject -Object $messageItem -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand

            if ($PSCmdlet.ParameterSetName -like 'DirectReply') {
                $bodyJSON = New-JsonMailObject -ToRecipients $ToRecipients -Comment $Comment -FunctionName $MyInvocation.MyCommand
                $msgAction = "Send"
            } else {
                $bodyJSON = ""
                $msgAction = "create"
            }
            #endregion checking input object type and query message if required

            #region send message
            $msg = $msgAction + " reply$(if($ReplyAll){" all"})"
            if ($pscmdlet.ShouldProcess($messageItem, $msg)) {
                Write-PSFMessage -Tag "MessageReply$msgAction" -Level Verbose -Message "$($msg) message for '$($messageItem)'"
                $invokeParam = @{
                    "User"         = $User
                    "Body"         = $bodyJSON
                    "ContentType"  = "application/json"
                    "Token"        = $Token
                    "FunctionName" = $MyInvocation.MyCommand
                }
                switch ($PSCmdlet.ParameterSetName) {
                    'Default' { $invokeParam.Add("Field", "messages/$($messageItem.Id)/createForward") }
                    'DirectReply' { $invokeParam.Add("Field", "messages/$($messageItem.Id)/forward") }
                    Default { Stop-PSFFunction -Message "Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistake." -EnableException $true -Category MetadataError -FunctionName $MyInvocation.MyCommand }
                }

                $output = Invoke-MgaRestMethodPost @invokeParam
                if ($PSCmdlet.ParameterSetName -like 'Default' -and $output) {
                    New-MgaMailMessageObject -RestData $output -FunctionName $MyInvocation.MyCommand
                } elseif ($PSCmdlet.ParameterSetName -like 'DirectReply' -and $PassThru) {
                    Write-PSFMessage -Tag "MessageQuery" -Level Verbose -Message "PassThru specified, query forward message from sentItems folder."
                    Get-MgaMailMessage -FolderName Sentitems -Subject "FW: $($messageItem.Name)" -ResultSize 5
                }
            }
            #endregion send message
        }
    }

    end {
    }
}