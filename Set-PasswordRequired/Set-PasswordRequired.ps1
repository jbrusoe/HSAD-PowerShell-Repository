<#
.SYNOPSIS
	This file ensures that all AD users have their passwordnotrequired attribute set to $false

.NOTES
	Last Modified by: Jeff Brusoe
	Last Modified: January 26, 2020
#>

try {
	Set-HSCEnvironment -ErrorAction Stop

	#This array just prevents cosmetic errors from showing in the output
	$ExclusionArray = "WVUH$","UHC$","CHI$","WVU-AD$","WVUHS$","HSAD$"
}
catch {
	Write=Warning "Unable to configure environment."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
	Write-Output "Generating list of AD users"

	$GetADUserParams = @{
		Filter = "{PasswordNotRequired -eq $true}"
		Properties = "PasswordNotRequired"
		ErrorAction = "Stop"
	}

	$ADUsers = Get-ADUser @GetADUserParams |
		Where-Object {$ExclusionArray -NotContains $_.SamAccountName}
}
catch {
	Write-Warning "There was an error generating the list of AD users"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

if (($ADUsers | Measure-Object).Count -eq 0) {
	Write-Output "All users have password required set"
}
else {
	try {
		$ADUsers | Set-HSCPasswordRequired -ErrorAction Stop
	}
	catch {
		Write-Warning "Unable to set password required."
	}
}

Invoke-HSCExitCommand -ErrorCount $Error.Count