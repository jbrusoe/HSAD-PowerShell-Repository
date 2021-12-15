<#
	.SYNOPSIS
		This file ensures that all AD users have passwords set to be required.

	.NOTES
		Last Modified by: Jeff Brusoe
		Last Modified: December 14, 2020
#>

[CmdletBinding()]
param ()

Import-Module ActiveDirectory

Set-HSCEnvironment

Write-Output "`nLog File Paths:"
$NullExt10File = "$PSScriptRoot\Logs\" +
					(Get-Date -Format yyyy-MM-dd-HH-mm) +
					"-NullExt10.csv"
Write-Output "Null Ext10 File: $NullExt10File"

$PasswordNeverExpiresFile = "$PSScriptRoot\Logs\" +
								(Get-Date -Format yyyy-MM-dd-HH-mm) +
								"-PasswordNeverExpires.csv"
Write-Output "Password Never Expires File: $PasswordNeverExpiresFile"

$AlreadySetFile = "$PSScriptRoot\Logs\" +
					(Get-Date -Format yyyy-MM-dd-HH-mm) +
					"-AlreadySet.csv"
Write-Output "Already Set File: $AlreadySetFile"

$ErrorLogFile = "$PSScriptRoot\Logs\" +
					(Get-Date -Format yyyy-MM-dd-HH-mm) +
					"-ErrorLogFile.csv"
Write-Output "Error Log File: $ErrorLogFile"

try {
	Write-Output "`nGenerating list of AD users"

	$ADUsers = Get-ADUser -Filter * -Properties extensionAttribute10,PasswordNeverExpires |
		Where-Object {($_.extensionAttribute10 -ne "Resource") -AND
						($_.extensionAttribute10 -ne "EPA")}
}
catch {
	Write-Warning "Unable to generate list of AD users. Program is exiting."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output "`nLooping through AD users"
Write-Output "--------------------------------------`n"

$AlreadySetCount = 0
$NotSetCount = 0

$Properties = @(
			"SamAccountName",
			"extensionAttribute10",
			"PasswordNeverexpires",
			"DistinguishedName"
		)

foreach ($ADUser in $ADUsers)
{
	Write-Output $("Current User: " + $ADUser.SamAccountName)
	Write-Output $("extensionAttribute10: " + $ADUser.extensionAttribute10)
	Write-Output $("Password Never Expires: " + $ADUser.PasswordNeverExpires)
	Write-Output $("Distinguished Name: " + $ADUser.DistinguishedName + "`n")

	if ([string]::IsNullOrEmpty($ADUser.extensionAttribute10))
	{
		Write-Output "extensionAttribute10 is null"

		$ADUser |
			Select-Object -Property $Properties |
			Export-Csv $NullExt10File -Append
	}
	else
	{
		Write-Output "extensionAttribute10 is not null"

		if ($ADUser.PasswordNeverExpires)
		{
			Write-Output "Password Never Expires is true... Setting to false"

			$ADUser |
				Select-Object -Property $Properties |
				Export-Csv $PasswordNeverExpiresFile -Append

			try
			{
				Write-Output "Setting password never expires to false"
				$ADUser | Set-ADUser -PasswordNeverExpires $false -ErrorAction Stop
				Write-Output "Successfully set password never expires"
			}
			catch
			{
				Write-Warning "There was an error setting password never expires"
				$ADUser |
					Select-Object -Property $Properties |
					Export-Csv $ErrorLogFile -Append
			}

			$NotSetCount++
		}
		else
		{
			Write-Output "Password never expires is already set to false."
			$ADUser |
				Select-Object -Property $Properties |
				Export-Csv $AlreadySetFile -Append
			$AlreadySetCount++
		}
	}

	Write-Output "`nAlready Set Count: $AlreadySetCount"
	Write-Output "Changed Count: $NotSetCount"
	Write-Output "**********************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count