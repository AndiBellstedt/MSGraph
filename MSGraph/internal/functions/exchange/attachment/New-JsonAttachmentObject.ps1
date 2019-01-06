function New-JsonAttachmentObject {
    <#
    .SYNOPSIS
        Creates a json attachment object for use in Microsoft Graph REST api

    .DESCRIPTION
        Creates a json attachment object for use in Microsoft Graph REST api
        Helper function used for internal commands.

    .PARAMETER Name
        The name of attachment.

    .PARAMETER Size
        The size in bytes of the attachment.

    .PARAMETER IsInline
        Set to true if this is an inline attachment.

    .PARAMETER LastModifiedDateTime
        The date and time when the attachment was last modified.
        The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time.
        For example, midnight UTC on Jan 1, 2014 would look like this: '2014-01-01T00:00:00Z'

    .PARAMETER ContentType
        The content type of the attachment.

    .PARAMETER contentBytes
        The base64-encoded contents of the file.

    .PARAMETER contentLocation
        The Uniform Resource Identifier (URI) that corresponds to the location of the content of the attachment.

    .PARAMETER Item
        The attached message or event. Navigation property.

    .PARAMETER IsFolder
        Property indicates, wether the object is a folder or not.

    .PARAMETER Permission
        The stated permission on the reference attachment.

    .PARAMETER PreviewUrl
        The url the preview the reference attachment.

    .PARAMETER ProviderType
        Specifies what type of reference is it.

    .PARAMETER SourceUrl
        The Url where the reference attachment points to.

    .PARAMETER ThumbnailUrl
        The Url of the thumbnail for the reference attachment.

    .PARAMETER FunctionName
        Name of the higher function which is calling this function.
        (Just used for logging reasons)

    .NOTES
        For addiontional information about Microsoft Graph API go to:
        https://docs.microsoft.com/en-us/graph/api/resources/attachment?view=graph-rest-1.0

        https://docs.microsoft.com/en-us/graph/api/resources/fileattachment?view=graph-rest-1.0
        https://docs.microsoft.com/en-us/graph/api/resources/itemattachment?view=graph-rest-1.0
        https://docs.microsoft.com/en-us/graph/api/resources/referenceattachment?view=graph-rest-1.0

    .EXAMPLE
        PS C:\> New-JsonAttachmentObject

        Creates a json attachment object for use in Microsoft Graph REST api

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding(SupportsShouldProcess = $false, ConfirmImpact = 'Low', DefaultParameterSetName = 'FileAttachment')]
    [OutputType([String])]
    param (
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string]
        $Name,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [int32]
        $Size,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [bool]
        $IsInline,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string]
        $LastModifiedDateTime,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string]
        $ContentType,

        [Parameter(ParameterSetName = 'FileAttachment')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string]
        $contentBytes,

        [Parameter(ParameterSetName = 'FileAttachment')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string]
        $contentLocation,

        [Parameter(ParameterSetName = 'ItemAttachment')]
        [psobject]
        $Item,

        [Parameter(ParameterSetName = 'ReferenceAttachment')]
        [String]
        $SourceUrl,

        [Parameter(ParameterSetName = 'ReferenceAttachment')]
        [String]
        $ProviderType,

        [Parameter(ParameterSetName = 'ReferenceAttachment')]
        [String]
        $ThumbnailUrl,

        [Parameter(ParameterSetName = 'ReferenceAttachment')]
        [String]
        $PreviewUrl,

        [Parameter(ParameterSetName = 'ReferenceAttachment')]
        [String]
        $Permission,

        [Parameter(ParameterSetName = 'ReferenceAttachment')]
        [bool]
        $IsFolder,

        [String]
        $FunctionName
    )
    begin {
    }

    process {
        Write-PSFMessage -Level Debug -Message "Create attachment JSON object" -Tag "ParameterSetHandling"

        #region variable definition
        $boundParameters = @()
        $bodyHash = [ordered]@{}
        $variableNames = @("Name", "Size", "IsInline", "LastModifiedDateTime", "ContentType")
        switch ($PSCmdlet.ParameterSetName) {
            'FileAttachment' { $variableNames = $variableNames + @("contentBytes", "contentLocation") }
            'ItemAttachment' { $variableNames = $variableNames + @("item") }
            'ReferenceAttachment' { $variableNames = $variableNames + @("SourceUrl", "ProviderType", "ThumbnailUrl", "PreviewUrl", "Permission", "IsFolder") }
        }
        #endregion variable definition

        #region Parsing string and boolean parameters to json data parts
        Write-PSFMessage -Level VeryVerbose -Message "Parsing parameters to json data parts ($([string]::Join(", ", $variableNames)))" -Tag "ParameterParsing" -FunctionName $FunctionName

        $bodyHash.Add("@odata.type", """#microsoft.graph.$($PSCmdlet.ParameterSetName)""")

        foreach ($variableName in $variableNames) {
            if (Test-PSFParameterBinding -ParameterName $variableName) {
                $boundParameters = $boundParameters + $variableName
                Write-PSFMessage -Level Debug -Message "Parsing parameter $($variableName)" -Tag "ParameterParsing"
                $bodyHash.Add($variableName, ((Get-Variable $variableName -Scope 0).Value | ConvertTo-Json))
            }
        }
        #endregion Parsing string and boolean parameters to json data parts

        # Put parameters (JSON Parts) into a valid JSON-object together and output the result
        $bodyJSON = Merge-HashToJson $bodyHash
        $bodyJSON
    }

    end {
    }
}