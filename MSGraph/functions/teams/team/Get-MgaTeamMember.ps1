function Get-MgaTeamMember {
    <#
    .SYNOPSIS
        Get members from a Microsoft Teams Team

    .DESCRIPTION
        Get members from Microsoft Teams Team(s) via Microsoft Graph API

    .PARAMETER InputObject
        A team object where to get members from.

    .PARAMETER Name
        Name filter for the members to query.
        (Client Side filtering)

    .PARAMETER Id
        Id filter for the members to query.
        (Client Side filtering)

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
        PS C:\> Get-MgaTeamMember $team

        Returns all members from team in variable $team.
        Assuming that the variable $team is representing a team queried earlier by Get-MgaTeam

    .EXAMPLE
        PS C:\> $team | Get-MgaTeamMember -Name "*John*"

        Returns any member contains "John" in his name from team in variable $team.
        Assuming that the variable $team is representing a team queried earlier by Get-MgaTeam

    .EXAMPLE
        PS C:\> $team | Get-MgaTeamMember -ResultSize 5

        Retrieves only the first 5 members from team in variable $team.
        Assuming that the variable $team is representing a team queried earlier by Get-MgaTeam
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Default')]
    [OutputType([MSGraph.AzureAD.Users.User])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [Alias('Team', 'TeamName', 'TeamID')]
        [MSGraph.Teams.TeamParameter[]]
        $InputObject,

        [Alias('Filter', 'NameFilter', 'FilterName', 'DisplayName')]
        [string]
        $Name,

        [Alias('FilterId', 'IdFilter')]
        [string]
        $Id,

        [Int64]
        $ResultSize = (Get-PSFConfigValue -FullName 'MSGraph.Query.ResultSize' -Fallback 100),

        [MSGraph.Core.AzureAccessToken]
        $Token
    )

    begin {
        $requiredPermission = "Group.Read.All"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand

        #region helper subfunctions
        #endregion helper subfunctions
    }

    process {
        Write-PSFMessage -Level VeryVerbose -Message "Gettings team(s) member by parameterset $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"
        Write-PSFMessage -Level Important -Message "This command uses beta version of Microsoft Graph API. Be aware, that this is not supported in production! Use carefully." -Tag "QueryData"

        foreach ($teamItem in $InputObject) {
            #region checking input object type and query message if required
            if ($teamItem.TypeName -like "System.String") {
                $teamItem = Resolve-MailObjectFromString -Object $teamItem -User $User -Token $Token -NoNameResolving -FunctionName $MyInvocation.MyCommand
                if (-not $teamItem) { continue }
            }
            #endregion checking input object type and query message if required


            #region query data
            $invokeParam = @{
                "Field"          = "groups/$($teamItem.Id)/members"
                "Token"          = $Token
                'UserUnspecific' = $true
                "ResultSize"     = $ResultSize
                "ApiVersion"     = "beta"
                "FunctionName"   = $MyInvocation.MyCommand
            }
            Write-PSFMessage -Level Verbose -Message "Getting team '$($teamItem)' members" -Tag "QueryData"
            $data = Invoke-MgaRestMethodGet @invokeParam
            if ($Name) { [array]$data = $data | Where-Object displayName -Like $Name }
            if ($Id) { [array]$data = $data | Where-Object Id -Like $Id }

            #endregion query data


            #region output data
            Write-PSFMessage -Level VeryVerbose -Message "Output $($data.Count) objects." -Tag "OutputData"
            foreach ($output in $data) {
                $outputObject = [MSGraph.AzureAD.Users.User]::new()
                foreach($prop in ($output | Get-Member -MemberType NoteProperty | Where-Object name -notlike "extension_*" | Where-Object name -notlike "@*").Name) {
                    if($output.$prop) {
                        $outputObject.$prop = $output.$prop
                    }
                }
                Write-PSFMessage -Level Debug -Message "Output member '$($outputObject)'." -Tag "OutputData"
                $outputObject
            }
            #endregion output data
        }

    }

    end {
    }
}