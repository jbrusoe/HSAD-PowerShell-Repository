<#
    .SYNOPSIS
        

    .OUTPUTS
        

    .EXAMPLE
        

    .EXAMPLE
        

    .NOTES
        Written by: Kevin Russell
        Last Updated: 

        PS Version 5.1 Tested:  
        PS Version 7.0.2 Tested: 
#>	

Function Get-WVUUserInfo
{
    [CmdletBinding()]
    param(
        [string]$username
    )
		
	Try
	{
		Write-Host "`n`nWVU-AD Information:" -ForegroundColor Yellow 
		Write-Host "===================" -ForegroundColor Blue		
		
		$domain = New-Object System.DirectoryServices.DirectoryEntry("LDAP://DC=WVU-AD,DC=WVU,DC=EDU")
		$Searcher = New-Object System.DirectoryServices.DirectorySearcher
		$Searcher.SearchRoot = $domain
		$Searcher.PageSize = 10000
		$Searcher.Filter = "(&(objectCategory=person)(sAMAccountName=$username))"
		$Searcher.SearchScope = "Subtree"
			
		#Select WVU-AD attributes wanted		
		$PropertyList = "sAMAccountName", "mail", "givenName", "CN", "Department", "DistinguishedName", "userAccountControl", "pwdLastSet", "badPasswordTime", "lastLogonTimestamp", "info", "whenCreated", "accountExpires"

		#add attributes to variable
		foreach ($attribute in $PropertyList)
		{
			$index = $Searcher.PropertiesToLoad.Add($attribute)
		}
		 
		$SearchResults = $Searcher.FindAll()
				
		foreach ($SearchResult in $SearchResults)
		{
			$result = $SearchResult.GetDirectoryEntry()

			$Item = $result.Properties
			"FullName:                  " + $Item.CN
			"UserName:                  " + $Item.sAMAccountName
			if ([string]::IsNullOrEmpty($Item.mail))
			{
				"EmailAddress:              There was no email address found for this user"
			}
			else
			{
				"EmailAddress:              " + $Item.mail
			}
			
			
			if ($Item.whenCreated)
			{
				Write-Host "Created On:               "$Item.whenCreated
			}
			else
			{
				Write-Host -NoNewLine "Created On:                 "
				Write-Host "Field Empty" -ForegroundColor Magenta
			}
			
			
			if ([string]::IsNullOrEmpty($Item.Department))
			{
				"Department:                There is no department listed for this user"
			}
			else
			{
				"Department:                " + $Item.Department
			}
			
			
			if ([string]::IsNullOrEmpty($Item.info))
			{
				"Major:                     There is no major listed for this user"
			}
			else
			{
				"Major:                     " + $Item.info
			}
			
			
			"distinguishedName:         " + $Item.DistinguishedName
			"Password Last Set:         " + [datetime]::fromfiletime($result.ConvertLargeIntegerToInt64($result.pwdLastSet[0]))
				
			
			"Password Expires:          " + [datetime]::fromfiletime($result.ConvertLargeIntegerToInt64($result.accountExpires[0]))
			if ([string]::IsNullOrEmpty($Item.badPasswordTime))
			{
				"LastBadPasswordAttempt:    The last bad password field is null or empty"
			}
			else
			{
				"LastBadPasswordAttempt:    " + [datetime]::fromfiletime($result.ConvertLargeIntegerToInt64($result.badPasswordTime[0]))
			}
			
			
			if ([string]::IsNullOrEmpty($Item.lastLogonTimestamp))
			{
				"LastLogonTimestamp:        The last logon timestamp field is null or empty"
			}
			else
			{			
				"LastLogonTimestamp:        " + [datetime]::fromfiletime($result.ConvertLargeIntegerToInt64($result.lastLogonTimestamp[0]))
			}			
			
			
			[int]$uac = $Item.userAccountControl.toString()			
				
			$AccountIsDisabled = $false
			$AccountLocked = $false
			$PasswordExpired = $false
					
			foreach ($value in $uacValue)
			{
				if ($value -eq 514)
				{
					$AccountIsDisabled = $true
				}
				
				if ($value -contains 16)
				{
					$AccountLocked = $true
				}
					
				if ($value -contains 8388608)
				{
					$PasswordExpired = $true
				}
			}			
			"Account Is Disabled:       " + $AccountIsDisabled
			"Account Is Locked:         " + $AccountLocked
			"Password Expired:          " + $PasswordExpired
		}       
				
		if ($AccountLocked)
		{
			Write-Warning "It appears the WVU account is locked."  
			$WVUserUnlock = Read-Host "Would you like to unlock? (y/n)"
			if ($WWUserUnlock -eq "y")
			{
				Unlock-ADAccount -Identity $username
			}
		}

		if ($AccountIsDisabled)
		{
			Write-Warning "It appears the WVU account is disabled."
		}
				   
		if ($PasswordExpired)
		{
			Write-Warning "It appears the WVU account password has expired."
		}
				
		if ($Item.DistinguishedName -like '*Disabled*')
		{
			Write-Warning "It appears this user is in a disabled OU."
		}
	}
	Catch
	{
		
	}
}