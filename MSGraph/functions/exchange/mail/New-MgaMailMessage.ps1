function New-MgaMailMessage {
    <#
    .SYNOPSIS
        Creates a folder in Exchange Online using the graph api.

    .DESCRIPTION
        Creates a new folder in Exchange Online using the graph api.

    .PARAMETER Folder
        The folder where the new folder should be created in. Do not specify to create
        a folder on the root level.

        Possible values are a valid folder Id or a Mga folder object passed in.
        Tab completion is available on this parameter for a list of well known folders.

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

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .NOTES
        For addiontional information go to:
        https://docs.microsoft.com/en-us/graph/api/user-post-messages?view=graph-rest-1.0

    .LINK

    .EXAMPLE
        PS C:\> New-MgaMailMessage -ToRecipients 'someone@something.org' -Subject 'A new Mail' -Body 'This is a new mail'

        Creates a new message in the drafts folder

    .EXAMPLE
        PS C:\> New-MgaMailMessage -Subject 'A new Mail' -Folder 'MyFolder'

        Creates a new message in the folder named "MyFolder"

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Default')]
    [OutputType([MSGraph.Exchange.Mail.Message])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias('Name', 'Title')]
        [string[]]
        $Subject,

        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'WithFolder')]
        [Alias('FolderName', 'FolderId')]
        [MSGraph.Exchange.Mail.FolderParameter]
        $Folder,

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
        [Alias('To', 'Recipients')]
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

        [string]
        $User,

        [MSGraph.Core.AzureAccessToken]
        $Token
    )
    begin {
        $requiredPermission = "Mail.ReadWrite"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand

        #region checking input object type and query folder if required
        if ($Folder.TypeName -like "System.String") {
            $Folder = Resolve-MailObjectFromString -Object $Folder -User $User -Token $Token -FunctionName $MyInvocation.MyCommand
            if (-not $Folder) { throw }
        }

        if ($Folder) {
            $User = Resolve-UserInMailObject -Object $Folder -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
        }
        #endregion checking input object type and query message if required
    }

    process {
        Write-PSFMessage -Level Debug -Message "Creating message(s) by parameterset $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

        #region Put parameters (JSON Parts) into a valid "message"-JSON-object together
        $jsonParams = @{}

        $names = "Subject","Sender","From","ToRecipients","CCRecipients","BCCRecipients","ReplyTo","Body","Categories","Importance","InferenceClassification","IsDeliveryReceiptRequested","IsReadReceiptRequested"
        foreach ($name in $names) {
            if (Test-PSFParameterBinding -ParameterName $name) {
                Write-PSFMessage -Level Debug -Message "Add $($name) from parameters to message" -Tag "ParameterParsing"
                $jsonParams.Add($name, (Get-Variable $name -Scope 0).Value)
            }
        }

        $bodyJSON = New-JsonMailObject @jsonParams -FunctionName $MyInvocation.MyCommand
        #endregion Put parameters (JSON Parts) into a valid "message"-JSON-object together

        #region create messages
        if ($pscmdlet.ShouldProcess($Subject, "New")) {
            $msg = "Creating message '$($Subject)'"
            if ($Folder) { $msg = $msg + " in '$($Folder)'" } else { $msg = $msg + " in drafts folder" }
            Write-PSFMessage -Level Verbose -Message $msg -Tag "MessageCreation"

            $invokeParam = @{
                "User"         = $User
                "Body"         = $bodyJSON
                "ContentType"  = "application/json"
                "Token"        = $Token
                "FunctionName" = $MyInvocation.MyCommand
            }
            if ($Folder.Id) {
                $invokeParam.Add("Field", "mailFolders/$($Folder.Id)/messages")
            }
            else {
                $invokeParam.Add("Field", "messages")
            }

            $output = Invoke-MgaRestMethodPost @invokeParam
            if($output) {
                New-MgaMailMessageObject -RestData $output -FunctionName $MyInvocation.MyCommand
            }
        }
        #endregion create messages
    }

    end {
    }
}