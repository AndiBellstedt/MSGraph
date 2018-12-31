function New-MgaMailboxSettingObject {
    <#
    .SYNOPSIS
        Create new mailboxSettings object

    .DESCRIPTION
        Create new mailboxSettings object
        Helper function used for internal commands.

    .PARAMETER RestData
        The RestData object containing the data for the new message object.

    .PARAMETER Type
        The type of the settings object to be created.

    .PARAMETER User
        The user to execute this under. Defaults to the user the token belongs to.

    .PARAMETER Token
        The access token to use to connect.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.

    .EXAMPLE
        PS C:\> New-MgaMailboxSettingObject -RestData $output -Type MailboxSettings

        Create a MSGraph.Exchange.MailboxSetting.MailboxSettings object from data in variable $output
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param (
        $RestData,

        [String]
        $Type,

        [string]
        $User,

        [MSGraph.Core.AzureAccessToken]
        $Token,

        [String]
        $FunctionName
    )
    Write-PSFMessage -Level Debug -Message "Create $($Type) mailbox Setting object" -Tag "CreateObject"

    if ($Type -notlike "TimeZoneSetting") {
        $name = [System.Web.HttpUtility]::UrlDecode(([uri]$RestData.'@odata.context').Fragment).TrimStart("#")
        $outputHash = [ordered]@{
            Name       = $name
            User       = $RestData.user
            BaseObject = $RestData
        }
    }

    switch ($Type) {
        'AllSettings' {
            # create the full set of mailbox settings
            try {
                $archivFolder = Get-MgaMailFolder -Name $RestData.archiveFolder -User $User -Token $Token -ErrorAction Stop
            } catch {
                Stop-PSFFunction -Message "Failed to get information about archiv folder on $($outputHash.Name)" -EnableException $true -Exception $_.Exception -Category ReadError -ErrorRecord $_ -Tag "QueryData" -FunctionName $FunctionName
            }
            $outputHash.Add("ArchiveFolder", $archivFolder)

            $timeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($RestData.timeZone)
            $outputHash.Add("TimeZone", $timeZone)

            $autoReplySetting = [MSGraph.Exchange.MailboxSetting.AutomaticRepliesSetting]::new(
                [MSGraph.Exchange.MailboxSetting.AutomaticRepliesStatus]$RestData.automaticRepliesSetting.Status,
                [MSGraph.Exchange.MailboxSetting.ExternalAudienceScope]$RestData.automaticRepliesSetting.ExternalAudience,
                $RestData.automaticRepliesSetting.ExternalReplyMessage, $RestData.automaticRepliesSetting.internalReplyMessage,
                [MSGraph.Exchange.DateTimeTimeZone]$RestData.automaticRepliesSetting.ScheduledStartDateTime,
                [MSGraph.Exchange.DateTimeTimeZone]$RestData.automaticRepliesSetting.ScheduledEndDateTime,
                "$($name)/automaticRepliesSetting"
            )
            $outputHash.Add("AutomaticRepliesSetting", $autoReplySetting)

            $language = [MSGraph.Exchange.MailboxSetting.LocaleInfoSetting]::new(
                [cultureinfo]$RestData.language.locale,
                $RestData.language.displayName,
                "$($name)/language"
            )
            $outputHash.Add("Language", $language)

            $workingHours = [MSGraph.Exchange.MailboxSetting.WorkingHoursSetting]::new(
                $RestData.WorkingHours.daysOfWeek.ForEach( {[dayOfWeek]$_}),
                [datetime]$RestData.WorkingHours.startTime,
                [datetime]$RestData.WorkingHours.endTime,
                [MSGraph.Exchange.TimeZoneBase]::new($RestData.WorkingHours.timeZone.name),
                "$($name)/workingHours"
            )
            $outputHash.Add("WorkingHours", $workingHours)

            New-Object -TypeName MSGraph.Exchange.MailboxSetting.MailboxSettings -Property $outputHash
        }

        'AutomaticReplySetting' {
            # create auto reply settings object
            $outputHash.Add("Status", [MSGraph.Exchange.MailboxSetting.AutomaticRepliesStatus]$RestData.Status)
            $outputHash.Add("ExternalAudience", [MSGraph.Exchange.MailboxSetting.ExternalAudienceScope]$RestData.ExternalAudience)
            $outputHash.Add("ExternalReplyMessage", $RestData.ExternalReplyMessage)
            $outputHash.Add("InternalReplyMessage", $RestData.internalReplyMessage)
            $outputHash.Add("ScheduledStartDateTime", [MSGraph.Exchange.DateTimeTimeZone]$RestData.ScheduledStartDateTime)
            $outputHash.Add("ScheduledEndDateTime", [MSGraph.Exchange.DateTimeTimeZone]$RestData.ScheduledEndDateTime)

            New-Object -TypeName MSGraph.Exchange.MailboxSetting.AutomaticRepliesSetting -Property $outputHash
        }

        'LanguageSetting' {
            # create language setting object
            $outputHash.Add("Locale", [cultureinfo]$RestData.locale)
            $outputHash.Add("DisplayName", $RestData.displayName)

            New-Object -TypeName MSGraph.Exchange.MailboxSetting.LocaleInfoSetting -Property $outputHash
        }

        'TimeZoneSetting' {
            # create timeZone object
            [System.TimeZoneInfo]::FindSystemTimeZoneById($RestData)
        }

        'WorkingHourSetting' {
            # create workingHours object
            $outputHash.Add("DaysOfWeek", $RestData.daysOfWeek.ForEach( {[dayOfWeek]$_}))
            $outputHash.Add("StartTime", [datetime]$RestData.startTime)
            $outputHash.Add("EndTime", [datetime]$RestData.endTime)
            $outputHash.Add("TimeZone", [MSGraph.Exchange.TimeZoneBase]::new($RestData.timeZone.name))

            New-Object -TypeName MSGraph.Exchange.MailboxSetting.WorkingHoursSetting -Property $outputHash
        }

        Default {
            Stop-PSFFunction -Message "Unable to output a valid MailboxSetting object, because of unhandled type '$($Type)'. Developer mistake." -EnableException $true -Category InvalidData -FunctionName $MyInvocation.MyCommand
        }
    }

}