function Get-MgaMailAttachment {
    <#
    .SYNOPSIS
        Retrieves the attachment object from a email message in Exchange Online using the graph api.

    .DESCRIPTION
        Retrieves the attachment object from a email message in Exchange Online using the graph api.

    .PARAMETER Message
        The display name of the folder to search.
        Defaults to the inbox.

    .PARAMETER Name
        The name to filter by.
        (Client Side filtering)

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER IncludeInlineAttachment
        This will retrieve also attachments like pictures in the html body of the mail.

    .PARAMETER ResultSize
        The user to execute this under. Defaults to the user the token belongs to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .EXAMPLE
        PS C:\> Get-MgaMailMessage | Get-MgaMailAttachment

        Return all emails attachments in the inbox of the user connected to through a token.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    #[OutputType([MSGraph.Exchange.Attachment.])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByInputObject', Position = 0)]
        [Alias('InputObject', 'Id', 'Mail', 'MailMessage', 'MessageId', 'MailId')]
        [MSGraph.Exchange.Mail.MessageParameter[]]
        $Message,

        [Parameter(Position = 1)]
        [Alias('Filter', 'NameFilter')]
        [string]
        $Name = "*",

        [switch]
        $IncludeInlineAttachment,

        [string]
        $User,

        [Int64]
        $ResultSize = (Get-PSFConfigValue -FullName 'MSGraph.Query.ResultSize' -Fallback 100),

        [MSGraph.Core.AzureAccessToken]
        $Token
    )
    begin {
        $requiredPermission = "Mail.Read"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand
    }

    process {
        foreach ($messageItem in $Message) {
            #region checking input object type and query message if required
            if ($messageItem.TypeName -like "System.String") {
                $messageItem = Resolve-MailObjectFromString -Object $messageItem -User $User -Token $Token -NoNameResolving -FunctionName $MyInvocation.MyCommand
                if (-not $messageItem) { continue }
            }

            $User = Resolve-UserInMailObject -Object $messageItem -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
            #endregion checking input object type and query message if required

            #region query data
            $invokeParam = @{
                "Field"        = "messages/$($messageItem.Id)/attachments"
                "Token"        = $Token
                "User"         = $User
                "ResultSize"   = $ResultSize
                "ApiVersion"   = "beta"
                "FunctionName" = $MyInvocation.MyCommand
            }

            Write-PSFMessage -Level Verbose -Message "Getting attachment from message '$($messageItem)'" -Tag "QueryData"
            $data = Invoke-MgaGetMethod @invokeParam | Where-Object { $_.name -like $Name }
            if (-not $IncludeInlineAttachment) { $data = $data | Where-Object isInline -eq $false }
            #endregion query data

            #region output data
            foreach ($output in $data) {
                $outputHash = [ordered]@{
                    Id                   = $output.Id
                    Name                 = $output.Name
                    AttachmentType       = [MSGraph.Exchange.Attachment.AttachmentTypes]$output.'@odata.type'.split(".")[($output.'@odata.type'.split(".").count - 1)]
                    ContentType          = $output.ContentType
                    IsInline             = $output.isInline
                    LastModifiedDateTime = $output.LastModifiedDateTime
                    Size                 = $output.Size
                    User                 = $output.user
                    ParentObject         = $messageItem.InputObject
                    BaseObject           = $output
                }
                switch ($output.'@odata.type') {
                    '#microsoft.graph.itemAttachment' {
                        $invokeParam.Field = $invokeParam.Field + "/$($data.id)/?`$expand=microsoft.graph.itemattachment/item"
                        $itemData = Invoke-MgaGetMethod @invokeParam

                        $outputHash.BaseObject = $itemData
                        $outputHash.Id = $itemData.id
                        $outputHash.Add("Item", $itemData.Item)

                        New-Object -TypeName MSGraph.Exchange.Attachment.ItemAttachment -Property $outputHash
                    }

                    '#microsoft.graph.referenceAttachment' {
                        $outputHash.Add("SourceUrl", $output.SourceUrl)
                        $outputHash.Add("ProviderType", $output.ProviderType)
                        $outputHash.Add("ThumbnailUrl", $output.ThumbnailUrl)
                        $outputHash.Add("PreviewUrl", $output.PreviewUrl)
                        $outputHash.Add("Permission", $output.Permission)
                        $outputHash.Add("IsFolder", $output.IsFolder)

                        New-Object -TypeName MSGraph.Exchange.Attachment.ReferenceAttachment -Property $outputHash
                    }

                    '#microsoft.graph.fileAttachment' {
                        $outputHash.Add("ContentId", $output.ContentId)
                        $outputHash.Add("ContentLocation", $output.ContentLocation)
                        $outputHash.Add("ContentBytes", [system.convert]::FromBase64String($output.contentBytes))

                        New-Object -TypeName MSGraph.Exchange.Attachment.FileAttachment -Property $outputHash
                    }

                    Default {
                        New-Object -TypeName MSGraph.Exchange.Attachment.Attachment -Property $outputHash
                    }
                }
            }
            #endregion output data
        }
    }

    end {
    }
}