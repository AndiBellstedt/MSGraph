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

    begin {}

    process {}

    end {
        # check screen resultion and calculate size for login form
        $screenResolution = Get-CimInstance -ClassName Win32_VideoController
        $formWidth = [math]::round(($screenResolution.CurrentHorizontalResolution / 4.36), 0)
        $formHeight = [math]::round(($screenResolution.CurrentVerticalResolution / 1.69), 0)
        if ($formWidth -lt 440) { $formWidth = 440 }
        if ($formHeight -lt 640) { $formHeight = 640 }

        # Create form object
        $form = New-Object -TypeName "System.Windows.Forms.Form" -Property @{
            Width  = $formWidth #440
            Height = $formHeight #640
        }

        # Create web browser object
        $web = New-Object -TypeName "System.Windows.Forms.WebBrowser" -Property @{
            Url                    = $Url
            ClientSize             = $form.ClientSize
            ScriptErrorsSuppressed = $true
        }

        #region Event actions
        # parse code or error message from URL, when Login is completed
        $web.Add_DocumentCompleted( {
                if ($web.Url.AbsoluteUri -match "error=[^&]*|code=[^&]*") { $form.Close() }
            } )

        # Things to do when form is opened/shown
        $form.Add_Shown( {
                $form.BringToFront()
                $null = $form.Focus()
                $form.Activate()
                $web.Navigate($Url)
                $form.Text = $web.DocumentTitle
            } )

        # make form resizeable
        $form.Add_Resize( {
                $web.ClientSize = $form.ClientSize
                $form.Text = $web.DocumentTitle
            } )
        #endregion Event actions

        # Add browser to windows form
        $form.Controls.Add($web)

        # Show form to the user
        $null = $form.ShowDialog()

        # Get result from uri (query string within the uri)
        $queryOutput = [System.Web.HttpUtility]::ParseQueryString($web.Url.Query)
        $output = @{}
        foreach ($key in $queryOutput.Keys) {
            $output["$key"] = $queryOutput[$key]
        }

        # output result
        [pscustomobject]$output
    }
}