<#
	.SYNOPSIS
        This file backs up all AD extension attributes to a CSV file.

	.NOTES
		Backup-ADExtensionAttribute.ps1
		Last Modified by: Jeff Brusoe
		Last Modified: July 13, 2021
#>

[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]$ADMigrationPath = (Get-HSCGitHubRepoPath) +
                                "4ADMigrationProject\"
)
try {
    Set-HSCEnvironment -ErrorAction Stop
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $ErrorCount
}

$OutputFile = "$PSScriptRoot\Logs\" +
                (Get-Date -Format yyyy-MM-dd-HH-mm-ss) +
                "-ExtensionAttributesBackup.csv"

$ADMigrationLog = $ADMigrationPath + "UserExtensionAttributes\" +
                    (Get-Date -Format yyyy-MM-dd) +
                    "-ADUserExtensionAttributes.csv"

try {
    New-Item -ItemType File -Path $OutputFile -Force -ErrorAction Stop
    New-Item -ItemType File -Path $ADMigrationLog -Force -ErrorAction Stop
}
catch {
    Write-Warning "Unable to generate log files"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Getting HSC AD extension attributes"

    $Properties =   @("SamAccountName","UserPrincipalName","whenCreated","whenChanged",
                        "extensionAttribute1","extensionAttribute2","extensionAttribute3",
                        "extensionAttribute4","extensionAttribute5","extensionAttribute6",
                        "extensionAttribute7","extensionAttribute8","extensionAttribute9",
                        "extensionAttribute10","extensionAttribute11","extensionAttribute12",
                        "extensionAttribute13","extensionAttribute14","extensionAttribute15"
                        "DistinguishedName"
                        )

    $ADUsers = Get-ADUser -Filter * -Properties $Properties -ErrorAction Stop

	$ADUsers |
        Select-Object -Property $Properties |
        Export-Csv $OutputFile -NoTypeInformation

    $ADUsers |
        Select-Object -Property $Properties |
        Export-Csv $ADMigrationLog -NoTypeInformation

    Write-Output "Successfully backed up extension attribute"
}
catch {
    Write-Warning "Unable to backup extension attributes"
}
finally {
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}