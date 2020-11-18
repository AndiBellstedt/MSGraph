function Get-MgaMailAttachment {
    <#
    .SYNOPSIS
        Retrieves the attachment object from a email message in Exchange Online using the graph api.

    .DESCRIPTION
        Retrieves the attachment object from a email message in Exchange Online using the graph api.

    .PARAMETER Message
        Carrier object for Pipeline input.
        This can be the id of the message or a message object passed in.

    .PARAMETER Name
        The name to filter by.
        (Client Side filtering)

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER IncludeInlineAttachment
        This will retrieve also attachments like pictures in the html body of the mail.

    .PARAMETER ResultSize
        The amount of objects to query within API calls to MSGraph.
        To avoid long waitings while query a large number of items, the graph api only
        query a special amount of items within one call.

        A value of 0 represents "unlimited" and results in query all items wihtin a call.
        The default is 100.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .EXAMPLE
        PS C:\> Get-MgaMailMessage | Get-MgaMailAttachment

        Return all emails attachments from all mails in the inbox of the user connected to through a token.

    .EXAMPLE
        PS C:\> Get-MgaMailMessage | Get-MgaMailAttachment -Name "MyName*"

        Return all emails attachments with name MyName* from all mails in the inbox of the user connected to through a token.

    .EXAMPLE
        PS C:\> Get-MgaMailMessage | Get-MgaMailAttachment -IncludeInlineAttachment

        Return also "inline" attachments, like pictures in html mails from all emails in the inbox of the user connected to through a token.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
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
            $data = Invoke-MgaRestMethodGet @invokeParam | Where-Object { $_.name -like $Name }
            if (-not $IncludeInlineAttachment) { $data = $data | Where-Object isInline -eq $false }
            #endregion query data

            #region output data
            foreach ($output in $data) {
                $AttachmentObject = New-MgaAttachmentObject -RestData $output -ParentObject $messageItem.InputObject -ApiVersion "beta" -ResultSize $ResultSize -User $User -Token $Token -FunctionName $MyInvocation.MyCommand
                $AttachmentObject
            }
            #endregion output data
        }
    }

    end {
    }
}