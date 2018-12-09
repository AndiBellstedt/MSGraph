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
        BaseObject                 = $output
        Subject                    = $output.subject
        Body                       = $output.body
        BodyPreview                = $output.bodyPreview
        Categories                 = $output.categories
        ChangeKey                  = $output.changeKey
        ConversationId             = $output.conversationId
        CreatedDateTime            = [datetime]::Parse($output.createdDateTime)
        Flag                       = $output.flag.flagStatus
        HasAttachments             = $output.hasAttachments
        Id                         = $output.id
        Importance                 = $output.importance
        InferenceClassification    = $output.inferenceClassification
        InternetMessageId          = $output.internetMessageId
        IsDeliveryReceiptRequested = $output.isDeliveryReceiptRequested
        IsDraft                    = $output.isDraft
        IsRead                     = $output.isRead
        isReadReceiptRequested     = $output.isReadReceiptRequested
        lastModifiedDateTime       = [datetime]::Parse($output.lastModifiedDateTime)
        MeetingMessageType         = $output.meetingMessageType
        ParentFolderId             = $output.parentFolderId
        ReceivedDateTime           = [datetime]::Parse($output.receivedDateTime)
        SentDateTime               = [datetime]::Parse($output.sentDateTime)
        WebLink                    = $output.webLink
    }
    if($output.from.emailAddress) {
        $hash.Add("from", ($output.from.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)"} -ErrorAction Continue))
    }
    if($output.Sender.emailAddress) {
        $hash.Add("Sender", ($output.Sender.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)"} -ErrorAction Continue ))
    }
    if($output.bccRecipients.emailAddress) {
        $hash.Add("bccRecipients", [array]($output.bccRecipients.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)"} -ErrorAction Continue))
    }
    if($output.ccRecipients.emailAddress) {
        $hash.Add("ccRecipients", [array]($output.ccRecipients.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)"} -ErrorAction Continue))
    }
    if($output.replyTo.emailAddress) {
        $hash.Add("replyTo", [array]($output.replyTo.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)"} -ErrorAction Continue))
    }
    if($output.toRecipients.emailAddress) {
        $hash.Add("toRecipients", [array]($output.toRecipients.emailAddress | ForEach-Object { [mailaddress]"$($_.name) $($_.address)"}))
    }

    $messageOutputObject = New-Object -TypeName MSGraph.Exchange.Mail.Message -Property $hash
    $messageOutputObject
}