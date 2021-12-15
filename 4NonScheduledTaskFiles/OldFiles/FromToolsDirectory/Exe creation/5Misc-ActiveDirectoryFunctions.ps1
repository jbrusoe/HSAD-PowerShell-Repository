#--------------------------------------------------------------------------------
#
#  File:  5Misc-Office365Functions.ps1
#
#  Author:  Jeff Brusoe
#
#  Last Update: September 7, 2017
#
#  Version:  1.0
#
#  Description: Contains various functions commonly used with Office 365.
#
#---------------------------------------------------------------------------------

<#
.SYNOPSIS
 	This file contains various functions used in the account creation process.
    
.DESCRIPTION
 	This function has various Active Directory functions that are used by various
 	PowerShell files. There is no need to have a connection to the cloud
 	or the Quest cmdlets to run any function in this file.
 	
 	Functions currently in this file include:
 	1. DirectoryMapping
 	2. Get-UserGroups
 	3. 
 	
.PARAMETER
	Each function accepts certain parameters. See function comments to figure out what these are.

.NOTES
    Author: Jeff Brusoe
    Last Updated: September 7, 2017
    This file is used for new accounts created by the Trident IDM system.
#>

$DoNotDisable = "cdrake","bpcopenhaver","jbrusoe","krodney","mkondrla","jnesselrodt","jlgodwin","rnichols","microsoft","jmarton","llroth","jwshaffer","jnesselrodtadmin","jbrusoeadmin","kadmin","mlkadmin","jlga","r.nichols","rcgamble"

Function DirectoryMapping ($UserDN)
{
	#This function takes a user's distinguished name for input
	#and returns the path to the users home directory.
	
	#Used in create new account file
		
	#Create object to hold directory information
	$HomeDirectoryInfo = new-object PSObject
	
	$HomeDirectoryInfo | add-member -type NoteProperty -Name DirectoryPath -value $null 
	$HomeDirectoryInfo | add-member -type NoteProperty -Name FullPath -Value $false
	#In cases where the DN still needs to be parsed up later recursively, the FullPath value is set to false.
	#If the DirectoryPath value is the correct (& final) home directory path, the FullPath value is set to true.
  
	if (![string]::IsNullOrEmpty($UserDN))
	{
		switch -wildcard ($UserDN)
		{
			"*OU=Network and Voice Services,OU=ITS*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\ITS\Network and Voice Services\"
				$HomeDirectoryInfo.FullPath = $true
				break
			}
			"*OU=MGMT,OU=ITS*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\ITS\mgmt\"
				$HomeDirectoryInfo.FullPath = $true
				break
			}
			"*OU=Application and Web Services,OU=ITS*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\ITS\application and web services\"
				$HomeDirectoryInfo.FullPath = $true
				break
			}
			"*OU=Desktop Support,OU=Support Services,OU=ITS*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\ITS\support services\desktop support\"
				$HomeDirectoryInfo.FullPath = $true
				break
			}
			"*OU=Classroom Technology,OU=Support Services,OU=ITS*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\ITS\support services\classroom technology\"
				$HomeDirectoryInfo.FullPath = $true
				break
			}
			"*OU=Security Services,OU=ITS*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\ITS\security services\"
				$HomeDirectoryInfo.FullPath = $true
				break
			}
			"*OU=ITS*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\ITS\"
				$HomeDirectoryInfo.FullPath = $false
				break
			}
			"*OU=ADMIN*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\Admin\"
				$HomeDirectoryInfo.FullPath = $false
				break
			}
			"*OU=BIOCHEM*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\bassci\bioc\"
				$HomeDirectoryInfo.FullPath = $true
				break
			}
			"*OU=MICRO*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\bassci\micro\"
				$HomeDirectoryInfo.FullPath = $true
				break
			}
			"*OU=ANAT*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\bassci\anat\"
				$HomeDirectoryInfo.FullPath = $true
				break
			}
			"*OU=BASSCI*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\bassci\"
				$HomeDirectoryInfo.FullPath = $false
				break
			}
			"*OU=MBRCC*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\mbrcc\"
				$HomeDirectoryInfo.FullPath = $false
				break
			}			
			"*OU=PATH,OU=SOM*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\path\"
				$HomeDirectoryInfo.FullPath = $true
				break
			}
			"*OU=SOM*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\som\"
				$HomeDirectoryInfo.FullPath = $false
				break
			}
			"*OU=SON*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\son\"
				$HomeDirectoryInfo.FullPath = $false
				break
			}
			"*OU=SOP*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\sop\"
				$HomeDirectoryInfo.FullPath = $false
				break
			}
			"*OU=SPH*" 
			{
				$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\sph\"
				$HomeDirectoryInfo.FullPath = $false
				break
			}
			default 
			{
				$HomeDirectoryInfo.DirectoryPath = "NoHomeDirectory"
				$HomeDirectoryInfo.FullPath = $true
			}
		}
	}
	else
	{
		Write-Host -foregroundcolor red "The distinguished name must be specified"
		exit
	}
	
	return $HomeDirectoryInfo
}

Function Get-UserGroups ($UserDN)
{
	#This function returns an array of groups which a user is a member of.
	
	Return $null
}

Function OrgGroupMappings($Department)
{
	Return $null
}

Function Set-UserAccountControlValueTable
{
	# see http://support.microsoft.com/kb/305144/en-us
	
    $userAccountControlHashTable = New-Object HashTable
    $userAccountControlHashTable.Add("SCRIPT",1)
    $userAccountControlHashTable.Add("ACCOUNTDISABLE",2)
    $userAccountControlHashTable.Add("HOMEDIR_REQUIRED",8) 
    $userAccountControlHashTable.Add("LOCKOUT",16)
    $userAccountControlHashTable.Add("PASSWD_NOTREQD",32)
    $userAccountControlHashTable.Add("ENCRYPTED_TEXT_PWD_ALLOWED",128)
    $userAccountControlHashTable.Add("TEMP_DUPLICATE_ACCOUNT",256)
    $userAccountControlHashTable.Add("NORMAL_ACCOUNT",512)
    $userAccountControlHashTable.Add("INTERDOMAIN_TRUST_ACCOUNT",2048)
    $userAccountControlHashTable.Add("WORKSTATION_TRUST_ACCOUNT",4096)
    $userAccountControlHashTable.Add("SERVER_TRUST_ACCOUNT",8192)
    $userAccountControlHashTable.Add("DONT_EXPIRE_PASSWORD",65536) 
    $userAccountControlHashTable.Add("MNS_LOGON_ACCOUNT",131072)
    $userAccountControlHashTable.Add("SMARTCARD_REQUIRED",262144)
    $userAccountControlHashTable.Add("TRUSTED_FOR_DELEGATION",524288) 
    $userAccountControlHashTable.Add("NOT_DELEGATED",1048576)
    $userAccountControlHashTable.Add("USE_DES_KEY_ONLY",2097152) 
    $userAccountControlHashTable.Add("DONT_REQ_PREAUTH",4194304) 
    $userAccountControlHashTable.Add("PASSWORD_EXPIRED",8388608) 
    $userAccountControlHashTable.Add("TRUSTED_TO_AUTH_FOR_DELEGATION",16777216) 
    $userAccountControlHashTable.Add("PARTIAL_SECRETS_ACCOUNT",67108864)

    $userAccountControlHashTable = $userAccountControlHashTable.GetEnumerator() | Sort-Object -Property Value 
    return $userAccountControlHashTable
}

Function Get-UserAccountControlFlags($userInput)
{
	[string]$UserFlags = @()
	Set-UserAccountControlValueTable | foreach {
		$binaryAnd = $_.value -band $userInput
		if ($binaryAnd -ne "0")
		{
			return $_.name
			
		}
    }
}