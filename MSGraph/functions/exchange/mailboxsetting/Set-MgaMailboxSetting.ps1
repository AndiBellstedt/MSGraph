function Set-MgaMailboxSetting {
    <#
    .SYNOPSIS
        Set the mailbox settings from Exchange Online using the graph api.

    .DESCRIPTION
        set the mailbox settings in Exchange Online using the graph api.
        This includes settings for automatic replies (notify people automatically
        upon receipt of their email), locale (language and country/region),
        and time zone, and working hours.

        You can parse in modified settings from Get-MgaMailboxSetting command.

    .PARAMETER InputObject
        Carrier object for Pipeline input. Accepts all the different setting objects
        outputted by Get-MgaMailboxSetting.

    .PARAMETER AutomaticReply
        If specified, the command will set AutomaticReply settings

    .PARAMETER Language
        If specified, the command will set Language settings

    .PARAMETER TimeZone
        If specified, the command will set TimeZone settings

    .PARAMETER WorkingHours
        If specified, the command will set WorkingHour settings

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .PARAMETER PassThru
        Outputs the mailbox settings to the console.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .NOTES
        For addiontional information about Microsoft Graph API go to:
        https://docs.microsoft.com/en-us/graph/api/user-update-mailboxsettings?view=graph-rest-1.0

    .EXAMPLE
        PS C:\> Set-MgaMailboxSetting

        Return all mailbox settings for the user connected to through the registered token.

    .EXAMPLE
        PS C:\> Set-MgaMailboxSetting -AutomaticReply

        Set

    .EXAMPLE
        PS C:\> Set-MgaMailboxSetting -Language

        Set

    .EXAMPLE
        PS C:\> Set-MgaMailboxSetting -TimeZone

        Set

    .EXAMPLE
        PS C:\> Get-MgaMailboxSetting -WorkingHours

        Set
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'InputObject')]
    param (
        [Parameter(ParameterSetName = 'InputObject')]
        [Alias('MailboxSetting', 'ArchiveFolderSetting', 'AutomaticReplySetting', 'LanguageSetting', 'TimeZoneSetting', 'WorkingHoursSetting', 'Setting', 'SettingObject')]
        [MSGraph.Exchange.MailboxSetting.MailboxSettingParameter]
        $InputObject,

        [Parameter(ParameterSetName = 'AutomaticReplySetting')]
        [Alias()]
        [switch]
        $AutomaticReply,

        [Parameter(ParameterSetName = 'LanguageSetting')]
        [Alias()]
        [switch]
        $Language,

        [Parameter(ParameterSetName = 'TimeZoneSetting')]
        [Alias()]
        [switch]
        $TimeZone,

        [Parameter(ParameterSetName = 'WorkingHoursSetting')]
        [Alias()]
        [switch]
        $WorkingHours,

        [string]
        $User,

        [MSGraph.Core.AzureAccessToken]
        $Token,

        [switch]
        $PassThru
    )
    begin {
        $requiredPermission = "MailboxSettings.ReadWrite"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand

        $invokeParam = @{
            "Field"        = "mailboxSettings"
            "Token"        = $Token
            "User"         = $User
            "FunctionName" = $MyInvocation.MyCommand
        }
    }

    process {
        #region prepare rest data
        switch ($PSCmdlet.ParameterSetName) {
            'InputObject' {
                Write-PSFMessage -Level Verbose -Message "Working on mailbox settings '$($InputObject)' for '$(Resolve-UserString -User $User)' by ParameterSet $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"
                $User = Resolve-UserInMailObject -Object $InputObject -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
                $bodyJSON = New-JsonMailboxSettingObject -SettingObject $InputObject -User $User -FunctionName $MyInvocation.MyCommand
                $invokeParam.Add('Body', $bodyJSON)
            }

            Default { Stop-PSFFunction -Message "Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistake." -EnableException $true -Category MetadataError -FunctionName $MyInvocation.MyCommand }
        }
        #endregion prepare rest data

        if ($pscmdlet.ShouldProcess("mailbox of '$(Resolve-UserString -User $User -ContextData)'", "Set $InputObject")) {
            # set data
            $data = Invoke-MgaRestMethodPatch @invokeParam

            #region output data
            if($PassThru) {
                foreach ($output in $data) {
                    $mailboxSettingObject = New-MgaMailboxSettingObject -RestData $output -Type $InputObject.Name -User $User -Token $Token -FunctionName $MyInvocation.MyCommand
                    $mailboxSettingObject
                }
            }
            #endregion output data
        }
    }

    end {
    }
}