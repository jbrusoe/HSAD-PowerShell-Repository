<#
	.SYNOPSIS
		The purpose of this file is to import the HSC address book
		to the WVU Foundation's Office 365 tenant.

	.PARAMETER HSCMailboxFile
		This is the source file that will be imported to the WVUF tenant address book

	.PARAMETER ChangeDays
		Specifies how far back to make changes to a
		contact based on the whenChanged field in the input file.

	.PARAMETER DeleteOnly
		Switch parameter to indicate that non-existant contacts in import file should
		be deleted.

	.PARAMETER MinimumFileSize
		A safety parameter to make sure that the input file has a minimum number of users in it

	.PARAMETER MaximumDeletes
		A safety parameter to make sure that too many users aren't deleted

	.NOTES
		Written by: Jeff Brusoe
		Last Updated: May 19, 2021
#>

[CmdletBinding(SupportsShouldProcess = $true,
				ConfirmImpact = "Medium")]

param (
	[ValidateNotNullOrEmpty()]
	[string]$HSCMailboxFile = $(
		(Get-HSCGitHubRepoPath) +
		"Get-HSCMailboxForWVUF\Logs\" +
		(Get-Date -Format yyyy-MM-dd) +
		"-HSCMailboxExport.csv"
	),

	[ValidateRange(-30,30)]
	[int]$ChangeDays = 7,

	[ValidateRange(1, [int]::MaxValue)]
	[int]$MinimumFileSize = 4000,

	[ValidateRange(1, [int]::MaxValue)]
	[int]$MaximumDeletes = 50,

	[switch]$DeleteOnly = $false
)

try {
	Write-Output "Configuring environment..."

	Set-Environment -ErrorAction Stop
	Connect-WVUFoundationExchangeOnline -ErrorAction Stop
	Connect-WVUFoundationOffice365 -ErrorAction Stop

	$Count = 0 #For keeping track of total number of users
	$NewContact = 0 #New contacts created
	$ExistingContacts = 0 #Existing contacts that are modified
	[string]$PrimarySMTPAddress = $null
	[string]$Alias = $null

	#Ensure $ChangeDays is negative.
	#This is necessary to work with the .NET method of .AddDays()
	if ($ChangeDays -gt 0) {
		$ChangeDays = -1*$ChangeDays
	}

	Write-Output "Done configuring environment..."
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#Read export file from Get-HsCMailbox.ps1
if ($DeleteOnly) {
	$HSCMailboxes = $null
}
else
{
	try
	{
		Write-Output "Attempting to open input file:"
		Write-Output $HSCMailboxFile

		$HSCMailboxes = Import-Csv $HSCMailboxFile -ErrorAction Stop
	}
	catch {
		Write-Warning "There was an error opening the input file. Program is exiting."
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}

	if (($HSCMailboxes | Measure-Object).Count -lt $MinimumFileSize) {
		Write-Warning "Not enough mailboxes in input file. Program is ending."
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}
	else {
		Write-Output "Successfully opened input file."
	}
}

##################################
# Begin going through input file #
##################################
foreach ($HSCMailbox in $HSCMailboxes)
{
	$PrimarySMTPAddress = $HSCMailbox.PrimarySMTPAddress.Trim()
	$Alias = $HSCMailbox.Alias.Trim()
	[datetime]$DateWhenChanged = $HSCMailbox.WhenChanged

	$Count++
	Write-ColorOutput -ForegroundColor "Cyan" -Message "Processing: $PrimarySMTPAddress"
	Write-ColorOutput -ForegroundColor "Cyan" -Message "User Number: $Count"
	Write-ColorOutput -ForegroundColor "Cyan" -Message "New Contacts Created: $NewContact"
	Write-ColorOutput -ForegroundColor "Cyan" -Message "Existing Contacts Modified: $ExistingContacts"

	if ($DateWhenChanged -gt (Get-Date).AddDays($ChangeDays))
	{
		Write-Output "Contact will be modified"
		Write-Output "Last modified date: $DateWhenChanged"

		#Begin changing attributes
		$DisplayName = $HSCMailbox.DisplayName
		Write-Output $("Display Name: " + $DisplayName)

		try
		{
			Write-Output "Trying to create new contact"

			$NewMailContactParams = @{
				Name = $DisplayName
				ExternalEmailAddress = $PrimarySMTPAddress
				FirstName = $HSCMailbox.FirstName
				LastName = $HSCMailbox.LastName
				DisplayName = $DisplayName
				Alias = $HSCMailbox.Alias
				ErrorAction = "Stop"
			}

			New-MailContact @NewMailContactParams
			$NewContact++

			#Next line prevents potential errors when trying to set properties of newly created contacts.
			Start-HSCCountdown -Seconds 5 -Message "Delay after creating new email contact"
		}
		catch
		{
			#Most likely this code is executed because New-Mailcontact had an
			#error due to the contact already existing.
			$ExistingContacts++

			Write-Output "Contact already exists"
		}

		Write-ColorOutput -ForeGroundColor "Cyan" -Message "Updating New Contact Information"

		Write-Output "Setting Phone Number, Title, and Department"
		Write-Output $("Phone Number: " + $HSCMailbox.Phone)
		Write-Output $("Title: " + $HSCMailbox.Title)
		Write-Output $("Department: " + $HSCMailbox.Department)
		Write-Output $("Last modified date: " + $HSCMailbox.WhenChanged)

		try
		{
			$SetContactParams = @{
				Identity = $PrimarySMTPAddress
				Phone = $HSCMailbox.Phone
				Title = $HSCMailbox.Title
				Department = $HSCMailbox.Department
				ErrorAction = "Stop"
			}

			Set-Contact @SetContactParams
		}
		catch {
			Write-Warning "Set-Contact Error"

			if ($Error[0].toString().indexOf("the object is being synchronized from your on-premises") -gt 0) {
				Write-Warning "Cosmetic error: Synced from onprem"

				$Error.Clear()
			}
		}

		try {
			Set-MailContact -Identity $PrimarySMTPAddress -Alias $HSCMailbox.Alias -ErrorAction Stop
		}
		catch {
			Write-Warning "Set-MailContact Error"
			if ($Error[0].toString().indexOf("the object is being synchronized from your on-premises") -gt 0) {
				Write-Warning "Cosmetic error: Synced from onprem"

				$Error.Clear()
				continue
			}
			elseif ($Error[0].toString().indexOf("couldn't be found on") -gt 0) {
				Write-Warning "Primary SMTP Error"
				$Error.Clear()

				continue
			}
		}

		Write-Output "Setting CustomAttribute1 to HSC"
		Write-Output "Setting CustomAttribute7 with TimeStamp"

		try
		{
			$SetMailContactParams = @{
				Identity = $PrimarySMTPAddress
				DisplayName = $DisplayName
				Name = $DisplayName
				CustomAttribute1 = "HSC"
				CustomAttribute7 = (Get-Date -format d)
				ErrorAction = "Stop"
			}

			Set-MailContact @SetMailContactParams

			Write-Output $("HiddenFromAddressListsEnabled: " + $HSCMailbox.HiddenFromAddressListsEnabled)

			if ($HSCMailbox.HiddenFromAddressListsEnabled -eq "True") {
				Write-Output "Contact is being hidden from the address list"
				Set-MailContact -Identity $PrimarySMTPAddress -HiddenFromAddressListsEnabled $true
			}
			else {
				Write-Output "Contact will be visible in the address list."
				Set-MailContact -Identity $PrimarySMTPAddress -HiddenFromAddressListsEnabled $false
			}
		}
		catch {
			Write-Warning "Set-MailContact Error"
			if ($Error[0].toString().indexOf("the object is being synchronized from your on-premises") -gt 0) {
				Write-Warning "Cosmetic error: Synced from onprem"

				$Error.Clear()
				continue
			}
		}
	}
	else {
		Write-Output "Contact will not be modified"
		Write-Output "Last modified Date: $DateWhenChanged"
	}

	Write-Output "*****************************************"
}

Write-Output "Address book import from file has been done."

#At this point, any new contacts have been created, and any updates have been applied.
#The final step is to loop through the existing contacts to verify that they are in the
#import file. Any that aren't will be deleted.

$Error.Clear()

Write-Output "Beginning to delete old contacts"

try {
	Write-Output "Reading HSC email addresses"
	$ValidHSCContacts = Import-csv $HSCMailboxFile -ErrorAction Stop
}
catch {
	Write-Warning "Error reading HSC mailbox file"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}


try {

	Write-Output "Generating list of current contacts in the WVUF domain..."

	$CurrentHSCContacts = Get-AzureADContact -All $true|
		Where-Object {($_.EmailAddress -like "*@hsc.wvu.edu") -OR
						($_.EmailAddress -like "*@wvumedicine.org") }

	Write-Output $("Number of Contacts in WVUF Address book: " +
				($CurrentHSCContacts | Measure-Object).Count)
}
catch {
	Write-Warning "Error generaring list of AzureAD contacts"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$DeleteCount = 0
$TotalCount = 0

#The following block of code is here for safety measures.
#It ensures that the file input and contact search were
#both successful before proceeding. Piping into Measure
#is needed due to Set-StrictMode which is from the HSC PowerShell modules.
if (($CurrentHSCContacts | Measure-Object).Count -lt $MinimumFileSize) {
	#Verify a reasonable value for WVUF Tenant contacts (contained in $CurrentContacts)
	Write-Warning "There was an error reading contacts from the WVUF Tenant."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}
elseif (($ValidHSCContacts | Measure-Object).Count -lt $MinimumFileSize)
{
	#Verify contacts in file
	Write-Warning "There was an error reading contacts from the input file."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($CurrentHSCContact in $CurrentHSCContacts)
{
	$TotalCount++

	Write-Output $("Processing: " + $CurrentHSCContact.EmailAddress)
	Write-Output $("Contact Number: $TotalCount")

	if ($ValidHSCContacts.PrimarySMTPAddress -contains $CurrentHSCContact.EmailAddress) {
		Write-Output "Contact found in import file - Will not be deleted"
	}
	else
	{
		Write-Output "Contact not found in import file and will be deleted"
		Write-Output "Total deleted: $DeleteCount"

		$MailContact = Get-MailContact $CurrentHSCContact.EmailAddress
		if ($CurrentHSCContact.IsDirSynced -eq $true) {
			#This is the case where a contact was created by the WVU Foundation - It will not be deleted.
			Write-Output "Contact is synced from WVU Foundation - Will not be deleted."
		}
		else
		{
			Write-Output "Contact is not synced from WVU Foundation - Will be deleted."

			$DeleteCount++

			try
			{
				Add-Content $DeleteFile $contact.EmailAddress

				#Get-MsolContact -searchstring $contact.EmailAddress -ErrorAction Stop | Remove-MsolContact -force -ErrorAction Stop
			}
			catch {
				Write-Warning "There was an error trying to remove the contact."
			}

			if ($DeleteCount -gt $MaximumDeletes)
			{
				#Safety Measure which needs to be removed after testing is done.
				Write-Output "Maximum deletes have been reached. Program is exiting."
				Invoke-HSCExitCommand -ErrorCount $Error.Count
			}
		}
	}

	Write-Output "*****************************************"
}

Write-Output "Deleting old contacts has been completed."

Invoke-HSCExitCommand -ErrorCount $Error.Count