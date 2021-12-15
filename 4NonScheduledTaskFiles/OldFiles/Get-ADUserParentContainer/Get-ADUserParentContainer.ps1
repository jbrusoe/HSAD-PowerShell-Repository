#Get-ADUserParentContainer.ps1
#Written by: Jeff Brusoe
#Last Updated: August 30, 2019
#
#The purpose of this file is to get the AD Users's parent container.
#This needs to be added to the AD module common code file.

[CmdletBinding()]
param (
	[string]$User
	)

Write-Output "Searching for $User"

try
{	
	$ADUser = Get-ADUser $User -ErrorAction Stop
	Write-Output "Successfully found user"
}
catch
{
	Write-Warning "User not found."
	return
}

$UserDN = $ADUser.DistinguishedName
Write-Output "User DN: $UserDN"

$ParentContainer = $UserDN.substring($UserDN.indexOf("OU="))
$ParentContainer = $ParentContainer.substring(0,$ParentContainer.indexOf(","))
Write-Output "Parent Container: $ParentContainer"