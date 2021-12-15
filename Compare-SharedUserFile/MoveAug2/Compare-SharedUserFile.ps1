<#
.SYNOPSIS
          This file compares the current days shared users file with the previous days shared
          users file.  If it find any new users it marks exatt10 as Shared and if it find any
          removed users it changes exatt10 back to Standard User.  It also emails 
          Michele/Jackie/Cindy B/myself a list of the removed users.
    
.DESCRIPTION
 	      
 	
.PARAMETER
	    Paramter information.

.NOTES
	    Author: Kevin Russell
    	Last Updated by: Kevin Russell
	    Last Updated: 10/6/2020
		
		Assumes file name will be "Shared Users HSC WVUPC MMdd.xlxs"
#>

$SessionTranscript = "\\hs-tools\tools\SharedUsersRpt\Logs\" + $((Get-Date -Format yyyy-MM-dd) + "-SessionTranscript.txt")
Start-Transcript $SessionTranscript -Force

#Change PowerShell window title
$Host.UI.RawUI.WindowTitle = "Compare Shared Users Report"


$InstalledModules = Get-InstalledModule

if ($InstalledModules.Name -contains "ImportExcel")
{
    Write-Host "ImportExcel module already loaded"
}
else
{
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
}


#Find day of week
$DayOfWeek = (get-date).DayOfWeek


if (($DayOfWeek -eq "Saturday") -or ($DayOfWeek -eq "Sunday"))
{
	Write-Host "It's the weekend.  What's wrong with you, go home."
}
else
{
	##########################################################
	#import previous days excel file for referenceobject file
	##########################################################
	
	if ($DayOfWeek -eq "Monday")
	{
		$FridayDate = (Get-Date).AddDays(-3).ToString("MM/dd/yyyy")
		
		#Get MMdd for file name
		$MM = $FridayDate.Split("/,/")[0]
		$dd = $FridayDate.Split("/,/")[1]

		#MMdd for date in filename
		$RefDate = $MM + $dd
	}
	else
	{
		$YesterdayDate = (Get-Date).AddDays(-1).ToString("MM/dd/yyyy")
		
		#Get MMdd for file name
		$MM = $YesterdayDate.Split("/,/")[0]
		$dd = $YesterdayDate.Split("/,/")[1]

		#MMdd for date in filename
		$RefDate = $MM + $dd
	}
	
	#path to reference file	
	$RefPath = "\\hs-tools\tools\SharedUsersRpt\Shared Users HSC WVUPC $RefDate.xlsx" #testing
	
	#test path and import file
	if (Test-Path $RefPath)
	{		
		$ReferenceObject = Import-Excel -Path $RefPath
	
		#Check to make sure file is not empty
		if ($ReferenceObject -ne $null)
		{
			Write-Host "The reference file was imported successfully." -Foregroundcolor "Green"
		}
		else
		{
			Write-Host "There was a problem importing the reference file.  Stopping program." -Foregroundcolor "Red"
			Exit
		}
		#End check
	}
	else
	{
		Write-Host "The reference file path does not exist." -Foregroundcolor "Red"
	}
	####################################
	#End import of referenceobject file
	####################################
	
	
	
	####################################################
	#import todays excel file for differenceobject file
	####################################################

	#Get todays date
	$TodaysDate = Get-Date -format MM/dd/yyyy

	#Get MMdd for file name
	$MM = $TodaysDate.Split("/,/")[0]
	$dd = $TodaysDate.Split("/,/")[1]

	#MMdd for date in filename
	$DiffDate = $MM + $dd
	
	#path to difference file	
	$DiffPath = "\\hs-tools\tools\SharedUsersRpt\Shared Users HSC WVUPC $DiffDate.xlsx" # testing
	
	#test path and import file
	if (Test-Path $DiffPath)
	{		
		$DifferenceObject = Import-Excel -Path $DiffPath   

		#Check to make sure file is not empty
		if ($DifferenceObject -ne $null)
		{
			Write-Host "The difference file was imported successfully." -Foregroundcolor "Green"			
		}
		else
		{
			Write-Host "There was a problem importing difference file.  Stopping program." -Foregroundcolor "Red"
			Exit
		}
		#End check
	}
	else
	{
		Write-Host "The difference file path does not exist." -Foregroundcolor "Red"
	}
	######################################
	#End import of diffferenceobject file
	######################################
	
	
	
	#############################################################################################
	#compare files for removed users and if file is not $null email and removed shared attribute
	#############################################################################################
	
	#compare files for removed users and export to RemovedSharedUsers folder	
	Compare-Object $ReferenceObject $DifferenceObject -property status, wvu_id, uid, firstname, lastname, "wvu userid", wvuid, first, mid, last | Where {$_.sideIndicator -eq "<="} | select-object Status, wvu_id, uid, firstname, lastname, "wvu userid", wvuid, first, mid, last | Export-excel \\hs-tools\tools\SharedUsersRpt\RemovedSharedUsers\RemovedSharedUsers$DiffDate.xlsx
	
	#pause for file creation
	Start-Sleep -s 2
	
	#import file and check to see if file is $null
	$RemovedSharedUsers = Import-Excel -Path \\hs-tools\tools\SharedUsersRpt\RemovedSharedUsers\RemovedSharedUsers$DiffDate.xlsx
	
	
	if ($RemovedSharedUsers -ne $null)
	{
		Write-Host "`nUsers where removed today.  Emailing update."
		
		#sending email
		Try
		{
			$from = "No-Reply@hsc.wvu.edu"
		
			#$bcc = "krussell@hsc.wvu.edu" #testing
			$to = "cbarnes@hsc.wvu.edu"
			$cc = "jnesselrodt@hsc.wvu.edu","mkondrla@hsc.wvu.edu","krussell@hsc.wvu.edu"
		
			$Subject = "Removed shared users $DiffDate"	
		
			$MsgBody = "Attached is a list of users not in todays Shared Users HSC WVUPC file.  You can also find files here: `n`n"
			$MsgBody += "https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Compare-SharedUser `n"
			$MsgBody += "and here: `n"
			$MsgBody += "\\hs-tools\tools\SharedUsersRpt"
		
			$attachment = "\\hs-tools\tools\SharedUsersRpt\RemovedSharedUsers\RemovedSharedUsers$DiffDate.xlsx"
			$smtpserver = "hssmtp.hsc.wvu.edu"
		
			Send-MailMessage -To $to -CC $cc -From $from -Subject $Subject -Body $MsgBody -SMTPServer $smtpserver -Attachment $attachment 
		}
		Catch
		{
			Write-Host "There was an error sending the email." -Foregroundcolor "Red"
		}
		
		Write-Host "`nChecking status of users"
		Write-Host "========================"
		
		foreach ($user in $RemovedSharedUsers)
		{
			if ($user.Status -eq "Accepted")
			{
				#check to see if exAtt already set to shared, if so remove
				Try
				{
					$exAtt10 = Get-AdUser -Identity $user.uid -properties extensionAttribute10					
					
					if ($exAtt10.extensionAttribute10 -eq "Shared")
					{
						Write-Host "$($user.firstname) $($user.lastname) is listed as a shared user.  Setting to Standard User."
						Try
						{
							Set-AdUser -Identity $user.uid -Replace @{extensionAttribute10="Standard User"}
							Write-Host "extensionAttribute10 for $($user.firstname) $($user.lastname) has been change." -Foregroundcolor "Green"
						}
						Catch
						{
							Write-Host "There was an error trying to set exAtt10 for $($user.firstname) $($user.lastname)" -Foregroundcolor "Red"
						}
					}
					else
					{
						Write-Host "$($user.firstname) $($user.lastname) is not set as a shared user.  Nothing changed."
					}
				}
				Catch
				{
					Write-Host "$($user.firstname) $($user.lastname) could not be found." -Foregroundcolor "Magenta"
				}
			}
			else
			{
				Write-Host "$($user.firstname) $($user.lastname) is not an accepted shared user.  Status: $($user.Status)."
			}		
		}	
	}
	else
	{
		Write-Host "There where no users removed today."	
	}
	########################################
	#end email and removed shared attribute
    ########################################
    

    #############################################################################
	#compare files for added users and if file is not $null add shared attribute
	#############################################################################
		
	#compare files for added users	
	Compare-Object $ReferenceObject $DifferenceObject -property status, wvu_id, uid, firstname, lastname, "wvu userid", wvuid, first, mid, last | Where {$_.sideIndicator -eq "=>"} | select-object Status, wvu_id, uid, firstname, lastname, "wvu userid", wvuid, first, mid, last | Export-excel \\hs-tools\tools\SharedUsersRpt\AddedSharedUsers\AddedSharedUsers$DiffDate.xlsx
	
	#pause for file creation
	Start-Sleep -s 2
	
	#import file and check to see if file is $null
	$AddedSharedUsers = Import-Excel -Path \\hs-tools\tools\SharedUsersRpt\AddedSharedUsers\AddedSharedUsers$DiffDate.xlsx
	
	if ($AddedSharedUsers -ne $null)
	{
		Write-Host "`nThere where new users added today.`n" 
		Write-Host "Checking status of new users"
		Write-Host "============================"
	
		foreach ($user in $AddedSharedUsers)
		{
			if ($user.Status -eq "Accepted")
			{
				Try
				{
					$exAtt10 = Get-AdUser -Identity $user.uid -properties extensionAttribute10
					
					if ($exAtt10.extensionAttribute10 -eq "Shared")
					{
						Write-Host "$($user.firstname) $($user.lastname) is already listed as a Shared user.  No changes made."
					}
					else
					{
						Write-Host "$($user.firstname) $($user.lastname) is not set as a shared user.  Setting user shared."
					
						Try
						{
							Set-AdUser -Identity $user.uid -Replace @{extensionAttribute10="Shared"}
							Write-Host "extensionAttribute10 for $($user.firstname) $($user.lastname) has been change." -Foregroundcolor "Green"
						}
						Catch
						{
							Write-Host "There was an error trying to set exAtt10" -Foregroundcolor "Red"
						}
					}				
				}
				Catch
				{
					Write-Host "$($user.firstname) $($user.lastname) does not exist." -Foregroundcolor "Magenta"
				}
				
				
			}
			else
			{
				Write-Host "$($user.firstname) $($user.lastname) is not an accepted user.  Status: $($user.Status)"
			}
		}
	}
	else
	{
		Write-Host "There where no users add today."			
	}
}

Stop-Transcript
	