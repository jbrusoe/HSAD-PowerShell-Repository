#--------------------------------------------------------------------------------------------------
#RemoveTcpIpPrinters.ps1
#
#Written by: Kevin Russell
#
#Last Modified by: Kevin Russell
#
#Last Modified: 
#
#Version: 
#
#Purpose: The purpose of this script is to detect TCP/IP printers on machine and to remove them. 
#         If you do not define $LogFilePath you will get a warning and prompt to enter path for 
#		  log files.
#--------------------------------------------------------------------------------------------------

<#
.SYNOPSIS
 	      
    
.DESCRIPTION
 	      
 	
.PARAMETER
	    Paramter information.

.NOTES
	    Author: Kevin Russell
    	Last Updated by:
	    Last Updated:
#>

#Change PowerShell window title
$Host.UI.RawUI.WindowTitle = "RemoveTcpIpPrinters.ps1"

#csv filepath
$Dept = Read-Host "Enter the department"
#$FilePath = "C:\AD-Development\RemoveTcpIpPrinters\RemoveTcpIpPrinters.csv"
$FilePath = "C:\AD-Development\RemoveTcpIpPrinters\$Dept.csv"


#Import Printer list
#Write-Host "Preparing to import RemoveTcpIpPrinters.csv from $filepath" -Foregroundcolor "Green"
Write-Host "Preparing to import CSV..." -Foregroundcolor "Green"
$PCList = Import-CSV $FilePath

#Check to make sure file is not empty
if ($PCList -ne $null)
{
	Write-Host "`Your CSV file was imported successfully." -Foregroundcolor "Green"
}

else
{
	Write-Host "`There was a problem importing your file." -Foregroundcolor "Red"
}
#End check

#Connect to remote machine on PCList and run RemoveTcpIPPrinters and log
ForEach ($PC in $PCList)
{
	$ComputerName = $PC.PCList
	
	#Path where log file will be stored
	$LogFilePath = "C:\AD-Development\RemoveTcpIpPrinters\Logs"

	#Create the log file
	$RemoveTcpIpPrintersLog = $LogFilePath + "\" + $ComputerName + "\" + (get-date).ToString('M-d-y') + "-RemoveTcpIpPrinters-Log.txt"
	Write-Host "`Log file path is $RemoveTcpIpPrintersLog" -Foreground "Green"
	New-Item $RemoveTcpIpPrintersLog -type file -force	
	
	Write-Host "`Preparing to run ScriptBlockToRemoveTcpIpPrinters.ps1 on $ComputerName" -Foregroundcolor "Green"	
	$results = Invoke-Command -Computer $ComputerName -FilePath "c:\AD-Development\RemoveTcpIpPrinters\ScriptBlockToRemoveTcpIpPrinters.ps1"

	$results | Tee-Object -FilePath $RemoveTcpIpPrintersLog
}


