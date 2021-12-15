#--------------------------------------------------------------------------------------------------
#5Set-ComputerACL.ps1
#
#Written by: Jeff Brusoe
#
#Last Modified by: Jeff Brusoe
#
#Last Modified:	June 16, 2017
#
#Version: 1.2
#
#Purpose: Retrieves a list of all computer objects in the ClincPCs OU for the School of Dentistry. The
#		  windows\temp directory is cleared and the correct ACl is set.
#--------------------------------------------------------------------------------------------------

<#
.SYNOPSIS
 	Retrieves a list of all computer objects in the ClincPCs OU for the School of Dentistry. The
	windows\temp directory is cleared and the correct ACl is set.
    
.DESCRIPTION
 	This file is used to give full control to authenticated users to the Windows\temp directory on computers
	for the School of Dentistry. Because some of these directories also had hundreds of thousands of files in them,
	it also attempts to delete any files that it finds there. It does require the ActiveDirectory module, but does not
	require a connection to the cloud.
 	
.PARAMETER SessionTranscript
	This parameter is a boolean value that determines if a session transcript should be logged
	
.PARAMETER LogFilePath
	This is the path to the log file directory.
	
.PARAMETER StopOnError
	StopOnError is used for testing purposes. If it is true, it will stop anytime an error happens.


.NOTES
	Author: Jeff Brusoe
	Last Updated by: Jeff Brusoe
    Last Updated: June 16, 2017
#>

[CmdletBinding()]
param (
	[switch]$SessionTranscript = $true,
	[string]$LogFilePath = "C:\AD-Development\Set-ComputerACL\Logs",
	[switch]$StopOnError = $false, #$true is used for testing purposes,
	[string]$SuccessFile = "AclSet.txt",
	[string]$FailureFile = "AclNotSet.txt"
	)

if ($StopOnError)
{
		$ErrorAction = "STOP"
}
cls

#Change PowerShell window title
$Host.UI.RawUI.WindowTitle = "5Set-ComputerACL.ps1"

#Load ActiveDirectory module. It's required and program stops if an error happens.
try
{
	Import-Module ActiveDirectory -ea "Stop"
}
catch
{
	#AD module can't be loaded. End program.
	Write-Error "The Active Directory module can't be loaded."
	Return
}

#Verify the log file directory exists
#First check if $LogFilePath is null
if ([string]::IsNullOrEmpty($LogFilePath))
{
	Write-Warning "Log file path is null."
	Write-Warning "Setting log path to c:\ad-development\5Set-ComputerACL\Logs"
	
	$LogFilePath = "c:\ad-development\5Set-ComputerACL\Logs"

}

#Test for a valid file path
if (!(Test-Path $LogFilePath))
{
	New-Item $LogFilePath -type Directory -force -ea "SilentlyContinue"
}
New-Item $SuccessFile -type File -Force
New-Item $FailureFile -type File -Force

Function Write-ColorOutput
{
	#This function allows color output in combination with Write-Output.
	#It's needed since Write-Output doesn't support this feature found in Write-Host.
	#Write-Output is used due to some issues writing log files.
	#
	#In this code, ForegroundColor refers to the color of the text.
	#
	#Written by: Jeff Brusoe
	#Last Updated: October 21, 2016
	#
	#FunctionStatus: Working. No changes are currently planned.
	
	[CmdletBinding()]
	param (
		[string]$Message = $null,
		[string]$ForegroundColor = "Green"
	)
	
	if ([string]::IsNullOrEmpty($Message))
	{
		Write-Verbose "A null message value was passed into the function."
		return $null
	}
	elseif ([Enum]::GetValues([System.ConsoleColor]) -NotContains $ForegroundColor)
	{
		Write-Verbose "An invalid system color was passed into the function. The default value of green is being used."
		$ForegroundColor = "Green"
	}
	
	$CurrentColor = [Console]::ForegroundColor
	$BackgroundColor = [Console]::BackgroundColor

	if ($CurrentColor -eq $ForegroundColor)
	{
		Write-Verbose "Current color matches input foreground color."
	}

	if ($BackgroundColor -eq "ForegroundColor")
	{
		Write-Verbose "Foreground color matches background color and will not be changed."
	}

	[Console]::ForegroundColor = $ForegroundColor

	Write-Output $Message

	[Console]::ForegroundColor = $CurrentColor
		
}

#Main part of the program

#Generate list of computers in this OU
$pcs = Get-ADComputer -SearchBase "OU=ClinicPCs,OU=SOD,OU=HS Computers,DC=HS,DC=wvu-ad,DC=wvu,DC=edu" -Filter *

foreach ($pc in $pcs) 
{
    $acl = $null
    $ar = $null
    [string]$path = $null
	$SetAclSuccess = $false
	$CurrentlySet = $false
	[string]$AclFailureMessage = $null
	
	$Error.Clear()

	"Current Computer: " + $pc.Name
	
    $path = "\\" + $pc.Name + "\c$\windows\temp"
    #$path
	
	"Deleteing files from directory"
	$CleanPath = "\\" + $pc.Name + "\c$\windows\temp\*"
    "Current Path: $CleanPath"
    
	Remove-Item $CleanPath -force -recurse -verbose -ea "SilentlyContinue"
    
	$acl = get-acl $path -ea "SilentlyContinue"
	
	if ($acl -ne $null)
	{
		#$acl

		Write-ColorOutput -Message "ACL successfully read for $path" -ForegroundColor "Green"
		
		$ar = new-object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\authenticated users", "FullControl", "Allow")
		#$ar
    
		foreach ($access in $acl.access)
		{
			Write-Verbose $access.FileSystemRights.toString().Trim()
			Write-Verbose $access.IdentityReference.toString().Trim()
			Write-Verbose $access.AccessControlType.toString().Trim()
			Write-Verbose "---------------------------"
			
			if (($access.FileSystemRights.toString() -eq "FullControl") -AND ($access.IdentityReference.toString() -contains "NT AUTHORITY\authenticated users") -AND ($access.AccessControlType.toString() -eq "Allow"))
			{
				Write-ColorOutput "Access right is currently set. No change is required."
				$SetAclSuccess = $true
				$CurrentlySet = $true
			}
		}
		
		if (!$SetAclSuccess)
		{
			try 
			{
				"Attempting to set ACL. This may take time to enumerate through all files."
				
				#$acl.SetAccessRule($ar)
				#Set-Acl -path $path -AclObject $acl
				
				$SetAclSuccess = $true
				
				Write-ColorOutput -Message "ACL successfully set" -ForegroundColor "Green"
			}
			catch
			{
				#Error trying to set acl
				$Error
				$AclFailureMessage = "Error attempting to set new ACL"
				Write-Warning "Failure trying to set ACL"
				
				$Error.Message
			}
		}
	}
	else
	{
		#$acl is null.
		Write-Warning "ACL is null."
		$AclFailureMessage = "Unable to retrieve current ACL"
	}
	
	"*******************************"
	
	#Write Log Files
	"Writing to log file"
	if ($SetAclSuccess)
	{
		Add-Content $SuccessFile -value $pc.Name
		if ($CurrentlySet)
		{
			Add-Content $SuccessFile -value "ACL was already set."
		}
		else
		{
			Add-Content $SuccessFile -value "ACL was set correctly"
		}
		
		Add-Content $SuccessFile "***************************"
	}
	else
	{
		Add-Content $FailureFile -value $pc.Name
		Add-Content $FailureFile -value $AclFailureMessage
		Add-COntent $FailureFile -value "**********************************"
	}
}