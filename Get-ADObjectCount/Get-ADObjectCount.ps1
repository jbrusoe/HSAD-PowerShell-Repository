# Get-ADObjectCount.ps1
# Written by: Jeff Brusoe
# Last Updated: October 13, 2021
#
# This file counts all of the different types of
# objects in AD and is used to help monitor the
# AD migration project.

[CmdletBinding()]
param (
	[ValidateNotNullOrEmpty()]
	[string]$OutputFilePath = (Get-HSCGitHubRepoPath) +
								"4ADMigrationProject\"
)

try {
	Set-HSCEnvironment -ErrorAction Stop

	$ADObjectCountLog = $OutputFilePath + "ObjectCount\ADObjectCount.csv"
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
	Write-Output "Getting list of all AD Objects"

	$ADObjects = Get-ADObject -Filter * -ErrorAction Stop
}
catch {
	Write-Warning "Unable to get list of AD objects"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$SummaryInfo = [PSCustomObject]@{
	Date = Get-Date
	Total = $ADObjects.Count
}

try {
	Write-Output "Generating list of AD object types"

	$ADObjectTypes = $ADObjects |
		Select-Object objectClass -Unique -ErrorAction Stop

	Write-Output "Unique AD Object Types:"
	Write-Output $ADObjectTypes
	Write-Output "`n*****************************`n"
}
catch {
	Write-Warning "Unable to determine unique AD object types"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($ADObjectType in $ADObjectTypes)
{
	Write-Output $("Current AD Object Type: " + $ADObjectType.objectClass)

	$Count = ($ADObjects |
				Where-Object {$_.objectClass -eq $ADObjectType.objectClass} |
				Measure-Object).Count

	$AddMemberParams = @{
		MemberType = "NoteProperty"
		Name = $ADObjectType.objectClass
		Value = $Count
		ErrorAction = "Stop"
	}

	try {
		$SummaryInfo | Add-Member @AddMemberParams
	}
	catch {
		Write-Warning "Unable to get count for AD object type"
	}

	Write-Output "Object Type Count: $Count"
	Write-Output "*********************************"
}

$SummaryInfo

try {
	$SummaryInfo |
		Export-Csv $ADObjectCountLog -NoTypeInformation -Append -ErrorAction Stop

	Write-Output "Finished writing to log file"
}
catch {
	Write-Warning "Unable to write summary log file"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count