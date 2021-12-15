<#
	.SYNOPSIS
		This module contains functions used by HSC PowerShell functions related
		to SharePoint Online.

	.DESCRIPTION
		The following functions are contained within it:
		1. Get-HSCSPOCancerCenterDL
		2. Get-HSCSPOCredential
		2. Get-HSCSPOExclusionList

	.NOTES
		Written by: Jeff Brusoe
		Last Updated by: Jeff Brusoe
		Last Updated: August 12, 2021

		Requires PnP PowerShell module:
		https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-pnp/sharepoint-pnp-cmdlets?view=sharepoint-ps
#>

[CmdletBinding()]
param()

function Connect-HSCSPOnline
{
	<#
		.SYNOPSIS

		.DESCRIPTION

		.OUTPUTS
			bool

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: August 12, 2021
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string]$SiteURL
	)

	Write-Verbose "Site URL: $SiteURL"

	try
	{
		Write-Verbose "Getting Connection Account"
		$Account = Get-HSCConnectionAccount -ErrorAction Stop
		Write-Verbose "Connection Account: $Account"

		$EncryptedFilePath = Get-HSCEncryptedFilePath -ErrorAction Stop
		Write-Verbose "Encrypted File Path: $EncryptedFilePath"

		Write-Verbose "Generating user credentials from file"
		$Password = Get-Content $EncryptedFilePath -ErrorAction Stop |
						ConvertTo-SecureString -ErrorAction Stop

		Write-Verbose "Successfully decrypted password"
	}
	catch {
		Write-Warning "Unable to decrypt password"
		return $false
	}

	try
	{
		Write-Verbose "Generating credential for $Account"

		$Password = Get-Content $EncryptedFilePath -ErrorAction Stop |
						ConvertTo-SecureString -ErrorAction Stop

		$Credential = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $Account, $Password

		Write-Verbose "Successfully generated credential object"
	}
	catch {
		Write-Warning "Error generating SPO credential"
		return $false
	}

	try {
		Write-Verbose "Connecting to SPO site"
		Connect-PnPOnline -Url $SiteURL -Credentials $Credential -ErrorAction Stop
	}
	catch {
		Write-Warning "Unable to connect to SharePoint Online"
		return $false	
	}

	return $true
}

function Get-HSCSPOCancerCenterDL
{
	<#
		.SYNOPSIS

		.DESCRIPTION

		.OUTPUTS
			PSObject

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: August 13, 2021
	#>

	[CmdletBinding()]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$SiteURL = "https://wvuhsc.sharepoint.com/sites/mbrcc/DL",

		[ValidateNotNullOrEmpty()]
		[string]$ListName = "DL"
	)

	try {
		$SPConnection = Connect-HSCSPOnline -SiteURL $SiteURL -ErrorAction Stop

		if (!$SPConnection) {
			throw
		}
		else {
			Write-Output "Successfully connected to SharePoint Online"
		}
	}
	catch {
		Write-Warning "Unable to connect to SharePoint Online"
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}

	try {
		Write-Output "Pulling List Data"

		$GetPnPListItemParams = @{
			List = $ListName
			Fields = @(	"DLName",
						"PrimaryLocation",
						"Email_x0020_Address_x0020__x002d",
						"EmailAddress"
					)
			ErrorAction = "Stop"
		}

		$ListItems = Get-PnPListItem @GetPnPListItemParams
		#Use Get-PnPField to find the names. The displayed field names 
		#do not match up with the fields you actually query.

		return $ListItems
	}
	catch {
		Write-Warning "Unable to pull list data"
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}
}

function Get-HSCSPOCredential 
{
	<#
		.SYNOPSIS

		.DESCRIPTION

		.OUTPUTS
			PSObject

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: August 12, 2021
	#>
	
}

function Get-HSCSPOExclusionList
{
	<#
		.SYNOPSIS
			This function retrieve users who are in the HSC exlusion list from SharePoint Online.

		.DESCRIPTION
			Users in the exlusion list include those with a null end date as well as ones who still have
			a valid end date set. This is a safety measure to ensure that certain users are not disabled
			due to incorrect settings.

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: September 2, 2020
	#>

	[CmdletBinding()]
	[OutputType([String[]])]
	param (
    	[ValidateNotNull()]
		[string]$SiteURL="https://wvuhsc.sharepoint.com/PowerShellDevelopment",

    	[ValidateNotNull()]
		[string]$ListName= "DoNotDisableList"
	)

	try
	{
		Write-Verbose "Getting Connection Account"
		$Account = Get-HSCConnectionAccount
		Write-Verbose "Connection Account: $Account"

		$EncryptedFilePath = Get-HSCEncryptedFilePath
		Write-Verbose "Encrypted File Path: $EncryptedFilePath"

		Write-Verbose "Generating user credentials from file"
		$Password = Get-Content $EncryptedFilePath  | ConvertTo-SecureString
	}
	catch
	{
		Write-Warning "Unable to decrypt password"
		Invoke-HSCExitCommand
	}

	try
	{
		Write-Verbose "Generating credential for $Account"

		$Password = Get-Content $EncryptedFilePath  | ConvertTo-SecureString
		$Credential = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $Account, $Password

		Write-Verbose "Successfully generated credential object"
	}
	catch
	{
		Write-Warning "Error generating credential. Unable to connect to SharePointOnline"
		Invoke-HSCExitCommand
	}

	try
	{
		Connect-PnPOnline -Url $SiteURL -Credentials $Credential -ErrorAction Stop

		$GetPnPListItemParams = @{
			List = $ListName
			Fields = @(	"Title",
						"End_x0020_Date"
					)
			ErrorAction = "Stop"
		}
		$ListItems = Get-PnPListItem @GetPnPListItemParams
		#Use Get-PnPField to find the names. The displayed field names 
		#do not match up with the fields you actually query.

		$ADExclusionList = @()

		#Adds each user to an array as long as the "enddate" is null or >= current date
		foreach ($ListItem in $ListItems)
		{
			if (($null -eq $ListItem["End_x0020_Date"]) -OR ([datetime]$ListItem["End_x0020_Date"] -ge (Get-Date)))
			{
				$ADExclusionList += $ListItem["Title"]
			}
		}

		return $ADExclusionList
	}
	catch
	{
		Write-Warning "Unable to retrieve HSC exclusion list. Program is exiting."
		Invoke-HSCExitCommand
	}
}