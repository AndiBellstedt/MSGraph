function Remove-MgaMailMessage {
    <#
    .SYNOPSIS
        Remove message(s) in Exchange Online using the graph api.

    .DESCRIPTION
        Remove message(s) in Exchange Online using the graph api.

        ATTENTION! The command does what it is name to!
        The message will not be moved to 'deletedObjects', it will be deleted.

    .PARAMETER Message
        The message to be removed.
        This can be the id of the message or a message object passed in.

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
        PS C:\> Remove-MgaMailMessage -Message $message

        Removes message represented by the variable $message.
        This example will purge (the first 100 messages in) the inbox.
        You will be prompted for confirmation.

        The variable $message can be represent:
        PS C:\> $message = Get-MgaMailMessage -Folder Inbox

    .EXAMPLE
        PS C:\> $message | Remove-MgaMailMessage -Force

        Removes message represented by the variable $message.
        This example will purge (the first 100 messages in) the inbox.
        ATTENTION, there will be NO prompt for confirmation!

        The variable $mails can be represent:
        PS C:\> $message = Get-MgaMailMessage -Folder Inbox

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([MSGraph.Exchange.Mail.Message])]
    param (
        [Parameter(Mandatory=$true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('InputObject', 'MessageId', 'Id', 'Mail', 'MailId')]
        [MSGraph.Exchange.Mail.MessageParameter[]]
        $Message,

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
        Write-PSFMessage -Level Debug -Message "Gettings message(s) by parameterset $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

        foreach ($messageItem in $Message) {
            #region checking input object type and query message if required
            if ($messageItem.TypeName -like "System.String") {
                $messageItem = Resolve-MailObjectFromString -Object $messageItem -User $User -Token $Token -NoNameResolving -FunctionName $MyInvocation.MyCommand
                if(-not $messageItem) { continue }
            }

            $User = Resolve-UserInMailObject -Object $messageItem -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
            #endregion checking input object type and query message if required

            if($Force) { $doAction = $true } else { $doAction = $pscmdlet.ShouldProcess($messageItem, "Remove (ATTENTION! Message will not be moved to 'deletedObjects')") }
            if ($doAction) {
                Write-PSFMessage -Tag "MessageRemove" -Level Verbose -Message "Remove message '$($messageItem)'"
                $invokeParam = @{
                    "Field"        = "messages/$($messageItem.Id)"
                    "User"         = $User
                    "Body"         = ""
                    "ContentType"  = "application/json"
                    "Token"        = $Token
                    "Force"        = $true
                    "FunctionName" = $MyInvocation.MyCommand
                }
                $null = Invoke-MgaRestMethodDelete @invokeParam
                if ($PassThru) {
                    $messageItem.InputObject
                }
            }
        }
    }

    end {
    }
}