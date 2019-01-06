function New-JsonWorkingHoursSettingFraction {
    <#
    .SYNOPSIS
        Creates a json object from WorkingHoursSetting object

    .DESCRIPTION
        Creates a json object from WorkingHoursSetting object used for Microsoft Graph REST api
        Helper function used for internal commands.

    .PARAMETER WorkingHoursSetting
        The object to convert to json

    .EXAMPLE
        PS C:\> New-JsonWorkingHoursSettingFraction -WorkingHoursSetting $workingHoursSetting

        Creates a json object from WorkingHoursSetting object used for Microsoft Graph REST api

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding(SupportsShouldProcess = $false, ConfirmImpact = 'Low')]
    [OutputType([String])]
    param (
        [MSGraph.Exchange.MailboxSetting.WorkingHoursSetting]
        $WorkingHoursSetting
    )

    $workingHoursSettingHash = [ordered]@{
        "daysOfWeek" = [array]$WorkingHoursSetting.DaysOfWeek.ForEach( {$_.ToString()} )
        "startTime"  = $WorkingHoursSetting.StartTime.ToString("HH:mm:ss.fffffff")
        "endTime"    = $WorkingHoursSetting.EndTime.ToString("HH:mm:ss.fffffff")
        "timeZone"   = @{
            "name" = $WorkingHoursSetting.TimeZone.ToString()
        }
    }
    $workingHoursSettingObject = New-Object psobject -Property $workingHoursSettingHash
    $workingHoursSettingJSON = ConvertTo-Json -InputObject $workingHoursSettingObject
    $workingHoursSettingJSON
}
