#----------------------------------------------------------
#Repair-WMI.ps1
#
#Written by: Kevin Russell
#
#Last Modified by: Kevin Russell
#
#Version: 1
#
#Purpose: The purpose of this script is to uninstall   
#         ccmsetup, reset the repository and clean up 
#         left over files/folders.  Assumes tech is
#         logged in and not end user; also that scirpt is 
#         running as admin.
#----------------------------------------------------------



#check is script is running as admin and elevate if not

# Get the ID and security principal of the current user account
$myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($env:username)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
{
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = "CCM uninstall/cleanup WMI repair (Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
}
else
{
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
}
#end check and elevation    
   


#Define variables
$smtpserver = "hssmtp.hsc.wvu.edu"    
$emailFrom = "$env:username@hsc.wvu.edu"
$emailTo = "$env:username@hsc.wvu.edu"


Write-Host "Attempting to uninstall CCM" -Foregroundcolor Green	
	
if (Test-Path -Path "c:\windows\ccmsetup\ccmsetup.exe")
{
	Start-Process c:\windows\ccmsetup\ccmsetup.exe /uninstall
	Write-Host "Pausing script for 5 minutes for ccmsetup uninstall to finish." -Foregroundcolor Green
	Start-Sleep -Seconds 300
}
else
{
	Write-Host "c:\windows\ccmsetup\ccmsetup.exe does not exist.  Stopping program." -Foregroundcolor Red
	Write-Host "Hit enter to exit program"
	CMD /c PAUSE
	Exit
}


#Get CCM return code
if (Test-Path "C:\windows\ccmsetup\Logs\ccmsetup.log")
{
	$LastLine = Get-Content "C:\windows\ccmsetup\Logs\ccmsetup.log" -Tail 1

	#Parse data for exit code
	$ExitCode = $LastLine.Split("[,[,]")[2]
}
else
{
	Write-Host "Log file does not exist.  Stopping program." -Foregroundcolor Red
	Write-Host "Hit enter to exit program"
	CMD /c PAUSE
	Exit
}


if ($ExitCode -eq "CcmSetup is exiting with return code 0")
{
	Write-Host "CcmSetup exited with return code 0.  Resetting repository" -Foregroundcolor Green
	winmgmt /resetrepository
	
	winmgmt /verifyrepository | Out-File -FilePath c:\users\$env:username\desktop\VerifyRepository.txt
	$VerifyRepository = Get-Content "c:\users\$env:username\desktop\VerifyRepository.txt"
	
	if ($VerifyRepository -eq "WMI repository is consistent")
	{
		Write-Host "WMI repository is consistent" -Foregroundcolor Green
		Write-Host " "
		Write-Host "Cleaning up CCM files/folders"
		Write-Host "-----------------------------"
		
		#Remove directories if exist
		If (Test-Path -Path "c:\windows\ccm")
		{
			Write-Host "Removing c:\windows\ccm..."
			Remove-Item -Path c:\windows\ccm -recurse
		}
		else
		{
			Write-Host "c:\windows\ccm does not exist" -Foregroundcolor Red
		}
		
		
		If (Test-Path -Path "c:\windows\ccmcache")
		{
			Write-Host "Removing c:\windows\ccmcache..."
			Remove-Item -Path c:\windows\ccmcache -recurse
		}
		else
		{
			Write-Host "c:\windows\ccmcache does not exist" -Foregroundcolor Red
		}
		
		
		If (Test-Path -Path "c:\windows\ccmsetup")
		{
			Write-Host "Removing c:\windows\ccmsetup..."
			Remove-Item -Path c:\windows\ccmsetup -recurse
		}
		else
		{
			Write-Host "c:\windows\ccmsetup does not exist" -Foregroundcolor Red
		}
		
		
		Write-Host "Pausing script for 2 minutes"
		Start-Sleep -Seconds 120
		Write-Host "Sending confirmation email..."
		$subject = 'CCM uninstall WMI repair successful'
		$body = "$env:computername has finished WMI repair/CCM cleanup and will reboot in 60 secconds.  Remember to push client install from SCCM and you should see the C:\windows\ccmsetup folder appear and you can monitor the setup log again."
		Send-MailMessage -To $emailTo -From $emailFrom -Subject $subject -Body $body -SmtpServer $smtpserver
		Write-Host "Restarting computer in 60 seconds"
		Start-Sleep -Seconds 60
		Restart-Computer
	}
	else
	{
		Write-Host "WMI repository is not consistent.  Emailing status update." -Foregroundcolor Red
		$subject = 'WMI repository failure'
		$body = "$env:computername did not come back with repository is consistent.  Machine will need rebooted.  Log back in and verify winmgmt /verifyrepository returns WMI repository is consistent and run RD /S /Q c:\windows\CCM and RD /S /Q c:\windows\ccmsetup then reboot."
		Send-MailMessage -To $emailTo -From $emailFrom -Subject $subject -Body $body -SmtpServer $smtpserver
		Write-Host "Hit enter to restart..."
		CMD /c PAUSE
		Restart-Computer
	}
}
elseif ($ExitCode -eq "CcmSetup is exiting with return code 7")
{
	Write-Host "CCMSetup exited with return code 7.  A reboot is required." -Foregroundcolor Red
	Write-Host "Emailing status update"
	$subject = 'CCMSetup Return code 7 - reboot required'
	$body = "$env:computername returned with return code 7, a reboot is required.  Machine will reboot in 60 seconds and the script needs run again."
	Send-MailMessage -To $emailTo -From $emailFrom -Subject $subject -Body $body -SmtpServer $smtpserver
	Write-Host "Hit enter to restart..."
	CMD /c PAUSE
	Restart-Computer	
}
else
{
	
	Write-Host "Unexpected exit code" -Foregroundcolor Red
	Write-Host "Emailing status update"
	$subject = 'Unexpected exit code'
	$body = "$env:computername returned an unexpected error code.  $ExitCode.  Machine needs furthur attention."
	Send-MailMessage -To $emailTo -From $emailFrom -Subject $subject -Body $body -SmtpServer $smtpserver	
}

