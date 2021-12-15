<#
	.SYNOPSIS
        This file compares the current days shared users file with the previous days shared
        users file.  It also emails Michele/Jackie/Cindy B/myself a list of the removed users.

	.DESCRIPTION
 	    1. Checks for ImportExcel module which is required
		2. Imports previous days excel file as reference file
		3. Imports todays excel file as difference file
		4. Compares files and exports a list of both added and removed user
		5. If removed users exist emails group

	.PARAMETER
	    Paramter information.

	.NOTES
	    Author: Kevin Russell
    	Last Updated by: Kevin Russell
	    Last Updated: 03/16/2021

		Assumes file name will be "Shared Users HSC WVUPC MMdd.xlxs"
#>

[CmdletBinding()]
param (
	[ValidateNotNullOrEmpty()]
	[string]$SharedUsersDirectory = "\\hs-tools\tools\SharedUsersRpt\",

	[ValidateNotNullOrEmpty()]
	[string[]]$EmailReceipents = @(
			"mkondrla@hsc.wvu.edu",
			"cbarnes@hsc.wvu.edu",
			"jnesselrodt@hsc.wvu.edu"
		)
)

$error.Clear()

try {
	Set-HSCEnvironment -ErrorAction Stop
}
catch {
	Write-Warning "Unable to configure environmenet"
	Write-Warning $error[0].Exception.Message
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

### check for ImportExcel module ###
try{
	$InstalledModules = Get-InstalledModule -ErrorAction Stop
}
catch{
	Write-Warning "Error getting installed module, cannot check for ImportExcel module"
	Write-Warning $error[0].Exception.Message
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

if(($InstalledModules.Name).Contains("ImportExcel")){
	Write-Output "ImportExcel module:  Installed"
}
else{
	$NewObjectParams = @{
		TypeName = "Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())"
		ErrorAction = "Stop"
	}

	$CurrentPrincipal = New-Object @NewObjectParams
	if($CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
		try{
			Install-Module ImportExcel -Scope CurrentUser -ErrorAction Stop
		}
		catch{
			Write-Warning "There was an error importing the Excel module"
			Write-Warning $error[0].Exception.Message
			Invoke-HSCExitCommand -ErrorCount $Error.Count
		}
	}
	else{
		Write-Warning "ImportExcel module:  Not installed."
		Write-Warning "Please restart powershell as admin and run:"
		Write-Warning "Install-Module ImportExcel -Scope CurrentUser"
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}
}
### end module check ###


### import previous days excel file for referenceobject file ###

if(((get-date).dayofweek) -eq "Monday"){

	$FridayDate = (Get-Date).AddDays(-3).ToString("MM/dd/yyyy")

	$MM = $FridayDate.Split("/,/")[0]
	$dd = $FridayDate.Split("/,/")[1]
	$yy = $FridayDate.Split("/,/")[2]
}
else{
	$YesterdayDate = (Get-Date).AddDays(-1).ToString("MM/dd/yyyy")

	$MM = $YesterdayDate.Split("/,/")[0]
	$dd = $YesterdayDate.Split("/,/")[1]
	$yy = $YesterdayDate.Split("/,/")[2]
}

$RefDate = $MM + $dd + $yy

#path to reference file
$RefPath = $SharedUsersDirectory + "Shared Users HSC WVUPC $RefDate.xlsx"

#test path and import file
if (Test-Path $RefPath){
	try{
		$ReferenceObject = Import-Excel -Path $RefPath
	}
	catch{
		Write-Warning "There was an error importing the reference file"
		Write-Warning $error[0].Exception.Message
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}

	if ($null -eq $ReferenceObject){
		Write-Warning "The reference file is empty.  Exiting program."
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}
}
else{
	Write-Warning "$RefPath does not exist."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}
### end import of referenceobject file ###


### import todays excel file for differenceobject file ###
$TodaysDate = Get-Date -format MM/dd/yyyy

$MM = $TodaysDate.Split("/,/")[0]
$dd = $TodaysDate.Split("/,/")[1]
$yy = $TodaysDate.Split("/,/")[2]

$DiffDate = $MM + $dd + $yy

#path to difference file
$DiffPath = $SharedUsersDirectory +
				"SharedUsersRpt\Shared Users HSC WVUPC $DiffDate.xlsx"

#test path and import file
if(Test-Path $DiffPath){
	try{
		$DifferenceObject = Import-Excel -Path $DiffPath
	}
	catch{
		Write-Warning "There was an error importing the difference file"
		Write-Warning $error[0].Exception.Message
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}

	if ($null -eq $DifferenceObject){
		Write-Warning "The difference file is empty.  Exiting program."
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}
}
else{
	Write-Warning "$DiffPath does not exist."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}
### end import of diffferenceobject file ###


### compare files for added/removed users and if removed users found email ###

$CompareProperties = @(
	"status",
	"wvu_id",
	"uid",
	"firstname",
	"lastname",
	"wvu userid",
	"wvuid",
	"first",
	"mid",
	"last"
)

#find added users
try{
	Compare-Object $ReferenceObject $DifferenceObject -property $CompareProperties |
		Where-Object {$_.sideIndicator -eq "=>"} |
		Select-Object $CompareProperties |
		Export-Excel $SharedUsersDirectory +
						"AddedSharedUsers\AddedSharedUsers$DiffDate.xlsx"
}
catch{
	Write-Warning "There was an error comparing the files"
	Write-Warning $error[0].Exception.Message
}

#find removed users
try{
	Compare-Object $ReferenceObject $DifferenceObject -property $CompareProperties |
		Where-Object {$_.sideIndicator -eq "<="} | select-object $CompareProperties |
		Export-excel $SharedUsersDirectory +
						"RemovedSharedUsers\RemovedSharedUsers$DiffDate.xlsx"
}
catch{
	Write-Warning "There was an error comparing the files"
	Write-Warning $error[0].Exception.Message
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Start-Sleep -s 2

try{
	$RemovedSharedUsers = Import-Excel -Path $SharedUsersDirectory +
							"\RemovedSharedUsers\RemovedSharedUsers$DiffDate.xlsx"
}
catch{
	Write-Warning "There was an importing the removed shared users file"
	Write-Warning $error[0].Exception.Message
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}


if ($null -ne $RemovedSharedUsers){

	Write-Output "Users where removed today.  Preparing to email..."

	$MsgBody = "Attached is a list of users not in todays Shared Users HSC WVUPC file.`n"
	$MsgBody += "You can also find files here: `n`n"
	$MsgBody += "https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Compare-SharedUser `n"
	$MsgBody += "and here: `n"
	$MsgBody += $SharedUsersDirectory

	$EmailParams = @{
		From = "No-Reply@hsc.wvu.edu"
		To = $EmailReceipents
		Subject = "Removed shared users $DiffDate"
		Body = $MsgBody
		Attachment = $SharedUsersDirectory +
							"RemovedSharedUsers\RemovedSharedUsers$DiffDate.xlsx"
		SMTPServer = 'hssmtp.hsc.wvu.edu'
	}

	try{
		Send-MailMessage @EmailParams
	}
	catch{
		Write-Warning "There was an error sending the email"
		Write-Warning $error[0].Exception.Message
	}
}
else{
	Write-Output "There where no users removed today."
}
### end find added/removed and email ###

Invoke-HSCExitCommand -ErrorCount $Error.Count