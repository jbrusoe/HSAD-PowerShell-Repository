#--------------------------------------------------------------------------------------------------
#
#  File:  5Cleanup-ADAccounts.ps1
#
#  Author:  Jeff Brusoe
#
#  Last Update: December 27, 2017
#
#  Version:  1.5
#
#  Description: This file performs various maintenance tasks on Active Directory accounts. These include:
#		1. Disable all users in NewUsers (including NewUsers-OLD)
#		2. Disable all users in InActiveAccounts
#		3. Move accounts older than 30 days from NewUsers to NewUsers-OLD
#		4. Delete accounts in NewUsers-OLD after 60 days
#
#  Note: A connection to the cloud is not required.
#--------------------------------------------------------------------------------------------------

param (
	[switch]$SessionTranscript = $true,
	[switch]$StopOnError = $true, #$true is used for testing purposes. For normal use, this should be false.
	[switch]$InactiveAccount, #Search inactive accounts
	[switch]$SearchNewUsers, #Search new users
	[string]$LogFileDirectory = "c:\AD-Development\Misc-AccountCleanUp\Logs\"
)

#Initialization section
Clear-Host
$Error.Clear()
Set-StrictMode -Version Latest

#Add references to file containing needed functions
. ..\5Misc-ActiveDirectoryFunctions.ps1
. ..\5Misc-Functions.ps1

$InactiveUserCount = 0
$EnabledUserCount = 0
$Yes365Count = 0

#Log Files
if ($LogFileDirectory[$LogFileDirectory.length - 1] -ne "\")
{
	#This ensures that the directory path will be a valid one.
	$LogFileDirectory = $LogFileDirectory + "\"
}

$SessionTranscriptFile = $LogFIleDirectory + (get-date -format yyyy-MM-dd-HH-mm) + "-ADAccountCleanup-SessionTranscript-4.txt"

New-Item $SessionTranscriptFile -type File

if ($SessionTranscript)
{
	Start-Transcript -Path $SessionTranscriptFile -Force
}

if ($InactiveAccount)
{
	Write-ColorOutput -Message "Beginning to scan Inactive Accounts"

	$InactiveUsers = Get-QADUser -searchroot "hs.wvu-ad.wvu.edu/Inactive Accounts" -sizelimit 0 -includedProperties extensionAttribute7,extensionAttribute1

	foreach ($InactiveUser in $InactiveUsers)
	{
		if (($Error.Count -gt 0) -AND $StopOnError)
		{
			Return
		}

		if ($DoNotDisable -contains $InactiveUser.SamAccountName)
		{
			#This should never be executed, but is here as a safetey measure.
			"Skipping this user"
		}
		elseif ($InactiveUser.dn.indexOf("Inactive Accounts") -gt 0)
		{
			$InactiveUserCount++
			$InactiveUser.DN
			Write-Output $("extensionAttribute7: " + $InactiveUser.extensionAttribute7)

			if (!$InactiveUser.AccountIsDisabled)
			{
				$EnabledUserCount++
				"Disabling User"
				$InactiveUser | Disable-QADUser
			}

			#Set extensionAttribute7
			if ($InactiveUser.extensionAttribute7 -ne "No365")
			{ 
				Write-Output $("extensionAttribute7: " + $InactiveUser.extensionAttribute7)
				"Setting extensionAttribute7 to No365"

				$InactiveUser | set-qaduser -oa @{extensionAttribute7 = "No365"}

				$Yes365Count++	
			}

			$ExpirationDate = (Get-Date)

			"Account Expires: " + $InactiveUser.AccountExpires
			"Ext1: " + $InactiveUser.extensionAttribute1

			if ($InactiveUser.AccountExpires -eq $null)
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

				$InactiveUser | set-qaduser -AccountExpires $ExpirationDate
			}
			else
			{
				$AccExp = [datetime]$InactiveUser.AccountExpires

				if ($AccExp -gt (get-date))
				{
					#Debugging code. Program should never reach here.
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
				"Deleting Account"
				"Delete Account: " + $DeleteAccount
				"EAD: " + $EAD.toString()
				"AccExp: " + $AccExp.toString()

				Start-Sleep -s 5
				#$InactiveUser | remove-qadobject -force
				Start-Sleep -s 5
				#Return
			}
			"*****************************"
		}
	}

	"Inactive User Count: " + $InactiveUserCount
	"Disabled User Count: " + $EnabledUserCount
	"Yes365 Count: " + $Yes365Count
}


if ($SearchNewUsers)
{
	Write-ColorOutput -Message "`nBeginning to scan NewUsers"

	$NewUsers = Get-QADUser -searchroot "hs.wvu-ad.wvu.edu/NewUsers" -sizelimit 0 #| where {$_.whenCreated -lt "11/18/2017"}

	$NewUsersCount = 0
	$EnabledNewUsersCount = 0
	$NewUsersOldCount = 0
	$MovedUserCount = 0
	$DeletedUserCount = 0

	$Error.Clear()

	foreach ($NewUser in $NewUsers)
	{
		$NewUsersCount++
		"NewUsersCount: $NewUsersCount"
	
		"Current User: " + $NewUser.SamAccountName
		"Current User DN: " + $NewUser.dn
		"Current User Creation Date: " + $NewUser.whenCreated.toString()
		"Deleted User Count: " + $DeletedUserCount
		"New Users Count: " + $NewUsersCount

		if ($NewUser.dn.indexOf("NewUsers") -gt 0) #This shouldn't be needed but is a safety measure.
		{
			$NewUser.dn
			
			if (!$NewUser.AccountIsDisabled)
			{
				$EnabledNewUsersCount++
				"Disabling User"
				
				
				$NewUser | Disable-QADUser
			}

			if ($NewUser.dn.indexOf("NewUsers-OLD") -gt 0)
			{
				$NewUsersOldCount++

				if ($NewUser.whenCreated -lt (Get-Date).AddDays(-60))
				{
					"User is being deleted"
					$DeletedUserCount++

					start-sleep -s 2
					#$NewUser | Remove-QADObject -Force
					$NewUser | Disable-QADUser
					start-sleep -s 2
					#Return
				}
			}
			elseif ($NewUser.whenCreated -lt (Get-Date).AddDays(-30))
			{
				"Moving user"
				"Creation Date: " + $NewUser.whenCreated.toString()
				$MovedUserCount++

				$NewUser | Move-QADObject -NewParentContainer "hs.wvu-ad.wvu.edu/NewUsers/NewUsers-OLD"
			}

		}
		else
		{
			Return
		}
		"****************************************"

		if ($Error.Count -gt 0)
		{
			Return
		}
	}
}

Stop-Transcript         