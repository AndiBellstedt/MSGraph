function Update-MgaMailMessage {
    <#
    .SYNOPSIS
        *** UNDER CONSTRUCTION ***
        Updates messages from a email folder

    .DESCRIPTION
        Update messages from Exchange Online using the graph api.

    .PARAMETER InputObject
        Carrier object for Pipeline input. Accepts messages.

    .PARAMETER Name
        The display name of the folder to search.
        Defaults to the inbox.

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER ResultSize
        The user to execute this under. Defaults to the user the token belongs to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-EORAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-EORAccessToken.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .EXAMPLE
        PS C:\> Update-MgaMailMessage

        Update emails
    #>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', DefaultParameterSetName='ByInputObject')]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName='ByInputObject')]
        [MSGraph.Exchange.Mail.Message]
        $InputObject,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName='ByName')]
        [Alias('DisplayName')]
        [string[]]
        $Name = '',

        [string]
        $User = 'me',

        [Int64]
        $ResultSize = (Get-PSFConfigValue -FullName 'MSGraph.Query.ResultSize' -Fallback 100),

        #[MSGraph.Core.AzureAccessToken]
        $Token
    )
    begin {
    }

    process {
        foreach ($Item in $Name) {
            if ($pscmdlet.ShouldProcess("Target", "Operation")) {

            }
        }
    }

}