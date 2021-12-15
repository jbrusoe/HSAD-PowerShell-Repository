#--------------------------------------------------------------------------------------------------
#
#  File:  5Cleanup-ADAccounts.ps1
#
#  Author:  Jeff Brusoe
#
#  Last Update: September 21, 2017
#
#  Version:  2.0
#
#  Description: This file performs various maintenance tasks on Active Directory accounts. These include:
#		1. Disable all users in NewUsers (including NewUsers-OLD)
#		2. Disable all users in InActiveAccounts
#		3. Move accounts older than 30 days from NewUsers to NewUsers-OLD
#		4. Move accounts older than 60 days from NewUsers to DeletedAccounts\FromNewUsers
#
#  Note: A connection to the cloud is not required.
#--------------------------------------------------------------------------------------------------

<#
.SYNOPSIS
 	This file looks at all accounts that have had their passwords changed in the last 7 days. For these accounts,
	it sets the BlockCredential attribute of the MSOL User object to false.
    
.DESCRIPTION
 	Requires
	1. Active Directory Cmdlets
	2. Access to C:\AD-Development\5Misc-ActiveDirectoryFunctions.ps1
    3. Access to C:\AD-Development\5Misc-Functions.ps1

.PARAMETER
	Paramter information.

.NOTES
	Author: Jeff Brusoe
    	Last Updated by: Matt Logue
		Last Updated: September 21, 2017
#>

[CmdletBinding()]
param (
	[switch]$SessionTranscript = $true,
	[switch]$StopOnError = $true, #$true is used for testing purposes. For normal use, this should be false.
	[switch]$InactiveAccount = $true, #Search inactive accounts
	[switch]$SearchNewUsers = $true, #Search new users
	[string]$LogFileDirectory = "c:\AD-Development\Misc-AccountCleanUp\Logs",
    [int]$DaysToKeepLogFiles = 15 #this value used to clean old log files

)

Set-StrictMode -Version Latest

#Initialization section
cls
$Error.Clear()

#Add references to file containing needed functions
. ..\5Misc-ActiveDirectoryFunctions.ps1
. ..\5Misc-Functions.ps1

#Change PowerShell window title
$Host.UI.RawUI.WindowTitle = "5Cleanup-ADAccount.ps1"

#verify the log file directory exist----------------------------------------------------
if ([string]::IsNullOrEmpty($LogFilePath))
{
	Write-ColorOutput -Message "Log file path is null." -Color "Yellow"
	Write-ColorOutput -Message "Setting log path to c:\ad-development\1Verify-BlockCredential\Logs" -Color "Yellow"
	
	$LogFilePath = "c:\ad-development\Misc-AccountCleanUp\Logs"
	
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


#Common variable declarations	
$TranscriptLogFile = $LogFilePath + "\" + (Get-FileDatePrefix) +  "-ADAccountCleanup-SessionOutput.txt"
$ErrorLogFile = $LogFilePath + "\" + (Get-FileDatePrefix) +  "-ADAccountCleanup-ErrorLog.txt"
	
#initaling logfile information
if (!(test-path $ErrorLogFile))
{
	New-Item $ErrorLogFile -type file -force
	Write-LogFileSummaryInformation -FilePath $ErrorLogFile -Summary "5Cleanup-ADAccount error log"
}
	
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
	
$Error.Clear()
	


#################################
#         MAIN PROGRAM          #
#################################



$InactiveUserCount = 0
$EnabledUserCount = 0
$Yes365Count = 0



if ($InactiveAccount)
{
	Write-ColorOutput -Message "Beginning to scan Inactive Accounts"

	$InactiveUsers = Get-ADUser -SearchBase "OU=Inactive Accounts,DC=HS,DC=wvu-ad,DC=wvu,DC=edu" -Properties extensionAttribute7,extensionAttribute1,Enabled -Filter *

	foreach ($InactiveUser in $InactiveUsers)
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

		if ($DoNotDisable -contains $InactiveUser.SamAccountName)
		{
			#This should never be executed, but is here as a safetey measure.
			Write-ColorOutput -Message "Skipping this user" -ForegroundColor "Yellow"
		}
		elseif ($InactiveUser.DistinguishedName.indexOf("Inactive Accounts") -gt 0)
		{
			$InactiveUserCount++
			$InactiveUser.DistinguishedName
			Write-Output "extensionAttribute7: $($InactiveUser.extensionAttribute7)"

			if ($InactiveUser.Enabled)
			{
				$EnabledUserCount++
				"Disabling User"
				$InactiveUser | Disable-Account -Whatif
			}

			#Set extensionAttribute7
			if ($InactiveUser.extensionAttribute7 -ne "No365")
			{ 
				Write-Output "extensionAttribute7: $($InactiveUser.extensionAttribute7)"
				Write-ColorOutput -Message "Setting extensionAttribute7 to No365" -ForegroundColor "Green"

				$InactiveUser | Set-ADuser -replace @{extensionAttribute7 = "No365"} -WhatIf

				$Yes365Count++
			}

			$ExpirationDate = (Get-Date)

			"Account Expires: " + $InactiveUser.AccountExpires
			"Ext1: " + $InactiveUser.extensionAttribute1

			if ( ($InactiveUser.AccountExpires -eq 0) -or ($InactiveUser.AccountExpires -gt [DateTime]::MaxValue.Ticks) )
			{
				#Need to set account expiration date

				if ($InactiveUser.extensionAttribute1 -ne $null)
				{
					[datetime]$EAD = $InactiveUser.extensionAttribute1

					if ($EAD -lt (get-date))
					{
						$ExpirationDate = $EAD
						$ExpirationDate
					}
					else
					{
						$ExpirationDate
					}
				}
				else
				{
					#Ext1 is null
					$ExpirationDate

				}

                
				$InactiveUser | Set-ADuser -AccountExpirationDate $ExpirationDate -WhatIf
                Write-Output "Expiration Date set for user: $($InactiveUser.SamAccountName)"
			}
			else
			{
				$AccExp = [datetime]$InactiveUser.AccountExpires

				if ($AccExp -gt (get-date))
				{
					#Debugging code. Program should never reach here.
                    Add-Content -path $ErrorLogFile -value "ERROR: Expiration date for $InactiveUser is in the future"
					Return
				}
			}

			#If necessary, delete accounts
			[datetime]$EAD = [datetime]::MinValue
			[datetime]$AccExp = [datetime]::MinValue

			$DeleteAccount = $false

			if ($InactiveUser.extensionAttribute1 -ne $null)
			{
				$EAD = $InactiveUser.extensionAttribute1	
			}

			if ($InactiveUser.AccountExpires -ne $null)
			{
				$AccExp = $InactiveUser.AccountExpires
			}

			if ($EAD -eq [datetime]::MinValue -AND $AccExp -eq [datetime]::MinValue)
			{
				#This should hopefully never happen
                Add-Content -path $ErrorLogFile -value "ERROR: End Access Date or Account expiration date not accurate for $InactiveUser"
				Return
			}
			elseif ($EAD -eq [datetime]::MinValue)
			{
				if ($AccExp -lt (Get-Date).AddDays(-365))
				{
					$DeleteAccount = $true
				}
			}
			elseif ($AccExp -eq [datetime]::MinValue)
			{
				if ($AccExp -lt (Get-Date).AddDays(-365))
				{
					$DeleteAccount = $true
				}
			}
			else
			{
				#non null values for $AccExp and $EAD

				if ($EAD -gt $AccExp)
				{
					if ($AccExp -lt (Get-Date).AddDays(-365))
					{
						$DeleteAccount = $true
					}
				}
				else
				{
					if ($EAD -lt (Get-Date).AddDays(-365))
					{
						$DeleteAccount = $true
					}
				}
			}

			if ($DeleteAccount)
			{
				Write-Output "Deleting Account: $($InactiveUser.SamAccountName)"
				Write-Output "Delete Account: $($DeleteAccount)"
				Write-Output "EAD: $($EAD.toString())"
				Write-Output "AccExp: $($AccExp.toString())"

				Start-Sleep -s 5
				Move-ADObject $InactiveUser -TargetPath "OU=FromNewUsers,OU=DeletedAccounts,DC=HS,DC=wvu-ad,DC=wvu,DC=edu" -WhatIf
                Write-Output "Account moved to DeletedAccounts\FromNewUsers: $($InactiveUser.samaccountname)`n"
				Start-Sleep -s 5
				#Return
			}
			Write-Output "*****************************`n"
		}
	}

	Write-Output "Inactive User Count: " + $InactiveUserCount
	Write-Output "Disabled User Count: " + $EnabledUserCount
	Write-Output "Yes365 Count: " + $Yes365Count
}


if ($SearchNewUsers)
{
	Write-ColorOutput -Message "`nBeginning to scan NewUsers"

	$NewUsers = Get-ADUser -SearchBase "OU=NewUsers,DC=HS,DC=wvu-ad,DC=wvu,DC=edu" -Filter * -Properties Enabled

	$NewUsersCount = 0
	$EnabledNewUsersCount = 0
	$NewUsersOldCount = 0
	$MovedUserCount = 0
	$DeletedUserCount = 0

	$Error.Clear()

	foreach ($NewUser in $NewUsers)
	{
		$NewUsersCount++
		Write-Output "Current User: " + $NewUser.SamAccountName
		Write-Output "Current User DN: " + $NewUser.DistinguishedName
		Write-Output "Current User Creation Date: " + $NewUser.whenCreated.toString()

		Write-Output "New Users Count: " + $NewUsersCount

		if ($NewUser.DistinguishedName.indexOf("NewUsers") -gt 0) #This shouldn't be needed but is a safety measure.
		{
			if ($NewUser.Enabled)
			{
				$EnabledNewUsersCount++
				Write-Output "Disabling User: $($NewUser.SamAccountName)"
				$NewUser | Disable-ADAccount -WhatIf
			}

			if ($NewUser.DistinguishedName.indexOf("NewUsers-OLD") -gt 0)
			{
				$NewUsersOldCount++

				if ($NewUser.whenCreated -lt (Get-Date).AddDays(-60))
				{
					Write-Output "User is being deleted:  $($NewUser.SamAccountName)"
					$DeletedUserCount++

					start-sleep -s 2
					Move-ADObject $NewUser -TargetPath "OU=FromNewUsers,OU=DeletedAccounts,DC=HS,DC=wvu-ad,DC=wvu,DC=edu" -WhatIf
					start-sleep -s 2
					#Return
				}
			}
			elseif ($NewUser.whenCreated -lt (Get-Date).AddDays(-30))
			{
				Write-Output "Moving user $($NewUser.Samaccountname) to NewUsers-Old"
				Write-Output "Creation Date: $($NewUser.whenCreated.toString())"
				$MovedUserCount++

				$NewUser | Move-ADObject -TargetPath "OU=NewUsers-OLD,OU=NewUsers,DC=HS,DC=wvu-ad,DC=wvu,DC=edu" -WhatIf
			}

		}
		"****************************************"

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
			Add-Content -Path $ErrorLogFile -Value "Stopping due to error"
			Return
		}
	}
}

if ($SessionTranscript)
	{
		"TranscriptLogFile: " + $TranscriptLogFile
		
		Stop-Transcript 
		
		"Transcript log file stopped"
	}    