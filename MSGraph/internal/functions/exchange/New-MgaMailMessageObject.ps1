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
    [OutputType([MSGraph.Exchange.Mail.Message])]
    [CmdletBinding()]
    param (
        $RestData,

        [String]
        $FunctionName
    )

    $hash = [ordered]@{
        BaseObject                 = $RestData
        Subject                    = $RestData.subject
        Body                       = $RestData.body
        BodyPreview                = $RestData.bodyPreview
        Categories                 = $RestData.categories
        ChangeKey                  = $RestData.changeKey
        ConversationId             = $RestData.conversationId
        CreatedDateTime            = [datetime]::Parse($RestData.createdDateTime)
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
        lastModifiedDateTime       = [datetime]::Parse($RestData.lastModifiedDateTime)
        MeetingMessageType         = $RestData.meetingMessageType
        ParentFolderId             = $RestData.parentFolderId
        ReceivedDateTime           = [datetime]::Parse($RestData.receivedDateTime)
        SentDateTime               = [datetime]::Parse($RestData.sentDateTime)
        WebLink                    = $RestData.webLink
        User                       = $RestData.User
    }
    if ($RestData.from.emailAddress) {
        $hash.Add("from", ($RestData.from.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)"} -ErrorAction Continue))
    }
    if ($RestData.Sender.emailAddress) {
        $hash.Add("Sender", ($RestData.Sender.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)"} -ErrorAction Continue ))
    }
    if ($RestData.bccRecipients.emailAddress) {
        $hash.Add("bccRecipients", [array]($RestData.bccRecipients.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)"} -ErrorAction Continue))
    }
    if ($RestData.ccRecipients.emailAddress) {
        $hash.Add("ccRecipients", [array]($RestData.ccRecipients.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)"} -ErrorAction Continue))
    }
    if ($RestData.replyTo.emailAddress) {
        $hash.Add("replyTo", [array]($RestData.replyTo.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)"} -ErrorAction Continue))
    }
    if ($RestData.toRecipients.emailAddress) {
        $hash.Add("toRecipients", [array]($RestData.toRecipients.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)"}))
    }

    $messageOutputObject = New-Object -TypeName MSGraph.Exchange.Mail.Message -Property $hash
    $messageOutputObject
}