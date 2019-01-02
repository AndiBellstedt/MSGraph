function Export-MgaMailAttachment {
    <#
    .SYNOPSIS
        Export a mail attachment to a file

    .DESCRIPTION
        Export/saves a mail attachment to a file

    .PARAMETER Attachment
        The attachment object to export

    .PARAMETER Path
        The directory where to export the attachment

    .PARAMETER PassThru
        Outputs the token to the console

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .EXAMPLE
        PS C:\> Export-MgaMailAttachment -Attachment $attachment -Path "$HOME"

        Export the attement to the users profile base directory
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [Alias('Save-MgaMailAttachment')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false)]
        [Alias('InputObject', 'AttachmentId', 'Id')]
        [MSGraph.Exchange.Attachment.AttachmentParameter[]]
        $Attachment,

        [String]
        $Path = (Get-Location).Path,

        [switch]
        $PassThru
    )
    begin {
        if (Test-Path -Path $Path -IsValid) {
            if (-not (Test-Path -Path $Path -PathType Container)) {
                Stop-PSFFunction -Message "Specified path is a file and not a path. Please specify a directory." -EnableException $true -Category "InvalidPath" -Tag "Attachment"
            }
        }
        else {
            Stop-PSFFunction -Message "Specified path is not valid. Please specify a valid directory." -EnableException $true -Category "InvalidPath" -Tag "Attachment"
        }
        $Path = Resolve-Path -Path $Path
    }

    process {
        foreach ($attachmentItem in $Attachment) {
            #switching between different types to export
            switch ($attachmentItem.TypeName) {
                "MSGraph.Exchange.Mail.Attachment.FileAttachment" {
                    if ($pscmdlet.ShouldProcess($attachmentItem, "Export to $($Path.Path)")) {
                        Write-PSFMessage -Level Verbose -Message "Exporting attachment '$($attachmentItem)' to $($Path.Path)" -Tag "ExportData"
                        $attachmentItem.InputObject.ContentBytes | Set-Content -Path (Join-Path -Path $Path -ChildPath $attachmentItem.Name) -Encoding Byte
                    }
                }

                "MSGraph.Exchange.Mail.Attachment.ItemAttachment" {
                    if ($pscmdlet.ShouldProcess($attachmentItem, "Export to $($Path.Path)")) {
                        Write-PSFMessage -Level Important -Message "Export of $($attachmentItem.TypeName) is not implemented, yet. Could not export '$($attachmentItem.InputObject)'" -Tag "ExportData"
                    }
                }

                "MSGraph.Exchange.Mail.Attachment.ReferenceAttachment" {
                    if ($pscmdlet.ShouldProcess($attachmentItem, "Export to $($Path.Path)")) {
                        $shell = New-Object -ComObject ("WScript.Shell")
                        $shortCut = $shell.CreateShortcut("$($Path.Path)\$($attachmentItem.InputObject.Name).lnk")
                        $shortCut.TargetPath = $attachmentItem.InputObject.SourceUrl
                        $shortCut.Save()
                    }
                }

                "MSGraph.Exchange.Mail.Attachment.Attachment" {
                    Write-PSFMessage -Level Warning -Message "$($attachmentItem) is not a exportable attachment." -Tag "ParameterSetHandling"
                }

                Default {
                    Write-PSFMessage -Level Warning -Message "$($attachmentItem) is not a exportable attachment." -Tag "ParameterSetHandling"
                    continue
                }
            }

            if ($PassThru) { $attachmentItem }
        }
    }

    end {
    }
}