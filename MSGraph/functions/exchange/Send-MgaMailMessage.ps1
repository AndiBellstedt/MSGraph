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

    .PARAMETER Subject
        The subject of the new message.

    .PARAMETER Sender
        The account that is actually used to generate the message.
        (Updatable only when sending a message from a shared mailbox or sending a message as a delegate.
        In any case, the value must correspond to the actual mailbox used.)

    .PARAMETER From
        The mailbox owner and sender of the message.
        Must correspond to the actual mailbox used.

    .PARAMETER ToRecipients
        The To recipients for the message.

    .PARAMETER CCRecipients
        The Cc recipients for the message.

    .PARAMETER BCCRecipients
        The Bcc recipients for the message.

    .PARAMETER ReplyTo
        The email addresses to use when replying.

    .PARAMETER Body
        The body of the message.

    .PARAMETER Categories
        The categories associated with the message.

    .PARAMETER Importance
        The importance of the message.
        The possible values are: Low, Normal, High.

    .PARAMETER InferenceClassification
        The classification of the message for the user, based on inferred relevance or importance, or on an explicit override.
        The possible values are: focused or other.

    .PARAMETER IsDeliveryReceiptRequested
        Indicates whether a delivery receipt is requested for the message.

    .PARAMETER IsReadReceiptRequested
        Indicates whether a read receipt is requested for the message.

    .PARAMETER SaveToSentItems
        Indicates whether to save the message in Sent Items.
        Only needed to be specified if the parameter should be $false, default is $true.

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
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'DirectSend')]
    [Alias()]
    [OutputType([MSGraph.Exchange.Mail.Message])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByInputObject')]
        [Alias('InputObject', 'MessageId', 'Id', 'Mail', 'MailId')]
        [MSGraph.Exchange.Mail.MessageParameter[]]
        $Message,

        [Parameter(ParameterSetName = 'DirectSend', Mandatory = $true)]
        [Alias('Name', 'Title')]
        [string[]]
        $Subject,

        [Parameter(ParameterSetName = 'DirectSend')]
        [String]
        $Body,

        [Parameter(ParameterSetName = 'DirectSend', Mandatory = $true)]
        [Alias('To', 'Recipients')]
        [string[]]
        $ToRecipients,

        [Parameter(ParameterSetName = 'DirectSend')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]
        $CCRecipients,

        [Parameter(ParameterSetName = 'DirectSend')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string]
        $Sender,

        [Parameter(ParameterSetName = 'DirectSend')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string]
        $From,

        [Parameter(ParameterSetName = 'DirectSend')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]
        $BCCRecipients,

        [Parameter(ParameterSetName = 'DirectSend')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]
        $ReplyTo,

        [Parameter(ParameterSetName = 'DirectSend')]
        [String[]]
        $Categories,

        [Parameter(ParameterSetName = 'DirectSend')]
        [ValidateSet("Low", "Normal", "High")]
        [String]
        $Importance = "Normal",

        [Parameter(ParameterSetName = 'DirectSend')]
        [ValidateSet("focused", "other")]
        [String]
        $InferenceClassification = "other",

        [Parameter(ParameterSetName = 'DirectSend')]
        [bool]
        $IsDeliveryReceiptRequested = $false,

        [Parameter(ParameterSetName = 'DirectSend')]
        [bool]
        $IsReadReceiptRequested = $false,

        [Parameter(ParameterSetName = 'DirectSend')]
        [bool]
        $SaveToSentItems = $true,

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
        Write-PSFMessage -Level Debug -Message "Working on parameter set $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

        #region send message
        switch ($PSCmdlet.ParameterSetName) {
            'ByInputObject' {
                foreach ($messageItem in $Message) {
                    #region checking input object type and query message if required
                    if ($messageItem.TypeName -like "System.String") {
                        $messageItem = Resolve-MailObjectFromString -Object $messageItem -User $User -Token $Token -NoNameResolving -FunctionName $MyInvocation.MyCommand
                        if (-not $messageItem) { continue }
                    }

                    $User = Resolve-UserInMailObject -Object $messageItem -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
                    #endregion checking input object type and query message if required

                    #region send message
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
                        $null = Invoke-MgaPostMethod @invokeParam
                        if ($PassThru) { $messageItem.InputObject }
                    }
                    #endregion send message
                }
            }

            'DirectSend' {
                #region Put parameters (JSON Parts) into a valid "message"-JSON-object together
                $jsonParams = @{}
                $bodyJsonParts = @()

                $names = "Subject","Sender","From","ToRecipients","CCRecipients","BCCRecipients","ReplyTo","Body","Categories","Importance","InferenceClassification","IsDeliveryReceiptRequested","IsReadReceiptRequested"
                foreach ($name in $names) {
                    if (Test-PSFParameterBinding -ParameterName $name) {
                        Write-PSFMessage -Level Debug -Message "Add $($name) from parameters to message" -Tag "ParameterParsing"
                        $jsonParams.Add($name, (Get-Variable $name -Scope 0).Value)
                    }
                }

                $bodyHash = @{
                    "message"         = (New-JsonMailObject @jsonParams -FunctionName $MyInvocation.MyCommand)
                    "saveToSentItems" = ($SaveToSentItems | ConvertTo-Json)
                }
                foreach ($key in $bodyHash.Keys) {
                    $bodyJsonParts = $bodyJsonParts + """$($key)"" : $($bodyHash[$Key])"
                }

                $bodyJSON = "{`n" + ([string]::Join(",`n", $bodyJsonParts)) + "`n}"
                #endregion Put parameters (JSON Parts) into a valid "message"-JSON-object together

                #region send message
                if ($pscmdlet.ShouldProcess($Subject, "Send")) {
                    Write-PSFMessage -Tag "MessageSend" -Level Verbose -Message "Send message with subject '$($Subject)' to recipient '$($ToRecipients)'"
                    $invokeParam = @{
                        "Field"        = "sendMail"
                        "User"         = $User
                        "Body"         = $bodyJSON
                        "ContentType"  = "application/json"
                        "Token"        = $Token
                        "FunctionName" = $MyInvocation.MyCommand
                    }
                    $null = Invoke-MgaPostMethod @invokeParam
                    if ($PassThru) { $messageItem.InputObject }
                }
                #endregion send message
            }

            Default { stop-PSFMessage -Message "Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistake." -EnableException $true -Category "ParameterSetHandling" -FunctionName $MyInvocation.MyCommand }
        }
        #endregion send message
    }

    end {
    }
}