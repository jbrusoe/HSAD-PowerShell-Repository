#Set-MailContactCompanyField.ps1
#Written by: Jeff Brusoe
#Last Updated: January 26, 2021
#
#The purpose of this file is to set the mail contact company field for MSOL contacts.

[CmdletBinding()]
param (
	[string]$InvalidEmailFile = ("$PSScriptRoot\Logs\" +
								(Get-Date -format yyyy-MM-dd) +
								"-InvalidEmail.txt")
)

try {
	#Configure environment
	Set-HSCEnvironment -ErrorAction Stop
	Connect-HSCOffice365MSOL -ErrorAction Stop

	$CurrentUserCount = 1
	$CompanyAddCount = 0
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try
{
	Write-Output "Getting Msol Contacts"

	$MSOLContacts = Get-MsolContact -All -ErrorAction Stop
	Write-Output "Successfully generated list of Msol contacts"
}
catch {
	Write-Warning "Unable to get list of Msol users. Program is exiting."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output $("Total Number of MsolContacts: " + ($MSOLContacts | Measure-Object).Count)

foreach ($MSOLContact in $MSOLContacts)
{
	$EmailAddress = $MSOLContact.EmailAddress
	Write-Output "Current User: $EmailAddress"

	$CompanyName = $MSOLContact.CompanyName
	Write-Output "Company Name: $CompanyName"

	if (([string]::IsNullOrEmpty($CompanyName) -OR ($CompanyName -ne "WVU")) -AND
		($EmailAddress -like "*@mail.wvu.edu*" -OR $EmailAddress -like "*@wvu.edu*"))
	{
		try {
			Set-Contact -Identity $EmailAddress -Company "WVU" -ErrorAction Stop
			$CompanyAddCount++
		}
		catch {
			Write-Warning "Unable to configure contact company information"
		}
	}
	elseif (([string]::IsNullOrEmpty($CompanyName) -OR $CompanyName -ne "WVUF") -AND
			($EmailAddress -like "*wvuf.org"))
	{
		try {
			Set-Contact -Identity $EmailAddress -Company "WVUF" -ErrorAction Stop
		}
		catch {
			Write-Warning "Unable to configure WVUF contact information"
		}

	}
	elseif ($EmailAddress -notlike "*mail.wvu.edu*" -AND
			$EmailAddress -notlike "*wvuf.org*" -AND
			$EmailAddress -notlike "*@wvu.edu*")
	{
		#This is here to ensure that no @gmail.com etc. type of contacts.

		try {
			Add-Content $InvalidEmailFile -Value $EmailAddress -ErrorAction Stop
		}
		catch {
			Write-Warning "Unable to write content to file"
		}

	}

	Write-Output "Current User Count: $CurrentUserCount"
	$CurrentUserCount++

	Write-Output "Company Add Count: $CompanyAddCount"

	Write-Output "**********************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count