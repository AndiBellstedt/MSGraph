function New-JsonAutomaticRepliesSettingFraction {
    <#
    .SYNOPSIS
        Creates a json object from AutomaticRepliesSetting object

    .DESCRIPTION
        Creates a json object from AutomaticRepliesSetting object used for Microsoft Graph REST api
        Helper function used for internal commands.

    .PARAMETER AutomaticRepliesSetting
        The object to convert to json

    .EXAMPLE
        PS C:\> New-JsonAutomaticRepliesSettingFraction -AutomaticRepliesSetting $automaticRepliesSetting

        Creates a json object from AutomaticRepliesSetting object used for Microsoft Graph REST api

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding(SupportsShouldProcess = $false, ConfirmImpact = 'Low')]
    [OutputType([String])]
    param (
        [MSGraph.Exchange.MailboxSetting.AutomaticRepliesSetting]
        $AutomaticRepliesSetting
    )

    $automaticRepliesSettingHash = [ordered]@{
        "status"                 = $AutomaticRepliesSetting.Status.ToString()
        "externalAudience"       = $AutomaticRepliesSetting.ExternalAudience.ToString()
        "internalReplyMessage"   = $AutomaticRepliesSetting.InternalReplyMessage
        "externalReplyMessage"   = $AutomaticRepliesSetting.ExternalReplyMessage
        "scheduledStartDateTime" = [ordered]@{
            #"dateTime" = ($AutomaticRepliesSetting.ScheduledStartDateTimeUTC.DateTime | Get-Date -Format s)
            "dateTime" = $AutomaticRepliesSetting.ScheduledStartDateTimeUTC.DateTime.ToString("s") # "s" means sortable date: 2000-01-01T01:01:01(.010001)
            "timeZone" = $AutomaticRepliesSetting.ScheduledStartDateTimeUTC.TimeZone
        }
        "scheduledEndDateTime"   = [ordered]@{
            #"dateTime" = ($AutomaticRepliesSetting.ScheduledEndDateTimeUTC.DateTime | Get-Date -Format s)
            "dateTime" = $AutomaticRepliesSetting.ScheduledEndDateTimeUTC.DateTime.ToString("s") # "s" means sortable date: 2000-01-01T01:01:01(.010001)
            "timeZone" = $AutomaticRepliesSetting.ScheduledEndDateTimeUTC.TimeZone
        }
    }
    $automaticRepliesSettingObject = New-Object psobject -Property $automaticRepliesSettingHash
    $automaticRepliesSettingJSON = ConvertTo-Json -InputObject $automaticRepliesSettingObject
    $automaticRepliesSettingJSON
}
