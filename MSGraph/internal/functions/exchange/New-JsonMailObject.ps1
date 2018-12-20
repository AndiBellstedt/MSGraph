function New-JsonMailObject {
    <#
    .SYNOPSIS
        Creates a json message object for use in Microsoft Graph REST api

    .DESCRIPTION
        Creates a json message object for use in Microsoft Graph REST api
        Helper function used for internal commands.

    .PARAMETER Subject
        The subject of the new message.

    .PARAMETER Sender
        The account that is actually used to generate the message.
        (Updatable only when sending a message from a shared mailbox or sending a message as a delegate.
        In any case, the value must correspond to the actual mailbox used.)

    .PARAMETER From
        The mailbox owner and sender of the message.
        Must correspond to the actual mailbox used.

    .PARAMETER ToRecipients
        The To recipients for the message.

    .PARAMETER CCRecipients
        The Cc recipients for the message.

    .PARAMETER BCCRecipients
        The Bcc recipients for the message.

    .PARAMETER ReplyTo
        The email addresses to use when replying.

    .PARAMETER Body
        The body of the message.

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

    .PARAMETER IsDeliveryReceiptRequested
        Indicates whether a delivery receipt is requested for the message.

    .PARAMETER IsReadReceiptRequested
        Indicates whether a read receipt is requested for the message.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.
        (Just used for logging reasons)

    .NOTES
        For addiontional information go to:
        https://docs.microsoft.com/en-us/graph/api/resources/message?view=graph-rest-1.0

    .LINK

    .EXAMPLE
        PS C:\> New-JsonMailObject

        Creates a json message object for use in Microsoft Graph REST api

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding(SupportsShouldProcess = $false, ConfirmImpact = 'Low')]
    [OutputType([String])]
    param (
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]
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

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [String[]]
        $Categories,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        #[ValidateSet("Low", "Normal", "High")]
        [String]
        $Importance = "Normal",

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        #[ValidateSet("focused", "other")]
        [String]
        $InferenceClassification,

        [String]
        $InternetMessageId,

        [bool]
        $IsDeliveryReceiptRequested,

        [bool]
        $IsReadReceiptRequested,

        [String]
        $FunctionName
    )
    begin {
        #region variable definition
        $boundParameters = @()
        $mailAddressNames = @("sender", "from", "toRecipients", "ccRecipients", "bccRecipients", "replyTo")
        #endregion variable definition

        # parsing mailAddress parameter strings to mailaddress objects (if not empty)
        foreach ($Name in $mailAddressNames) {
            if (Test-PSFParameterBinding -ParameterName $name) {
                New-Variable -Name "$($name)Addresses" -Force -Scope 0
                if ( (Get-Variable -Name $Name -Scope 0).Value ) {
                    try {
                        Set-Variable -Name "$($name)Addresses" -Value ( (Get-Variable -Name $Name -Scope 0).Value | ForEach-Object { [mailaddress]$_ } -ErrorAction Stop -ErrorVariable parseError )
                    }
                    catch {
                        Stop-PSFFunction -Message "Unable to parse $($name) to a mailaddress. String should be 'name@domain.topleveldomain' or 'displayname name@domain.topleveldomain'. Error: $($parseError[0].Exception.Message)" -Tag "ParameterParsing" -Category InvalidData -EnableException $true -Exception $parseError[0].Exception -FunctionName $FunctionName
                    }
                }
            }
        }

    }

    process {
        $bodyHash = @{}
        Write-PSFMessage -Level Debug -Message "Create message JSON object" -Tag "ParameterSetHandling"

        #region Parsing string and boolean parameters to json data parts
        $names = @("Subject", "Categories", "Importance", "InferenceClassification", "InternetMessageId", "IsDeliveryReceiptRequested", "IsReadReceiptRequested")
        Write-PSFMessage -Level VeryVerbose -Message "Parsing string and boolean parameters to json data parts ($([string]::Join(", ", $names)))" -Tag "ParameterParsing"
        foreach ($name in $names) {
            if (Test-PSFParameterBinding -ParameterName $name) {
                if( (Get-Variable $name -Scope 0).Value ) {
                    $boundParameters = $boundParameters + $name
                    Write-PSFMessage -Level Debug -Message "Parsing text parameter $($name)" -Tag "ParameterParsing"
                    $bodyHash.Add($name, ((Get-Variable $name -Scope 0).Value | ConvertTo-Json))
                }
            }
        }

        if($Body) {
            $bodyHash.Add("Body", ([MSGraph.Exchange.Mail.MessageBody]$Body | ConvertTo-Json))
        }
        #endregion Parsing string and boolean parameters to json data parts

        #region Parsing mailaddress parameters to json data parts
        Write-PSFMessage -Level VeryVerbose -Message "Parsing mailaddress parameters to json data parts ($([string]::Join(", ", $mailAddressNames)))" -Tag "ParameterParsing"
        foreach ($name in $mailAddressNames) {
            if ((Test-PSFParameterBinding -ParameterName $name) -and (Get-Variable -Name "$($name)Addresses" -Scope 0).Value) {
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
                }
                else {
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

        #region output created object
        $bodyJSON
        #endregion output created object
    }

    end {
    }
}