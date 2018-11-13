function Get-MgaMailMessage {
    <#
    .SYNOPSIS
        Retrieves messages from a email folder from Exchange Online using the graph api.
    
    .DESCRIPTION
        Retrieves messages from a email folder from Exchange Online using the graph api.
    
    .PARAMETER Name
        The display name of the folder to search.
        Defaults to the inbox.
    
    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER ResultSize
        The user to execute this under. Defaults to the user the token belongs to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.
    
    .EXAMPLE
        PS C:\> Get-MgaMailMessage
    
        Return all emails in the inbox of the user connected to through a token
    #>
    [CmdletBinding(DefaultParameterSetName='ByFolderName')]
    [OutputType([MSGraph.Exchange.Mail.Message])]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName='ByInputObject')]
        [MSGraph.Exchange.Mail.Folder]
        $InputObject,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName='ByFolderName')]
        [Alias('FolderName')]
        [string[]]
        $Folder = 'Inbox',

        [string]
        $User = 'me',

        [Int64]
        $ResultSize = (Get-PSFConfigValue -FullName 'MSGraph.Query.ResultSize' -Fallback 100),

        [MSGraph.Core.AzureAccessToken]
        $Token
    )
    begin {
    }

    process {
        foreach ($folderItem in $Folder) {
            Write-PSFMessage -Level Verbose -Message "Searching $folderItem"
            $data = Invoke-MgaGetMethod -Field "mailFolders/$($folderItem)/messages" -User $User -Token $Token -ResultSize $ResultSize
            foreach ($output in $data) {
                [MSGraph.Exchange.Mail.Message]@{
                    BaseObject = $output
                }
            }
        }
    }

}