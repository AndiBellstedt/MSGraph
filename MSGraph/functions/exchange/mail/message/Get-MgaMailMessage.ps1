function Get-MgaMailMessage {
    <#
    .SYNOPSIS
        Retrieves messages from a email folder from Exchange Online using the graph api.

    .DESCRIPTION
        Retrieves messages from a email folder from Exchange Online using the graph api.

    .PARAMETER InputObject
        Carrier object for Pipeline input
        Accepts messages or folders from other Mga-functions

    .PARAMETER FolderName
        The display name of the folder to search.
        Defaults to the inbox.

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER Subject
        The subject to filter by (Client Side filtering)

    .PARAMETER Delta
        Indicates a "delta-query" for incremental changes on mails.
        The switch allows you to query mutliple times against the same user and folder while only getting additional,
        updated or deleted messages.

        Please notice, that delta queries needs to be handeled right. See the examples for correct usage.

    .PARAMETER ResultSize
        The user to execute this under. Defaults to the user the token belongs to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .EXAMPLE
        PS C:\> Get-MgaMailMessage

        Return emails in the inbox of the user connected to through a token.

    .EXAMPLE
        PS C:\> $mails = Get-MgaMailMessage -Delta

        Return emails in the inbox of the user connected to through a token and write the output in the variable $mails.
        IMPORTANT, the -Delta switch needs to be specified on the first call, because the outputobject will has to be piped
        into the next delta query.

        The content of $mails can be used and processed:
        PS C:\> $mails

        So the second Get-MgaMailMessage call has to be:
        PS C:\> $deltaMails = Get-MgaMailMessage -InputObject $mails -Delta

        This return only unqueried, updated, or new messages from the previous call and writes the result in the
        variable $deltaMails.

        The content of the $deltaMails variable can be used as output and should only overwrites the $mail variable if there is content in $deltaMails:
        PS C:\> if($deltaMails) {
            $mails = $deltaMails
            $deltaMails
        }

        From the second call, the procedure can be continued as needed, only updates will be outputted by Get-MgaMailMessage.

        .EXAMPLE
        PS C:\> Get-MgaMailFolder -Name "Junkemail" | Get-MgaMailMessage

        Return emails from the Junkemail folder of the user connected to through a token.

        .EXAMPLE
        PS C:\> Get-MgaMailMessage -FolderName "MyFolder" -Subject "Important*"

        Return emails where the subject starts with "Important" from the folder "MyFolder" of the user connected to through a token.
#>
    [CmdletBinding(DefaultParameterSetName = 'ByInputObject')]
    [OutputType([MSGraph.Exchange.Mail.Message])]
    param (
        [Parameter(ParameterSetName = 'ByInputObject', Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Input', 'Id')]
        [MSGraph.Exchange.Mail.MessageOrFolderParameter[]]
        $InputObject,

        [Parameter(ParameterSetName = 'ByFolderName', Position = 0)]
        [Alias('FolderId', 'Folder')]
        [string[]]
        $FolderName,

        [string]
        $User,

        [string]
        $Subject = "*",

        [switch]
        $Delta,

        [Int64]
        $ResultSize = (Get-PSFConfigValue -FullName 'MSGraph.Query.ResultSize' -Fallback 100),

        [MSGraph.Core.AzureAccessToken]
        $Token
    )
    begin {
        $requiredPermission = "Mail.Read"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand

        $InvokeParams = @()
    }

    process {
        Write-PSFMessage -Level VeryVerbose -Message "Gettings mails by parameter set $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"
        if ($PSCmdlet.ParameterSetName -like "ByInputObject" -and -not $InputObject) {
            Write-PSFMessage -Level Verbose -Message "No InputObject specified. Gettings mail from default folder (inbox)." -Tag "ParameterSetHandling"
            [MSGraph.Exchange.Mail.MessageOrFolderParameter]$InputObject = [MSGraph.Exchange.Mail.WellKnownFolder]::Inbox.ToString()
        }
        if ($PSCmdlet.ParameterSetName -like "ByFolderName") {
            foreach ($folderItem in $FolderName) {
                $folderItem = [MSGraph.Exchange.Mail.MessageOrFolderParameter]$folderItem
                if($folderItem.Name -and (-not $folderItem.IsWellKnownName)) {
                    [MSGraph.Exchange.Mail.MessageOrFolderParameter]$folderItem = Get-MgaMailFolder -Name $folderItem.Name -User $User -Token $Token
                }
                $InputObject = $InputObject + $folderItem
            }
        }

        foreach ($InputObjectItem in $InputObject) {
            Write-PSFMessage -Level VeryVerbose -Message "Parsing input $($InputObjectItem.TypeName) object '$($InputObjectItem)'"
            switch ($InputObjectItem.TypeName) {
                "MSGraph.Exchange.Mail.Message" {
                    if ($Delta -and ('@odata.deltaLink' -in $InputObjectItem.InputObject.BaseObject.psobject.Properties.Name)) {
                        # if delta message, construct a delta query from mail
                        Write-PSFMessage -Level VeryVerbose -Message "Delta parameter specified and delta message found. Checking on message '$($InputObjectItem)' from the pipeline"
                        $invokeParam = @{
                            "deltaLink"    = $InputObjectItem.InputObject.BaseObject.'@odata.deltaLink'
                            "Token"        = $Token
                            "ResultSize"   = $ResultSize
                            "FunctionName" = $MyInvocation.MyCommand
                        }
                    }
                    else {
                        # if non delta message is parsed in, the message will be queried again (refreshed)
                        # Not really necessary, but works as intend from pipeline usage
                        Write-PSFMessage -Level VeryVerbose -Message "Refresh message '$($InputObjectItem)' from the pipeline"
                        $invokeParam = @{
                            "Field"        = "messages/$($InputObjectItem.Id)"
                            "User"         = $InputObjectItem.InputObject.BaseObject.User
                            "Token"        = $Token
                            "ResultSize"   = $ResultSize
                            "FunctionName" = $MyInvocation.MyCommand
                        }
                        if ($Delta) { $invokeParam.Add("Delta", $true) }
                    }
                    $invokeParams = $invokeParams + $invokeParam
                }

                "MSGraph.Exchange.Mail.Folder" {
                    Write-PSFMessage -Level VeryVerbose -Message "Gettings messages in folder '$($InputObjectItem)' from the pipeline"
                    $invokeParam = @{
                        "Field"        = "mailFolders/$($InputObjectItem.Id)/messages"
                        "User"         = $InputObjectItem.InputObject.User
                        "Token"        = $Token
                        "ResultSize"   = $ResultSize
                        "FunctionName" = $MyInvocation.MyCommand
                    }
                    if ($Delta) { $invokeParam.Add("Delta", $true) }
                    $invokeParams = $invokeParams + $invokeParam
                }

                "System.String" {
                    $invokeParam = @{
                        "User"         = $User
                        "Token"        = $Token
                        "ResultSize"   = $ResultSize
                        "FunctionName" = $MyInvocation.MyCommand
                    }
                    if ($Delta) { $invokeParam.Add("Delta", $true) }

                    $name = if ($InputObjectItem.IsWellKnownName) { $InputObjectItem.Name } else { $InputObjectItem.Id }
                    if($name.length -eq 152 -or $name.length -eq 136) {
                        # Id is a message
                        Write-PSFMessage -Level VeryVerbose -Message "Gettings messages with Id '$($InputObjectItem)'" -Tag "InputValidation"
                        $invokeParam.Add("Field","messages/$($name)")
                    }
                    elseif ($name.length -eq 120 -or $name.length -eq 104)
                    {
                        # Id is a folder
                        Write-PSFMessage -Level VeryVerbose -Message "Gettings messages in folder with Id '$($InputObjectItem)'" -Tag "InputValidation"
                        $invokeParam.Add("Field","mailFolders/$($name)/messages")
                    }
                    elseif ($InputObjectItem.IsWellKnownName -and $name) {
                        # a well known folder is specified by name
                        $invokeParam.Add("Field","mailFolders/$($name)/messages")
                    }
                    else {
                        # not a valid Id -> should not happen
                        Write-PSFMessage -Level Warning -Message "The specified Id seeams not be a valid Id. Skipping object '$($name)'" -Tag "InputValidation"
                        continue
                    }

                    $invokeParams = $invokeParams + $invokeParam
                    Remove-Variable -Name name -Force -ErrorAction Ignore -WhatIf:$false -Confirm:$false -Verbose:$false -Debug:$false
                }

                Default { Write-PSFMessage -Level Critical -Message "Failed on type validation. Can not handle $($InputObjectItem.TypeName)" -EnableException $true -Tag "TypeValidation" }
            }
        }
    }

    end {
        $fielList = @()
        $InvokeParamsUniqueList = @()
        Write-PSFMessage -Level Verbose -Message "Checking $( ($InvokeParams | Measure-Object).Count ) objects on unique calls..."
        foreach ($invokeParam in $InvokeParams) {
            if ($invokeParam.Field -and ($invokeParam.Field -notin $fielList)) {
                $InvokeParamsUniqueList = $InvokeParamsUniqueList + $invokeParam
                $fielList = $fielList + $invokeParam.Field
            }
            elseif ($invokeParam.deltaLink -notin $fielList) {
                $InvokeParamsUniqueList = $InvokeParamsUniqueList + $invokeParam
                $fielList = $fielList + $invokeParam.deltaLink
            }
        }
        Write-PSFMessage -Level Verbose -Message "Invoking $( ($InvokeParamsUniqueList | Measure-Object).Count ) REST calls for gettings messages"

        # run the message query and process the output
        foreach ($invokeParam in $InvokeParamsUniqueList) {
            $data = Invoke-MgaRestMethodGet @invokeParam | Where-Object { $_.subject -like $Subject }
            $output = foreach ($messageOutput in $data) {
                New-MgaMailMessageObject -RestData $messageOutput
            }
        }

        if ($output) {
            $output
        }
        else {
            Write-PSFMessage -Level Warning -Message "Message not found." -Tag "QueryData"
        }
    }
}