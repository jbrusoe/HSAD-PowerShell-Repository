<#
	.SYNOPSIS
		This file imports mailboxes from the WVU tenant to the HSC tenant as mail contacts.
		Input to the file is provided from the Get-MainCampusMailbox.ps1 file.

	.DESCRIPTION
		Requires
		1. Connection to the HSC tenant (Get-AzureADUser etc)
		2. Connection to Exchange online and PowerShell cmdlets
		3. Output file from 6Get-MainCampusMailbox.ps1

	.PARAMETER ChangeDays
		This parameter specifies how far back to look for mailbox changes. Only users changed
		within this time will be updated/created.

	.PARAMETER DeleteOnly
		A value of true for this parameter tells the file to only delete contacts that are
		outdated instead of searching for changes.

	.PARAMETER MinimumFileSize
		This parameter is a safety measure to ensure that the input file has a minimum number
		of entries. Without this, many contacts could be deleted. This used to be a problem
		when running this on a server locally, but doesn't seem to be much of an issue
		since moving it to the cloud.

	.NOTES
		Author: Jeff Brusoe
		Last Updated: December 1, 2020
#>

[CmdletBinding()]
param (
	[int]$ChangeDays = 3, #How far back to look for any contact changes

	[ValidateScript({$_ -ge 8000})]
	[int]$MinimumFileSize = 7400,

	[ValidateScript({$_ -le 200})]
	[int]$MaximumDeletes = 200,

	[switch]$DeleteOnly = $false,
	[switch]$Testing
)

try {
	Write-Output "Configuring HSC Environment"
	Set-HSCEnvironment -ErrorAction Stop

	Write-Output "`nConnected to Office 365 with AzureAD"
	Connect-HSCOffice365 -ErrorAction Stop

	Write-Output "`nConnecting to Exchange Online"
	Connect-HSCExchangeOnline -ErrorAction Stop
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#Add references to file containing needed functions
#Build path to HSC PowerShell Modules
$ImportFilePath = $PSScriptRoot
$ImportFilePath = $ImportFilePath.substring(0,$ImportFilePath.lastIndexOf("\")+1)
$ImportFilePath = $ImportFilePath + "Get-MainCampusMailbox\Logs\"

Write-Output "Import File Path: $ImportFilePath"

#Generate & initialize log files
$ErrorFile = "$PSScriptRoot\Logs\" +
	(Get-Date -Format yyyy-MM-dd-HH-mm) +
	"-MainCampusImport-ErrorLog.txt"
New-Item -Type file -Path $ErrorFile -Force

$ImportFile = (Get-ChildItem $ImportFilePath -File |
	Where-Object {$_.Name -like "*MainCampusExchangeExport.csv*"} |
	Sort-Object LastWriteTime |
	Select-Object -Last 1).FullName
Write-Output "Import File: $ImportFile"

$DeletedAccounts = "$PSScriptRoot\Logs\" +
	(Get-Date -Format yyyy-MM-dd-HH-mm) +
	"-MainCampusImport-DeletedAccounts.txt"
New-Item -Type file -Path $DeletedAccounts -Force

Write-HSCLogFileSummaryInformation -FilePath $ErrorFile
Write-HSCLogFileSummaryInformation -FilePath $DeletedAccounts

#End code block that generates & initializes log files

#Count variables used for summary information
$TotalCount = 0
$NewContactCount = 0
$ExistingContactsCount = 0

#Ensure $ChangeDays is negative
#This is necessary to work with the .NET method of .AddDays()
if ($ChangeDays -gt 0) {
	$ChangeDays = -1*$ChangeDays
}

#Read export file from Get-MainCampusMailbox.ps1
try {
	Write-Output "Reading input file"
	$MCMailboxes = $ImportFile | Import-Csv -ErrorAction Stop

	$MCMailboxes.Count
}
catch {
	Write-Warning "Unable to read input file"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#This is a safeguard to make sure the import file was generated correctly.
#Currently (September 19, 2017), the main campus has about 9300 mailboxes to import.
if ($MCMailboxes.Count -lt $MinimumFileSize) {
	Write-Error "Exiting because there are too few entries in the input file."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}
elseif (($Error.Count -gt 0) -AND $Testing) {
	#Final safeguard against a bad file
	Write-Warning "Exiting due to error"
	Invoke-HSCExitCommand -ErrorAction Stop
}
else {
	Write-Output $($MCMailboxes.count.ToString() + " entries in input file... Continuing...`n")
}

#Begin going through input file
if (!$DeleteOnly)
{
	foreach ($MCMailbox in $MCMailboxes)
	{
		#Check for errors and log any that have happened
		$PrimarySMTPAddress = $MCMailbox.PrimarySMTPAddress.Trim()
		$Alias = $MCMailbox.Alias.Trim()
		[datetime]$DateWhenChanged = $MCMailbox.WhenChanged

		$TotalCount++
		Write-HSCColorOutput -ForegroundColor "Cyan" -Message $("Processing: " +
			$PrimarySMTPAddress)

		Write-Output $("User Number: " + $TotalCount)
		Write-Output $("New Contacts Created: " + $NewContactCount)
		Write-Output $("Existing Contacts Modified: " + $ExistingContactsCount)

		if ((($MCMailbox.PrimarySMTPAddress -ne "Gordon.gee@mail.wvu.edu") -AND
			($MCMailbox.PrimarySMTPAddress -ne "ur@mail.wvu.edu")) -AND
			([string]::IsNullOrEmpty($MCMailbox.FirstName) -OR
			[string]::IsNullOrEmpty($MCMailbox.LastName)))
		{
			Write-Warning "Skipping user due to missing name"
		}
		elseif ($DateWhenChanged -lt (get-date).AddDays($ChangeDays))
		{
			#Contact hasn't been updated recently - Don't waste time updating now.
			Write-Output $("Last Changed: " + $MCMailbox.WhenChanged)
			Write-Output "Skipping - No recent changes"
		}
		elseif ($MCMailbox.Title -like "*Student Worker*")
		{
			Write-Output "Skipping: Student Worker"
		}
		else
		{
			try {
				Write-Output "Searching for AzureADContact: $PrimarySMTPAddress"
				$AzureADContact = Get-AzureADContact -ErrorAction Stop -All $true |
					Where-Object {$_.Mail -eq $PrimarySMTPAddress}
			}
			catch {
				Write-warning "Unable to find Azure AD Contact"
			}

			#Begin changing attributes
			if (![string]::IsNullOrEmpty($MCMailbox.CustomAttribute8)) {
				Write-Output $("CustomAttribute8: " + $MCMailbox.CustomAttribute8)
				$DisplayName = $MCMailBox.LastName.Trim() + ", " + $MCMailbox.CustomAttribute8.Trim()
			}
			else {
				$DisplayName = $MCMailBox.LastName.Trim() + ", " + $MCMailbox.FirstName.Trim()
			}

			Write-Output "Display Name: $DisplayName"

			if ($null -eq $AzureADContact)
			{
				Write-Output "Contact does not exist in the cloud - Creating contact"

				$NewMailContactParams = @{
					Name = $DisplayName
					ExternalEmailAddress = $PrimarySMTPAddress
					FirstName = $MCMailbox.FirstName
					LastName = $MCMailbox.LastName
					DisplayName = $DisplayName
					Alias = $Alias
					ErrorAction = "Stop"
				}

				try {
					Write-Output "Attempting to create contact"
					New-MailContact @NewMailContactParams
					Write-Output "Successfully crated contact"

					$NewContactCount++
				}
				catch {
					Write-Warning "Error creating mail contact"
				}

				#This is a syncrhonization delay before setting the attributes below.
				Start-HSCCountdown -Seconds 5 -Message "Delay after creating new email contact"
			}

			Write-HSCColorOutput -foregroundcolor "Cyan" -Message "Updating Contact Information"

			Write-Output "Setting Phone Number, Title, and Department"
			Write-Output $("Phone Number: " + $MCMailbox.Phone)
			Write-Output $("Title: " + $MCMailbox.Title)
			Write-Output $("Department: " + $MCMailbox.Department)

			try {
				$SetContactParams =@{
					Identity = $PrimarySMTPAddress
					Phone = $MCMailbox.Phone
					Title = $MCMailbox.Title
					Department = $MCMailbox.Department
					ErrorAction = "Stop"
				}

				Set-Contact @SetContactParams
			}
			catch {
				Write-Warning "Unable to set parameters"
			}
	
			try {
				Write-Output "Setting mail alias"

				Set-Mailcontact -Identity $PrimarySMTPAddress -Alias $Alias -ErrorAction Stop
			}
			catch {
				Write-Warning "Unable to set mail alias"
			}

			Write-Output "Setting CustomAttribute1 to WVU MainCampus"
			Write-Output "Setting CustomAttribute7 with TimeStamp"
			try {
				$SetMailContactParams = @{
					Identity = $PrimarySMTPAddress
					CustomAttribute1 = "WVUMainCampus"
					CustomAttribute7 = (Get-date -format d) #flag to keep track of when import was done
					ErrorAction = "Stop"
				}

				Set-MailContact @SetMailContactParams
			}
			catch {
				Write-Warning "Unable to update CustomAttribute1 and CustomAttribute7"
			}

			$ExistingContactsCount++

			if ($error.count -gt 0)
			{
				Add-Content $ErrorFile $PrimarySMTPAddress
				Write-Warning $("Error with: " + $PrimarySMTPAddress)

				$Error.Clear()
			}
		}
		Write-Output "*****************************************"
	}
}

Invoke-HSCExitCommand -ErrorCount $Error.Count