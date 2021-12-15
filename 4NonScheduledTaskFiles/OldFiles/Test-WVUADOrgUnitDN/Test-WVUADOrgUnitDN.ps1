#Test-WVUADOrgUnitDN.ps1
#Written by: Jeff Brusoe
#Last Updated: September 3, 2019

#The purpose of this function is to test if an org unit is valid in WVU-AD

[CmdletBinding()]
param (
	[string]$WVUADOUDN = "OU=HSC,OU=Main,DC=wvu-ad,DC=wvu,DC=edu",
	[string]$SearchRoot = "LDAP://OU=Main,DC=wvu-ad,DC=wvu,DC=edu"	
)

Write-Output "Attempting to find this org unit:" | Out-Host
Write-Output $WVUADOUDN | Out-Host

try
{
	$WVUAD = New-Object System.DirectoryServices.DirectoryEntry($SearchRoot)
	$Searcher = New-Object System.DirectoryServices.DirectorySearcher
	$Searcher.SearchRoot = $WVUAD
	$Searcher.PageSize = 50000
	$Searcher.Filter = "(&(objectCategory=organizationalUnit)(DistinguishedName=$WVUADOUDN))"
	$Searcher.SearchScope = "Subtree"

	$SearchResults = $Searcher.FindAll()
	Write-Output $("Number of Org Units Found: " + $SearchResults.length) | Out-Host
	
	if ($SearchResults.length -eq 0)
	{
		Write-Warning "Could not find the OU" | Out-Host
		return $false
	}
	elseif ($SearchResults.length -eq 1)
	{
		Write-Output "Found the DN" | Out-Host
		return $true
	}
	else
	{
		#This is the case where a non-unique OU was found.
		Write-Warning "Multiple org units were found." | Out-Host
		
		return $false
	}
}
catch
{
	Write-Warning "The org unit doesn't exist." | Out-Host
	
	return $false
}