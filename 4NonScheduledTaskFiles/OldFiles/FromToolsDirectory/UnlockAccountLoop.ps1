#--------------------------------------------------------------------------------------------------
#UnlockAccountLoop.ps1
#
#Written by: Matt Logue
#
#Last Modified by: Kevin Russell
#
#Last Modified date: 8/30/18
#
#Version: 1
#
#Purpose: This script is a loop that checks to see if an account is locked, and if it is locked
#         it will unlock the account and wait a specified time and check again.  Default is 5
#         minutes.  Its only used when a users account keeps locking out and research needs to be
#         done to figure out what device keeps locking them out.
#
#         format like .\UnlockAccountLoop.ps1 krussell
#
#--------------------------------------------------------------------------------------------------

[CmdletBinding()]
param (
[Parameter(Position=0)][string]$user = $(Throw "You must pass in a username"),
[int32]$Delay = 15,
[int32]$CheckLockInterval = 300
)

#Change PowerShell window title
$Host.UI.RawUI.WindowTitle = "UnlockAccountLoop for $user"

$i = 1;

#start loop
while ($i -ne 0) 
{
	$dateTime = Get-Date -Format g
	$lockout = Get-ADUser $user -Properties * | Select-Object LockedOut
        
    	
	if ($lockout.LockedOut -eq $true) 
	{        
		Write-Output $("Account Locked " + $dateTime) | Add-Content $user-lock.txt
		Unlock-ADAccount $user
		Write-Output $("Unlocked account" + $dateTime) | Add-Content $user-lock.txt
		Start-Sleep $Delay
	}
	
	#convert seconds to minutes
	$TimeInMinutes = $CheckLockInterval / 60
	
	Write-Output $("Account Not Locked. Waiting for $TimeInMinutes minutes - " + $dateTime) | Add-Content $user-lock.txt
	Start-Sleep $CheckLockInterval
	$i++	
}