#Test-HSOrgUnitDN.ps1
#Written by: Jeff Brusoe
#Last Updated: September 3, 2019

#The purpose of this function is to test if the $HSADOUDN
	
	
[CmdletBinding()]
param (
	[string]$HSADOUDN = "OU=hsc,dc=hs,dc=wvu-ad,dc=wvu,dc=edu"
)

Write-Output "Attempting to find this org unit:" | Out-Host
Write-Output $HSADOUDN | Out-Host

try
{
	Get-ADOrganizationalUnit -Identity $HSADOUDN -ErrorAction Stop | Out-Host
	Write-Output "Found the DN" | Out-Host
	
	return $true
}
catch
{
	Write-Warning "The org unit doesn't exist." | Out-Host
	
	return $false
}