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

    process {
        $web = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{
            Width  = 420
            Height = 600
            Url    = $Url
        }
        $web.ScriptErrorsSuppressed = $true
        $web.Add_DocumentCompleted( {
                if ($web.Url.AbsoluteUri -match "error=[^&]*|code=[^&]*") { $form.Close() }
            })

        $form = New-Object -TypeName System.Windows.Forms.Form -Property @{
            Width  = 440
            Height = 640
        }
        $form.Controls.Add($web)
        $form.Add_Shown( {
                $form.BringToFront()
                $null = $form.Focus()
                $form.Activate()
                $web.Navigate($Url)
            })

        $null = $form.ShowDialog()

        $queryOutput = [System.Web.HttpUtility]::ParseQueryString($web.Url.Query)
        $output = @{}
        foreach ($key in $queryOutput.Keys) {
            $output["$key"] = $queryOutput[$key]
        }
        [pscustomobject]$output
    }
}