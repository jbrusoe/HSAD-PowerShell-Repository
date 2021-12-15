#------------------------------------------------------------------------------------------------
#Import-ADInfoUpdate.ps1
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

#$SessionTranscript = "c:\AD-Development\Import-ADInfoUpdate\Logs\" + $((Get-Date -Format yyyy-MM-dd) + "-SessionTranscript.txt")
#Start-Transcript $SessionTranscript -Force

#Change PowerShell window title
$Host.UI.RawUI.WindowTitle = "AD Description/Location update"

#Path to file
$FilePath = "c:\AD-Development\Import-ADInfoUpdate"
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
		$ComputerName = $PC.Name
		
		#search AD for machine
		$Comp = Get-ADComputer -LDAPFilter "(Name=$ComputerName*)"
		
		#Make sure its not null, empty or has white spaces
		$EmptyValue = [string]::IsNullOrEmpty($Comp)
		$WhiteSpaceValue = [string]::IsNullOrWhiteSpace($Comp)
		
		if ($EmptyValue -OR $WhiteSpaceValue)
		{
			Write-Host "`n$($PC.Name) was not found." -Foregroundcolor "Red"
			Write-Output "$($PC.Name) was not found.  Please verify machine name." | Add-Content -Path ".\Logs\" + $((Get-Date -Format yyyy-MM-dd) + "-FailureToFind.txt") -Force
		}
		else
		{
			if ($Comp.length -ne "$null")
			{
				Write-Host "`nShowing"$Comp.length"results for $($PC.Name)" -Foregroundcolor "Magenta"
				Write-Output "$($PC.Name) is showing multiple entries.  Something done went wacky." | Add-Content -Path ".\Logs\" + $((Get-Date -Format yyyy-MM-dd) + "-MultipleMachines.txt") -Force
			}
			else
			{							
				[string]$SearchBase = $Comp				
				$ADPCName = ("$SearchBase" -split ',*..=')[1]
				
				
				Write-Host "`n$($PC.Name) was found.  AD name is $ADPCName" -Foregroundcolor "Green"				
								
				#save any old data wanted				
				$OldDesc = $Comp.Description				
				$OldLocation = $Comp.Location
				
				
				#set new data, comment out what is not used (description) or add new fields
				$Comp.Description = $PC.Description
				$Comp.Location = $PC.Location		
				
				Try
				{
					Set-ADComputer -Instance $Comp
					Write-Host "$ADPCName was successfully updated." -Foregroundcolor Green
					Write-Host "Description changed from $OldDesc to $($Comp.Description)"
					Write-Host "Location was changed from $OldLocation to $($Comp.Location)"
					Write-Output "$ADPCName was successfully found." | Add-Content FoundAndChanged.txt
					Write-Output "LDAP $SearchBase" | Add-Content FoundAndChanged.txt
					Write-Output "Location changed from $OldLocation to $($Comp.Location)" | Add-Content -Path ".\Logs\" + $((Get-Date -Format yyyy-MM-dd) + "-FoundAndChanged.txt") -Force
					Write-Output "Description changed from $OldDesc to $($Comp.Description)" | Add-Content -Path ".\Logs\" + $((Get-Date -Format yyyy-MM-dd) + "-FoundAndChanged.txt") -Force
					Write-Output "=========================================================" | Add-Content -Path ".\Logs\" + $((Get-Date -Format yyyy-MM-dd) + "-FoundAndChanged.txt") -Force
				}
				Catch
				{
					Write-Host "There was an error updating $ADPCName." -Foregroundcolor Red
					Write-Output "$ADPCName was successfully found, however there was an error updating.  Located at $SearchBase." | Add-Content -Path ".\Logs\" + $((Get-Date -Format yyyy-MM-dd) + "-FailureToChange.txt") -Force
				}
			}			
		}	
}

#Stop-Transcript

#pause until user hits key
Write-Host "`nPress any key to exit...." -foregroundcolor Green
[void][System.Console]::ReadKey($true)