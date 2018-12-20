<#
This is the configuration file for default values in the module

By default, it is enough to have a single one of them,
however if you have enough configuration settings to justify having multiple copies of it,
feel totally free to split them into multiple files.
#>

# module creation defaults - used by module creation framework (PSModuleDevelopment)
Set-PSFConfig -Module 'MSGraph' -Name 'Import.DoDotSource' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be dotsourced on import. By default, the files of this module are read as string value and invoked, which is faster but worse on debugging."
Set-PSFConfig -Module 'MSGraph' -Name 'Import.IndividualFiles' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be imported individually. During the module build, all module code is compiled into few files, which are imported instead by default. Loading the compiled versions is faster, using the individual files is easier for debugging and testing out adjustments."

#region Settings inside the module
# Azure Active Directory App
Set-PSFConfig -Module 'MSGraph' -Name 'Tenant.Application.ClientID' -Value "bbc256f6-f642-44a4-add5-7f665e8b90cb" -Initialize -Validation 'string' -Description "Well known ClientID from registered Application in Azure tenant"
Set-PSFConfig -Module 'MSGraph' -Name 'Tenant.Application.RedirectUrl' -Value "https://login.microsoftonline.com/common/oauth2/nativeclient" -Initialize -Validation 'string' -Description "Redirection URL specified in MS Azure Application portal for the registered application"
Set-PSFConfig -Module 'MSGraph' -Name 'Tenant.Application.DefaultPermission' -Value @("Mail.ReadWrite.Shared") -Initialize -Validation 'string' -Description "The default permission to consent when getting a token"
Set-PSFConfig -Module 'MSGraph' -Name 'Tenant.ApiConnection' -Value "https://graph.microsoft.com" -Initialize -Validation 'string' -Description "The App ID URI of the target web API (secured resource). To find the App ID URI, in the Azure Portal, click Azure Active Directory, click Application registrations, open the application's Settings page, then click Properties."
Set-PSFConfig -Module 'MSGraph' -Name 'Tenant.Authentiation.IdentityPlatformVersion' -Value "2.0" -Initialize -Validation 'string' -Description "Specifies the endpoint version of the logon platform (Microsoft identity platform) where to connect for logon. For more information goto https://docs.microsoft.com/en-us/azure/active-directory/develop/about-microsoft-identity-platform"
Set-PSFConfig -Module 'MSGraph' -Name 'Tenant.Authentiation.Endpoint' -Value "https://login.microsoftonline.com" -Initialize -Validation 'string' -Description "The URI for authentication and query tokens (access and refresh)"


# web client
Set-PSFConfig -Module 'MSGraph' -Name 'WebClient.UserAgentName' -Value "PowerShellModule.MSGraph.RestClient" -Initialize -Validation 'string' -Description "Name of the user agent in the web client used by module"
Set-PSFConfig -Module 'MSGraph' -Name 'WebClient.UserAgentVersion' -Value "1.1" -Initialize -Validation 'string' -Description "Version for the user agent in the web client used by module"

# command behavior
Set-PSFConfig -Module 'MSGraph' -Name 'Query.ResultSize' -Value 100 -Initialize -Validation integer -Description "Limit of amount of records returned by a function. Use 0 for unlimited."
Set-PSFConfig -Module 'MSGraph' -Name 'Hierarchy.Path.Separator' -Value "\" -Initialize -Validation string -Description "the character used to process hierarchical names (like FullName property on folders) in MSGraph module."

#endregion Settings inside the module