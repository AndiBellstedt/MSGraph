function Send-MgaMailMessage {
    <#
    .SYNOPSIS
        Send a previously created draft message(s)

    .DESCRIPTION
        Send a previously created draft message(s) within Exchange Online using the graph api.
        The message is saved in the SendItems folder.

    .PARAMETER Message
        Carrier object for Pipeline input.
        This can be the id of the message or a message object passed in.

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
        PS C:\> $mail | Send-MgaMailMessage

        Send message(s) in variable $mail.
        also possible:
        PS C:\> Send-MgaMailMessage -Message $mail

        The variable $mail can be represent:
        PS C:\> $mail = New-MgaMailMessage -ToRecipients 'someone@something.org' -Subject 'A new Mail' -Body 'This is a new mail'

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [Alias()]
    [OutputType([MSGraph.Exchange.Mail.Message])]
    param (
        [Parameter(Mandatory=$true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('InputObject', 'MessageId', 'Id', 'Mail', 'MailId')]
        [MSGraph.Exchange.Mail.MessageParameter[]]
        $Message,

        [string]
        $User,

        [MSGraph.Core.AzureAccessToken]
        $Token,

        [switch]
        $PassThru
    )
    begin {
        $requiredPermission = "Mail.Send"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand
    }

    process {
        #Write-PSFMessage -Level Debug -Message "Working on parameter set $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

        #region send message
        foreach ($messageItem in $Message) {
            #region checking input object type and query message if required
            if ($messageItem.TypeName -like "System.String") {
                $messageItem = Resolve-MailObjectFromString -Object $messageItem -User $User -Token $Token -NoNameResolving -FunctionName $MyInvocation.MyCommand
                if(-not $messageItem) { continue }
            }

            $User = Resolve-UserInMailObject -Object $messageItem -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
            #endregion checking input object type and query message if required

            if ($pscmdlet.ShouldProcess($messageItem, "Send")) {
                Write-PSFMessage -Tag "MessageSend" -Level Verbose -Message "Send message '$($messageItem)'"
                $invokeParam = @{
                    "Field"        = "messages/$($messageItem.Id)/send"
                    "User"         = $User
                    "Body"         = ""
                    "ContentType"  = "application/json"
                    "Token"        = $Token
                    "FunctionName" = $MyInvocation.MyCommand
                }
                $output = Invoke-MgaPostMethod @invokeParam
                if ($PassThru) { $messageItem.InputObject }
            }
        }
        #endregion send message
    }

    end {
    }
}