
Register-PSFTeppScriptblock -Name "MSGraph.Exchange.Mail.WellKnowFolders" -ScriptBlock { [enum]::GetNames([MSGraph.Exchange.Mail.WellKnownFolder]) | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase( $_ ) } }
