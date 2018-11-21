function Update-MgaMailMessage {
    <#
    .SYNOPSIS
        *** UNDER CONSTRUCTION ***
        Updates messages from a email folder

    .DESCRIPTION
        Update messages from Exchange Online using the graph api.

    .PARAMETER InputObject
        Carrier object for Pipeline input. Accepts messages.

    .PARAMETER Id
        The ID of the message to update

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER IsRead
        Indicates whether the message has been read.

    .PARAMETER Subject
        The subject of the message.
        (Updatable only if isDraft = true.)

    .PARAMETER Sender
        The account that is actually used to generate the message.
        (Updatable only if isDraft = true, and when sending a message from a shared mailbox,
        or sending a message as a delegate. In any case, the value must correspond to the actual mailbox used.)

    .PARAMETER From
        The mailbox owner and sender of the message.
        Must correspond to the actual mailbox used.
        (Updatable only if isDraft = true.)

    .PARAMETER ToRecipients
        The To recipients for the message.
        (Updatable only if isDraft = true.)

    .PARAMETER CCRecipients
        The Cc recipients for the message.
        (Updatable only if isDraft = true.)

    .PARAMETER BCCRecipients
        The Bcc recipients for the message.
        (Updatable only if isDraft = true.)

    .PARAMETER ReplyTo
        The email addresses to use when replying.
        (Updatable only if isDraft = true.)

    .PARAMETER Body
        The body of the message.
        (Updatable only if isDraft = true.)

    .PARAMETER Categories
        The categories associated with the message.

    .PARAMETER Importance
        The importance of the message. 
        The possible values are: Low, Normal, High.

    .PARAMETER InferenceClassification
        The classification of the message for the user, based on inferred relevance or importance, or on an explicit override. 
        The possible values are: focused or other.

    .PARAMETER InternetMessageId
        The message ID in the format specified by RFC2822.
        (Updatable only if isDraft = true.)

    .PARAMETER IsDeliveryReceiptRequested
        Indicates whether a delivery receipt is requested for the message.

    .PARAMETER IsReadReceiptRequested
        Indicates whether a read receipt is requested for the message.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-EORAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-EORAccessToken.

    .PARAMETER PassThru
        Outputs the token to the console

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .EXAMPLE
        PS C:\> Update-MgaMailMessage

        Update emails
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'ByInputObject')]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByInputObject')]
        [MSGraph.Exchange.Mail.Message]
        $InputObject,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [string[]]
        $Id,

        [string]
        $User,

        [bool]
        $IsRead,

        [string]
        $Subject,

        [mailaddress]
        $Sender,

        [mailaddress]
        $From,

        [mailaddress[]]
        $ToRecipients,

        [mailaddress[]]
        $CCRecipients,

        [mailaddress[]]
        $BCCRecipients,

        [mailaddress[]]
        $ReplyTo,

        [String]
        $Body,

        [String[]]
        $Categories,

        [ValidateSet("Low", "Normal", "High")]
        [String]
        $Importance,

        [ValidateSet("focused", "other")]
        [String]
        $InferenceClassification,

        [String]
        $InternetMessageId,

        [bool]
        $IsDeliveryReceiptRequested,

        [bool]
        $IsReadReceiptRequested,

        $Token,

        [switch]
        $PassThru
    )
    begin {
    }

    process {
        $messages = @()
        $bodyHash = @{}
        $boundParameters = @()

        switch ($PSCmdlet.ParameterSetName) {
            "ByInputObject" { $messages = $InputObject.Id }
            "ById" { $messages = $Id }
            Default { stop-PSFMessage -Message "Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistage." -EnableException $true -Category "ParameterSetHandling" -FunctionName $MyInvocation.MyCommand }
        }
        
        $names = @("sender", "from", "toRecipients", "ccRecipients", "bccRecipients", "replyTo")
        foreach ( $name in $names ) {
            if (Test-PSFParameterBinding -ParameterName $name) {
                $boundParameters = $boundParameters + $name
                Write-PSFMessage -Level Verbose -Message "Parsing mailaddress parameter $($name)"
                $address = foreach ($item in (Get-Variable $name -Scope 0).Value) {
                    @{
                        "emailAddress" = @{
                            address = $item.Address
                            name    = $item.DisplayName
                        }
                    }
                }
                $bodyHash.Add($name, $address)
            }
        }

        $names = @("IsRead", "Subject", "Body", "Categories", "Importance", "InferenceClassification", "InternetMessageId", "IsDeliveryReceiptRequested", "IsReadReceiptRequested")
        foreach ( $name in $names ) {
            if (Test-PSFParameterBinding -ParameterName $name) {
                $boundParameters = $boundParameters + $name
                Write-PSFMessage -Level Verbose -Message "Parsing text parameter $($name)"
                $bodyHash.Add($name, (Get-Variable $name -Scope 0).Value)
            }
        }

        foreach ($messageId in $messages) {
            if ($pscmdlet.ShouldProcess("messageId $($messageId)", "Update properties '$([string]::Join("', '", $boundParameters))'")) {
                $invokeParam = @{
                    "Field"        = "messages/$($messageId)"
                    "User"         = $User
                    "Body"         = $bodyHash
                    "ContentType"  = "application/json"
                    "Token"        = $Token
                    "FunctionName" = $MyInvocation.MyCommand
                }
                $output = Invoke-MgaPatchMethod @invokeParam
                [MSGraph.Exchange.Mail.Message]@{ BaseObject = $output }
            }
        }
    }

}