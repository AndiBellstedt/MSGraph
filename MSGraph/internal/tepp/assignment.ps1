<#
# Example:
Register-PSFTeppArgumentCompleter -Command Get-Alcohol -Parameter Type -Name MSGraph.alcohol
#>

Register-PSFTeppArgumentCompleter -Command Get-MgaMailFolder -Parameter "Name" -Name "MSGraph.Exchange.Mail.WellKnowFolders"
