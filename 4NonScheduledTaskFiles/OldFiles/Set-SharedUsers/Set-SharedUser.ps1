<#
.SYNOPSIS
 	      
    
.DESCRIPTION
 	      
 	
.PARAMETER
	    Paramter information.

.NOTES
	    Author: Kevin Russell
    	Last Updated by: Kevin Russell
	    Last Updated: 11/06/2019		
#>

$SessionTranscript = "c:\users\microsoft\documents\github\hsc-powershell-repository\4nonscheduledtaskfiles\set-sharedusers\Logs\" + $((Get-Date -Format yyyy-MM-dd) + "-SessionTranscript.txt")
Start-Transcript $SessionTranscript -Force

#Change PowerShell window title
$Host.UI.RawUI.WindowTitle = "Set ExAtt10 to Shared for shared users"

#import modules
Write-Host "Importing modules..."
Try
{
	Install-Module -Name ImportExcel -RequiredVersion 5.4.2 #need to add yes -no reply 
	Write-Host "`nImportExcel module loaded fine" -Foregroundcolor "Green"
}
catch
{
	Write-Host "`nThere was an error importing the ImportExcel module :(" -Foregroundcolor "Red"
	Write-Host "Module required.  Exiting program" -Foregroundcolor "Red"
	Exit
}
Try
{
	Import-Module -Name ActiveDirectory
	Write-Host "ActiveDirectory module loaded fine" -Foregroundcolor "Green"
}
Catch
{
	Write-Host "There was an error importing the ActiveDirectory module :(" -Foregroundcolor "Red"
}

Write-Host "Importing shared users excel file..."
$SharedUsers = Import-Excel -Path "\\hs-tools\tools\SharedUsersRpt\Shared Users HSC WVUPC 1106.xlsx"

#Check to make sure file is not empty
if ($SharedUsers -ne $null)
{
	Write-Host "The shared users file was imported successfully." -Foregroundcolor "Green"			
}
else
{
	Write-Host "There was a problem importing shared users file.  Stopping program." -Foregroundcolor "Red"
}
#End check

foreach ($user in $SharedUsers)
{
	
	Try
	{
		$exAtt10 = Get-ADuser -Identity $user.uid -Properties extensionAttribute10	
	
		if ($user.Status -eq "Accepted")
		{
			Write-Host "`n*******************************"
			Write-Host "$($user.firstname) $($user.lastname) is an accepted user.  Checking exAtt10 for status."		
			Write-Host "username            : "$user.uid
			Write-Host "status              : "$user.status
			Write-Host "extensionAttribute10: "$exAtt10.extensionAttribute10
			Write-Host "-------------------------------"
			if ($exAtt10.extensionAttribute10 -eq "Shared")
			{
				Write-Host "No changes made."
				Write-Host "*******************************"
			}
			else
			{
				Write-Host "$($user.uid) is not set as a shared user.  Changing exAtt10 to Shared."
				Try
				{
					Set-AdUser -Identity $user.uid -Replace @{extensionAttribute10="Shared"}
					Write-Host "extensionAttribute10 for $($user.firstname) $($user.lastname) has been change." -Foregroundcolor "Green"
					Write-Host "*******************************"
				}
				Catch
				{
					Write-Host "There was an error trying to set exAtt10" -Foregroundcolor "Red"
					Write-Host "*******************************"
				}
			}
		}
		else
		{
			Write-Host "`n*******************************"
			Write-Host "$($user.firstname) $($user.lastname) is not an accepted user.  No changes made."
			Write-Host "username            : "$user.uid
			Write-Host "status              : "$user.status
			Write-Host "extensionAttribute10: "$exAtt10.extensionAttribute10
			Write-Host "*******************************"		
		}
	}
	Catch
	{
		Write-Host "`n$($user.firstname) $($user.lastname) does not exist.`n" -Foregroundcolor "Magenta"
	}
}


Stop-Transcript