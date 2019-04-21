function Get-MgaTeam {
    <#
    .SYNOPSIS
        Get Microsoft Teams Team

    .DESCRIPTION
        Get joined Microsoft Teams Team(s) with current settings via Microsoft Graph API

    .PARAMETER Name
        The name of the team(s) to query.

    .PARAMETER ListAll
        Show all available teams in the whole tenant.
        As default behaviour, only teams where the current user is joined will be shown.

    .PARAMETER Filter
        The name to filter by.
        (Client Side filtering)

        Try to avoid, when filtering on single name, use parameter -Name instead of -Filter.

    .PARAMETER ResultSize
        The user to execute this under.
        Defaults to the user the token belongs to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .EXAMPLE
        PS C:\> Get-MgaTeam

        Returns all teams the connected user is joined to.

    .EXAMPLE
        PS C:\> Get-MgaTeam -Name $team

        Returns refreshed info for the team out of the variable $team.
        Assuming that the variable $team is representing a team queried earlier by Get-MgaTeam

    .EXAMPLE
        PS C:\> Get-MgaTeam -ListAll

        Returns all teams in the tenant.
        Detailed information about configuration for the team is only listed, when the connected user
        has appropriate permissions (administrative permissions or joined member of the team).

    .EXAMPLE
        PS C:\> Get-MgaMailFolder -Filter "My*"

        Returns all joined teams by the connected user matching the name "My" at the begin of the team.

    .EXAMPLE
        PS C:\> Get-MgaMailFolder -ResultSize 5 -Token $Token

        Retrieves only the first 5 teams for the connected user with the token represented in the variable $token.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    #[OutputType([MSGraph.Teams.Team])]
    param (
        [Parameter(ParameterSetName = 'ByInputOBject', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true, Position = 0)]
        [Alias('Team', 'TeamName', 'Id')]
        [MSGraph.Teams.TeamParameter[]]
        $InputObject,

        [Parameter(ParameterSetName = 'Default', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $false, Position = 0)]
        [Parameter(ParameterSetName = 'ListAll', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $false, Position = 0)]
        [Alias('Filter', 'NameFilter', 'FilterName', 'DisplayName')]
        [string]
        $Name,

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

                $teamInfo = [PSCustomObject]@{}
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
        switch ($PSCmdlet.ParameterSetName) {
            "Default" {
                Write-PSFMessage -Level Verbose -Message "Gettings joined team(s) for user $($token.UserprincipalName)" -Tag "QueryData"
                $invokeParam = @{
                    "Field"        = 'joinedTeams'
                    "Token"        = $Token
                    "User"         = "me"
                    "ResultSize"   = $ResultSize
                    "FunctionName" = $MyInvocation.MyCommand
                }
                [array]$teamList = Invoke-MgaRestMethodGet @invokeParam
                if ($Name) { [array]$teamList = $teamList | Where-Object displayName -Like $Name }

                if ($teamList) {
                    Write-PSFMessage -Level VeryVerbose -Message "Found $($teamList.Count) team(s) for user $($token.UserprincipalName)" -Tag "QueryData"
                    $data = $data + (invoke-internalMgaGetTeamsDetail -teamList $teamList -token $Token -resultSize $ResultSize -functionName $MyInvocation.MyCommand)
                } else {
                    Stop-PSFFunction -Message "No joined teams found for user $($token.TokenOwner)" -Tag "QueryData"
                }
            }

            "ListAll" {
                Write-PSFMessage -Level Verbose -Message "Gettings all team(s) from the tenant" -Tag "QueryData"
                #Write-PSFMessage -Level Important -Message "This command uses beta version of Microsoft Graph API. Be aware, that this is not supported in production! Use carefully." -Tag "QueryData"
                $invokeParam = @{
                    "Field"          = "groups?`$select=id,displayname,description,resourceProvisioningOptions"
                    "Token"          = $Token
                    "UserUnspecific" = $true
                    "ResultSize"     = $ResultSize
                    "FunctionName"   = $MyInvocation.MyCommand
                }

                [array]$teamList = Invoke-MgaRestMethodGet @invokeParam | Where-Object resourceProvisioningOptions -like "Team"
                if ($Name) { [array]$teamList = $teamList | Where-Object displayName -Like $Name }

                if ($teamList) {
                    Write-PSFMessage -Level VeryVerbose -Message "Found $($teamList.Count) team(s) in tenant" -Tag "QueryData"
                    $data = $data + (invoke-internalMgaGetTeamsDetail -teamList $teamList -token $Token -resultSize $ResultSize -functionName $MyInvocation.MyCommand)
                } else {
                    Stop-PSFFunction -Message "Unexpected Error while getting all teams team information from the tenant." -Tag "QueryData"
                }
            }

            "ByInputOBject" {
                foreach ($team in $ByInputOBject) {
                    Write-PSFMessage -Level Important -Message "not implemented yet" -Tag "ParameterSetHandling"
                    #Write-PSFMessage -Level Verbose -Message "Getting team '$( if($team.Name){$team.Name}else{$team.Id} )'" -Tag "ParameterSetHandling"
                    #$data = $data + (invoke-internalMgaGetTeamsDetail -teamList $teamList -token $Token -resultSize $ResultSize -functionName $MyInvocation.MyCommand)

                    #if (-not $data) {
                    #    Stop-PSFFunction -Message "Unexpected Error while getting information on team '$($team)'" -Tag "QueryData"
                    #}
                }
            }

            Default { Stop-PSFFunction -Message "Unhandled parameter set. ($($PSCmdlet.ParameterSetName)) Developer mistake." -EnableException $true -Category MetadataError -FunctionName $MyInvocation.MyCommand }
        }

        #region output data
        Write-PSFMessage -Level VeryVerbose -Message "Output $($data.Count) objects." -Tag "OutputData"
        foreach ($output in $data) {
            if($output.memberSettings) {
                # team object with accessible information
                $teamObject = [MSGraph.Teams.Team]::new(
                    $output.id,
                    $output.displayName,
                    $output.description,
                    $output.user,
                    $output.isArchived,
                    $output.internalId,
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
                    $output.isArchived
                )
            }
            #$teamObject = $output
            Write-PSFMessage -Level Debug -Message "Output new object '$($teamObject)'." -Tag "OutputData"
            $teamObject
        }
        #endregion output data
    }

    end {
    }
}