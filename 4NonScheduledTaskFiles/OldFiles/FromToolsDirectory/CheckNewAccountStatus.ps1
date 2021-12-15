#--------------------------------------------------------------------------------------------------
#CheckNewAccountStatus.ps1
#
#Written by: Kevin Russell
#
#Last Modified by: Kevin Russell
#
#Last Modified date: 9/10/18
#
#Version: 1
#
#Purpose: The purpose of this script is to make sure a new account has been provisioned correctly
#         This program assumes you are already connected to the cloud.  It check to make sure the 
#         user is in AD, if user exists it checks to make sure they are not in the new users OU.
#         If they are in the new users OU it stops and reports user in new user OU.  It then check
#         if exAtt7 is set.  If its not set it stops and reports user's exAtt7 is not set.  It then
#         checks via Msol if user has any licenses.
#
#         format like .\CheckNewAccountStatus.ps1 "kevin russell" to run
#
#--------------------------------------------------------------------------------------------------

[CmdletBinding()]
param (
[Parameter(Position=0)]
[string]$user
)

#Get info
$HSUser = Get-ADUser -Filter {Name -eq $user} -Properties CN, Department, DistinguishedName, EmailAddress, extensionAttribute7, extensionAttribute12


Function Set-OfficeLicense
{  	
	$user = Get-MsolUser -SearchString $user@hsc.wvu.edu    
    $UPNEmail = $user.UserPrincipalName
	
    $disabledplans = @(
    "AAD_BASIC_EDU","SCHOOL_DATA_SYNC_P1","STREAM_O365_E3","TEAMS1","INTUNE_O365","Deskless","FLOW_O365_P2","POWERAPPS_O365_P2",
    "RMS_S_ENTERPRISE","OFFICE_FORMS_PLAN_2","PROJECTWORKMANAGEMENT","SWAY","YAMMER_EDU","SHAREPOINTWAC_EDU","SHAREPOINTSTANDARD_EDU","EXCHANGE_S_STANDARD","MCOSTANDARD"
    )

    Write-Output "Adding licenses...`n"	
    Set-MsolUser -UserPrincipalName $UPNEmail -UsageLocation "US"
    $disableYammerOnly = New-MsolLicenseOptions -AccountSkuId "WVUHSC:STANDARDWOFFPACK_FACULTY" -DisabledPlans "YAMMER_EDU"
    Set-MsolUserLicense -UserPrincipalName $UPNEmail -AddLicenses "WVUHSC:STANDARDWOFFPACK_FACULTY" -LicenseOptions $disableYammerOnly
    $disableAllExceptO365Plus = New-MsolLicenseOptions -AccountSkuId "WVUHSC:STANDARDWOFFPACK_IW_FACULTY" -DisabledPlans $disabledplans
    Set-MsolUserLicense -UserPrincipalName $UPNEmail -AddLicenses "WVUHSC:STANDARDWOFFPACK_IW_FACULTY" -LicenseOptions $disableAllExceptO365Plus
    Write-Output "Licenses added for $($user.UserprincipalName)`n"
}




Function Get-NewAccountInfo
{
	#check if dN is empty and if not make sure not in new users OU
	if (![string]::IsNullOrEmpty($HsUser.DistinguishedName))
	{	
		if ($HSUser.DistinguishedName -like '*NewUsers*')
		{
			"`n"
			Write-Warning "It appears this user is still in NewUsers OU.  The account has not been processed.  Stopping program."
			"`n`n"			
			Exit
		}	
		else
		{
			"`n`n"
			write-host "AD Info" -foregroundcolor yellow 
			write-host "-------" -foregroundcolor yellow
			"`n"
			"Name        : " + $HSUser.CN
			"Department  : " + $HSUser.Department
			"OU          : " + $HSUser.DistinguishedName
			"Email       : " + $HSUser.EmailAddress
		}
		
		#Check to see if exAtt7 is set to Yes365
		if ($HSUser.extensionAttribute7 -ne "Yes365")
		{
			"`n"
			Write-Warning "exAtt7 is not set to Yes365.  This person does not need a office365 account.  Stopping program."
			"`n`n"
			Exit
		}
		else
		{
			"exAtt7      : " + $HSUser.extensionAttribute7
		}
		#End Check

		"`n`n"	
	
		#Check to see which licenses user has
		$user = $HSUser.extensionAttribute12
		write-host "MSOL Info" -foregroundcolor yellow
		write-host "---------" -foregroundcolor yellow
		Get-MsolUser -UserPrincipalName $user@hsc.wvu.edu | Format-List DisplayName,isLicensed,Licenses
		$MsolUserInfo = Get-MsolUser -UserPrincipalName $user@hsc.wvu.edu | Select-Object isLicensed
				
		if (($HSUser.extensionAttribute7 -eq "Yes365") -And ($MsolUserInfo.isLicensed -eq $false))
		{
			write-host "exAtt7 was set to yes but isLicensed is false." -foregroundcolor green
			Set-OfficeLicense
		}		
		"`n`n`n`n"
	}
	else
	{
		"`n"
		Write-Warning "No person by that name could be found in the HSC AD.  If you feel you received this error by mistake please check the spelling."
		"`n`n"
		Exit
	}
}




Function Get-NewAccountInfoMultUser
{	
	#check if dN is empty and if not make sure not in new users OU
	if (![string]::IsNullOrEmpty($HsUser.DistinguishedName))
	{	
		"`n`n"
		#list number of users found with that name
		write-host "Showing"$HSUser.length"results for $user." -foregroundcolor green

		#pause to see number of users
		start-sleep 3
		
		for ($i=0; $i -lt $HSUser.length; $i++)
		{
			if ($HSUser[$i].DistinguishedName -like '*NewUsers*')
			{
				"`n"
				Write-Warning "It appears this user is still in NewUsers OU.  The account has not been processed.  Stopping program."
				"`n`n"			
				Exit
			}	
			else
			{
				"`n`n"
				write-host "AD Info" -foregroundcolor yellow 
				write-host "-------" -foregroundcolor yellow
				"`n"
				"Name        : " + $HSUser[$i].CN
				"Department  : " + $HSUser[$i].Department
				"OU          : " + $HSUser[$i].DistinguishedName
				"Email       : " + $HSUser[$i].EmailAddress
			}
		
			#Check to see if exAtt7 is set to Yes365
			if ($HSUser[$i].extensionAttribute7 -ne "Yes365")
			{
				"`n"
				Write-Warning "exAtt7 is not set to Yes365.  This person does not need a office365 account.  Stopping program."
				"`n`n"
				Exit
			}
			else
			{
				"exAtt7      : " + $HSUser[$i].extensionAttribute7
			}
			#End Check

			"`n`n"	
	
			
			$user = $HSUser[$i].extensionAttribute12
			write-host "MSOL Info" -foregroundcolor yellow
			write-host "---------" -foregroundcolor yellow
			Get-MsolUser -UserPrincipalName $user@hsc.wvu.edu | Format-List DisplayName,isLicensed,Licenses
			$MsolUserInfo = Get-MsolUser -UserPrincipalName $user@hsc.wvu.edu | Select-Object isLicensed
				
			if (($HSUser.extensionAttribute7 -eq "Yes365") -And ($MsolUserInfo.isLicensed -eq $false))
			{
				write-host "exAtt7 was set to yes but isLicensed is false." -foregroundcolor green
				Set-OfficeLicense
			}		
			"`n`n`n`n"						
		}		
	}
	else
	{
		"`n"
		Write-Warning "No person by that name could be found in the HSC AD.  If you feel you received this error by mistake please check the spelling."
		"`n`n"
		Exit
	}
}




if ($HSUser.length -ne "$null")
{
	Get-NewAccountInfoMultUser	
}
else
{
	Get-NewAccountInfo
}