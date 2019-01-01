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

    if ($Type -notlike "TimeZoneSetting" -and $Type -notlike "ArchiveFolderSetting") {
        $name = [System.Web.HttpUtility]::UrlDecode(([uri]$RestData.'@odata.context').Fragment).TrimStart("#")
        $outputHash = [ordered]@{
            Name       = $name
            User       = $RestData.user
            BaseObject = $RestData
        }
    }

    switch ($Type) {
        {$_ -like 'AllSettings' -or $_ -like 'ArchiveFolderSetting'} {
            # create the full set of mailbox settings
            if ($RestData.archiveFolder) {
                try {
                    $archivFolder = Get-MgaMailFolder -Name $RestData.archiveFolder -User $User -Token $Token -ErrorAction Stop
                } catch {
                    Stop-PSFFunction -Message "Failed to get information about archiv folder on $($outputHash.Name)" -EnableException $true -Exception $_.Exception -Category ReadError -ErrorRecord $_ -Tag "QueryData" -FunctionName $FunctionName
                }

                if ($Type -like 'ArchiveFolderSetting') {
                    return $archivFolder
                } else {
                    $outputHash.Add("ArchiveFolder", $archivFolder)
                }
            } else {
                $archivFolder = ""
            }

            $timeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($RestData.timeZone)
            $outputHash.Add("TimeZone", $timeZone)

            $autoReplySetting = [MSGraph.Exchange.MailboxSetting.AutomaticRepliesSetting]::new(
                [MSGraph.Exchange.MailboxSetting.AutomaticRepliesStatus]$RestData.automaticRepliesSetting.Status,
                [MSGraph.Exchange.MailboxSetting.ExternalAudienceScope]$RestData.automaticRepliesSetting.ExternalAudience,
                $RestData.automaticRepliesSetting.ExternalReplyMessage.Trim([char]65279),
                $RestData.automaticRepliesSetting.internalReplyMessage.Trim([char]65279),
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
            if ($RestData.automaticRepliesSetting) { $autoReplySetting = $RestData.automaticRepliesSetting } else { $autoReplySetting = $RestData }
            $outputHash.Add("Status", [MSGraph.Exchange.MailboxSetting.AutomaticRepliesStatus]$autoReplySetting.Status)
            $outputHash.Add("ExternalAudience", [MSGraph.Exchange.MailboxSetting.ExternalAudienceScope]$autoReplySetting.ExternalAudience)
            $outputHash.Add("ExternalReplyMessage", $autoReplySetting.ExternalReplyMessage.Trim([char]65279))
            $outputHash.Add("InternalReplyMessage", $autoReplySetting.internalReplyMessage.Trim([char]65279))
            $outputHash.Add("ScheduledStartDateTimeUTC", [MSGraph.Exchange.DateTimeTimeZone]$autoReplySetting.ScheduledStartDateTime)
            $outputHash.Add("ScheduledEndDateTimeUTC", [MSGraph.Exchange.DateTimeTimeZone]$autoReplySetting.ScheduledEndDateTime)

            New-Object -TypeName MSGraph.Exchange.MailboxSetting.AutomaticRepliesSetting -Property $outputHash
            Remove-Variable -Name autoReplySetting -Force -WhatIf:$false -Confirm:$false -Verbose:$false -Debug:$false -WarningAction Ignore -ErrorAction Ignore
        }

        'LanguageSetting' {
            # create language setting object
            if($RestData.language) { $languageSetting = $RestData.language } else { $languageSetting = $RestData }
            $outputHash.Add("Locale", [cultureinfo]$languageSetting.locale)
            $outputHash.Add("DisplayName", $languageSetting.displayName)

            New-Object -TypeName MSGraph.Exchange.MailboxSetting.LocaleInfoSetting -Property $outputHash
            Remove-Variable -Name languageSetting -Force -WhatIf:$false -Confirm:$false -Verbose:$false -Debug:$false -WarningAction Ignore -ErrorAction Ignore
        }

        'TimeZoneSetting' {
            # create timeZone object
            if($RestData.timeZone) { $timeZoneSetting = $RestData.timeZone } else { $timeZoneSetting = $RestData }
            [System.TimeZoneInfo]::FindSystemTimeZoneById($timeZoneSetting)
            Remove-Variable -Name timeZoneSetting -Force -WhatIf:$false -Confirm:$false -Verbose:$false -Debug:$false -WarningAction Ignore -ErrorAction Ignore
        }

        'WorkingHoursSetting' {
            # create workingHours object
            if($RestData.workingHours) { $workingHourSetting = $RestData.workingHours } else { $workingHourSetting = $RestData }
            $outputHash.Add("DaysOfWeek", $workingHourSetting.daysOfWeek.ForEach( {[dayOfWeek]$_}))
            $outputHash.Add("StartTime", [datetime]$workingHourSetting.startTime)
            $outputHash.Add("EndTime", [datetime]$workingHourSetting.endTime)
            $outputHash.Add("TimeZone", [MSGraph.Exchange.TimeZoneBase]::new($workingHourSetting.timeZone.name))

            New-Object -TypeName MSGraph.Exchange.MailboxSetting.WorkingHoursSetting -Property $outputHash
            Remove-Variable -Name workingHourSetting -Force -WhatIf:$false -Confirm:$false -Verbose:$false -Debug:$false -WarningAction Ignore -ErrorAction Ignore
        }

        Default {
            Stop-PSFFunction -Message "Unable to output a valid MailboxSetting object, because of unhandled type '$($Type)'. Developer mistake." -EnableException $true -Category InvalidData -FunctionName $MyInvocation.MyCommand
        }
    }

}