function Export-MgaMailAttachment {
    <#
    .SYNOPSIS
        Export a mail attachment to a file

    .DESCRIPTION
        Export/saves a mail attachment to a file

    .PARAMETER Path
        The directory where to export the attachment

    .PARAMETER InputObject
        The attachment object to export

    .EXAMPLE
        PS C:\> Export-MgaMailAttachment -InputObject $attachment -Path "$HOME"

        Export the attement to the users profile base directory
    #>
    [CmdletBinding ()]
    [Alias('Save-MgaMailAttachment')]
    param (
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,ValueFromRemainingArguments=$false)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        [String]
        $Path
    )
    begin {
        if (Test-Path -Path $Path -IsValid) {
            if (-not (Test-Path -Path $Path -PathType Container)) {
                Stop-PSFFunction -Message "Specified path is a file and not a path. Please specify a directory." -EnableException $true -Category "InvalidPath" -Tag "Attachment"
            }
        } else {
            Stop-PSFFunction -Message "Specified path is not valid. Please specify a valid directory." -EnableException $true -Category "InvalidPath" -Tag "Attachment"
        }
        $Path = Resolve-Path -Path $Path
    }

    process {
        foreach ($attachment in $InputObject) {
            [system.convert]::FromBase64String($attachment.contentBytes) | Set-Content -Path (Join-Path -Path $Path -ChildPath $attachment.Name) -Encoding Byte
        }
    }

    end {
    }
}