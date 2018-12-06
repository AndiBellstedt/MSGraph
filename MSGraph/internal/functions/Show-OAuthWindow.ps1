function Show-OAuthWindow {
    <#
    .SYNOPSIS
        Generates a OAuth window for interactive authentication.

    .DESCRIPTION
        Generates a OAuth window for interactive authentication.

    .PARAMETER Url
        The url to the service offering authentication.

    .EXAMPLE
        PS C:\> Show-OAuthWindow -Url $uri

        Opens an authentication window to authenticate against the service pointed at in $uri
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Uri]
        $Url
    )

    begin {
        $form = New-Object -TypeName System.Windows.Forms.Form -Property @{ Width = 440; Height = 640 }
        $web = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{ Width = 420; Height = 600; Url = ($url) }
        $docComp = {
            if ($web.Url.AbsoluteUri -match "error=[^&]*|code=[^&]*") { $form.Close() }
        }
        $web.ScriptErrorsSuppressed = $true
        $web.Add_DocumentCompleted($docComp)
        $form.Controls.Add($web)
        $form.Add_Shown( { $form.Activate() })
    }

    process {
        $null = $form.ShowDialog()
    }

    end {
        $queryOutput = [System.Web.HttpUtility]::ParseQueryString($web.Url.Query)
        $output = @{ }
        foreach ($key in $queryOutput.Keys) {
            $output["$key"] = $queryOutput[$key]
        }
        [pscustomobject]$output
    }
}