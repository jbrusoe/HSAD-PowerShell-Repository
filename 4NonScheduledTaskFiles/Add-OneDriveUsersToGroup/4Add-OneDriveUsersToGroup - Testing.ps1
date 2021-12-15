#--------------------------------------------------------------------------------------------------
#4Add-OneDriveUsersToGroup.ps1
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
	[string]$LogFilePath = "c:\ad-development\4Add-OneDriveUsersToGroup\Logs",
	[string]$TenantName = "WVUHSC",
	[switch]$StopOnError = $false, #$true is used for testing purposes
	[int]$DaysToKeepLogFiles = 7 #How far back to look for any password changes
	)


#Change PowerShell window title
$Host.UI.RawUI.WindowTitle = "4Add-OneDriveUsersToGroup.ps1"


#Add references to file containing needed functions
. ..\5Misc-Functions.ps1
. ..\5Misc-Office365Functions.ps1


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


#Include Quest Tools--------------------------------------------------------------------
$Quest = Get-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"
if ($Quest -eq $null)
{
	Write-ColorOutput -Message "Adding Quest Tools" -ForegroundColor "Green"
	Add-PSSnapin Quest.ActiveRoles.ADManagement
	
	Start-Sleep -s 1	
}

$error.clear()

$Quest = Get-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"
if ($error.count -gt 0)
{
	Write-ColorOutput -Message "There was an error loading the Quest Cmdlets." -ForegroundColor "Red"
	exit
}
#End of code block ot test for quest----------------------------------------------------


#verify the log file directory exist----------------------------------------------------
if ([string]::IsNullOrEmpty($LogFilePath))
{
	Write-ColorOutput -Message "Log file path is null." -Color "Yellow"
	Write-ColorOutput -Message "Setting log path to c:\ad-development\4Add-OneDriveUsersToGroup\Logs" -Color "Yellow"
	
	$LogFilePath = "c:\ad-development\4Add-OneDriveUsersToGroup\Logs"
	
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


#clean up old log files
Write-Verbose "Removing old log files...."
Remove-OldLogFiles -Days $DaysToKeepLogFiles -Path $LogFilePath


#Declare common and file specific variables and create/write to logfiles------------------
if ($TenantName -eq "WVUHSC")
{

	#Common variable declarations	
	$TranscriptLogFile = $LogFilePath + "\" + (Get-FileDatePrefix) +  "-Add-OneDriveUsersToGroup-SessionOutput.txt"
	$ErrorLogFile = $LogFilePath + "\" + (Get-FileDatePrefix) +  "-Add-OneDriveUsersToGroup-ErrorLog.txt"
	
	#File specific variable declarations	
	
	New-Item $ErrorLogFile -type file -force
		
	Write-LogFileSummaryInformation -FilePath $ErrorLogFile -Summary "4Add-OneDriveUsersToGroup error log"	
#End common and file specific variable declarations---------------------------------------


#Check to see if session transcript is running and start----------------------------------	
	if ($SessionTranscript)
	{
		try
		{
		Stop-Transcript -ea "Stop"
		}
		catch
		{
		
		}
				
		"TranscriptLogFile: " + $TranscriptLogFile
		
		Start-Transcript -path $TranscriptLogFile -Force
		
		"Transcript log file started"
	}
#End session transcript------------------------------------------------------------------------	
	
	
$Error.Clear()
	

while ($true)
{
	if ($Error.Count -gt 0)
		{
			Write-Verbose $("Error Count: " + $Error.Count)
			
			for ($i = 0; $i -lt $Error.Count ; $i++)
			{
			Add-Content -path $ErrorLogFile -value $Error($i).InvocationInfo.Line
			Add-Content -path $ErrorLogFile -value $Error($i).InvocationInfo.PositionMessage
			Add-Content -path $ErrorLogFile -value "********************************"
			}
		}
		
		if ($StopOnError)
		{
			Write-Verbose "Stopping due to error."
			
			Return
		}

	$GroupObjectID = "04ba5d1d-0a23-47b6-8cea-9f5d6a2a20ad"

	#Add to SharePoint Group
	#This is the file that has the users to add to the SharePoint group.
	$FilePath = "\\hs.wvu-ad.wvu.edu\public\ITS\Network and Voice Services\jbrusoe\Powershell\OneDriveUsers.txt"

	foreach ($user in get-content $FilePath)
	{
		$error.clear()
		
		echo $user
		$Date = get-Date
		
		Add-Content "C:\AD-Development\4Add-OneDriveUsersToGroup\Logs\4Add-OneDriveUsersToGroup-Output.txt" $user
		Add-Content "C:\AD-Development\4Add-OneDriveUsersToGroup\Logs\4Add-OneDriveUsersToGroup-Output.txt" $Date
		Add-Content "C:\AD-Development\4Add-OneDriveUsersToGroup\Logs\4Add-OneDriveUsersToGroup-Output.txt" "***************************"
		
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

if ($SessionTranscript)
	{
		"TranscriptLogFile: " + $TranscriptLogFile
		
		Stop-Transcript 
		
		"Transcript log file stoped"
	}