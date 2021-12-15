<#
	.SYNOPSIS
		The purpose of this file is to copy the primary SMTP address
		over to the mail attribute field in AD.

	.PARAMETER Testing
		Only used for testing purposes.

	.PARAMETER ChangeLog
		Log file to record any mail attribute changes that are made

	.NOTES
		Set-ADMailAttribute.ps1
		Last Modified by: Jeff Brusoe
		Last Modified: March 8, 2021
#>

[CmdletBinding()]
param (
	[switch]$Testing,

	[ValidateNotNullOrEmpty()]
	[string]$ChangeLog = ("$PSScriptRoot\Logs\" +
							(Get-Date -format yyyy-MM-dd-hh-mm-ss) +
							"-Set-ADMailAttribute-ChangeLog.txt")
)

#Configure Environment
try {
	Write-Verbose "Configuring Environment"

	Set-HSCEnvironment -ErrorAction Stop

	New-Item -type file -path $ChangeLog -Force -ErrorAction Stop
}
catch {
	Write-Warning "Unable to configure environment. Program is exiting"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try
{
	Write-Output "Generating list of all users."

	$Properties = @(
			"proxyAddresses",
			"mail")

	$ADUsers = Get-ADUser -Filter * -Properties $Properties -ErrorAction Stop

	Write-Output "Finished generating all user list.`n`n"
}
catch
{
	Write-Warning "Unable to generate AD user list. Program is exiting."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output "Beginning to loop through user array."

foreach ($ADUser in $ADUsers)
{
	Write-Output $("Current User: " + $ADUser.SamAccountName)

	[string]$PrimarySMTPAddress = $null
	$PrimarySMTPAddress = $ADUser.ProxyAddresses |
							Where-Object {$_ -clike "SMTP:*"}
	$PrimarySMTPAddress = $PrimarySMTPAddress -replace "SMTP:",""

	Write-Output "Primary SMTP Address: $PrimarySMTPAddress"
	Write-Output $("Current Mail Attribute: " + $ADUser.mail)

	if (![string]::IsNullOrEmpty($PrimarySMTPAddress))
	{
		if ($PrimarySMTPAddress.indexOf("@hsc.wvu.edu") -gt 0 -OR
			$PrimarySMTPAddress.indexOf("@wvumedicine.org") -gt 0)
		{
			if ((![string]::IsNullOrEmpty($ADUser.mail) -AND
					($PrimarySMTPAddress.toLower().Trim()) -eq $ADUser.mail.toLower().Trim())) {
				Write-Output "Primary SMTP address matches mail attribute."
			}
			else
			{
				Write-Output "Primary SMTP address does not match mail attribute."

				if ($Testing) {
					Read-Host "Press enter key to continue"
				}

				try
				{
					$OriginalMailAttribute = $ADUser.mail

					$ADUser | Set-ADUser -EmailAddress $PrimarySMTPAddress -ErrorAction Stop

					Write-Output "Successfully changed mail attribute"

					Add-Content -Value "Original Mail Attribute: $OriginalMailAttribute" -Path $ChangeLog
					Add-Content -Value "New Mail Attribute: $PrimarySMTPAddress" -Path $ChangeLog
					Add-Content -Value "Successfully changed attribute" -Path $ChangeLog
					Add-Content -Value "************************" -Path $ChangeLog
				}
				catch {
					Write-Warning "Error setting primary SMTP address"
				}
			}
		}
		else {
			Write-Output "Proxy address is null and is being skipped."
		}
	}

	Write-Output "**********************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count