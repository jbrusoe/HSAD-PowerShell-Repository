<#
	.SYNOPSIS
		This file sets extensionAttribute10 to be standard user for accounts in
		OUs such as NewUsers. See the SearchBaseArray to see a list of all OUs.

	.NOTES
		Author: Jeff Brusoe
		Last Updated: August 27, 2020
#>

[CmdletBinding()]
param ()

###############################
# Configure environment block #
###############################

try {
	Set-HSCEnvironment -ErrorAction Stop

	$TotalUserCount = 0
	$CurrentOUCount = 0
	$TotalSetCount = 0

	#Define OUs to search
	$SearchBaseArray = @(
		"OU=NewUsers,DC=hs,DC=wvu-ad,DC=WVU,DC=edu",
		"OU=Inactive Accounts,DC=hs,DC=wvu-ad,DC=WVU,DC=edu",
		"OU=Retirees,OU=hsc,DC=hs,DC=wvu-ad,DC=wvu,DC=edu",
		"OU=Guests,DC=hs,DC=wvu-ad,DC=WVU,DC=edu",
		"OU=WVUH Users,DC=HS,DC=wvu-ad,DC=wvu,DC=edu",
		"OU=DeletedAccounts,DC=HS,DC=wvu-ad,DC=wvu,DC=edu"
		)

	Write-Output "Search Base Array:"
	Write-Output $SearchBaseArray
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($SearchBase in $SearchBaseArray)
{
	Write-Output "Current Search Base: $SearchBase"
	$CurrentOUCount = 0

	try {
		$GetADUserParams = @{
			Filter = "*"
			SearchBase = $SearchBase
			Properties = "extensionAttribute10"
			ErrorAction = "Stop"
		}
		$NewUsers = Get-ADUser @GetADUserParams
	}
	catch {
		Write-Warning "Error generating list of users. Program is exiting."
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}

	foreach ($NewUser in $NewUsers)
	{
		Write-Output $("Current User: " + $NewUser.DistinguishedName)
		Write-Output $("SamAccountName: " + $NewUser.SamAccountName)
		Write-Output $("extensionAttribute10: " + $NewUser.extensionAttribute10)

		if (![string]::IsNullOrEmpty($NewUser.extensionAttribute10)) {
			Write-Output "extensionAttribute10 is already set."
		}
		else {
			Write-Output "extensionAttribute10 is null. Setting to StandardUser"
			$TotalSetCount++

			try
			{
				$NewUser |
					Set-ADUser -Add @{extensionAttribute10="StandardUser"} -ErrorAction Stop

					Write-Output "Successfully set extensionAttribute10"
			}
			catch {
				Write-Warning "Error setting extensionAttribute10"
			}
		}

		$TotalUserCount++
		Write-Output "User count: $TotalUserCount"

		$CurrentOUCount++
		Write-Output "Current OU User Count: $CurrentOUCount"

		Write-Output "Total Set Count: $TotalSetCount"
		Write-Output "*************************"
	}
}

Invoke-HSCExitCommand -ErrorCount $Error.Count