function Get-MgaMailMessage {
    <#
    .SYNOPSIS
        Retrieves messages from a email folder from Exchange Online using the graph api.

    .DESCRIPTION
        Retrieves messages from a email folder from Exchange Online using the graph api.

    .PARAMETER InputObject
        Carrier object for Pipeline input
        Accepts messages or folders from other Mga-functions

    .PARAMETER Folder
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

        Return emails in the inbox of the user connected to through a token

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
        PS C:\> Get-MgaMailFolder -Filter "MyFolder*" | Get-MgaMailMessage

        Return emails in the folders "MyFolder*" of the user connected to through a token

        .EXAMPLE
        PS C:\> Get-MgaMailMessage

        Return emails in the folders "MyFolder*" of the user connected to through a token
#>
    [CmdletBinding(DefaultParameterSetName = 'ByFolderName')]
    [OutputType([MSGraph.Exchange.Mail.Message])]
    param (
        [Parameter(ParameterSetName = 'ByInputObject', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $InputObject,

        [Parameter(ParameterSetName = 'ByFolderName', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FolderName')]
        [string[]]
        $Folder = 'Inbox',

        [Parameter(ParameterSetName = 'ByFolderName')]
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
        $InvokeParams = @()
    }

    process {
        Write-PSFMessage -Level VeryVerbose -Message "Gettings mails by parameter set $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"
        switch ($PSCmdlet.ParameterSetName) {
            "ByInputObject" {
                $typeNames = ($InputObject | Get-Member).TypeName | Sort-Object -Unique
                foreach($typeName in $typeNames) {
                    switch ($typeName) {
                        "MSGraph.Exchange.Mail.Message" {
                            Write-PSFMessage -Level VeryVerbose -Message "Parsing messages from the pipeline"
                            [array]$messages = $InputObject | Where-Object { "MSGraph.Exchange.Mail.Message" -in $_.psobject.TypeNames }

                            if($Delta) {
                                # retreive delta messages
                                [array]$deltaMessages = $messages | Where-Object { '@odata.deltaLink' -in $_.BaseObject.psobject.Properties.Name }
                                [array]$deltaLinks = $deltaMessages.BaseObject | Select-Object -ExpandProperty '@odata.deltaLink' -Unique

                                Write-PSFMessage -Level VeryVerbose -Message "Delta parameter specified. Checking on $($deltaLinks.Count) deltalink(s) in $($deltaMessages.Count) message(s) from the pipeline"
                                # build hashtable for Invoke-MgaGetMethod parameter splatting
                                foreach($deltaLink in $deltaLinks) {
                                    $invokeParams = $invokeParams + @{
                                        "deltaLink"  = $deltaLink
                                        "Token"      = $Token
                                        "ResultSize" = $ResultSize
                                    }
                                }

                                # filtering out delta-messages to get owing message in messages-array
                                [array]$messages = $messages | Where-Object { $_.BaseObject.id -notin $deltaMessages.BaseObject.id }
                                Remove-Variable deltaLinks, deltaMessages
                            }

                            # if non delta messages are parsed in, the messages will be queried again (refresh). Not really necessary, but intend from pipeline usage
                            if($messages) {
                                Write-PSFMessage -Level VeryVerbose -Message "Refresh message for $($messages.count) message(s) from the pipeline"
                                foreach($message in $messages) {
                                    $invokeParam = @{
                                        "Field"        = "messages/$($message.id)"
                                        "User"         = $message.BaseObject.User
                                        "Token"        = $Token
                                        "ResultSize"   = $ResultSize
                                        "FunctionName" = $MyInvocation.MyCommand
                                    }
                                    if($Delta) { $invokeParam.Add("Delta", $true) }
                                    $invokeParams = $invokeParams + $invokeParam
                                }
                            }

                            Remove-Variable messages
                        }

                        "MSGraph.Exchange.Mail.Folder" {
                            $folders = $InputObject | Where-Object { "MSGraph.Exchange.Mail.Folder" -in $_.psobject.TypeNames }
                            foreach($folderItem in $folders) {
                                Write-PSFMessage -Level VeryVerbose -Message "Gettings messages in folder '$($folderItem.Name)' from the pipeline"
                                $invokeParam = @{
                                    "Field"        = "mailFolders/$($folderItem.Id)/messages"
                                    "User"         = $folderItem.User
                                    "Token"        = $Token
                                    "ResultSize"   = $ResultSize
                                    "FunctionName" = $MyInvocation.MyCommand
                                }
                                if($Delta) { $invokeParam.Add("Delta", $true) }
                                $invokeParams = $invokeParams + $invokeParam
                            }
                            Remove-Variable Folders
                        }

                        Default { Write-PSFMessage -Level Critical -Message "Failed on type validation. Can not handle $typeName" -EnableException $true -Tag "TypeValidation" }
                    }
                }
                Remove-Variable typeNames
            }

            "ByFolderName" {
                foreach ($folderItem in $Folder) {
                    Write-PSFMessage -Level VeryVerbose -Message "Getting messages in specified folder '$($folderItem.Name)'"
                    # construct parameters for message query
                    $invokeParam = @{
                        "Field"        = "mailFolders/$($folderItem)/messages"
                        "User"         = $User
                        "Token"        = $Token
                        "ResultSize"   = $ResultSize
                        "FunctionName" = $MyInvocation.MyCommand
                    }
                    if($Delta) { $invokeParam.Add("Delta", $true) }

                    $InvokeParams = $InvokeParams + $InvokeParam
                }
            }

            Default { stop-PSFMessage -Message "Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistage." -EnableException $true -Category "ParameterSetHandling" -FunctionName $MyInvocation.MyCommand }
        }
    }

    end {
        $fielList = @()
        $InvokeParamsUniqueList = @()
        foreach($invokeParam in $InvokeParams) {
            if($invokeParam.Field -notin $fielList) {
                $InvokeParamsUniqueList = $InvokeParamsUniqueList + $invokeParam
                $fielList = $fielList + $invokeParam.Field
            }
        }
        Write-PSFMessage -Level Verbose -Message "Invoking $( ($InvokeParamsUniqueList | Measure-Object).Count ) REST calls for gettings messages" #-FunctionName $MyInvocation.MyCommand

        # run the message query and process the output
        foreach($invokeParam in $InvokeParamsUniqueList) {
            $data = Invoke-MgaGetMethod @invokeParam | Where-Object { $_.subject -like $Subject }
            foreach ($output in $data) {
                [MSGraph.Exchange.Mail.Message]@{
                    BaseObject = $output
                }
            }
        }
    }
}