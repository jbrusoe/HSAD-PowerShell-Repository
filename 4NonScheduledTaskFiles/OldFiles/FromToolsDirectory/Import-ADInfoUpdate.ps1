#------------------------------------------------------------------------------------------------
#Import-SoDADDescUpdate.ps1
#
#Written by: Kevin Russell
#
#Last Modified by: 
#
#Last Modified date: 
#
#Version: 1
#
#Purpose: The purpose of this script is to accept in a CSV file with columns titled Name and 
#         Description and Location that populates AD with the desired description for the machine
#------------------------------------------------------------------------------------------------


#Change PowerShell window title
$Host.UI.RawUI.WindowTitle = "Import Description field for SoD IT AD info update"

#Path to file
$FilePath = Read-Host "Enter the path to the file"
$FileName = Read-Host "Enter the name of the file, include .csv"

#Import list
Write-Host "`n`nPreparing to import CSV..." -Foregroundcolor "Green"
$PCList = Import-CSV $FilePath\$FileName

#Check to make sure file is not empty
if ($PCList -ne $null)
{
	Write-Host "Your CSV file was imported successfully." -Foregroundcolor "Green"
}

else
{
	Write-Host "There was a problem importing your file.  Stopping program." -Foregroundcolor "Red"
	Exit
}
#End check

foreach ($PC in $PCList)
{	
	Try
	{
		$Comp = Get-ADComputer -Identity $PC.Name
		Write-Host "`n$PC.Name was successfully found" -Foregroundcolor "Green"
	}
	Catch
	{
		Write-Host "`n$PC.Name was not found.  Please verify machine name." -Foregroundcolor "Red"
	}
	Try
	{
		$Comp.Description = $PC.Description
		$Comp.Location = $PC.Location		
		Set-ADComputer -Instance $Comp
		Write-Host "`nThe description and location were successfully updated." -Foregroundcolor "Green"
	}
	Catch
	{
		Write-Host "`nThere was a problem updating the description and location.  Nothing has been changed." -Foregroundcolor "Red"
	}
}

#pause until user hits key
Write-Host "Press any key to exit...." -foregroundcolor Green
[void][System.Console]::ReadKey($true)