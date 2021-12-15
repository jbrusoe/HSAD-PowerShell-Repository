#Remove-OldAccount.ps1
#Written by: Jeff Brusoe
#Last Updated: January 29, 2020
#
#Note: This file is not designed to be run as a scheduled task. It should only be run manually.

$ADUsers = Get-ADuser -Filter * -Properties extensionAttribute1,PasswordLastSet,extensionAttribute10,extensionAttribute7 -SearchBase "OU=HSC,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU" | where {($_.PasswordLastSet) -AND ([datetime]$_.PasswordLastSet -lt (Get-Date).AddDays(-365)) -AND ($_.extensionAttribute10 -eq "StandardUser")}

$UserCount = 0
$TargetOU = "OU=DisabledDueToInactivity2,OU=Inactive Accounts,DC=HS,DC=wvu-ad,DC=wvu,DC=edu"

foreach ($ADUser in $ADUsers)
{
	Write-Output $("SamAccountName: " + $ADUser.SamAccountName)
	Write-Output $("PasswordLastSet: " + $ADUser.PasswordLastSet)
	Write-Output $("Enabled: " + $ADUser.Enabled)
	Write-Output $("extensionAttribute1: " + $ADUser.extensionAttribute1)
	Write-Output $("extensionAttribute7: " + $ADUser.extensionAttribute7)
	Write-Output $("extensionAttribute10: " + $ADUser.extensionAttribute10)
	Write-Output $("Distinguished Name: " + $ADUser.DistinguishedName)
	
	if ([string]::IsNullOrEmpty($ADUser.extensionAttribute1 ) -OR [datetime]$ADUser.extensionAttribute1 -gt (Get-Date))
	{
		$UserCount++
		Write-Output "User Count: $UserCount"
	
		$MoveUser = Read-Host "Move User:"
		if ($MoveUser -eq "y")
		{
			$ADUser | Disable-ADAccount
			Start-Sleep -s 2
			$ADUser | Move-ADObject -TargetPath $TargetOU
		}
		else
		{
			$DisableUser = Read-Host "Disable User"
			if ($DisableUser -eq "y")
			{
				$ADUser | Disable-ADAccount
			}
			
			$ResourceAccount = Read-Host "Resource"
			if ($ResourceAccount -eq "y")
			{
				$ADUser | Set-ADUser -Replace @{extensionAttribute10 = "Resource"}
			}
			
			$ProxyAccount = Read-Host "Proxy"
			if ($ProxyAccount -eq "y")
			{
				$ADUser | Set-ADUser -Replace @{extensionAttribute10 = "Proxy"}
			}
			
			$Unsure = Read-Host "Unsure"
			if ($Unsure -eq "y")
			{
				$ADUser | Set-ADUser -Replace @{extensionAttribute10 = "Unsure"}
			}
		}
		
		if ($UserCount -eq 10)
		{
			return
		}
	}
	else
	{
		Write-Output "Skipping Users"
	}

	Write-Output "****************"
}