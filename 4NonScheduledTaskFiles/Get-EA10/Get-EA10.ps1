#Get-EA10.ps1
#Written By: Jeff Brusoe
#Last Updated: December 18, 2020
#
#The purpose of this file is to backup the values in extensionAttribute10
#for all HS users.

[CmdletBinding()]
param()

try {
	Import-Module ActiveDirectory -ErrorAction Stop
	Set-HSCEnvironment -ErrorAction Stop

	$ValidEA10 = ("Resource","StandardUser","EPA","Clinic","Ruby","Terminated")
	$SearchBase = "DC=hs,DC=wvu-ad,DC=wvu,DC=edu"

	$Count = 0
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
	Write-Verbose "Generating output files"

	$UsersToCheck = "$PSScriptRoot\Logs\" +
	$((Get-Date -Format yyyy-MM-dd-HH-mm) +
	"-UsersToCheck.csv")

	$CompleteReport = "$PSScriptRoot\Logs\" +
		$((Get-Date -Format yyyy-MM-dd-HH-mm) +
		"-AllUsers.csv")

	New-Item -type File $UsersToCheck -Force -ErrorAction Stop
	New-Item -type File $CompleteReport -Force -ErrorAction Stop
}
catch {
	Write-Warning "Unable to generate output log files"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
	Write-Output "Generating list of AD Users"
	$ADUsers = Get-ADUser -Properties extensionAttribute10 -Filter * -SearchBase $SearchBase
}
catch {
	Write-Warning "Unable to generate list of AD Users"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($ADUser in $ADUsers)
{
	Write-Output $("Current SamAccountName: " + $ADUser.SamAccountName)
	Write-Output $("Current DN: " + $ADUser.DistinguishedName)
	Write-Output $("extensionAttribute10: " + $ADUser.extensionAttribute10)

	$ADUser |
		Select-Object SamAccountName,extensionAttribute10,DistinguishedName |
		Export-Csv $CompleteReport -Append -NoTypeInformation

	if ($ValidEA10 -contains $ADUser.extensionAttribute10) {
		Write-Output "Valid extensionAttribute10"
	}
	else {
		Write-Output "Invalid extensionAttribute10"
		$ADUser |
			Select-Object SamAccountName,extensionAttribute10,DistinguishedName |
			Export-Csv $UsersToCheck -Append
	}

	$Count++
	Write-Output "AD User count: $Count"
	Write-Output "********************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count