<#
    .SYNOPSIS
		The purpose of this function is to get the SCCM resource field
		that has the primary machine for a user	listed

    .DESCRIPTION

    .PARAMETER
		SiteCode - This the SCCM site code which is HS1

		ProviderMachineName - this is the SCCM server that has the provider
							  machine role

		UserName - user you want to lookup

    .INPUTS

    .OUTPUTS

    .EXAMPLE
		PS C:\> Get-HSCSCCMPrimaryPC -UserName "krussell"

    .LINK

    .NOTES
        Author: Kevin Russell
		Created: 03/16/21
        Last Updated:
        Last Updated By:

#>

[CmdletBinding()]
param (
	[string]$SiteCode = "HS1",

	[string]$ProviderMachineName = "hssccm.hs.wvu-ad.wvu.edu",

	$initParams = @{},

	[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
	[string]$UserName = "",

	[string]$CurrentLocation = (Get-Location)
)

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
$User = "HS\" + $UserName
$ComputerArray = @()
$ComputerArray = (Get-CMUserDeviceAffinity -UserName $User).ResourceName
#End Primary machine


$PrimaryMachineObject = [PSCustomObject]@{
	UserName = $UserName
	PrimaryMachine = $ComputerArray
}

if ($ComputerArray.Count -eq 0) {
	$ComputerArray = "No Primary machine found"
}
elseif ($ComputerArray.Count -gt 1) {
	for ( $index = 0; $index -lt $ComputerArray.length; $index++) {
		$PrimaryMachineObject | add-member NoteProperty PrimaryMachine$index $ComputerArray[$index]
	}
}

$PrimaryMachineObject

Set-Location $CurrentLocation