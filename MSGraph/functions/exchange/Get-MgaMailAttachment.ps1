function Get-MgaMailAttachment {
    <#
    .SYNOPSIS
        Retrieves the attachment object from a email message in Exchange Online using the graph api.

    .DESCRIPTION
        Retrieves the attachment object from a email message in Exchange Online using the graph api.

    .PARAMETER MailId
        The display name of the folder to search.
        Defaults to the inbox.

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
        PS C:\> MgaMailMessage | Get-MgaMailAttachment

        Return all emails attachments in the inbox of the user connected to through a token.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([MSGraph.Exchange.Mail.Attachment])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByInputObject', Position = 0)]
        [Alias('Id', 'Mail', 'MailMessage', 'MessageId', 'MailId')]
        [MSGraph.Exchange.Mail.MessageParameter[]]
        $Message,

        [Parameter(Position = 1)]
        [string]
        $Name = "*",

        [string]
        $User,

        [switch]
        $IncludeInlineAttachment,

        [Int64]
        $ResultSize = (Get-PSFConfigValue -FullName 'MSGraph.Query.ResultSize' -Fallback 100),

        [MSGraph.Core.AzureAccessToken]
        $Token
    )
    begin {
    }

    process {
        foreach ($item in $Message) {
            if($item.Name -and (-not $item.Id)) {
                Write-PSFMessage -Level Warning -Message "'$($item.Name)' has no valid ID to query. You have to input message objects or message Id to query attachments." -Tag "ParameterSetHandling"
                continue
            }
            $invokeParam = @{
                "Field"        = "messages/$($item.Id)/attachments"
                "Token"        = $Token
                "User"         = Resolve-UserString -User $User
                "ResultSize"   = $ResultSize
                "FunctionName" = $MyInvocation.MyCommand
            }

            Write-PSFMessage -Level Verbose -Message "Getting attachment from mail" -Tag "QueryData"

            $data = Invoke-MgaGetMethod @invokeParam | Where-Object { $_.name -like $Name }
            if (-not $IncludeInlineAttachment) { $data = $data | Where-Object isInline -eq $false}
            foreach ($output in $data) {
                [MSGraph.Exchange.Mail.Attachment]@{
                    BaseObject           = $output
                    Id                   = $output.Id
                    Name                 = $output.Name
                    ContentType          = $output.ContentType
                    ContentId            = $output.ContentId
                    ContentLocation      = $output.ContentLocation
                    IsInline             = $output.isInline
                    LastModifiedDateTime = $output.LastModifiedDateTime
                    Size                 = $output.Size
                }
            }
        }
    }

    end {
    }
}