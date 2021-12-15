<#
	.SYNOPSIS
		The purpose of this file is to read a log file from the SCCM Share
		and set the AD Location attribute on the PC after it is imaged.

	.PARAMETER SCCMComputerLocationPath
		The path to the log files which are read to get location information

	.NOTES
		Originally Written by: Matt Logue
		Currently Maintained by: Jeff Brusoe
		Last Modified: February 11, 2021
#>

[CmdletBinding()]
param (
	[ValidateNotNullOrEmpty()]
	[string]$SCCMComputerLocationPath = "\\hssccm\Packages\Logs\SCCMComputerLocations"
)

try {
	Set-HSCEnvironment -ErrorAction Stop

	if (Test-Path $SCCMComputerLocationPath) {
		Write-Output "SCCM Computer Locations: $SCCMComputerLocationPath"
	}
	else {
		throw "$SCCMComputerLocationPath does not exist"
	}
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#Done is a folder in the SCCMComputerLocationPath
try {
	Write-Output "Searching $SCCMComputerLocationPath"

	$GetChildItemParams = @{
		Path = $SCCMComputerLocationPath
		Exclude = "Done"
		ErrorAction = "Stop"
	}

	$SCCMComputerLocations = Get-ChildItem @GetChildItemParams
}
catch {
	Write-Warning "Unable to search $SCCMComputerLocations"
}

foreach ($SCCMComputerLocation in $SCCMComputerLocations) {
	try {
		$ComputerRoom = Get-Content $SCCMComputerLocation -ErrorAction Stop
		$ComputerName = $($SCCMComputerLocation.Name) -replace ".txt",""
	}
	catch {
		Write-Warning "Unble to read computer location information"
	}

    Write-Output "Trying Computer: $ComputerName"
	Write-Output "Computer Room: $ComputerRoom"

	try {
		$SetADComputerParams = @{
			Identity = $ComputerName
			Location = $ComputerRoom
			ErrorAction = "Stop"
		}
		Set-ADComputer @SetADComputerParams
		Write-Output "Successfully set computer location information"

		Start-Sleep -s 2

		$GetADComputerParams = @{
			Identity = $ComputerName
			Properties = "Location"
			ErrorAction = "Stop"
		}

		$TestLocation = Get-ADComputer @GetADComputerParams |
			Select-Object Name,Location

		if ($TestLocation.Location -eq $ComputerRoom) {
			$MoveItemParams = @{
				Path = "$SCCMComputerLocationPath\$($SCCMComputerLocation.Name)"
				Destination = "$SCCMComputerLocationPath\Done\$($SCCMComputerLocation.Name)"
				Force = $true
				ErrorAction = "Stop"
			}

			Move-Item @MoveItemParams
		}
	}
	catch {
		Write-Warning "$ComputerName - Computer Not Found"
	}

	Write-Output "***************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count