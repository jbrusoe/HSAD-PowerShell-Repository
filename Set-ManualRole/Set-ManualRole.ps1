#Set-ManualRole.ps1
#Written by: Jeff Brusoe
#Last Updated: December 14, 2020
#
#The purpose of this file is to ensure that manual role
#accounts are added to the DUO MFA group. See issue 154.

[CmdletBinding()]
param ()

try {
	Set-HSCEnvironment -ErrorAction Stop
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try
{
	$MFAGroup = Get-ADGroup "HSC DUO MFA" -ErrorAction Stop
	Write-Output "MFA Group:"
	Write-Output $MFAGroup.DistinguishedName
}
catch
{
	Write-Warning "Unable to find MFA group"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$DomainCN = "DC=hs,DC=wvu-ad,DC=wvu,DC=edu"
$OrgUnits = @(
	"OU=Guests,",
	"OU=Guest Accounts,OU=HSC,",
	"OU=Vendors,"
	)

foreach ($OrgUnit in $OrgUnits)
{
	$OU = $OrgUnit + $DomainCN
	Write-Output "`n`nCurrent OU: $OU"

	try {
		$GetADUserParams = @{
			Filter = "*"
			SearchBase = $OU
			Properties = "MemberOf"
			ErrorAction = "Stop"
		}
		#$users = Get-ADUser -Filter * -SearchBase $OU -Properties MemberOf -ErrorAction Stop
		$ADUsers = Get-ADUser @GetADUserParams
	}
	catch {
		Write-Warning "Unable to generate AD user list"
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}

	foreach ($ADUser in $ADUsers)
	{
		Write-Output $("Current User: " + $ADUser.SamAccountName)

		$UserGroups = $ADUser.MemberOf

		if ($UserGroups -contains $MFAGroup.DistinguishedName) {
			Write-Output "User is already a member of the MFA Group"
		}
		else
		{
			try
			{
				$MFAGroup |
					Add-ADGroupMember -Members $ADUser.DistinguishedName -ErrorAction Stop

				Write-Output "Successfully added user to MFA Group"
			}
			catch {
				Write-Warning "Unable to add user to MFA group"
			}
		}

		Write-Output "****************"
	}
}

Invoke-HSCExitCommand -ErrorCount $Error.Count