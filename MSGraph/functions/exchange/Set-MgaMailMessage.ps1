function Set-MgaMailMessage {
    <#
    .SYNOPSIS
        Set properties on message(s)

    .DESCRIPTION
        Set properties on message(s) in Exchange Online using the graph api.

    .PARAMETER Message
        Carrier object for Pipeline input. Accepts messages.

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER IsRead
        Indicates whether the message has been read.

    .PARAMETER Subject
        The subject of the message.
        (Updatable only if isDraft = true.)

    .PARAMETER Sender
        The account that is actually used to generate the message.
        (Updatable only if isDraft = true, and when sending a message from a shared mailbox,
        or sending a message as a delegate. In any case, the value must correspond to the actual mailbox used.)

    .PARAMETER From
        The mailbox owner and sender of the message.
        Must correspond to the actual mailbox used.
        (Updatable only if isDraft = true.)

    .PARAMETER ToRecipients
        The To recipients for the message.
        (Updatable only if isDraft = true.)

    .PARAMETER CCRecipients
        The Cc recipients for the message.
        (Updatable only if isDraft = true.)

    .PARAMETER BCCRecipients
        The Bcc recipients for the message.
        (Updatable only if isDraft = true.)

    .PARAMETER ReplyTo
        The email addresses to use when replying.
        (Updatable only if isDraft = true.)

    .PARAMETER Body
        The body of the message.
        (Updatable only if isDraft = true.)

    .PARAMETER Categories
        The categories associated with the message.

    .PARAMETER Importance
        The importance of the message.
        The possible values are: Low, Normal, High.

    .PARAMETER InferenceClassification
        The classification of the message for the user, based on inferred relevance or importance, or on an explicit override.
        The possible values are: focused or other.

    .PARAMETER InternetMessageId
        The message ID in the format specified by RFC2822.
        (Updatable only if isDraft = true.)

    .PARAMETER IsDeliveryReceiptRequested
        Indicates whether a delivery receipt is requested for the message.

    .PARAMETER IsReadReceiptRequested
        Indicates whether a read receipt is requested for the message.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .PARAMETER PassThru
        Outputs the token to the console

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .EXAMPLE
        PS C:\> $mail | Set-MgaMailMessage -IsRead $false

        Set messages represented by variable $mail to status "unread"
        The variable $mails can be represent:
        PS C:\> $mails = Get-MgaMailMessage -Folder Inbox -ResultSize 1

    .EXAMPLE
        PS C:\> $mail | Set-MgaMailMessage -IsRead $false -categories "Red category"

        Set status "unread" and category "Red category" to messages represented by variable $mail
        The variable $mails can be represent:
        PS C:\> $mails = Get-MgaMailMessage -Folder Inbox -ResultSize 1

    .EXAMPLE
        PS C:\> $mail | Set-MgaMailMessage -ToRecipients "someone@something.org"

        Set reciepent from draft mail represented by variable $mail
        The variable $mails can be represent:
        PS C:\> $mails = Get-MgaMailMessage -Folder Drafts

    .EXAMPLE
        PS C:\> Set-MgaMailMessage -Id $mail.Id -ToRecipients "someone@something.org" -Subject "Something important"

        Set reciepent from draft mail represented by variable $mail
        The variable $mails can be represent:
        PS C:\> $mails = Get-MgaMailMessage -Folder Drafts

    .EXAMPLE
        PS C:\> $mail | Set-MgaMailMessage -ToRecipients $null

        Clear reciepent from draft mail represented by variable $mail
        The variable $mails can be represent:
        PS C:\> $mails = Get-MgaMailMessage -Folder Drafts


    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Default')]
    [Alias("Update-MgaMailMessage")]
    [OutputType([MSGraph.Exchange.Mail.Message])]
    param (
        [Parameter(Mandatory=$true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('InputObject', 'MessageId', 'Id')]
        [MSGraph.Exchange.Mail.MessageParameter[]]
        $Message,

        [string]
        $User,

        [ValidateNotNullOrEmpty()]
        [bool]
        $IsRead,

        [string]
        $Subject,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string]
        $Sender,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string]
        $From,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]
        $ToRecipients,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]
        $CCRecipients,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]
        $BCCRecipients,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]
        $ReplyTo,

        [String]
        $Body,

        [String[]]
        $Categories,

        [ValidateSet("Low", "Normal", "High")]
        [String]
        $Importance,

        [ValidateSet("focused", "other")]
        [String]
        $InferenceClassification,

        [String]
        $InternetMessageId,

        [bool]
        $IsDeliveryReceiptRequested,

        [bool]
        $IsReadReceiptRequested,

        [MSGraph.Core.AzureAccessToken]
        $Token,

        [switch]
        $PassThru
    )
    begin {
        $requiredPermission = "Mail.ReadWrite"

        $boundParameters = @()
        $mailAddressNames = @("sender", "from", "toRecipients", "ccRecipients", "bccRecipients", "replyTo")

        # parsing mailAddress parameter strings to mailaddress objects (if not empty)
        foreach ($Name in $mailAddressNames) {
            if (Test-PSFParameterBinding -ParameterName $name) {
                New-Variable -Name "$($name)Addresses" -Force -Scope 0
                if( (Get-Variable -Name $Name -Scope 0).Value ) {
                    try {
                        Set-Variable -Name "$($name)Addresses" -Value ( (Get-Variable -Name $Name -Scope 0).Value | ForEach-Object { [mailaddress]$_ } -ErrorAction Stop -ErrorVariable parseError )
                    }
                    catch {
                        Stop-PSFFunction -Message "Unable to parse $($name) to a mailaddress. String should be 'name@domain.topleveldomain' or 'displayname name@domain.topleveldomain'. Error: $($parseError[0].Exception)" -Tag "ParameterParsing" -Category InvalidData -EnableException $true -Exception $parseError[0].Exception
                    }
                }
            }
        }
    }

    process {
        $bodyHash = @{}
        Write-PSFMessage -Level Debug -Message "Gettings messages by parameter set $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

        #region Parsing string and boolean parameters to json data parts
        $names = @("IsRead", "Subject", "Body", "Categories", "Importance", "InferenceClassification", "InternetMessageId", "IsDeliveryReceiptRequested", "IsReadReceiptRequested")
        Write-PSFMessage -Level VeryVerbose -Message "Parsing string and boolean parameters to json data parts ($([string]::Join(", ", $names)))" -Tag "ParameterParsing"
        foreach ( $name in $names ) {
            if (Test-PSFParameterBinding -ParameterName $name) {
                $boundParameters = $boundParameters + $name
                Write-PSFMessage -Level Debug -Message "Parsing text parameter $($name)" -Tag "ParameterParsing"
                $bodyHash.Add($name, ((Get-Variable $name -Scope 0).Value| ConvertTo-Json))
            }
        }
        #endregion Parsing string and boolean parameters to json data parts

        #region Parsing mailaddress parameters to json data parts
        Write-PSFMessage -Level VeryVerbose -Message "Parsing mailaddress parameters to json data parts ($([string]::Join(", ", $mailAddressNames)))" -Tag "ParameterParsing"
        foreach ( $name in $mailAddressNames ) {
            if (Test-PSFParameterBinding -ParameterName $name) {
                $boundParameters = $boundParameters + $name
                Write-PSFMessage -Level Debug -Message "Parsing mailaddress parameter $($name)" -Tag "ParameterParsing"
                $addresses = (Get-Variable -Name "$($name)Addresses" -Scope 0).Value
                if ($addresses) {
                    # build valid mail address object, if address is specified
                    [array]$addresses = foreach ($item in $addresses) {
                        [PSCustomObject]@{
                            emailAddress = [PSCustomObject]@{
                                address = $item.Address
                                name    = $item.DisplayName
                            }
                        }
                    }
                }
                else {
                    # place an empty mail address object in, if no address is specified (this will clear the field in the message)
                    [array]$addresses = [PSCustomObject]@{
                        emailAddress = [PSCustomObject]@{
                            address = ""
                            name    = ""
                        }
                    }
                }

                if ($name -in @("toRecipients", "ccRecipients", "bccRecipients", "replyTo")) {
                    # these kind of objects need to be an JSON array
                    if ($addresses.Count -eq 1) {
                        # hardly format JSON object as an array, because ConvertTo-JSON will output a single object-json-string on an array with count 1 (PSVersion 5.1.17134.407 | PSVersion 6.1.1)
                        $bodyHash.Add($name, ("[" + ($addresses | ConvertTo-Json) + "]") )
                    }
                    else {
                        $bodyHash.Add($name, ($addresses | ConvertTo-Json) )
                    }
                } else {
                    $bodyHash.Add($name, ($addresses | ConvertTo-Json) )
                }
            }
        }
        #endregion Parsing mailaddress parameters to json data parts

        #region Put parameters (JSON Parts) into a valid "message"-JSON-object together
        $bodyJsonParts = @()
        foreach ($key in $bodyHash.Keys) {
            $bodyJsonParts = $bodyJsonParts + """$($key)"" : $($bodyHash[$Key])"
        }
        $bodyJSON = "{`n" + ([string]::Join(",`n", $bodyJsonParts)) + "`n}"
        #endregion Put parameters (JSON Parts) into a valid "message"-JSON-object together

        #region Update messages
        foreach ($messageItem in $Message) {
            if ($messageItem.TypeName -like "System.String") {
                if ($messageItem.Id -and ($messageItem.Id.Length -eq 152)) {
                    [MSGraph.Exchange.Mail.MessageParameter]$messageItem = Get-MgaMailMessage -InputObject $messageItem.Id -User $User -Token $Token
                }
                else {
                    Write-PSFMessage -Level Warning -Message "The specified input string seams not to be a valid Id. Skipping object '$($messageItem)'" -Tag "InputValidation"
                    continue
                }
            }

            if ($User -and ($messageItem.TypeName -like "MSGraph.Exchange.Mail.Message") -and ($User -notlike $messageItem.InputObject.BaseObject.User)) {
                Write-PSFMessage -Level Important -Message "Individual user specified with message object! User from message object ($($messageItem.InputObject.BaseObject.User))will take precedence on specified user ($($User))!" -Tag "InputValidation"
                $User = $messageItem.InputObject.BaseObject.User
            }
            elseif ((-not $User) -and ($messageItem.TypeName -like "MSGraph.Exchange.Mail.Message")) {
                $User = $messageItem.InputObject.BaseObject.User
            }

            if ($pscmdlet.ShouldProcess("message '$($messageItem)'", "Update properties '$([string]::Join("', '", $boundParameters))'")) {
                Write-PSFMessage -Tag "MessageUpdate" -Level Verbose -Message "Update properties '$([string]::Join("', '", $boundParameters))' on message '$($messageItem)'"
                $invokeParam = @{
                    "Field"        = "messages/$($messageItem.Id)"
                    "User"         = $User
                    "Body"         = $bodyJSON
                    "ContentType"  = "application/json"
                    "Token"        = $Token
                    "FunctionName" = $MyInvocation.MyCommand
                }
                $output = Invoke-MgaPatchMethod @invokeParam
                if ($PassThru) { New-MgaMailMessageObject -RestData $output }
            }
        }
        #endregion Update messages
    }

}