#Filename: Backup-HSGPO.ps1
#Version: 1.2
#
#Written By: Kim Rodney
#Date: June 6, 2016
#Email: krodney@hsc.wvu.edu
#
#Updated by: Jeff Brusoe
#Updated on: July 28, 2021
#This file is designed to backup the GPOs in the HS domain.

[CmdletBinding()]
param (
	[ValidateNotNullOrEmpty()]
	[string]$OutputPath = "\\hs.wvu-ad.wvu.edu\public\ITS\" +
							"Network and Voice Services\public\Backups\GPO Backups\",

	[ValidateNotNullOrEmpty()]
	[string]$GitHubBackupPath = (Split-Path (Get-HSCGitHubRepoPath) -Parent) +
								"\BackupGPO\",

	[int]$TotalGPOs #This parameter is used for testing purpose
)

try {
	Write-Output "Configuring Environtment"

	Import-Module GroupPolicy -ErrorAction Stop

	Set-HSCEnvironment -ErrorAction Stop

	$DateString = Get-Date -Format yyyy-MM-dd-HH-mm
	$BackupPath = "$OutputPath\$DateString\"
	New-Item -Path $BackupPath -ItemType directory -ErrorAction Stop

	Write-Output "GitHub Backup Path: $GitHubBackupPath"
	if (!(Test-Path $GitHubBackupPath)) {
		Write-Warning "GitHub Backup Path doesn't exist"
		throw
	}

	if (!(Test-Path $OutputPath)) {
		Write-Warning "Output Path doesn't exist"
		throw
	}
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try
{
	Write-Output "Generating GPO List"
	$GPOs = Get-GPO -ALL -ErrorAction Stop

	if ($PSBoundParameters.ContainsKey('TotalGPOs')) {
		$GPOs = Get-GPO -All -ErrorAction Stop | Select-Object -First $TotalGPOs
	}
}
catch {
	Write-Warning "There was an error generating the list of GPOs."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output "Performing GPO Backup"
$GPOCount = 1
foreach ($GPO in $GPOs)
{
	Write-Output $("Current GPO: " + $GPO.DisplayName)
	Write-Output "GPO Count: $GPOCount"
	$GPOCount++

	try {
		$GPO | Backup-GPO -Path $BackupPath -ErrorAction Stop
	}
	catch {
		Write-Warning "There was an error backing up the GPO."
	}

	Write-Output "********************************"
}

Write-Output "Copying GPO Backups to GitHub"
Copy-Item -Path $BackupPath -Destination $GitHubBackupPath -Verbose -Recurse

Invoke-HSCExitCommand -ErrorCount $Error.Count