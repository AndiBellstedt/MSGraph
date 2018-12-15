function Invoke-TokenScopeValidation {
    <#
    .SYNOPSIS
        Validates the scope of a token object

    .DESCRIPTION
        Validates the scope of a token object and invoke update-token process, if needed.
        Helper function used for internal commands.

    .PARAMETER Token
        The Token to test.

    .PARAMETER Scope
        The scope(s) the check for existence.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.
        (Just used for logging reasons)

    .EXAMPLE
        PS C:\> $Token = Invoke-TokenScopeValidation -User $Token -Scope "Mail.Read"

        Test Token for scope and return the token. If necessary, the token will be renewed
    #>
    [OutputType([MSGraph.Core.AzureAccessToken])]
    [CmdletBinding()]
    param (
        [MSGraph.Core.AzureAccessToken]
        $Token,

        [Parameter(Mandatory = $true)]
        [string[]]
        $Scope,

        [String]
        $FunctionName = $MyInvocation.MyCommand
    )

    process {
        $Token = Resolve-Token -Token $Token -FunctionName $FunctionName

        if (-not (Test-TokenScope -Token $Token -Scope $requiredPermission -FunctionName $FunctionName)) {
            # required scope information are missing in token
            Write-PSFMessage -Level Warning -Message "Required scope information ($([String]::Join(", ",$Scope))) are missing in token." -Tag "Authentication" -FunctionName $FunctionName
            if ($Token.IdentityPlatformVersion -like '2.0') {
                # With Microsoft Identity Platform 2.0 it is possible to dynamically query new scope informations (incremental consent)
                Write-PSFMessage -Level Verbose -Message "Microsoft Identity Platform 2.0 is used. Dynamical permission request possible. Try to aquire new token." -Tag "Authentication" -FunctionName $FunctionName

                $Scope = $Scope + $Token.Scope
                $tenant = if ($Token.TenantID -like "9188040d-6c67-4c5b-b112-36a304b66dad") {'consumers'} else {'common'}

                # build parameters to query new token
                $paramsNewToken = @{
                    PassThru                = $true
                    ClientId                = $Token.ClientId.ToString()
                    RedirectUrl             = $Token.AppRedirectUrl.ToString()
                    ResourceUri             = $Token.Resource.ToString().TrimEnd('/')
                    IdentityPlatformVersion = $Token.IdentityPlatformVersion
                    Permission              = ($Scope | Where-Object { $_ -notin "offline_access", "openid", "profile", "email" })
                    Tenant                  = $tenant
                }
                if ($script:msgraph_Token.AccessTokenInfo.Payload -eq $Token.AccessTokenInfo.Payload) {
                    $paramsNewToken.Add("Register", $true)
                }
                if ($Token.Credential) {
                    $paramsNewToken.Add("Credential", $Token.Credential)
                }

                $Token = New-MgaAccessToken @paramsNewToken
            }
            else {
                Stop-PSFFunction -Message "FAILED, missing required scope information ($([String]::Join(", ",$Scope))) and Microsoft Identity Platform 1.0 is used.`nNo dynamic permission request available. Permissions has to be specified/granted in app registration process or portal." -EnableException $true -Category AuthenticationError -FunctionName $FunctionName
            }
        }
        else {
            Write-PSFMessage -Level VeryVerbose -Message "OK, required scope information are present. ($([String]::Join(", ",$Scope)))" -Tag "Authentication" -FunctionName $FunctionName
        }

        $Token
    }
}