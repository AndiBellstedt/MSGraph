function New-JsonMailboxSettingObject {
    <#
    .SYNOPSIS
        Creates a json mailsettings object for use in Microsoft Graph REST api

    .DESCRIPTION
        Creates a json mailsettings object for use in Microsoft Graph REST api
        Helper function used for internal commands.

    .PARAMETER SettingObject
        The object to be converted into JSON format containing the data for the new message object.

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.
        (Just used for logging reasons)

    .NOTES
        For addiontional information about Microsoft Graph API go to:
        https://docs.microsoft.com/en-us/graph/api/user-update-mailboxsettings?view=graph-rest-1.0

    .EXAMPLE
        PS C:\> New-JsonMailboxSettingObject -SettingObject $settingObject -User $user -FunctionName $MyInvocation.MyCommand

        Creates a json MailboxSetting object for use in Microsoft Graph REST api

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding(SupportsShouldProcess = $false, ConfirmImpact = 'Low')]
    [OutputType([String])]
    param (
        [MSGraph.Exchange.MailboxSetting.MailboxSettingParameter]
        $SettingObject,

        [string]
        $User,

        [String]
        $FunctionName
    )
    begin {
    }

    process {
        Write-PSFMessage -Level Debug -Message "Working on '$($SettingObject)' to create mailboxSetting JSON object" -Tag "ParameterSetHandling"
        #region variable definition
        $bodyHash = [ordered]@{}

        #endregion variable definition

        #region Parsing input to json data parts
        # set field @odata.context - required
        if ($SettingObject.InputObject.BaseObject.'@odata.context') {
            $context = $SettingObject.InputObject.BaseObject.'@odata.context'
            if ($context -match '\/mailboxSettings\/\w*$') { $context = $context.Replace($Matches.Values, "/mailboxsettings") }
            Remove-Variable -Name Matches -Force -WhatIf:$false -Confirm:$false -Verbose:$false -Debug:$false -WarningAction Ignore -ErrorAction Ignore
        } else {
            $apiConnection = Get-PSFConfigValue -FullName 'MSGraph.Tenant.ApiConnection' -Fallback 'https://graph.microsoft.com'
            $apiVersion = Get-PSFConfigValue -FullName 'MSGraph.Tenant.ApiVersion' -Fallback 'v1.0'
            $resolvedUser = Resolve-UserString -User $User -ContextData
            $context = "$($apiConnection)/$($apiVersion)/`$metadata#$($resolvedUser)/mailboxsettings"
            Remove-Variable -Name apiConnection, apiVersion -Force -WhatIf:$false -Confirm:$false -Verbose:$false -Debug:$false -WarningAction Ignore -ErrorAction Ignore
        }
        $bodyHash.Add('@odata.context', """$context""")

        # depending on type of object
        switch ($SettingObject.TypeName) {
            'MSGraph.Exchange.MailboxSetting.MailboxSettings' {
                # set archive folder
                Write-PSFMessage -Level VeryVerbose -Message "Prepare setting archive folder to '$($SettingObject.InputObject.ArchiveFolder)'" -Tag "CreateJSON" -FunctionName $FunctionName
                $bodyHash.Add('archiveFolder', ($SettingObject.InputObject.ArchiveFolder.Id | ConvertTo-Json))

                # set time zone
                Write-PSFMessage -Level VeryVerbose -Message "Prepare setting timezone to '$($SettingObject.InputObject.TimeZone.Id)'" -Tag "CreateJSON" -FunctionName $FunctionName
                $bodyHash.Add('timeZone', ($SettingObject.InputObject.TimeZone.Id | ConvertTo-Json))
                #$bodyHash.Add('timeZone', ('"' + "W. Europe Standard Time" + '"'))

                # set auto reply
                Write-PSFMessage -Level VeryVerbose -Message "Prepare setting autoreply to '$($SettingObject.InputObject.automaticRepliesSetting.Status)'" -Tag "CreateJSON" -FunctionName $FunctionName
                $automaticRepliesSettingJSON = New-JsonAutomaticRepliesSettingFraction -AutomaticRepliesSetting $SettingObject.InputObject.automaticRepliesSetting
                $bodyHash.Add('automaticRepliesSetting', $automaticRepliesSettingJSON)

                # set language
                Write-PSFMessage -Level VeryVerbose -Message "Prepare setting language to '$($SettingObject.InputObject.Language)'" -Tag "CreateJSON" -FunctionName $FunctionName
                $languageSettingJSON = New-JsonLanguageSettingFraction -LanguageSetting $SettingObject.InputObject.Language
                $bodyHash.Add('language', $languageSettingJSON)

                # set working hours
                Write-PSFMessage -Level VeryVerbose -Message "Prepare setting workingHours to '$($SettingObject.InputObject.WorkingHours)'" -Tag "CreateJSON" -FunctionName $FunctionName
                $workingHoursSettingJSON = New-JsonWorkingHoursSettingFraction -WorkingHoursSetting $SettingObject.InputObject.WorkingHours
                $bodyHash.Add('workingHours', $workingHoursSettingJSON)
            }

            'MSGraph.Exchange.Mail.Folder' {
                # set archive folder
                Write-PSFMessage -Level VeryVerbose -Message "Prepare setting archive folder to '$($SettingObject.InputObject)'" -Tag "CreateJSON" -FunctionName $FunctionName
                $bodyHash.Add('archiveFolder', ($SettingObject.InputObject.Id | ConvertTo-Json))
            }

            'System.TimeZoneInfo' {
                # set time zone
                Write-PSFMessage -Level VeryVerbose -Message "Prepare setting timezone to '$($SettingObject.InputObject.Id)'" -Tag "CreateJSON" -FunctionName $FunctionName
                $bodyHash.Add('timeZone', ($SettingObject.InputObject.Id | ConvertTo-Json))
            }

            'MSGraph.Exchange.MailboxSetting.AutomaticRepliesSetting' {
                # set auto reply
                Write-PSFMessage -Level VeryVerbose -Message "Prepare setting autoreply to '$($SettingObject.InputObject.Status)'" -Tag "CreateJSON" -FunctionName $FunctionName
                $automaticRepliesSettingJSON = New-JsonAutomaticRepliesSettingFraction -AutomaticRepliesSetting $SettingObject.InputObject
                $bodyHash.Add('automaticRepliesSetting', $automaticRepliesSettingJSON)
            }

            'MSGraph.Exchange.MailboxSetting.LocaleInfoSetting' {
                # set language
                Write-PSFMessage -Level VeryVerbose -Message "Prepare setting language to '$($SettingObject.InputObject)'" -Tag "CreateJSON" -FunctionName $FunctionName
                $languageSettingJSON = New-JsonLanguageSettingFraction -LanguageSetting $SettingObject.InputObject
                $bodyHash.Add('language', $languageSettingJSON)
            }

            'MSGraph.Exchange.MailboxSetting.WorkingHoursSetting' {
                # set working hours
                Write-PSFMessage -Level VeryVerbose -Message "Prepare setting workingHours to '$($SettingObject.InputObject)'" -Tag "CreateJSON" -FunctionName $FunctionName
                $workingHoursSettingJSON = New-JsonWorkingHoursSettingFraction -WorkingHoursSetting $SettingObject.InputObject
                $bodyHash.Add('workingHours', $workingHoursSettingJSON)
            }

            Default { Stop-PSFFunction -Message "Unhandled type ($($SettingObject.TypeName)) of SettingObject. Developer mistake!" -EnableException $true -Category InvalidType -FunctionName $MyInvocation.MyCommand }
        }
        #endregion Parsing input to json data parts

        # Put parameters (JSON Parts) into a valid JSON-object and output the result
        $bodyJSON = Merge-HashToJSON $bodyHash
        $bodyJSON
    }

    end {
    }
}