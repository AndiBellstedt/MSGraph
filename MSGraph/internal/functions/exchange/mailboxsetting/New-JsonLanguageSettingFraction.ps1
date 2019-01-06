function New-JsonLanguageSettingFraction {
    <#
    .SYNOPSIS
        Creates a json object from LocaleInfoSetting (LanguageSetting) object

    .DESCRIPTION
        Creates a json object from LocaleInfoSetting (LanguageSetting) object used for Microsoft Graph REST api
        Helper function used for internal commands.

    .PARAMETER LanguageSetting
        The object to convert to json

    .EXAMPLE
        PS C:\> New-JsonLanguageSettingFraction -LanguageSetting $languageSetting

        Creates a json object from LanguageSetting object used for Microsoft Graph REST api

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding(SupportsShouldProcess = $false, ConfirmImpact = 'Low')]
    [OutputType([String])]
    param (
        [MSGraph.Exchange.MailboxSetting.LocaleInfoSetting]
        $LanguageSetting
    )

    $languageSettingHash = [ordered]@{
        "locale"      = $LanguageSetting.Locale.ToString()
        #"displayName" = $LanguageSetting.DisplayName # causes errors on rest patch call
    }
    $languageSettingObject = New-Object psobject -Property $languageSettingHash
    $languageSettingJSON = ConvertTo-Json -InputObject $languageSettingObject
    $languageSettingJSON
}
