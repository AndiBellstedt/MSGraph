function Resolve-UserInMailObject {
    <#
    .SYNOPSIS
        Resolves the user from a mail or folder parameter class

    .DESCRIPTION
        Resolves the user a mail or folder parameter class and compares against the specified user.
        If user in object is different, from the specified user, the user from the object is put out.
        Helper function used for internal commands.

    .PARAMETER Object
        The mail or folder object

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER ShowWarning
        If specified, there will be no warning output on the console.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.

    .EXAMPLE
        PS C:\> Resolve-UserInMailObject -Object $MailFolder -User $User -Function $MyInvocation.MyCommand

        Resolves the user from a mail or folder parameter class.
    #>
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $false, ConfirmImpact = 'Low')]
    param (
        $Object,

        [string]
        $User,

        [switch]
        $ShowWarning,

        [String]
        $FunctionName = $MyInvocation.MyCommand
    )

    # check input object type
    if($Object.psobject.TypeNames[0] -like "MSGraph.Exchange.Mail.FolderParameter") {
        $Type= "Folder"
    } 
    elseif ($Object.psobject.TypeNames[0] -like "MSGraph.Exchange.Mail.MessageParameter") {
        $Type= "Message"
    }
    else {
        $msg = "Object '$($Object)' is not valid. Must be a 'MSGraph.Exchange.Mail.FolderParameter' or a 'MSGraph.Exchange.Mail.MessageParameter'."
        Stop-PSFFunction -Message $msg -Tag "InputValidation" -FunctionName $FunctionName -EnableException $true -Exception ([System.Management.Automation.RuntimeException]::new($msg))
    }
    Write-PSFMessage -Level Debug -Message "Object '$($Object)' is qualified as a $($Type)" -Tag "InputValidation" -FunctionName $FunctionName

    if($ShowWarning) {
        $level = @{ Level = "Warning" }
    }
    else {
        $level = @{ Level = "Verbose" }
        
    }


    # Resolve the object
    if ($User -and ($Object.TypeName -like "MSGraph.Exchange.Mail.$($Type)") -and ($User -notlike $Object.InputObject.User)) {
        Write-PSFMessage @Level -Message "Individual user specified! User from $($Type)Object ($($Object.InputObject.User)) will take precedence on specified user ($($User))!" -Tag "InputValidation" -FunctionName $FunctionName
        $output = $Object.InputObject.User
    }
    elseif ((-not $User) -and ($Object.TypeName -like "MSGraph.Exchange.Mail.$($Type)")) {
        $output = $Object.InputObject.User
    }

    # output the result
    $output
}