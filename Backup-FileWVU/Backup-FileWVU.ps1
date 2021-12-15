#PowerShell File Backup
#Written by: Jeff Brusoe
#Last Updated: July 21, 2021
#
#This file backs up the sysscript servers, nursing databases, and my VDI machine.
#The config file (BackupMap.csv) is stored locally on my VDI machine.

#To do: Build in option to do incremental backup

[CmdletBinding()]
param
(
	[string]$BackupMap="BackupMap.csv",
	[string]$ExcludeDirectories = "C:\Users\jbrusoeadmin\Documents\GitHub\HSC-PowerShell-Repository\.git\*"
)

try {
	Set-HSCEnvironment -ErrorAction Stop

	$BackupDirectories = Import-Csv $BackupMap -ErrorAction Stop
	Write-Output $BackupDirectories
}
catch {
	Write-Warning "Error Configuring Environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$BackupDirectory = "c:\users\jbrusoeadmin\desktop\" + 
					(Get-Date -format yyyy-MM-dd-HH-mm) +
					"-Backups"

$NursingBackups = "c:\users\jbrusoeadmin\desktop\" + (Get-Date -format yyyy-MM-dd-HH-mm) + "-Nursing-Backups"

Write-Output $("Creating Backup Directory: $BackupDirectory")
mkdir $BackupDirectory

Write-Output $("Creating Nursing Backup Directory: $NursingBackups")
mkdir $NursingBackups

Start-Sleep -s 1

foreach ($Directory in $BackupDirectories)
{

	if ($Directory.BackupType -eq "Regular")
	{
		Set-Location $BackupDirectory

		try
		{
			$DestinationDirectory = $BackupDirectory + "\" + $Directory.Name
			Write-Output "Creating: $DestinationDirectory"

			New-Item -Path $DestinationDirectory -type "directory" -ErrorAction Stop

			Write-Output "Successfully created backup directory"
		}
		catch {
			Write-Output "Destination directory already exists"
		}

		Start-Sleep -s 1

		#Start file copies
		$Path = $Directory.DirectoryPath
		Write-Output "Copying directory: $Path"

		$CopyItemParams = @{
			Path = $Path
			Destination = $DestinationDirectory
			Verbose = $true
			Recurse = $true
			Exclude = $ExcludeDirectories
			ErrorAction = "Stop"
		}

		Copy-Item @CopyItemParams

		Write-Output "Done copying directory"

	}
	elseif ($Directory.BackupType -eq "Nursing")
	{
		#Should be the case for nursing backups

		Set-Location $NursingBackups

		Write-Output $("Copying directory: " + $Directory.DirectoryPath)

		if ($Directory.DirectoryPath.indexOf("hssql2") -gt 0) {
			Copy-Item $Directory.DirectoryPath -Destination $NursingBackups -Verbose
		}
		else {
			Copy-Item $Directory.DirectoryPath -Destination $NursingBackups -Verbose -Recurse
		}
	}
}

#This code is here in order to remove 0 byte files. They cause a cosmetic error
#when saving these directories to OneDrive.
$Files = Get-ChildItem $BackupDirectory -Recurse

foreach ($File in $Files)
{
	if ($File.Length -eq 0) {
		"Deleting file: " + $File.Fullname
		"File Size: " + $File.Length

		Remove-Item $File.Fullname
	}
}

Write-Output "Backup Complete"
Invoke-HSCExitCommand -ErrorCount $Error.Count