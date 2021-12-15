<#
	.SYNOPSIS
        This file makes a backup of all proxy addresses for users in the
        HS AD Domain.

	.NOTES
		Written by: Jeff Brusoe
		Last Updated: November 19, 2020
#>

[CmdletBinding()]
param(
	[ValidateNotNullOrEmpty()]
	[string]$OutputFile = ("$PSScriptRoot\Logs\" +
							(Get-Date -Format yyyy-MM-dd-hh-mm) +
							"-HSADProxyAddresses.csv")
)

#Initialize environment
try {
    Write-verbose "Configuring Environment"
	Set-HSCEnvironment -ErrorAction Stop
}
catch {
	Write-Warning "Error configuring environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output "Output File: $OutputFile"

#Begin main part of program
Write-Output "Generating list of HS AD Users"
try {
    $ADUsers = Get-ADUser -Filter * -ErrorAction Stop -Properties proxyAddresses,mail
}
catch {
    Write-Warning "Unable to query the HS Domain and generate AD user list"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($ADUser in $ADUsers)
{
    Write-Output $("Current User: " + $ADUser.SamAccountName)

    $ProxyAddresses = $ADUser.ProxyAddresses #| Where-Object {$_ -match "^smtp"}
	Write-Output "ProxyAddresses:"
    Write-Output $ProxyAddresses

	$ADUser |
		Select-Object UserPrincipalName,
						SamAccountName,
						mail,
						@{name="ProxyAddresses";expression={$ProxyAddresses -join ";"}},
						DistinguishedName |
		Export-Csv $OutputFile -NoTypeInformation -Append

    Write-Output "*********************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count