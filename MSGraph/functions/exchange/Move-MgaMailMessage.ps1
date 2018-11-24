function Move-MgaMailMessage {
    <#
    .SYNOPSIS
        Move message(s) to a folder

    .DESCRIPTION
        Move message(s) to a folder in Exchange Online using the graph api.

    .PARAMETER InputObject
        Carrier object for Pipeline input. Accepts messages.

    .PARAMETER Id
        The ID of the message to update

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER DestinationFolder
        The destination folder where to move the message to

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-EORAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-EORAccessToken.

    .PARAMETER PassThru
        Outputs the token to the console

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .EXAMPLE
        PS C:\> Update-MgaMailMessage

        Update emails
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'ByInputObject')]
    [Alias()]
    [OutputType([MSGraph.Exchange.Mail.Message])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByInputObject')]
        [Alias("Message")]
        [MSGraph.Exchange.Mail.Message]
        $InputObject,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [Alias("MessageId")]
        [string[]]
        $Id,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [string]
        $User,

        [Parameter(Mandatory = $true)]
        [MSGraph.Exchange.Mail.Folder]
        $DestinationFolder,

        [MSGraph.Core.AzureAccessToken]
        $Token,

        [switch]
        $PassThru
    )
    begin {
    }

    process {
        $messages = @()

        # Get input from pipeable objects
        Write-PSFMessage -Level Debug -Message "Gettings messages by parameter set $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"
        switch ($PSCmdlet.ParameterSetName) {
            "ByInputObject" {
                $messages = $InputObject.Id
                $User = $InputObject.BaseObject.User
            }
            "ById" {
                $messages = $Id
            }
            Default { Stop-PSFFunction -Tag "ParameterSetHandling" -Message "Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistage." -EnableException $true -Exception ([System.Management.Automation.RuntimeException]::new("Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistage.")) -FunctionName $MyInvocation.MyCommand }
        }

        $bodyHash = @{
            destinationId = ($DestinationFolder.Id | ConvertTo-Json)
        }
        
        #region Put parameters (JSON Parts) into a valid "message"-JSON-object together
        $bodyJsonParts = @()
        foreach ($key in $bodyHash.Keys) {
            $bodyJsonParts = $bodyJsonParts + """$($key)"" : $($bodyHash[$Key])"
        }
        $bodyJSON = "{`n" + ([string]::Join(",`n", $bodyJsonParts)) + "`n}"
        #endregion Put parameters (JSON Parts) into a valid "message"-JSON-object together

        #region move messages
        foreach ($messageId in $messages) {
            if ($pscmdlet.ShouldProcess("messageId $($messageId)", "Move to folder '$($DestinationFolder.Name)'")) {
                Write-PSFMessage -Tag "MessageUpdate" -Level Verbose -Message "Move messageId '$($messageId)' to folder '$($DestinationFolder.Name)'"
                $invokeParam = @{
                    "Field"        = "messages/$($messageId)/move"
                    "User"         = $User
                    "Body"         = $bodyJSON
                    "ContentType"  = "application/json"
                    "Token"        = $Token
                    "FunctionName" = $MyInvocation.MyCommand
                }
                $output = Invoke-MgaPostMethod @invokeParam
                if ($PassThru) {
                    [MSGraph.Exchange.Mail.Message]@{ BaseObject = $output }
                }
            }
        }
        #endregion Update messages
    }

}