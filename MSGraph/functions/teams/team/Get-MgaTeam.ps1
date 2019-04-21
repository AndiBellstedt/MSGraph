function Get-MgaTeam {
    <#
    .SYNOPSIS
        Get Microsoft Teams Team

    .DESCRIPTION
        Get Microsoft Teams Team(s) with current settings via Microsoft Graph API

        The command can gather teams where the current connected user is joined,
        or list all existing teams in the tenant. Detailed settings for a team are
        only showed, if the connected user has appropriate permissions for the team.

    .PARAMETER Name
        The name of the team(s) to query.
        (Client Side filtering)

    .PARAMETER Id
        The Id of the team(s) to query.
        (Client Side filtering)

    .PARAMETER InputObject
        A team object piped in to refresh data.

    .PARAMETER ListAll
        Show all available teams in the whole tenant.
        As default behaviour, only teams where the current user is joined will be shown.

    .PARAMETER ResultSize
        The amount of objects to query within API calls to MSGraph.
        To avoid long waitings while query a large number of items, the graph api only
        query a special amount of items within one call.

        A value of 0 represents "unlimited" and results in query all items wihtin a call.
        The default is 100.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .EXAMPLE
        PS C:\> Get-MgaTeam

        Returns all teams the connected user is joined to.

    .EXAMPLE
        PS C:\> Get-MgaTeam -Name "MyTeam*"

        Returns all teams starting with name "MyTeam" where the connected user is joined to.

    .EXAMPLE
        PS C:\> Get-MgaTeam -InputObject $team

        Returns refreshed info for the team out of the variable $team.
        Assuming that the variable $team is representing a team queried earlier by Get-MgaTeam

    .EXAMPLE
        PS C:\> Get-MgaTeam -ListAll

        Returns all teams in the tenant.
        Detailed information about configuration for the team is only listed, when the connected user
        has appropriate permissions (administrative permissions or joined member of the team).

        If the user has permissions is indicated by the property "Accessible".

    .EXAMPLE
        PS C:\> Get-MgaTeam -Name "Sales*" -ListAll

        Returns all teams in the tenant starting with  name "Sales".
        Detailed information about configuration for the team is only listed, when the connected user
        has appropriate permissions (administrative permissions or joined member of the team).

        If the user has permissions is indicated by the property "Accessible".

    .EXAMPLE
        PS C:\> Get-MgaTeam -ResultSize 5 -Token $Token

        Retrieves only the first 5 teams for the connected user with the token represented in the variable $token.
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'ByName')]
    [OutputType([MSGraph.Teams.Team])]
    param (
        [Parameter(ParameterSetName = 'ByInputOBject', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true, Position = 0)]
        [Alias('Team')]
        [MSGraph.Teams.TeamParameter[]]
        $InputObject,

        [Parameter(ParameterSetName = 'ByName', ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, Mandatory = $false, Position = 0)]
        [Parameter(ParameterSetName = 'ListAll', ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, Mandatory = $false)]
        [Alias('Filter', 'NameFilter', 'FilterName', 'DisplayName')]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'ListAll', ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, Mandatory = $false)]
        [Parameter(ParameterSetName = 'ById', ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, Mandatory = $false)]
        [Alias('IdFilter', 'FilterId')]
        [string]
        $Id,

        [Parameter(ParameterSetName = 'ListAll', ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, Mandatory = $false)]
        [switch]
        $ListAll,

        [Int64]
        $ResultSize = (Get-PSFConfigValue -FullName 'MSGraph.Query.ResultSize' -Fallback 100),

        [MSGraph.Core.AzureAccessToken]
        $Token
    )

    begin {
        $requiredPermission = "Group.Read.All"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand

        #region helper subfunctions
        function invoke-internalMgaGetTeamsDetail ([psobject[]]$teamList, $token, $resultSize, [String]$functionName) {
            # Subfunction for query team information
            foreach ($teamListItem in $teamList) {
                Write-PSFMessage -Level VeryVerbose -Message "Getting details on team '$($teamListItem.displayName)'" -Tag "QueryData" -FunctionName $functionName
                $invokeParam = @{
                    "Field"          = "teams/$($teamListItem.id)"
                    "Token"          = $token
                    "UserUnspecific" = $true
                    "ResultSize"     = $resultSize
                    "FunctionName"   = $functionName
                }

                $teamInfo = [PSCustomObject]@{ }
                try {
                    $teamInfo = Invoke-MgaRestMethodGet @invokeParam
                } catch {
                    Write-PSFMessage -Level VeryVerbose -Message "Unable to query information on team '$($teamListItem.displayName)'. Assuming no permission or membership." -Tag "QueryData" -FunctionName $functionName
                    $teamInfo | Add-Member -MemberType NoteProperty -Name id -Value $teamListItem.id
                    $teamInfo | Add-Member -MemberType NoteProperty -Name isArchived -Value $teamListItem.isArchived
                    $teamInfo | Add-Member -MemberType NoteProperty -Name User -Value $teamListItem.User
                }
                $teamInfo | Add-Member -MemberType NoteProperty -Name displayName -Value $teamListItem.displayName
                $teamInfo | Add-Member -MemberType NoteProperty -Name description -Value $teamListItem.description

                $teamInfo
            }
        }
        #endregion helper subfunctions
    }

    process {
        Write-PSFMessage -Level VeryVerbose -Message "Gettings team(s) by parameterset $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"
        [array]$data = @()
        $invokeParam = @{
            "Token"        = $Token
            "ResultSize"   = $ResultSize
            "FunctionName" = $MyInvocation.MyCommand
        }
        switch ($PSCmdlet.ParameterSetName) {
            { $_ -in 'ByName', 'ById' } {
                Write-PSFMessage -Level Verbose -Message "Gettings joined team(s) for user $($token.UserprincipalName)" -Tag "QueryData"
                $invokeParam.Add('Field', 'joinedTeams')
                $invokeParam.Add('User', 'me')
                [array]$teamList = Invoke-MgaRestMethodGet @invokeParam

                if ($PSCmdlet.ParameterSetName -like 'ByName' -and $Name) { [array]$teamList = $teamList | Where-Object displayName -Like $Name }
                if ($PSCmdlet.ParameterSetName -like 'ById' -and $Id) { [array]$teamList = $teamList | Where-Object Id -Like $Id }

                if ($teamList) {
                    Write-PSFMessage -Level VeryVerbose -Message "Found $($teamList.Count) team(s) for user $($token.UserprincipalName)" -Tag "QueryData"
                    $teamList = invoke-internalMgaGetTeamsDetail -teamList $teamList -token $Token -resultSize $ResultSize -functionName $MyInvocation.MyCommand

                    $teamList = $teamList | Add-Member -MemberType NoteProperty -Name "InfoFromJoinedTeam" -Value $true -PassThru
                    $data = $data + $teamList
                } else {
                    Stop-PSFFunction -Message "No joined teams found for user $($token.TokenOwner)" -Tag "QueryData"
                }
            }

            'ListAll' {
                Write-PSFMessage -Level Verbose -Message "Gettings all team(s) from the tenant" -Tag "QueryData"
                #Write-PSFMessage -Level Important -Message "This command uses beta version of Microsoft Graph API. Be aware, that this is not supported in production! Use carefully." -Tag "QueryData"
                $invokeParam.Add('Field', "groups?`$select=id,displayname,description,resourceProvisioningOptions")
                $invokeParam.Add('UserUnspecific', $true)
                [array]$teamList = Invoke-MgaRestMethodGet @invokeParam | Where-Object resourceProvisioningOptions -like "Team"

                if ($Name) { [array]$teamList = $teamList | Where-Object displayName -Like $Name }
                if ($Id) { [array]$teamList = $teamList | Where-Object Id -Like $Id }

                if ($teamList) {
                    Write-PSFMessage -Level VeryVerbose -Message "Found $($teamList.Count) team(s) in tenant" -Tag "QueryData"
                    $teamList = invoke-internalMgaGetTeamsDetail -teamList $teamList -token $Token -resultSize $ResultSize -functionName $MyInvocation.MyCommand

                    $teamList = $teamList | Add-Member -MemberType NoteProperty -Name "InfoFromJoinedTeam" -Value $false -PassThru
                    $data = $data + $teamList
                } else {
                    Stop-PSFFunction -Message "Unexpected Error while getting all teams team information from the tenant." -Tag "QueryData"
                }
            }

            'ByInputOBject' {
                foreach ($team in $InputOBject) {
                    Write-PSFMessage -Level Verbose -Message "Getting team '$($team)'" -Tag "ParameterSetHandling"
                    # resolve team via name
                    if ($team.TypeName -like "System.String") {
                        if ($team.Name) {
                            # get team by name
                            $teamQueried = Get-MgaTeam -Name $team.Name -ListAll -ResultSize 0 -Token $Token
                        } else {
                            # get team by Id
                            $teamQueried = Get-MgaTeam -Id $team.Id -ListAll -ResultSize 0 -Token $Token
                        }
                    } else {
                        # a previsouly query team is piped in
                        if ($team.InputObject.InfoFromJoinedTeam) {
                            $teamQueried = Get-MgaTeam -Name $team.Name -Token $Token
                        } else {
                            $teamQueried = Get-MgaTeam -Name $team.Name -ListAll -ResultSize 0 -Token $Token
                        }
                    }

                    if ($teamQueried) {
                        $teamQueried
                    } else {
                        Stop-PSFFunction -Message "Unexpected Error while getting information on team '$($team)'" -Tag "QueryData"
                    }
                }
            }

            Default { Stop-PSFFunction -Message "Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistake." -EnableException $true -Category MetadataError -FunctionName $MyInvocation.MyCommand }
        }

        #region output data
        Write-PSFMessage -Level VeryVerbose -Message "Output $($data.Count) objects." -Tag "OutputData"
        foreach ($output in $data) {
            if ($output.memberSettings) {
                # team object with accessible information
                $teamObject = [MSGraph.Teams.Team]::new(
                    $output.id,
                    $output.internalId,
                    $output.displayName,
                    $output.description,
                    $output.user,
                    $output.isArchived,
                    $output.InfoFromJoinedTeam,
                    $output.webUrl,
                    $output
                )

                $memberSetting = [MSGraph.Teams.TeamMemberSettings]::new(
                    $output.memberSettings.allowCreateUpdateChannels,
                    $output.memberSettings.allowDeleteChannels,
                    $output.memberSettings.allowAddRemoveApps,
                    $output.memberSettings.allowCreateUpdateRemoveTabs,
                    $output.memberSettings.allowCreateUpdateRemoveConnectors
                )
                $teamObject.memberSettings = $memberSetting

                $guestSettings = [MSGraph.Teams.TeamGuestSettings]::new(
                    $output.guestSettings.allowCreateUpdateChannels,
                    $output.guestSettings.allowDeleteChannels
                )
                $teamObject.guestSettings = $guestSettings

                $messagingSettings = [MSGraph.Teams.TeamMessagingSettings]::new(
                    $output.messagingSettings.allowUserEditMessages,
                    $output.messagingSettings.allowUserDeleteMessages,
                    $output.messagingSettings.allowOwnerDeleteMessages,
                    $output.messagingSettings.allowTeamMentions,
                    $output.messagingSettings.allowChannelMentions
                )
                $teamObject.messagingSettings = $messagingSettings

                $funSettings = [MSGraph.Teams.TeamFunSettings]::new(
                    $output.funSettings.allowGiphy,
                    $output.funSettings.giphyContentRating,
                    $output.funSettings.allowStickersAndMemes,
                    $output.funSettings.allowCustomMemes
                )
                $teamObject.funSettings = $funSettings
            } else {
                # minimal team object. Basically, just information about the group
                $teamObject = [MSGraph.Teams.Team]::new(
                    $output.id,
                    $output.displayName,
                    $output.description,
                    $output.user,
                    $output.isArchived,
                    $output.InfoFromJoinedTeam
                )
            }

            Write-PSFMessage -Level Debug -Message "Output new object '$($teamObject)'." -Tag "OutputData"
            $teamObject
        }
        #endregion output data
    }

    end {
    }
}