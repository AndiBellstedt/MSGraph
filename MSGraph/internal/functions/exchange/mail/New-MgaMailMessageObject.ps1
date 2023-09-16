function New-MgaMailMessageObject {
    <#
    .SYNOPSIS
        Create new MessageObject

    .DESCRIPTION
        Create new MessageObject
        Helper function used for internal commands.

    .PARAMETER RestData
        The RestData object containing the data for the new message object.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.

    .EXAMPLE
        PS C:\> New-MgaMailMessageObject -RestData $output

        Create a MSGraph.Exchange.Mail.Message object from data in variable $output
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    [OutputType([MSGraph.Exchange.Mail.Message])]
    [CmdletBinding()]
    param (
        $RestData,

        [String]
        $FunctionName
    )

    #region Handle dates
    if ($RestData.createdDateTime.psobject.TypeNames[0] -like "System.DateTime") {
        $createdDateTime = $RestData.createdDateTime
    } else {
        $createdDateTime = [datetime]::Parse($RestData.createdDateTime)
    }

    if ($RestData.lastModifiedDateTime.psobject.TypeNames[0] -like "System.DateTime") {
        $lastModifiedDateTime = $RestData.lastModifiedDateTime
    } else {
        $lastModifiedDateTime = [datetime]::Parse($RestData.lastModifiedDateTime)
    }

    if ($RestData.receivedDateTime.psobject.TypeNames[0] -like "System.DateTime") {
        $receivedDateTime = $RestData.receivedDateTime
    } else {
        if($RestData.receivedDateTime) {
            $receivedDateTime = [datetime]::Parse($RestData.receivedDateTime)
        } else {
            $receivedDateTime = ""
        }
    }

    if ($RestData.sentDateTime.psobject.TypeNames[0] -like "System.DateTime") {
        $sentDateTime = $RestData.sentDateTime
    } else {
        if($RestData.sentDateTime) {
            $sentDateTime = [datetime]::Parse($RestData.sentDateTime)
        } else {
            $sentDateTime = ""
        }
    }

    #endregion Handle dates

    $hash = [ordered]@{
        BaseObject                 = $RestData
        Subject                    = $RestData.subject
        Body                       = $RestData.body
        BodyPreview                = $RestData.bodyPreview
        Categories                 = $RestData.categories
        ChangeKey                  = $RestData.changeKey
        ConversationId             = $RestData.conversationId
        CreatedDateTime            = $createdDateTime
        Flag                       = $RestData.flag.flagStatus
        HasAttachments             = $RestData.hasAttachments
        Id                         = $RestData.id
        Importance                 = $RestData.importance
        InferenceClassification    = $RestData.inferenceClassification
        InternetMessageId          = $RestData.internetMessageId
        IsDeliveryReceiptRequested = $RestData.isDeliveryReceiptRequested
        IsDraft                    = $RestData.isDraft
        IsRead                     = $RestData.isRead
        isReadReceiptRequested     = $RestData.isReadReceiptRequested
        lastModifiedDateTime       = $lastModifiedDateTime
        MeetingMessageType         = $RestData.meetingMessageType
        ParentFolderId             = $RestData.parentFolderId
        WebLink                    = $RestData.webLink
        User                       = $RestData.User
    }
    if ($RestData.receivedDateTime) { $hash.Add("ReceivedDateTime", $receivedDateTime) }
    if ($RestData.sentDateTime) { $hash.Add("SentDateTime", $sentDateTime) }
    if ($RestData.from.emailAddress) {
        if ($RestData.from.emailAddress.name -like $RestData.from.emailAddress.address) {
            # if emailaddress is same in address and in name field, only use address field
            $from = $RestData.from.emailAddress | ForEach-Object { [mailaddress]$_.address } -ErrorAction Continue
        } else {
            $from = $RestData.from.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)" } -ErrorAction Continue
        }
        $hash.Add("from", $from)
    }
    if ($RestData.Sender.emailAddress) {
        if ($RestData.Sender.emailAddress.name -like $RestData.Sender.emailAddress.address) {
            # if emailaddress is same in address and in name field, only use address field
            $senderaddress = $RestData.Sender.emailAddress | ForEach-Object { [mailaddress]$_.address } -ErrorAction Continue
        } else {
            $senderaddress = $RestData.Sender.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)" } -ErrorAction Continue
        }
        $hash.Add("Sender", $senderaddress)
    }
    if ($RestData.bccRecipients.emailAddress) {
        if ($RestData.bccRecipients.emailAddress.name -like $RestData.bccRecipients.emailAddress.address) {
            # if emailaddress is same in address and in name field, only use address field
            [array]$bccRecipients = $RestData.bccRecipients.emailAddress | ForEach-Object { [mailaddress]$_.address } -ErrorAction Continue
        } else {
            [array]$bccRecipients = $RestData.bccRecipients.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)" } -ErrorAction Continue
        }
        $hash.Add("bccRecipients", [array]$bccRecipients)
    }
    if ($RestData.ccRecipients.emailAddress) {
        if ($RestData.ccRecipients.emailAddress.name -like $RestData.ccRecipients.emailAddress.address) {
            # if emailaddress is same in address and in name field, only use address field
            [array]$ccRecipients = $RestData.ccRecipients.emailAddress | ForEach-Object { [mailaddress]$_.address } -ErrorAction Continue
        } else {
            [array]$ccRecipients = $RestData.ccRecipients.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)" } -ErrorAction Continue
        }
        $hash.Add("ccRecipients", [array]$ccRecipients)
    }
    if ($RestData.replyTo.emailAddress) {
        if ($RestData.replyTo.emailAddress.name -like $RestData.replyTo.emailAddress.address) {
            # if emailaddress is same in address and in name field, only use address field
            [array]$replyTo = $RestData.replyTo.emailAddress | ForEach-Object { [mailaddress]$_.address } -ErrorAction Continue
        } else {
            [array]$replyTo = $RestData.replyTo.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)" } -ErrorAction Continue
        }
        $hash.Add("replyTo", [array]$replyTo)
    }
    if ($RestData.toRecipients.emailAddress) {
        if ($RestData.toRecipients.emailAddress.name -like $RestData.toRecipients.emailAddress.address) {
            # if emailaddress is same in address and in name field, only use address field
            [array]$toRecipients = $RestData.toRecipients.emailAddress | ForEach-Object { [mailaddress]$_.address } -ErrorAction Continue
        } else {
            [array]$toRecipients = $RestData.toRecipients.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)" } -ErrorAction Continue
        }
        $hash.Add("toRecipients", [array]$toRecipients)
    }

    $messageOutputObject = New-Object -TypeName MSGraph.Exchange.Mail.Message -Property $hash
    $messageOutputObject
}