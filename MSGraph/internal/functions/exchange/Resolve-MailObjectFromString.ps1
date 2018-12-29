function Resolve-MailObjectFromString {
    <#
    .SYNOPSIS
        Resolves a name/id from a mail or folder parameter class

    .DESCRIPTION
        Resolves a name/id from a mail or folder parameter class to a full qualified mail or folder object and return the parameter class back.
        Helper function used for internal commands.

    .PARAMETER Object
        The mail or folder object

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .PARAMETER NoNameResolving
        If specified, there will be no checking on names. Only Id will be resolved.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.

    .EXAMPLE
        PS C:\> Resolve-MailObjectFromString -Object $MailFolder -User $User -Token $Token -Function $MyInvocation.MyCommand

        Resolves $MailFolder into a legitimate user targeting string element.
    #>
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $false, ConfirmImpact = 'Low')]
    param (
        $Object,

        [string]
        $User,

        [MSGraph.Core.AzureAccessToken]
        $Token,

        [switch]
        $NoNameResolving,

        [String]
        $FunctionName = $MyInvocation.MyCommand
    )

    # variable definition
    $invokeParam = @{
        "User"  = $User
        "Token" = $Token
    }

    # check input object type
    if ($Object.psobject.TypeNames[0] -like "MSGraph.Exchange.Mail.FolderParameter") {
        $type = "Folder"
        $typeNamespace = "MSGraph.Exchange.Mail"
        $nounPreFix = "MgaMail"
        $parameterName = "InputObject"
    }
    elseif ($Object.psobject.TypeNames[0] -like "MSGraph.Exchange.Mail.MessageParameter") {
        $type = "Message"
        $typeNamespace = "MSGraph.Exchange.Mail"
        $nounPreFix = "MgaMail"
        $parameterName = "InputObject"
    }
    elseif ($Object.psobject.TypeNames[0] -like "MSGraph.Exchange.Category.CategoryParameter") {
        $type = "Category"
        $typeNamespace = "MSGraph.Exchange.Category"
        $nounPreFix = "MgaExch"
        if ($Object.Id) { $parameterName = "Id" } else { $parameterName = "Name" }
    }
    else {
        $msg = "Object '$($Object)' is not valid. Must be one of: 'MSGraph.Exchange.Mail.FolderParameter', 'MSGraph.Exchange.Mail.MessageParameter', 'MSGraph.Exchange.Category.CategoryParameter'."
        Stop-PSFFunction -Message $msg -Tag "InputValidation" -FunctionName $FunctionName -EnableException $true -Exception ([System.Management.Automation.RuntimeException]::new($msg))
    }
    Write-PSFMessage -Level Debug -Message "Object '$($Object)' is qualified as a $($type)" -Tag "InputValidation" -FunctionName $FunctionName

    # Resolve the object
    if ($Object.Id -and (Test-MgaMailObjectId -Id $Object.Id -Type $type -FunctionName $FunctionName)) {
        Write-PSFMessage -Level Debug -Message "Going to resolve '$($Object)' with Id" -Tag "InputValidation" -FunctionName $FunctionName
        $invokeParam.Add($parameterName, $Object.Id)
        $output = .("Get-" + $nounPreFix + $type) @invokeParam
    }
    elseif ($Object.Name -and (-not $NoNameResolving)) {
        Write-PSFMessage -Level Debug -Message "Going to resolve '$($Object)' with name" -Tag "InputValidation" -FunctionName $FunctionName
        $invokeParam.Add($parameterName, $Object.Name)
        $invokeParam.Add("ErrorAction", "Stop")
        $output = .("Get-" + $nounPreFix + $type) @invokeParam
    }
    else {
        # not valid, end function without output
        Write-PSFMessage -Level Warning -Message "The specified input string seams not to be a valid Id. Skipping object '$($Object)'" -Tag "InputValidation" -FunctionName $FunctionName
        return
    }

    # output the result
    if ($output) {
        New-Object -TypeName "$($typeNamespace).$($type)Parameter" -ArgumentList $output
    }
}