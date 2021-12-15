<#
	.SYNOPSIS
		This file adds the SIP addresses for main campus email accounts
		to the contacts in the HSC Office 365 tenant.

	.DESCRIPTION
		The file which exports main campus mailbox information also pulls the SIP
		addresses. The purpose of this file is to read in the SIP addresses and add them to
		the corresponding contact information in the HSC address book.

	.NOTES
		Author: Jeff Brusoe
		Last Updated: January 27, 2021
#>

[CmdletBinding()]
param (
	[string]$ImportFile = $null
)

try {
	Set-HSCEnvironment -ErrorAction Stop
	Connect-HSCExchangeOnline -ErrorAction Stop

	Write-Output "Determining import file"
	$ImportDirectory = (Get-Item $PSScriptRoot).Parent.FullName
	$ImportDirectory = $ImportDirectory + "\Get-MainCampusMailbox\Logs\"

	$ImportFile = $ImportDirectory +
					(Get-Date -format yyyy-MM-dd) +
					"-05-00-SIP-MC.csv"
	Write-Output "Import File: $ImportFile"

	if (Test-Path $ImportFile) {
		Write-Output "Import file exists"
	}
	else {
		Write-Output "Import file does not exist"
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}

	#Configure Log Files
	$FoundSIPFile = "$PSScriptRoot\Logs\" +
					(Get-Date -format yyyy-MM-dd) +
					"-FoundSIP.txt"
	New-Item $FoundSIPFile -Force -ErrorAction Stop

	$NotFoundSIPFile = "$PSScriptRoot\Logs\" +
						(Get-Date -format yyyy-MM-dd) +
						"-SIPNotFound.txt"
	New-Item $NotFoundSIPFile -Force -ErrorAction Stop

	$UserNotFoundFile = "$PSScriptRoot\Logs\" +
						(Get-Date -format yyyy-MM-dd) +
						"-SIP-UserNotFound.txt"
	New-Item $UserNotFoundFile -Force -ErrorAction Stop

	$FoundSIPCount = 0
	$NotFoundSIPCount = 0
	$UserCount = 0
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
	Write-Output "Opening main campus SIP file"
	$MCUsers = Import-Csv $ImportFile -ErrorAction "Stop"
}
catch {
	Write-Warning "Unable to open import file"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($MCUser in $MCUsers)
{
	Write-Output "Current User Number: $UserCount"
	$UserCount++

	$PrimarySMTPAddress = $MCUser.PrimarySMTPAddress.Trim()
	$SIPAddress = $MCUser.SIPAddress.Trim()
	$Alias = $MCUser.Alias.Trim()

	Write-Output "PrimarySMTPAddress: $PrimarySMTPAddress"
	Write-Output "SIP Address: $SIPAddress"
	Write-Output "Alias: $Alias"

	if ($SIPAddress -like "*westvirginiauniversity.onmicrosoft.com") {
		#These types of addresses shouldn't be imported.
		"Bad SIP Address - will not be addded"
	}
	else
	{
		try {
			$MCMailContact = Get-MailContact -Identity $PrimarySMTPAddress -ErrorAction Stop
		}
		catch {
			Write-Warning "Unable to find mail contact"
		}

		if ($null -ne $MCMailContact)
		{
			#Continue cleaning code from here
			$EmailAddresses = $MCMailContact.EmailAddresses

			$SIPFound = $false

			foreach ($EmailAddress in $EmailAddresses)
			{
				Write-Output "Current Email Address: $EmailAddress"
				if ($EmailAddress.toLower() -eq $SIPAddress.toLower()) {
					$SIPFound = $true
					break
				}
			}

			if ($SIPFound)
			{
				Write-Output "SIP already present"
				$FoundSIPCount++

				Add-Content $FoundSIPFile -Value $PrimarySMTPAddress
				Add-Content $FoundSIPFile -Value $SIPAddress
				Add-Content $FoundSIPFile -Value "**********************************"
			}
			else
			{
				Write-Output "SIP not present"
				$NotFoundSIPCount++

				try {
					Set-MailContact -Identity $PrimarySMTPAddress -EmailAddress @{Add=$SIPAddress} -ErrorAction Stop
					Write-Output "Successfully set SIP address"
				}
				catch {
					Write-Warning "Unable to add SIP Address"
				}

				Add-Content $NotFoundSIPFile -Value $PrimarySMTPAddress
				Add-Content $NotFoundSIPFile -Value $SIPAddress
				Add-Content $NotFoundSIPFile -Value "**********************************"
			}

		}
		else
		{
			Write-Output "Unable to find mail contact"
			Add-Content -Path $UserNotFoundFile -Value $PrimarySMTPAddress
			Add-Content $UserNotFoundFile -Value "**********************************"
		}
	}

	Write-Output "Found SIP Count: $FoundSIPCount"
	Write-Output "Not Found SIP Count: $NotFoundSIPCount"

	Write-Output "*********************************************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count