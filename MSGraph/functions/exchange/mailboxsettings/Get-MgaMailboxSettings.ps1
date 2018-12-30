function Get-MgaMailboxSettings {
    <#
    .SYNOPSIS
        Get the mailbox settings from Exchange Online using the graph api.

    .DESCRIPTION
        Get the mailbox settings from Exchange Online using the graph api.
        This includes settings for automatic replies (notify people automatically 
        upon receipt of their email), locale (language and country/region), 
        and time zone, and working hours.

        You can view all mailbox settings, or get specific settings by 
        specifing switch parameters.

    .PARAMETER AutomaticReplySetting
        If specified, only the settings for automatic notifications to
        senders of an incoming email are outputted.

        Fun fact:
        Here's an interesting historical question - when we say Out of Office,
        why does it sometimes get shortened to ‘OOF’? Shouldn’t it be ‘OOO’? 
        https://blogs.technet.microsoft.com/exchange/2004/07/12/why-is-oof-an-oof-and-not-an-ooo/

    .PARAMETER LanguageSetting
        If specified, only the information about the locale, including the 
        preferred language and country/region are displayed.

    .PARAMETER TimeZoneSetting
        If specified, only the timezone settings from the users mailbox are displayed.

    .PARAMETER WorkingHourSetting
        If specified, only the settings for the days of the week and hours in a 
        specific time zone that the user works are displayed.

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .NOTES
        For addiontional information about Microsoft Graph API go to:
        https://docs.microsoft.com/en-us/graph/api/user-get-mailboxsettings?view=graph-rest-1.0

    .EXAMPLE
        PS C:\> Get-MgaMailboxSettings

        Return all mailbox settings for the user connected to through the registered token.

    .EXAMPLE
        PS C:\> Get-MgaMailboxSettings -AutomaticReplySetting

        Return only the settings for automatic notifications to senders of an incoming email
        for the user connected to through the registered token.

    .EXAMPLE
        PS C:\> Get-MgaMailboxSettings -LanguageSetting

        Return only the information about the locale, including the preferred language and
        country/region, for the user connected to through the registered token.

    .EXAMPLE
        PS C:\> Get-MgaMailboxSettings -TimeZoneSetting

        Return only the timezone settings for the user connected to through the registered token.

    .EXAMPLE
        PS C:\> Get-MgaMailboxSettings -WorkingHourSetting

        Return only the settings for the days of the week and hours in a specific time zone 
        the user connected to through the registered token works.
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'AllSettings')]
    param (
        [Parameter(ParameterSetName = 'AutomaticReplySetting')]
        [Alias('AutoReply', 'OutOfOffice', 'OutOfOfficeSetting', 'OOFSettings', 'OOF')]
        [switch]
        $AutomaticReplySetting,

        [Parameter(ParameterSetName = 'LanguageSetting')]
        [Alias('Language')]
        [switch]
        $LanguageSetting,

        [Parameter(ParameterSetName = 'TimeZoneSetting')]
        [Alias('TimeZone')]
        [switch]
        $TimeZoneSetting,

        [Parameter(ParameterSetName = 'WorkingHourSetting')]
        [Alias('WorkingHour')]
        [switch]
        $WorkingHourSetting,

        [string]
        $User,

        [MSGraph.Core.AzureAccessToken]
        $Token
    )
    begin {
        $requiredPermission = "MailboxSettings.Read"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand
    }
 
    process {
        Write-PSFMessage -Level Verbose -Message "Getting mailbox settings for '$(Resolve-UserString -User $User)' by parameter set $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

        #region query data
        $invokeParam = @{
            "Token"        = $Token
            "User"         = $User
            "FunctionName" = $MyInvocation.MyCommand
        }
        switch ($PSCmdlet.ParameterSetName) {
            'AllSettings' { $invokeParam.Add('Field', 'mailboxSettings') }
            'AutomaticReplySetting' { $invokeParam.Add('Field', 'mailboxSettings/automaticRepliesSetting') }
            'LanguageSetting' { $invokeParam.Add('Field', 'mailboxSettings/language') }
            'TimeZoneSetting' { $invokeParam.Add('Field', 'mailboxSettings/timeZone') }
            'WorkingHourSetting' { $invokeParam.Add('Field', 'mailboxSettings/workingHours') }
            Default { Stop-PSFMessage -Message "Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistake." -EnableException $true -Category "ParameterSetHandling" -FunctionName $MyInvocation.MyCommand }
        }

        $data = Invoke-MgaRestMethodGet @invokeParam | Where-Object { $_.name -like $Name }
        #endregion query data

        #region output data
        foreach ($output in $data) {
            switch ($PSCmdlet.ParameterSetName) {
                'AllSettings' {
                    $output
                }

                'AutomaticReplySetting' {
                    $output
                }

                'LanguageSetting' {
                    $output
                }

                'TimeZoneSetting' {
                    [System.TimeZoneInfo]::FindSystemTimeZoneById($output)
                }

                'WorkingHourSetting' {
                    $output
                }
            }
        }
        #endregion output data
    }

    end {
    }
}