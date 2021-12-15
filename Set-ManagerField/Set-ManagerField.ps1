<#
	.SYNOPSIS
		Sets the AD manager field

	.DESCRIPTION
		This file looks at extensionAttribute4 which is the employee
		number of the AD users's manager. If a match is found, the
		manager field is populated.

		extensionAttribute4 -> Manager's EmployeeNumber
		EmployeeNumber _> Users's EmployeeNumber

	.NOTES
		Set-ManagerField.ps1
		Last Modified by: Jeff Brusoe
		Last Modified: December 14, 2020
#>

[CmdletBinding()]
param (
	[switch]$Testing,
	[int]$TestDelay = 2
	)

try {
	Set-HSCEnvironment -ErrorAction Stop
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output "Generating list of AD users"
try
{
	$Properties = @("extensionAttribute4","EmployeeNumber")
	$ADUsers = Get-ADUser -filter * -Properties $Properties -ErrorAction Stop |
		Where-Object {$_.extensionAttribute4 -ne $null}
}
catch
{
	Write-Warning "Unable to generate AD user list. Program is exiting."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$ManagerFoundCount = 0
$ManagerNotFoundCount = 0
$TotalCount = 0

foreach ($ADUser in $ADUsers)
{
	Write-Output $("SamAccountName: " + $ADUser.SamAccountName)
	Write-Output $("EmployeeNumber: " + $ADUser.EmployeeNumber)
	Write-Output $("extensionAttribute4: " + $ADUser.extensionAttribute4)

	$Manager = $ADUsers |
		Where-Object {$ADUser.extensionAttribute4 -eq $_.EmployeeNumber}

	if (($Manager | Measure-Object).Count -gt 1) {
		#This is a safety measure to make sure one unique value is returned
		Write-Warning "Unable to find one unique value for the manager field."
	}
	elseif ($null -eq $Manager) {
		Write-Output "Unable to find manager"
		$ManagerNotFoundCount++
	}
	else
	{
		Write-Output $("Manager: " + $Manager.SamAccountName)
		$ManagerFoundCount++

		if ($Testing) {
			#Short delay for testing purposes
			Start-Sleep -s $TestDelay
		}

		try
		{
			$ADUser | Set-ADUser -Manager $Manager -ErrorAction Stop
			Write-Output "Successfully set manager field"
		}
		catch
		{
			Write-Warning "Error setting manager field"
			$Error | Format-List

			if ($Testing) {
				Write-Warning "Program is exiting."
				Invoke-HSCExitCommand -ErrorCount $Error.Count
			}
		}
	}

	$TotalCount++

	Write-Output "Manager Found Count: $ManagerFoundCount"
	Write-Output "Manager Not Found Count: $ManagerNotFoundCount"
	Write-Output "Total Count: $TotalCount"

	Write-Output "**************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count