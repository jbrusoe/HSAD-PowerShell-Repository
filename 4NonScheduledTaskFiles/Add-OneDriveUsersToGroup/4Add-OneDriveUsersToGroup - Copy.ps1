#--------------------------------------------------------------------------------------------------
#Add-OneDriveUsersToGroup.ps1
#
#Written by: Jeff Brusoe
#
#Last Modified by: Kevin Russell
#
#Last Modified: December 7, 2016
#
#Version: 1.2
#
#Purpose: Add OneDrive users to group
#
#--------------------------------------------------------------------------------------------------

<#
.SYNOPSIS
 	Add OneDrive users to group
    
.DESCRIPTION
 	Requires
	1. Connection to the HSC tenant (Get-MsolUser etc)
	2. Connectoin to Exchange online and PowerShell cmdlets
 	
.PARAMETER
	Paramter information.

.NOTES
	Author: Jeff Brusoe
    	Last Updated by: Kevin Russell
	Last Updated: December 7, 2016
#>


[CmdletBinding()]
param (
	[switch]$SessionTranscript = $true,
	[string]$PathToConnectionFile = "c:\ad-development\Connect-ToOffice365-MS1-Kevin.ps1",
	[string]$LogFilePath = "c:\ad-development\1Verify-BlockCredential\Logs",
	[string]$TenantName = "WVUHSC",
	[switch]$StopOnError = $false, #$true is used for testing purposes,
	[int]$DaysToKeepLogFiles = 7 #How far back to look for any password changes
	)


#Change PowerShell window title
$Host.UI.RawUI.WindowTitle = "Add-OneDriveUsersToGroup.ps1"


#Add references to file containing needed functions
. ..\5Misc-Functions.ps1
. ..\5Misc-Office365Functions.ps1


#./Connect-ToOffice365-MS1-Kevin.ps1


#Verify connection to the main campus tenant of Office 365-----------------------------
Write-ColorOutput -Message "Connecting to the WVUHSC tenant" -foregroundcolor Green
Test-CloudConnection -PathToConnectionFile $PathToConnectionFile -AttemptConnection:$true -Tenant $TenantName | Out-Null

$ConnectionCount = 0
[string]$TenantName = $null

while ($ConnectionCount -lt 10)
{
	#Serves as a delay before continuing
	$ConnectionCount++
	
	$TenantName = Get-TenantName
	
	if ($TenantName -ne $null)
	{
		"Tenant Name: " + $TenantName
		$ConnectionCount = 11
	}
	else
	{
		"Currently not connected..."
		"Connection Attempt: " + $ConnectionCount
		Start-Countdown -seconds 15 -message "Waiting for connection to be established"
	}
}
#End Verification Process---------------------------------------------------------------


$Error.Clear()


#test if connected to cloud.  stop progam if not----------------------------------------
$session = get-pssession | where {$_.ComputerName -eq "ps.outlook.com"}
if ($session -eq $null)
{
	Write-ColorOutput "You must connect to Office 365." -ForegroundColor "Red"
	exit
}
else
{
	Write-ColorOutput "Connected to Office 365." -ForegroundColor "Green"
}
#end test for cloud connection----------------------------------------------------------


#verify the log file directory exist----------------------------------------------------
if ([string]::IsNullOrEmpty($LogFilePath))
{
	Write-ColorOutput -Message "Log file path is null." -Color "Yellow"
	Write-ColorOutput -Message "Setting log path to c:\ad-development\Add-OneDriveUsersToGroup\Logs" -Color "Yellow"
	
	$LogFilePath = "c:\ad-development\Add-OneDriveUsersToGroup\Logs"
	
	if (!(Test-Path $LogFilePath))
	{
		New-Item $LogFilePath -type Directory -force
	}
	
	if ($Error.count -gt 0)
	{
		$Continue = Read-Host "There was an error creating the log file directory.  Continue (y/n)?"
		
		if ($Continue -ne "y")
		{
			exit
		}
	}
}
#end directory verification------------------------------------------------------------


while ($true)
{
	$GroupObjectID = "04ba5d1d-0a23-47b6-8cea-9f5d6a2a20ad"

	#Add to SharePoint Group
	#This is the file that has the users to add to the SharePoint group.
	$FilePath = "\\hs.wvu-ad.wvu.edu\public\ITS\Network and Voice Services\jbrusoe\Powershell\OneDriveUsers.txt"

	foreach ($user in get-content $FilePath)
	{
		$error.clear()
		
		echo $user
		$Date = get-Date
		
		Add-Content "C:\ad-development\AddOneDriveUsers-Output.txt" $user
		Add-Content "C:\ad-development\AddOneDriveUsers-Output.txt" $Date
		Add-Content "C:\ad-development\AddOneDriveUsers-Output.txt" "***************************"
		
		$usr = get-msoluser -searchstring $user -ea "SilentlyContinue"
        
        if ($usr.Count -eq 1)
        {
		    Add-MsolGroupMember -groupObjectid $GroupObjectID -GroupMemberType "User" -GroupMemberObjectId $usr.ObjectID -ea "SilentlyContinue"
        }
		
		if ((get-date).hour -eq 19 -AND (get-date).minute -eq 10)
		{
			./Connect-ToOffice365-MS1-Kevin.ps1
		}
		
		echo "***************************"
	}

	Start-Sleep -s 60
}