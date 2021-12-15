#Get-HSDomainUserInfo.ps1
#Written by: Jeff Brusoe
#Last Updated: March 5, 2020
#
#This is PowerShell version of this VB Script DomainUsers.vbs:
#https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/Get-HSDomainUserInfo/OriginalFiles/DomainUsers.vbs

[CmdletBinding()]
param (
	[string]$LogFilePath = $null,
	[switch]$StopOnError #Used for testing purposes
)

#############################
# Environment configuration #
#############################
$Error.Clear()
Clear-Host
Set-StrictMode -Version Latest
Set-Location $PSScriptRoot

if ([string]::IsNullOrEmpty($LogFilePath))
{
	$LogfilePath = $PSScriptRoot + "\Logs\"
}

if (!(Test-Path $LogFilePath))
{
	$LogFilePath = $PSScriptRoot + "\"
}

Write-Verbose "Log File Path: $LogFilePath"

$TranscriptFile = $LogFilePath + (Get-Date -format "yyyy-MM-dd-HH-mm-ss") + "-SessionTranscript.txt"
Start-Transcript $TranscriptFile

$OutputFile = $LogFilePath + (Get-Date -format "yyyy-MM-dd-HH-mm-ss") + "-HSDomainUserInfo.csv"
New-Item $OutputFile -type file -Force | Out-Null

$UserCount = 0
##########################################
# End of environment configuration block #
##########################################

#Get AD user list
$UserPropertyArray = "DisplayName","Description","AccountExpirationDate","LockedOut","LastLogonTimeStamp","PasswordLastSet","AccountExpires","msDS-UserPasswordExpiryTimeComputed","PasswordNotRequired","CanonicalName"

try
{
	Write-Output "`n`nGenerating AD user list"
	
	$HSDomainUsers = Get-ADUser -Filter * -Properties $UserPropertyArray -ErrorAction Stop
	#$HSDomainUsers = Get-ADUser jbrusoe -Properties $UserPropertyArray
}
catch
{
	Write-Warning "Error getting AD user list. Program is exiting"
	Stop-Transcript
	return
}

#Get Domain Name
#This will be the same for all users and won't be calculated for each one.
$DomainName = (Get-ADDomain).DNSRoot

	
foreach ($HSDomainUser in $HSDomainUsers)
{
	$HSDomainUserInfo = New-Object -TypeName PSObject
	
	if ($Error.Count -gt 0 -AND $StopOnError)
	{
		break
	}
	
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name DomainName -Value $DomainName
	
	#SamAccountName
	$SamAccountName = $HSDomainUser.SamAccountName
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name SamAccountName -Value $SamAccountName
	
	Write-Output "Current User: $SamAccountName"
	
	#Display Name
	$DisplayName = $HSDomainUser.DisplayName
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name DisplayName -Value $DisplayName
	
	#User Description
	$Description = $HSDomainUser.Description
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name Description -Value $Description
	
	#Account Expiration Date
	try
	{
		$AccountExpirationDate = $HSDomainUser.AccountExpirationDate.toString()
	}
	catch
	{
		Write-Verbose "Account expiration date is not set"
		$AccountExpirationDate = "Not Set"
		$Error.Clear()
	}
	
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name AccountExpirationDate -Value $AccountExpirationDate
	
	#Intruder Lockout
	$LockedOut = $HSDomainUser.LockedOut
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name LockedOut -Value $LockedOut
	
	#Account Disabled
	$Disabled = [bool]$HSDomainUser.Enabled
	$Disabled = !$Disabled
	
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name Disabled -Value $Disabled
	
	#Last Logon Time Stamp
	try
	{
		#https://stackoverflow.com/questions/13091719/converting-lastlogon-to-datetime-format
		$LastLogonTimeStamp = ([datetime]::FromFileTime($HSDomainUser.LastLogonTimeStamp)).toString()
	}
	catch
	{
		Write-Verbose "User has not logged on to domain"
		$LastLogonTimeStamp = "No logon info"
		$Error.Clear()
	}
	
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name LastLogonTimeStamp -Value $LastLogonTimeStamp
	
	#Calculate password age
	try
	{
		$PasswordLastSet = [datetime]$HSDomainUser.PasswordLastSet
		Write-Output "Password Last Set: $PasswordLastSet"
		
		$PasswordAge = (New-TimeSpan -Start $PasswordLastSet -End (Get-Date)).Days
		Write-Output "Password Age: $PasswordAge"
	}
	catch 
	{
		Write-Verbose "Password has never been set"
		
		$PasswordAge = "Password never set"
		$Error.Clear()
	}
	
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name PasswordAge -Value $PasswordAge
	
	#Max and Min Password Ages
	try
	{
		$ADPasswordPolicy = $HSDomainUser | Get-ADUserResultantPasswordPolicy -ErrorAction Stop
		#$ADPasswordPolicy
	}
	catch
	{
		Write-Warning "Error retrieving user password policy"
		$Error.Clear()
	}
		
	try
	{
		#Original Format: 372.00:00:00
		#This code pulls the number in front of the decimal point.
		$MaxPasswordAge = $ADPasswordPolicy.MaxPasswordAge.toString()
		$MaxPasswordAge = $MaxPasswordAge.substring(0,$MaxPasswordAge.indexOf("."))
	}
	catch
	{
		$MaxPasswordAge = "No password policy set"
		$Error.Clear()
	}
	
	try
	{
		#If min password age is 0, the format is this: 00:00:00.
		#Otherwise, it has the same format as the max password age.
		$MinPasswordAge = $ADPasswordPolicy.MinPasswordAge.toString()
		
		if ($MinPasswordAge.indexOf(".") -lt 0)
		{
			$MinPasswordAge = 0
		}
		else
		{
			$MinPasswordAge = $MinPasswordAge.substring(0,$MinPasswordAge.indexOf("."))
		}	
	}
	catch
	{
		$MinPasswordAge = "No min password age"
		$Error.Clear()
	}

	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name MinPasswordAge -Value $MinPasswordAge
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name MaxPasswordAge -Value $MaxPasswordAge
	
	#Minimum Password Length
	try
	{
		$MinPasswordLength = $ADPasswordPolicy.MinPasswordLength
	}
	catch
	{
		Write-Verbose "No minimum password length"
		$MinPasswordLength = 0
	}
	
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name MinPasswordLength -Value $MinPasswordLength
	
	#Password History
	try
	{
		$PasswordHistoryCount = $ADPasswordPolicy.PasswordHistoryCount
	}
	catch
	{
		Write-Warning "No password history count information"
		$PasswordHistoryCount = "Not present"
	}
	
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name PasswordHistoryCount -Value $PasswordHistoryCount
	
	#Password Expiration Date
	try
	{
		$PasswordExpirationDate = ([datetime]::FromFileTime($HSDomainUser."msDS-UserPasswordExpiryTimeComputed")).toString()
		#$PasswordExpirationDate = $PasswordLastSet.AddDays($MaxPasswordAge)
	}
	catch
	{
		$PasswordExpirationDate = "Calculation error"
		$Error.Clear()
	}
	
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name PasswordExpirationDate -Value $PasswordExpirationDate
	
	#Password Required
	$PasswordRequired = !$HSDomainUser.PasswordRequired
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name PasswordRequired -Value $PasswordRequired
	
	#Org Unit
	$CanonicalName = $HSDomainUser.CanonicalName
	$CanonicalName = $CanonicalName.substring(0,$CanonicalName.lastIndexOf("/"))
	
	$HSDomainUserInfo | Add-Member -MemberType NoteProperty -Name OrgUnit -Value $CanonicalName
	
	$UserCount++
	Write-Output "User Count: $UserCount"
	
	#Write user info to output file
	$HSDomainUserInfo | Export-Csv $OutputFile -Append -NoTypeInformation
	
	Write-Output "**********************"
}

Write-Output "Done generating HS domain user information."

Stop-Transcript