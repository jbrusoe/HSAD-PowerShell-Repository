#Remove-HospitalHIPAATraining.ps1
#Written by: Jeff Brusoe
#Last Updated: May 24 2021
#
#The purpose of this file is to remove the hospital HIPAA training
#flag (extensionAttribute14) from users who no longer take this.

[CmdletBinding()]
param (
	[ValidateNotNullOrEmpty()]
	[string]$HospitalFilePath = $((Get-HSCGitHubRepoPath) +
									"2CommonFiles\" +
									"HospitalHIPAATraining\"),

	[int]$MaxRemoves = 50
)

try {
	Set-HSCEnvironment -ErrorAction Stop

	Write-Output "Hospital File Path: $HospitalFilePath"

	$GetHSCLastFileParams = @{
		DirectoryPath = $HospitalFilePath
		ErrorAction ="Stop"
	}

	$HospitalFile = Get-HSCLastFile @GetHSCLastFileParams

	Write-Output "Hospital File: $HospitalFile"
}
catch {
	Write-Warning "Unable to configure environment."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
	Write-Output "Generating list of WVUM User IDs."
	$WVUMUsers = Import-Csv $HospitalFile -ErrorAction Stop

	$WVUMUserIDs = $WVUMUsers."User Id"
}
catch {
	Write-Warning "Unable to open hospital file. Program is exiting."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
	Write-Output "Generating list of HSC AD Users"

	$GetADUserParams = @{
		Filter = "*"
		Properties = "extensionAttribute14"
		ErrorAction = "Stop"
	}

	$ADUsers = Get-ADUser @GetADUserParams |
		Where-Object {$_.extensionAttribute14 -eq "HospitalHIPAA"}

	Write-Output $("Hospital HIPAA Count: " +
						($ADUsers | Measure-Object).Count)
}
catch {
	Write-Warning "Unable to generate list of AD users"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$RemovedCount = 0
$NotRemovedCount = 0
$UserCount = 0

foreach ($ADUser in $ADUsers)
{
	$SamAccountName = $ADUser.SamAccountName

	$UserCount++
	Write-Output "User Count: $UserCount"

	Write-Output "SamAccountName: $SamAccountName"
	Write-Output "Distinguished Name:"
	Write-Output $ADUser.DistinguishedName

	if ($WVUMUserIDs -notcontains $SamAccountName) {
		Write-Output "extensionAttribute14 is being cleared."
		$RemovedCount++

		try {
			$ADUser |
				Set-ADUser -Clear extensionAttribute14 -ErrorAction Stop
		}
		catch {
			Write-Warning "Unable to clear extensionAttribute14"
		}
	}
	else {
		Write-Output "Hospital HIPAA is not being cleared"
		$NotRemovedCount++
	}

	Write-Output "***************************"

	if ($RemovedCount -gt $MaxRemoves) {
		break
	}
}

Write-Output "Removed: $RemovedCount"
Write-Output "Not Removed: $NotRemovedCount"

Invoke-HSCExitCommand -ErrorCount $Error.Count