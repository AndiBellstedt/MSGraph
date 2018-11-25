function Get-MgaMailFolder {
    <#
    .SYNOPSIS
        Searches mail folders in Exchange Online

    .DESCRIPTION
        Searches mail folders in Exchange Online

    .PARAMETER Name
        The name of the folder(S) to query.

    .PARAMETER Filter
        The name to filter by.
        (Client Side filtering)

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

        .PARAMETER ResultSize
        The user to execute this under.
        Defaults to the user the token belongs to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-EORAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-EORAccessToken.

    .EXAMPLE
        PS C:\> Get-MgaMailFolder

        Returns all folders in the mailbox of the connected user.

    .EXAMPLE
        PS C:\> Get-MgaMailFolder -Filter Inbox -User "max.master@contoso.onmicrosoft.com" -Token $Token

        Retrieves the inbox folder of the "max.master@contoso.onmicrosoft.com" mailbox, using the connection token stored in $Token.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([MSGraph.Exchange.Mail.Folder])]
    param (
        [Parameter(ParameterSetName = 'ByFolderName', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true, Position = 0)]
        [Alias('FolderName', 'InputObject', 'DisplayName', 'Id')]
        [MSGraph.Exchange.Mail.MailFolderParameter[]]
        $Name,

        [switch]
        $IncludeChildFolders,

        [string]
        $Filter = "*",

        [string]
        $User,

        [Int64]
        $ResultSize = (Get-PSFConfigValue -FullName 'MSGraph.Query.ResultSize' -Fallback 100),

        [MSGraph.Core.AzureAccessToken]
        $Token
    )

    begin {
        function invoke-internalMgaGetMethod ($invokeParam) {
            $folderData = Invoke-MgaGetMethod @invokeParam | Where-Object displayName -Like $Filter
            foreach ($folderOutput in $folderData) {
                [MSGraph.Exchange.Mail.Folder]@{
                    Id               = $folderOutput.Id
                    DisplayName      = $folderOutput.DisplayName
                    ParentFolderId   = $folderOutput.ParentFolderId
                    ChildFolderCount = $folderOutput.ChildFolderCount
                    UnreadItemCount  = $folderOutput.UnreadItemCount
                    TotalItemCount   = $folderOutput.TotalItemCount
                    User             = $folderOutput.User
                }
            }
        }
    }

    process {
        Write-PSFMessage -Level VeryVerbose -Message "Gettings folder(s) by parameter set $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"
        switch ($PSCmdlet.ParameterSetName) {
            "Default" {
                $invokeParam = @{
                    "Field"        = 'mailFolders'
                    "Token"        = $Token
                    "User"         = Resolve-UserString -User $User
                    "ResultSize"   = $ResultSize
                    "FunctionName" = $MyInvocation.MyCommand
                }

                [array]$output = invoke-internalMgaGetMethod $invokeParam

                if ($output -and $IncludeChildFolders) {
                    foreach ($folder in $output) {
                        [array]$result = $folder
                        Write-PSFMessage -Level VeryVerbose -Message "IncludeChildFolders switch specified. Getting childfolders for folder '$($folder.Name)'" -Tag "ParameterSetHandling"
                        $invokeParam.Field = "mailFolders/$($folder.Id)/childFolders"
                        $result = $result + (invoke-internalMgaGetMethod $invokeParam)
                        $result
                    }
                }
                else { 
                    $output
                }
            }
            "ByFolderName" {
                foreach ($folder in $Name) {
                    Write-PSFMessage -Level VeryVerbose -Message "Getting folder '$( if($folder.Name){$folder.Name}else{$folder.Id} )'" -Tag "ParameterSetHandling"
                    $invokeParam = @{
                        "Field"        = "mailFolders/$($folder.Id)"
                        "Token"        = $Token
                        "User"         = Resolve-UserString -User $User
                        "ResultSize"   = $ResultSize
                        "FunctionName" = $MyInvocation.MyCommand
                    }

                    [array]$output = invoke-internalMgaGetMethod $invokeParam
                    if ($output -and $IncludeChildFolders) {
                        Write-PSFMessage -Level VeryVerbose -Message "IncludeChildFolders switch specified. Getting childfolders for folder '$($output.Name)'" -Tag "ParameterSetHandling"
                        $invokeParam.Field = "$($invokeParam.Field)/childFolders"
                        $output = $output + (invoke-internalMgaGetMethod $invokeParam)
                    }

                    $output
                }

            }
            Default { stop-PSFMessage -Message "Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistage." -EnableException $true -Category "ParameterSetHandling" -FunctionName $MyInvocation.MyCommand }
        }
    }

    end {

    }
}