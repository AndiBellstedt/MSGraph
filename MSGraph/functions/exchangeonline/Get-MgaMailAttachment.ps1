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
        Can be created by using New-EORAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-EORAccessToken.
    
    .EXAMPLE
        PS C:\> Get-MgaMailMessage
    
        Return all emails in the inbox of the user connected to through a token
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName='ById')]
        [Alias('Id')]
        [string[]]
        $MailId,

        [Parameter(ParameterSetName='ById')]
        [string]
        $User = 'me',

        [switch]
        $IncludeInlineAttachment,

        [Int64]
        $ResultSize = (Get-PSFConfigValue -FullName 'MSGraph.Query.ResultSize' -Fallback 100),

        [MSGraph.Core.AzureAccessToken]
        $Token
    )
    begin {
        #[Parameter(ValueFromPipeline = $true,ParameterSetName='ByInputObject')]
        #[Alias('Mail', 'MailMessage', 'Message')]
        #[PSCustomObject]
        #$InputObject,

        $objectBaseType = "MSGraph.Exchange"
        $objectType = "MailAttachment"
    }

    process {
        foreach ($mail in $MailId) {
            Write-PSFMessage -Level Verbose -Message "Getting attachment from mail"
            $data = Invoke-MgaGetMethod -Field "messages/$($mail)/attachments" -User $User -Token $Token -ResultSize $ResultSize
            if(-not $IncludeInlineAttachment) { $data = $data | Where-Object isInline -eq $false}
            foreach ($output in $data) {
                $output.pstypenames.Insert(0, $objectBaseType)
                $output.pstypenames.Insert(0, "$($objectBaseType).$($objectType)")
                $output
            }
        }
    }

    end {
    }
}