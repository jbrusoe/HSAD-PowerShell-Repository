#--------------------------------------------------------------------------------
#
#  File:  5Misc-SharePointFunctions.ps1
#
#  Author:  Matt Logue
#
#  Last Update: October 20, 2017
#
#  Version:  1.0
#
#  Description: Contains various functions commonly used with SharePoint.
#
#---------------------------------------------------------------------------------

<#
.SYNOPSIS
 	This file contains various functions used in SharePoint Online.
    
.DESCRIPTION
 	This function has various SharePoint functions.  Most functions will require connecting to
	a SharePoint site with credentials that can access the specified site in the function.
	Most of these functions require a customized module to be located in C:\AD-Development\Custom-Modules
	The newest release of the module is available at https://gallery.technet.microsoft.com/office/SharePoint-Module-for-5ecbbcf0,
	but then has to be modified to import other desired fields.
 	
 	Functions currently in this file include:
 	1. Get-SPADExclusionList
 	
.PARAMETER
	Each function accepts certain parameters. See function comments to figure out what these are.

.NOTES
    Author: Matt Logue
    Last Updated: October 20, 2017
    This file is used for new accounts created by the Trident IDM system.
	
	Last Updated: September 16, 2019
	Update Purpose: Get files to work in GitHub directory.
#>

# This function pulls the "Do Not Disable List" from "https://wvuhsc.sharepoint.com/PowerShellDevelopment"
# If the "EndDate" in the field has passed the user does not get added to the exclusions

function Get-HSCSPOADExclusionList ()
{

	[CmdletBinding()]
	param ()
	
	#Check to make sure the Sharepoint 2016 Client SDK is install if not it sends you to the download page
	If (!(Test-Path "$env:ProgramFiles\Common Files\microsoft shared\Web Server Extensions\16\ISAPI"))
	{
		Write-Host "Not Installed: SharePoint Server 2016 Client Components SDK"
		$installit = Read-host "Would you like to install it? (y/n)"
		if ($installit -contains "y")
		{
			$IE=new-object -com internetexplorer.application
			$IE.navigate2("https://www.microsoft.com/en-us/download/details.aspx?id=51679")
			$IE.visible=$true
			return
		}
		else
		{
			return
		}
	}
	
	#imports the custom module for Sharepoint Functions
	Try 
	{
		Import-Module C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\HSC-SharePointOnlineModule\SharePointOnlineModule.psm1 -ErrorAction Stop
	}
	catch 
	{
		Write-Error -Message "Could not import SPOMod, please make sure path is valid"
		return
	}

	Write-Verbose "Generating user credentials from file"
	$password = Get-Content "C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\normal3.txt"  | convertto-securestring
	$UserCreds = New-Object -typename System.Management.Automation.PSCredential -argumentlist "microsoft3@hsc.wvu.edu", $password

	#Connects the she sharepoint site that contains the exclusion list
	##try 
	##{
		Write-Verbose "Attempting to connect to SharePoint Online"
		Connect-SPOCSOM -Url "https://wvuhsc.sharepoint.com/PowerShellDevelopment" -Credential $UserCreds 
		 
		$list = Get-SPOListItems -ListTitle "DoNotDisableList"
	
		$ADExclusionList = New-Object System.Collections.ArrayList
	
		#Adds each user to an array as long as the "enddate" is null or >= current date
		foreach ($user in $list)
		{
			if (($user.EndDate -eq $null) -OR ($user.EndDate -ge (Get-Date)))
			{
				[void]$ADExclusionList.Add($user.Title)
			}
		}
		
		return $ADExclusionList
	
	##}

	##catch
	##{
	##	Write-host "$($_.Exception.Message)" -foregroundcolor red
	##	return
	##}
	
}

Export-ModuleMember -Function Get-HSCSPOADExclusionList