function New-MgaAttachmentObject {
    <#
    .SYNOPSIS
        Create new Attachment object

    .DESCRIPTION
        Create new Attachment object
        Helper function used for internal commands.

    .PARAMETER RestData
        The RestData object containing the data for the new message object.

    .PARAMETER ParentObject
        The ParentObject object where the attachment came from.

    .PARAMETER ApiVersion
        The version used for queries in Microsoft Graph connection

    .PARAMETER ResultSize
        The amount of objects to query within API calls to MSGraph.
        To avoid long waitings while query a large number of items, the graph api only
        query a special amount of items within one call.

        A value of 0 represents "unlimited" and results in query all items wihtin a call.
        The default is 100.

    .PARAMETER User
        The user to execute this under. Defaults to the user the token belongs to.

    .PARAMETER Token
        The access token to use to connect.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.

    .EXAMPLE
        PS C:\> New-MgaAttachmentObject -RestData $output

        Create a MSGraph.Exchange.Attachment.* object from data in variable $output
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param (
        $RestData,

        $ParentObject,

        $ApiVersion,

        [Int64]
        $ResultSize,

        [string]
        $User,

        [MSGraph.Core.AzureAccessToken]
        $Token,

        [String]
        $FunctionName
    )

    $outputHash = [ordered]@{
        Id                   = $RestData.Id
        Name                 = $RestData.Name
        AttachmentType       = [MSGraph.Exchange.Attachment.AttachmentTypes]$RestData.'@odata.type'.split(".")[($RestData.'@odata.type'.split(".").count - 1)]
        ContentType          = $RestData.ContentType
        IsInline             = $RestData.isInline
        LastModifiedDateTime = $RestData.LastModifiedDateTime
        Size                 = $RestData.Size
        User                 = $RestData.user
        ParentObject         = $ParentObject
        BaseObject           = $RestData
    }

    switch ($RestData.'@odata.type') {
        '#microsoft.graph.itemAttachment' {
            $invokeParam = @{
                "Field"        = "messages/$($ParentObject.Id)/attachments/$($RestData.id)/?`$expand=microsoft.graph.itemattachment/item"
                "Token"        = $Token
                "User"         = $User
                "ResultSize"   = $ResultSize
                "ApiVersion"   = $ApiVersion
                "FunctionName" = $FunctionName
            }
            $itemData = Invoke-MgaRestMethodGet @invokeParam

            $outputHash.BaseObject = $itemData
            $outputHash.Id = $itemData.id
            $outputHash.Add("Item", $itemData.Item)

            New-Object -TypeName MSGraph.Exchange.Attachment.ItemAttachment -Property $outputHash
        }

        '#microsoft.graph.referenceAttachment' {
            $outputHash.Add("SourceUrl", [uri]$RestData.SourceUrl)
            $outputHash.Add("ProviderType", [MSGraph.Exchange.Attachment.ReferenceAttachmentProvider]$RestData.ProviderType)
            $outputHash.Add("ThumbnailUrl", [uri]$RestData.ThumbnailUrl)
            $outputHash.Add("PreviewUrl", [uri]$RestData.PreviewUrl)
            $outputHash.Add("Permission", [MSGraph.Exchange.Attachment.referenceAttachmentPermission]$RestData.Permission)
            $outputHash.Add("IsFolder", [bool]::Parse($RestData.IsFolder))

            New-Object -TypeName MSGraph.Exchange.Attachment.ReferenceAttachment -Property $outputHash
        }

        '#microsoft.graph.fileAttachment' {
            $outputHash.Add("ContentId", $RestData.ContentId)
            $outputHash.Add("ContentLocation", $RestData.ContentLocation)
            $outputHash.Add("ContentBytes", [system.convert]::FromBase64String($RestData.contentBytes))

            New-Object -TypeName MSGraph.Exchange.Attachment.FileAttachment -Property $outputHash
        }

        Default {
            New-Object -TypeName MSGraph.Exchange.Attachment.Attachment -Property $outputHash
        }
    }

}