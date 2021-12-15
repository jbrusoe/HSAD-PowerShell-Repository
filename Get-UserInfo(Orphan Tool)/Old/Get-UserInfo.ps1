#--------------------------------------------------------------------------------------------------
#Get-UserInfo.ps1
#
#Written by: Kevin Russell
#
#Last Modified by: Kevin Russell
#
#Version: 1
#
#Purpose: 
#         
#         
#         
#--------------------------------------------------------------------------------------------------

################################
#Change PowerShell window title
################################
$tech = $env:username
$Host.UI.RawUI.WindowTitle = "$tech, remember ALL HSC users love you"
#$Host.UI.RawUI.BackgroundColor = 'Blue'


Do
{
	###############
	#set variables
	###############		
	$username = Read-Host "`nEnter the username you want to lookup"
	$StartTime = get-date	
	#variables to make long int readable text
	$hash_badPasswordTime = @{Name="badPasswordTime";Expression={([datetime]::FromFileTime($_.badPasswordTime))}}
	###############
	#end variables
	###############



	#################
	#Find HS-AD info
	#################
		
	#Add header for HSC-AD info	
	Write-Host "`n`n`nHSC-AD Information:" -ForegroundColor Yellow 
	Write-Host "===================" -ForegroundColor Blue	
	#end header
		
	
	Try
	{		
		#Select HSC-AD attributes wanted, rename fields where needed		
		$HSUser = Get-ADUser -Identity $username -Properties CN, Department, DistinguishedName, EmailAddress, Enabled, extensionAttribute1, extensionAttribute6, extensionAttribute7, extensionAttribute11, extensionAttribute12, badPasswordTime, LockedOut, PasswordLastSet, lastLogon, whenCreated
		$HSTSProp = Get-ADUser -Identity $username | Select @{Name="TermPath";Expression={([adsi]("LDAP://$($_.distinguishedName)")).psbase.InvokeGet("terminalservicesprofilepath")}}, @{Name="TermHome";Expression={([adsi]("LDAP://$($_.distinguishedName)")).psbase.InvokeGet("TerminalServicesHomeDirectory")}}
		$ConvertFromMilitary = Get-ADuser -Identity $username | Select @{Name="PasswordLastSet";Expression={([datetime]::FromFileTime($_.pwdLastSet))}}, @{Name="badPasswordTime";Expression={([datetime]::FromFileTime($_.badPasswordTime))}}
		
		
		#Display info on screen and error handle/display reminders where needed
		if ($HSUser.CN)
		{
			Write-Host "Name:                          "$HSUser.CN
		}
		else
		{
			Write-Host -NoNewLine "Name:                           "
			Write-Host "CN (name) attribute is blank" -ForegroundColor Red
		}
		
		
		if ($HSUser.extensionAttribute12)
		{
			Write-Host "Username:                      "$HSUser.extensionAttribute12
		}
		else
		{
			Write-Host -NoNewLine "Username:                       " 
			Write-Host "exAtt12 (username) not found" -ForegroundColor Red
		}
		
		
		if ($HSUser.EmailAddress)
		{
			Write-Host "Email Address:                 "$HSUser.EmailAddress
		}
		else
		{
			Write-Host -NoNewLine "Email Address:                  "
			Write-Host "None" -ForegroundColor Magenta
		}
		
		
		if ($HSUser.whenCreated)
		{
			Write-Host "Created On:                    "$HSUser.whenCreated
		}
		else
		{
			Write-Host -NoNewLine "Created On:                     "
			Write-Host "None" -ForegroundColor Magenta
		}
		
		
		if ($HSUser.extensionAttribute11)
		{
			Write-Host "WVUID:                         "$HSUser.extensionAttribute11
		}
		else
		{
			Write-Host -NoNewLine "WVUID:                          "
			Write-Host "None" -ForegroundColor Magenta
		}
		
		
		if (($HSUser.extensionAttribute1) -AND ([datetime]$HsUser.extensionAttribute1 -lt $StartTime))
		{
			Write-Host -NoNewLine "End Date:                       " 
			Write-Host $HSUser.extensionAttribute1 -ForegroundColor Red
		}
		elseif ($HSUser.extensionAttribute1)
		{
			Write-Host "End Date:                      "$HSUser.extensionAttribute1
		}		
		else
		{
			Write-Host -NoNewLine "End Date:                       "
			Write-Host "None" -ForegroundColor Magenta
		}
		
		
		if ($HsUser.Department)
		{
			Write-Host "Department:                    "$HSUser.Department			
		}
		else
		{
			Write-Host -NoNewLine "Department:                     "
			Write-Host "None" -ForegroundColor Magenta
		}
		
		
		if ($HSUser.DistinguishedName)
		{
			Write-Host "LDAP:                          "$HSUser.DistinguishedName
		}
		else
		{
			Write-Host -NoNewLine "LDAP:                           "
			Write-Host "None" -ForegroundColor Magenta
		}
		
		
		if ($HSUser.extensionAttribute6)
		{
			Write-Host "Status:                        "$HSUser.extensionAttribute6
		}
		else
		{
			Write-Host -NoNewLine "Status:                         "
			Write-Host "None" -ForegroundColor Magenta
		}
		
		
		if ($HsUser.extensionAttribute7)
		{
			Write-Host "Licensed for O365:             "$HSUser.extensionAttribute7			
		}
		else
		{
			Write-Host -NoNewLine "Licensed for O365:              "
			Write-Host "exAtt7 not set to Yes365" -ForegroundColor Red
		}

		
		if ($HsUser.PasswordLastSet)
		{			
			if ($HSUser.PasswordLastSet -le [datetime]"2019-06-30")
			{
				Write-Host -NoNewLine "Password Last Set:              "
				Write-Host -NoNewLine $HSUser.PasswordLastSet -ForegroundColor Red	
				Write-Host "  Remind user to claim account not change password"
				
				#calculate password expire date 90 days
				$passwdExpires = $HSUser.PasswordLastSet.AddDays(90)
				$days = New-TimeSpan -Start $StartTime -End $passwdExpires
				
				Write-Host -NoNewLine "Password Expires:              "$passwdExpires"  "
				Write-Host -NoNewLine $days.Days -ForegroundColor Cyan
				Write-Host " days to change password"
			}
			else
			{
				Write-Host "Password Last Set:             "$HSUser.PasswordLastSet
				
				#calculate password expire date 365 days
				$passwdExpires = $HSUser.PasswordLastSet.AddDays(365)
				$days = New-TimeSpan -Start $StartTime -End $passwdExpires
				
				Write-Host -NoNewLine "Password Expires:              "$passwdExpires"  "
				Write-Host -NoNewLine $days.Days -ForegroundColor Cyan
				Write-Host " days to change password"
			}
			
			if ($days.Days -lt 1)
			{			
				Write-Host "The HS password has expired." -ForegroundColor Red
				Write-Output $("***************************************************************") | Out-File -FilePath \\hs.wvu-ad.wvu.edu\public\tools\scripts\Get-UserInfo\PasswdExpired.txt -Append -Encoding ASCII
				Write-Output $("***************************************************************") | Out-File -FilePath \\hs.wvu-ad.wvu.edu\public\tools\scripts\Get-UserInfo\PasswdExpired.txt -Append -Encoding ASCII
				Write-Output $($tech + " is the logged in technician") | Out-File -FilePath \\hs.wvu-ad.wvu.edu\public\tools\scripts\Get-UserInfo\PasswdExpired.txt -Append -Encoding ASCII
				Write-Output $($HSUser.CN + ", " + $HSUser.extensionAttribute12 + ", called due to expired password.") | Out-File -FilePath \\hs.wvu-ad.wvu.edu\public\tools\scripts\Get-UserInfo\PasswdExpired.txt -Append -Encoding ASCII
				Write-Output $($StartTime) | Out-File -FilePath \\hs.wvu-ad.wvu.edu\public\tools\scripts\Get-UserInfo\PasswdExpired.txt -Append -Encoding ASCII			
			}	
			else
			{
			}
		}		
		else
		{
			Write-Host -NoNewLine "Password Last Set:              "
			Write-Host "None" -ForegroundColor Magenta
		}
		
		
		if ($HSUser.badPasswordTime)
		{
			Write-Host "Last Bad Password Attempt:     "#[datetime]::fromfiletime($HSUser.ConvertLargeIntegerToInt64($HSUser.badPasswordTime[0]))
		}
		else
		{
			Write-Host -NoNewLine "Last Bad Password Attempt:      "
			Write-Host "None" -ForegroundColor Magenta
		}
		
		
		if ($HSUser.Enabled)
		{
			Write-Host "Account Enabled:               "$HSUser.Enabled
		}
		else
		{
			Write-Host -NoNewLine "Account Enabled:                " 
			Write-Host $HSUser.Enabled -ForegroundColor Red
		}
		
		
		if (!$HSUser.LockedOut)
		{
			Write-Host "Account Locked:                "$HSUser.LockedOut
		}
		else
		{
			Write-Host -NoNewLine "Account Locked:                 "
			Write-Host -NoNewLine $HSUser.LockedOut -ForegroundColor Red
			Unlock-ADAccount -Identity $username			
			Write-Host "  The password been done wore out, account has been unlocked." -ForegroundColor Cyan
			
			Write-Output $("***************************************************************") | Out-File -FilePath \\hs.wvu-ad.wvu.edu\public\tools\scripts\Get-UserInfo\LockedCalls.txt -Append -Encoding ASCII
			Write-Output $("***************************************************************") | Out-File -FilePath \\hs.wvu-ad.wvu.edu\public\tools\scripts\Get-UserInfo\LockedCalls.txt -Append -Encoding ASCII
			Write-Output $($tech + " is the logged in technician") | Out-File -FilePath \\hs.wvu-ad.wvu.edu\public\tools\scripts\Get-UserInfo\LockedCalls.txt -Append -Encoding ASCII
			Write-Output $($HSUser.CN + ", " + $HSUser.extensionAttribute12 + ", was unlocked at " + $StartTime)| Out-File -FilePath \\hs.wvu-ad.wvu.edu\public\tools\scripts\Get-UserInfo\LockedCalls.txt -Append -Encoding ASCII
		}
		
		
		if ([string]::IsNullOrEmpty($HSTSProp.TermPath))
		{
			"TS profile path:                Does not exist"
		}
		else
		{
			"TS profile path:                " + $HSTSProp.TermPath
		}
		
		
		if ([string]::IsNullOrEmpty($HSTSProp.TermHome))
		{
			"TS home directory:              Does not exist"
		}
		else
		{
			"TS home directory:              " + $HSTSProp.TermHome
		}
				
		
				
		#if ([datetime]$HsUser.extensionAttribute1 -lt $StartTime)
		#{
		#	Write-Host "The end date has passed." -ForegroundColor Red
		#}

		if ($HsUser.DistinguishedName -like '*NewUsers*')
		{
			Write-Host "It appears this user is still in a NewUsers OU." -ForegroundColor Red
		}
					
		if ($HsUser.DistinguishedName -like '*Disabled*')
		{
			Write-Host "It appears this user is in a disabled OU." -ForegroundColor Red
		}
			
		Write-Host "`nProxy Addresses"
		Write-Host "---------------"
		$proxy = Get-ADUser -Identity $username -Properties proxyAddresses
		$proxy.proxyAddresses
			
		Write-Host "`nAD Group Membership"
		Write-Host "-------------------"
		$MemberOf = Get-ADPrincipalGroupMembership -Identity $username | select name
		$MemberOf.name
	}

	Catch
	{
		
	}
	#####################
	#End find HS-AD info
	#####################



	

	##################
	#Find WVU-AD info
	##################	
	
	#Add header for WVU-AD info	
	Write-Host "`n`nWVU-AD Information:" -ForegroundColor Yellow 
	Write-Host "===================" -ForegroundColor Blue	
	#end header
		
	Try
	{
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
	######################
	#End find WVU-AD info
	######################




	################
	#Find WVUH info
	################	
	Write-Host "`n`nWVUH Information:" -ForegroundColor Yellow	
	Write-Host "=================" -ForegroundColor Blue
	
	$WVUHDomains = "wvuhs.com","wvuh.wvuhs.com","CHI.wvuhs.com","uhc.wvuhs.com"
	
	foreach ($domain in $WVUHDomains)
	{
		#Add header for WVUH info			
		Write-Host "`n$domain"  
		Write-Host "--------------"
		
		Try
		{	
			$WVUHUser = Get-ADUser -Identity $username -Server $domain -Properties CN, Department, Enabled, DistinguishedName, Mail, LastBadPasswordAttempt, LockedOut, PasswordExpired, PasswordLastSet, extensionAttribute13, whenCreated, extensionAttribute11
				
						
			Write-Host "Name:                     "$WVUHUser.CN
			Write-Host "WVU ID:                   "$WVUHUser.extensionAttribute11
			Write-Host "Enterprise ID:            "$WVUHUser.extensionAttribute13
			Write-Host "Created On:               "$WVUHUser.whenCreated
			Write-Host "Department:               "$WVUHUser.Department
			Write-Host "LDAP:                     "$WVUHUser.DistinguishedName
			Write-Host "Email:                    "$WVUHUser.Mail
			
			
			if ($WVUHUser.Enabled)
			{
				Write-Host "Account Enabled:          "$WVUHUser.Enabled
			}
			else
			{
				Write-Host -NoNewLine "Account Enabled:           "
				Write-Host $WVUHUser.Enabled -ForegroundColor Red
			}
			
			
			if (!$WVUHUser.LockedOut)
			{
				Write-Host "Account Locked:           "$WVUHUser.LockedOut
			}
			else
			{
				Write-Host -NoNewLine "Account Locked:           "
				Write-Host $WVUHUser.LockedOut -ForegroundColor Red
			}
			
			
			if (!$WVUHUser.PasswordExpired)
			{
				Write-Host "Password Expired:         "$WVUHUser.PasswordExpired
			}
			else
			{
				Write-Host -NoNewLine "Password Expired:          "
				Write-Host $WVUHUser.PasswordExpired -ForegroundColor Red
			}
			
			
			Write-Host "Last Bad Password Attempt:"$WVUHUser.LastBadPasswordAttempt
			Write-Host "Password Last Set:        "$WVUHUser.PasswordLastSet			
		}
		Catch
		{			
			Write-Host "User not found" -ForegroundColor Red		
		}		
	}		
	####################
	#End find WVUH info
	####################
		
		
		
	######################
	#Find Primary machine
	######################
	# Site configuration
	$SiteCode = "HS1" # Site code 
	$ProviderMachineName = "hssccm.hs.wvu-ad.wvu.edu" # SMS Provider machine name

	# Customizations
	$initParams = @{}
	#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
	#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

	# Do not change anything below this line

	# Import the ConfigurationManager.psd1 module 
	if((Get-Module ConfigurationManager) -eq $null) 
	{
		Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
	}

	# Connect to the site's drive if it is not already present
	if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) 
	{
		New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
	}

	# Set the current location to be the site code.
	Set-Location "$($SiteCode):\" @initParams
		
	#pass username to variable $user
	$user = "HS\" + $username
	$computersArray = (Get-CMUserDeviceAffinity -UserName $user).ResourceName	
	#####################
	#End Primary machine
	#####################



	####################
	#Find Computer info
	####################
	
	#Add header for machine/LAPs info		
	Write-Host "`n`nComputer Information:" -ForegroundColor Yellow
	Write-Host "=====================" -ForegroundColor Blue		
	#end header
	
	Try
	{		
		ForEach ($computer in $computersArray)
		{			
			#get computer properties			
			$ADInfo = Get-ADComputer -Identity $computer -Properties *
			
			
			#Get all BitLocker Recovery Keys for that Computer. Note the 'SearchBase' parameter
			$BitLockerObjects = Get-ADObject -Filter 'objectclass -eq "msFVE-RecoveryInformation"' -SearchBase $ADInfo.DistinguishedName -Properties 'msFVE-RecoveryPassword'
			$keys = $BitLockerObjects | select msFVE-RecoveryPassword, Name			
			#End get bitlocker recovery key

			
			#display PC name
			Write-Host -NoNewLine "Machine name:      "  
			Write-Host $computer -ForegroundColor Cyan
			
			
			#Display the LAPs password
			if($ADInfo."ms-Mcs-AdmPwd")
			{
				Write-Host "Admin password:   " $ADInfo."ms-Mcs-AdmPwd"				
			}
			else
			{
				Write-Host -NoNewLine "Admin password:    "  
				Write-Host "None" -ForegroundColor Magenta
			}
			#End display LAPs password
			
			
			#Display the LAPs expiration date
			if($ADInfo."ms-Mcs-AdmPwdExpirationTime")
			{            
				Write-Host ("Expiration date:   " + (Get-Date($ADInfo."ms-Mcs-AdmPwdExpirationTime") -Format "MM/dd/yy hh:mmtt"))
				
			}
			else
			{
				Write-Host -NoNewLine "Expiration date:   "
				Write-Host "None" -ForegroundColor Magenta
			} 
			#End display LAPs expiration date
						
			
			
			#Display physical location
			if ($ADInfo.Location)
			{
				Write-Host "Physical Location:" $ADInfo.Location
			}
			else
			{
				Write-Host -NoNewLine "Physical Location: "
				Write-Host "None" -ForegroundColor Magenta
			}
			#End physical location
			
			
			
			#Display OS
			if ($ADInfo.OperatingSystem -like "*Windows 10*")
			{
				Write-Host "Operating System: " $ADInfo.OperatingSystem
			}
			else
			{
				Write-Host -NoNewLine "Operating System:  "
				Write-Host $ADInfo.OperatingSystem -ForegroundColor Red
			}
			#End display OS
			
			
			
			
			#Display OS version
			Write-Host "OS Version:       " $ADInfo.OperatingSystemVersion.Split("()")[1]
			
			
			
			#Display canonical name of machine
			Write-Host "LDAP:             " $ADInfo.DistinguishedName
			
			
			
			#Display what groups PC is a member of			
			Write-Host "`nGroup Membership"
			Write-Host "----------------"
						
			if ($ADInfo.memberOf)
			{
				foreach ($group in $ADInfo.memberOf)
				{					
					$group.Split("=,")[1]					
				}
				Write-Host ""
			}
			else
			{
				Write-Host "This computer is not in any groups`n"
			}			
			#End display computer group membership
			
			
				
			#display bitlocker information			
			if ($keys.length -gt 1)			
			{
				#Define date array
				$Dates = @()
					
				Write-Host "`nThere were $($keys.length) bitlocker keys found."
				Write-Host "-----------------------------------"
				foreach ($key in $keys)
				{					
					$FindPasswordIDDate = $key.Name.Split("{")[0]
					$FindPasswordID = $key.Name.Split("{")[1]
					$PasswordID = $FindPasswordID.Split("-")[0]
					$PasswordIDDate = $FindPasswordIDDate.Substring(0,$FindPasswordIDDate.Length-6) + "  " + $PasswordID + "  "  +$key."msFVE-RecoveryPassword"
						
					$Dates += $PasswordIDDate					
				}
					
				$SortedDates = $Dates | sort-object -descending
					
				$SortedDates[0]
				$SortedDates[1]
				$SortedDates[2]
				"`n`n"
					
			}				
			else
			{
				Try
				{
					$FindPasswordID = $keys.Name.Split("{")[1]
					$PasswordID = $FindPasswordID.Split("-")[0]
					$FindPasswordIDDate = $keys.Name.Split("{")[0]				
					$PasswordIDDate = $FindPasswordIDDate.Substring(0,$FindPasswordIDDate.Length-6)				
					
					Write-Host "`nPassword ID:"  $PasswordID
					Write-Host "Password ID Date:" $PasswordIDDate
					Write-Host "Recovery Key:"  $keys."msFVE-RecoveryPassword"
				}
				Catch
				{
					Write-Host "There was an error finding the bitlocker information for this machine, it most likely does not exist`n" -ForegroundColor Red
				}
			}
			#End display bitlocker info
			
			
		}
	}
	Catch
	{
		Write-Warning "There was an error finding the information on this PC."        
	}    
	###################
	#End computer info
	###################
		

$EndTime = Get-Date
$ElapsedTime = $EndTime - $StartTime
Write-Host " "
Write-Host "Search took $($ElapsedTime.seconds) seconds to complete" -ForegroundColor Green	
}
While ($true)		



