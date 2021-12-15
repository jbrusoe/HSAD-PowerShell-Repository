<#
	.SYNOPSIS
    	This file makes a backup of all proxy addresses for users in the
    	WVUM AD domains.

	.PARAMETER OutputFile
		The name of the file to write the proxy addresses to

	.PARAMETER Domains
		These are the WVUM domains that will be searched

	.NOTES
		Written by: Jeff Brusoe
		Last Updated: August 3, 2021
#>

[CmdletBinding()]
param(
	[ValidateNotNullOrEmpty()]
	[string]$OutputFile = ("$PSScriptRoot\Logs\" +
							(Get-Date -Format yyyy-MM-dd-hh-mm) +
							"-WVUMProxyAddresses.csv"),

	[ValidateNotNullOrEmpty()]
	[string[]]$Domains = @(
						"wvuh.wvuhs.com",
						"wvuhs.com"
					)
)

try {
    Write-Output "Configuring Environment"
	Set-HSCEnvironment -ErrorAction Stop

	Write-Output "Output File: $OutputFile"
	Write-Output "Domains:"
	Write-Output $Domains
}
catch {
	Write-Warning "Error configuring environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#Begin main part of program
foreach ($Domain in $Domains)
{
	Write-Output "Generating list of WVUM $Domain Users"
	$Properties = @(
				"proxyAddresses",
				"mail"
				)

	try {
		$GetADUserParams = @{
			Filter = "*"
			Properties = $Properties
			Server = $Domain
			ErrorAction = "Stop"
		}
		
		$WVUMADUsers = Get-ADUser @GetADUserParams
	}
	catch {
		Write-Warning "Unable to query the HS Domain and generate AD user list"
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}

	foreach ($WVUMADUser in $WVUMADUsers)
	{
		Write-Output $("Current User: " + $WVUMADUser.SamAccountName)

		$ProxyAddresses = $WVUMADUser.ProxyAddresses
		Write-Output "ProxyAddresses:"
		Write-Output $ProxyAddresses

		$WVUMADUser |
			Select-Object UserPrincipalName,
							SamAccountName,
							mail,
							@{name="Domain";expression={$Domain}},
							@{name="ProxyAddresses";expression={$ProxyAddresses -join ";"}},
							DistinguishedName |
			Export-Csv $OutputFile -NoTypeInformation -Append

		Write-Output "*********************************"
	}
}

Invoke-HSCExitCommand -ErrorCount $Error.Count