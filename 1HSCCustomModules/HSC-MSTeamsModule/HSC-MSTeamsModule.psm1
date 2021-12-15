function Clear-HSCMSTeamsCache
{
	<#
		.SYNOPSIS
			The purpose of this function is to clear the cache for Microsoft Teams.  If Teams is open it will 
			shut down the program, search the apporiate folder and delete the contents while retaining the
			folder structure.
		.EXAMPLE
			.\Clear-HSCMSTeamsCache.ps1

		.EXAMPLE

		.NOTES
			Written by: Kevin Russell
			Last Updated: 
			
			PS Version 5.1 Tested:
			PS Version 7.0.2 Tested:
	#>
	[CmdletBinding()]
	param()
	

	#Folders to check and remove files from
	$FoldersToCheck = @("Application Cache\Cache","Blob_storage","Cache","databases","GPUCache","IndexedDB","Local Storage","tmp")

	$teams = Get-Process -Name "Teams" -ErrorAction SilentlyContinue

	if ($teams)
	{
		$teams  | Stop-Process -Force
		Write-Host "Teams has been shut down" -ForegroundColor Green
		
		#Adding pause to wait for program to shut down 7/13/20
		Start-Sleep -s 3
	}
	else
	{
		Write-Host "Teams not currently running" -ForegroundColor Green
	}

	ForEach ($Folder in $FoldersToCheck)
	{
		$folderPath = "$env:appdata\Microsoft\teams\$Folder"
		if (Test-Path -Path $folderPath)
		{
			Write-Host "Deleting file in $Folder folder"
			Get-ChildItem -Path $folderPath -File -Recurse | ForEach {$_.Delete()}
		}
		else
		{
			Write-Host "$Folder does not exist" -ForegroundColor Magenta
		}
	}
}
