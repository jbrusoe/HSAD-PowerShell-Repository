<#
	.SYNOPSIS
		This file generates a log of WVUM Ids (extension13) so that they can be imported
		to HSC users.

	.NOTES
		Author: Jeff Brusoe
		Last Updated: August 27, 2020
#>

[CmdletBinding()]
param (
	[string[]]$Domains = @("wvuh.wvuhs.com","wvuhs.com")
)

$Error.Clear()

try {
	Set-HSCEnvironment
	Import-Module ActiveDirectory
}
catch {
	Write-Warning "Unable to load required modules. Program is exiting."
	Invoke-HSCExitCommand
}

foreach ($Domain in $Domains)
{
	Write-Output "`n`nCurrent Donain: $Domain"

	$OutputFile = "$PSScriptRoot\Logs\" + (Get-Date -format yyyy-MM-dd-HH-mm) + "-$Domain-Ext13.csv"
	New-Item $OutputFile -type file -Force | Out-Null

	Write-Output "Output File: $OutputFile"
	Write-Output "`nGenerating list of users"

	try
	{
		Get-ADUser -Filter * -Server $Domain -Properties extensionAttribute13,Department,Title -ErrorAction Stop |
			Select-Object SamAccountName,Department,Title,Name,extensionAttribute13 | Export-Csv $OutputFile
	}
	catch
	{
		Write-Warning "Unable to generate list of AD users from $Domain"
	}
}

Write-Output "Files have been generated."

Invoke-HSCExitCommand -ErrorCount $Error.Count