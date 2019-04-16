@{
    # Script module or binary module file associated with this manifest
    RootModule         = 'MSGraph.psm1'

    # Version number of this module.
    ModuleVersion      = '1.2.9.2'

    # ID used to uniquely identify this module
    GUID               = '5f61c229-95d0-4423-ab50-938c0723ad21'

    # Author of this module
    Author             = 'Friedrich Weinmann, Andreas Bellstedt'

    # Company or vendor of this module
    CompanyName        = ''

    # Copyright statement for this module
    Copyright          = 'Copyright (c) 2018 Friedrich Weinmann, Andreas Bellstedt'

    # Description of the functionality provided by this module
    Description        = 'Tools for interacting with the Microsoft Graph Api'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion  = '5.0'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of the .NET Framework required by this module
    # DotNetFrameworkVersion = '2.0'

    # Minimum version of the common language runtime (CLR) required by this module
    # CLRVersion = '2.0.50727'

    # Processor architecture (None, X86, Amd64, IA64) required by this module
    # ProcessorArchitecture = 'None'

    # Modules that must be imported into the global environment prior to importing
    # this module
    RequiredModules    = @(
        @{ ModuleName = 'PSFramework'; ModuleVersion = '0.9.25.107' }
    )

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @('bin\MSGraph.dll')

    # Script files (.ps1) that are run in the caller's environment prior to
    # importing this module
    # ScriptsToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess   = @(
        # Core
        'xml\MSGraph.Core.AzureAccessToken.Format.ps1xml',

        # Exchange
        ## Attachments
        'xml\MSGraph.Exchange.Attachment.Format.ps1xml',
        ## Categories
        'xml\MSGraph.Exchange.Category.Format.ps1xml',
        ## Folder
        'xml\MSGraph.Exchange.Mail.Folder.Format.ps1xml',
        ## Message
        'xml\MSGraph.Exchange.Mail.Message.Format.ps1xml',
        ## MailboxSettings
        'xml\MSGraph.Exchange.MailboxSetting.MailboxSettings.Format.ps1xml',
        'xml\MSGraph.Exchange.MailboxSetting.AutomaticRepliesSetting.Format.ps1xml',
        'xml\MSGraph.Exchange.MailboxSetting.WorkingHoursSetting.Format.ps1xml',
        'xml\MSGraph.Exchange.MailboxSetting.LocaleInfoSetting.Format.ps1xml'
    )

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess     = @(
        # Core
        'xml\MSGraph.Core.AzureAccessToken.Types.ps1xml',

        # Exchange
        ## Attachments
        'xml\MSGraph.Exchange.Attachment.Types.ps1xml',
        ## Categories
        'xml\MSGraph.Exchange.Category.Types.ps1xml',
        ## Folder
        'xml\MSGraph.Exchange.Mail.Folder.Types.ps1xml',
        ## Message
        'xml\MSGraph.Exchange.Mail.Message.Types.ps1xml'
        ## MailboxSettings
        'xml\MSGraph.Exchange.MailboxSetting.MailboxSettings.Types.ps1xml'
        'xml\MSGraph.Exchange.MailboxSetting.AutomaticRepliesSetting.Types.ps1xml',
        'xml\MSGraph.Exchange.MailboxSetting.WorkingHoursSetting.Types.ps1xml',
        'xml\MSGraph.Exchange.MailboxSetting.LocaleInfoSetting.Types.ps1xml'
    )

    # Modules to import as nested modules of the module specified in
    # ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module
    FunctionsToExport  = @(
        # Exchange
        ## Folder
        'Get-MgaMailFolder',
        'Rename-MgaMailFolder',
        'New-MgaMailFolder',
        'Move-MgaMailFolder',
        'Remove-MgaMailFolder'

        ## Message
        'Get-MgaMailMessage',
        'Set-MgaMailMessage',
        'Move-MgaMailMessage',
        'Copy-MgaMailMessage',
        'Remove-MgaMailMessage',
        'New-MgaMailMessage',
        'Send-MgaMailMessage',
        'Add-MgaMailMessageReply',
        'Add-MgaMailMessageForward',

        ## Attachments
        'Get-MgaMailAttachment',
        'Export-MgaMailAttachment',
        "Add-MgaMailAttachment",
        'Remove-MgaMailAttachment',

        ## Categories
        'Get-MgaExchCategory',
        'New-MgaExchCategory',
        'Set-MgaExchCategory',
        'Remove-MgaExchCategory',

        ## MailboxSettings
        'Get-MgaMailboxSetting',
        'Set-MgaMailboxSetting',

        # Core
        'Invoke-MgaRestMethodGet',
        'Invoke-MgaRestMethodPatch',
        'Invoke-MgaRestMethodPost',
        'Invoke-MgaRestMethodDelete',
        'New-MgaAccessToken',
        'Update-MgaAccessToken',
        'Get-MgaAccessTokenRegistered',
        'Register-MgaAccessToken'
    )

    # Aliases to export from this module
    AliasesToExport    = @(
        # Exchange
        ## Message
        'Update-MgaMailMessage',
        'Add-MgaMailForwardMessage',
        'Add-MgaMailForwardMessage',

        ## Attachments
        'Save-MgaMailAttachment',

        # COre
        'Invoke-MgaDeleteMethod'
        'Invoke-MgaGetMethod',
        'Invoke-MgaPatchMethod',
        'Invoke-MgaPostMethod',
        'Get-MgaRegisteredAccessToken'
    )

    # Cmdlets to export from this module
    CmdletsToExport    = ''

    # Variables to export from this module
    VariablesToExport  = ''

    # List of all modules packaged with this module
    ModuleList         = @()

    # List of all files packaged with this module
    FileList           = @()

    # Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData        = @{

        #Support for PowerShellGet galleries.
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @(
                'MSGraph',
                'MSGraphAPI',
                'Graph',
                'GraphAPI',
                'MicrosoftGraph',
                'MicrosoftGraphAPI',
                'MicrosoftGraphRESTAPI',
                'PSGallery',
                'REST',
                'API',
                'RESTAPI',
                'OAuth',
                'Outlook',
                'Messages',
                'Mail',
                "Email"
            )

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/AndiBellstedt/MSGraph/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/AndiBellstedt/MSGraph'

            # A URL to an icon representing this module.
            IconUri      = 'https://github.com/AndiBellstedt/MSGraph/tree/Development/MSGraph/assets/MSGraph_128x128.png'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/AndiBellstedt/MSGraph/blob/master/MSGraph/changelog.md'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
