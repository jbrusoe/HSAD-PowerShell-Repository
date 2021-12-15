<#
.SYNOPSIS
	 The purpose of this program is to export mailbox information
	 from the WVU main campus Office 365 tenant.

.DESCRIPTION
	This file is used to export mailbox information from the
	WestVirginiaUniversity Office 365 tenant.

	Mailboxes that are selected for export must meet the following requirements.
	1. The mailbox must be a user mailbox.
	2. Primary SMTP Address is either @mail.wvu.edu or @wvu.edu.
	3. Not hidden in the main campus address book
	4. Contain a first and last name
	5. Gordon Gee - For some reason, his display name is correct, but
	   he has no first/last name in the address book. By rule 3, his
	   account would normally not be exported
	6. Does not contain the word "test" in the name

	There are some other minor clean up to account for discrepancies
	in the main campus address book as well.

.OUTPUTS
	This file generates the following output:
	1. Export main campus email addresses which will be
	   imported (via a separate script) the the HSC tenant.
	2. Create file to import SIP addresses into the HSC tenant.

.PARAMETER MainCampusMailboxFile
	This is the main output file which will be imported.

.PARAMETER SIPFile
	This is the file containing the SIP addresses which will also be imported.

.PARAMETER Testing
	Using this parameter will stop file processing if an error occurs.

.NOTES
    Author: Jeff Brusoe
    Last Updated: December 18, 2020
#>

[CmdletBinding()]
param (
	[ValidateNotNullOrEmpty()]
	[string]$MainCampusMailboxFile = ("$PSScriptRoot\Logs\" +
										(Get-Date -Format yyyy-MM-dd-HH-mm) +
										"-MainCampusExchangeExport.csv"),

	[ValidateNotNullOrEmpty()]
	[string]$SIPFile = ("$PSScriptRoot\Logs\" +
							(Get-Date -Format yyyy-MM-dd-HH-mm) +
							"-SIP-MC.csv"),

	[switch]$Testing
)

try {
	Set-HSCEnvironment -ErrorAction Stop
	Connect-MainCampusExchangeOnline -ErrorAction Stop

	$ExportProperties = @(
		"DisplayName",
		"FirstName",
		"LastName",
		"Title",
		"Department",
		"Phone",
		"PrimarySMTPAddress",
		"Alias",
		"WhenChanged",
		"CustomAttribute8",
		"HiddenFromAddressListsEnabled"
	)
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#Initialization of output files
New-Item -path $SIPFile -Type "file" -Force
New-Item -path $MainCampusMailboxFile -Type "file" -Force

#Get main campus mailboxes
Write-Output "Generating list of main campus mailboxes"

try
{
	$AdditionalProperties = @("FirstName",
							  "LastName",
							  "Title",
							  "Department",
							  "Phone",
							  "WhenChanged",
							  "CustomAttribute8","
							  HiddenFromAddressListsEnabled")

	$Mailboxes = Get-EXORecipient -Resultsize Unlimited -ErrorAction Stop -Properties $AdditionalProperties |
		Where-Object {(	($_.PrimarySMTPAddress -like "*@mail.wvu.edu") -OR ($_.PrimarySMTPAddress -like "*@wvu.edu")) -AND
				 	($_.HiddenFromAddressListsEnabled -eq $false) -AND
				 	($_.Title -notlike "*Retiree*") }
}
catch
{
	Write-Warning "Unable to query main campus mailboxes. Program is exiting."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output "`nBeginning to process main campus mailboxes"

$MailboxCount = 1
foreach ($Mailbox in $Mailboxes)
{
	if ($Error.Count -gt 0 -AND $Testing)
	{
		Write-Warning "Stopping due to error. Program is exiting."
		$Error | Format-List

		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}

	Write-Output $("`n`nCurrent Mailbox: " + $Mailbox.PrimarySMTPAddress)
	Write-Output $("Mailbox Count: $MailboxCount")

	if (($Mailbox.PrimarySMTPAddress -eq "Gordon.gee@mail.wvu.edu") -OR
		($Mailbox.PrimarySMTPAddress -eq "ur@mail.wvu.edu"))
	{
		#Make sure to include this address
		#Currently (April 25, 2016) there is no first or last name entry for him,
		#but his display name is correct.
		Write-Output "Adding Gordon Gee/UR@mail.wvu.du to export file."

		$Mailbox |
			Select-Object $ExportProperties |
			Export-Csv $MainCampusMailboxFile -Append -NoTypeInformation

		$MailboxCount++
	}
	elseif (([string]::IsNullOrEmpty($Mailbox.LastName)) -OR ([string]::IsNullOrEmpty($Mailbox.FirstName)))
	{
		if ([string]::IsNullOrEmpty($Mailbox.LastName)) {
			Write-Warning "Skipping mailbox because of missing last name"
		}
		else {
			Write-Warning "Skipping mailbox because of missing first name"
		}
	}
	elseif ($Mailbox.DisplayName.toLower().IndexOf("test") -ge 0)
	{
		Write-Warning "Test account - Skipping"
	}
	else
	{
		Write-Output "Exporting user information"

		$Mailbox |
			Select-Object -Property $ExportProperties |
			Export-Csv $MainCampusMailboxFile -Append -NoTypeInformation

		$MailboxCount++
	}

	#Examine email addresses to see if any are SIP ones.
	Write-Output "Looking for SIP Addresses"

	$EmailAddresses = $Mailbox.EmailAddresses

	foreach ($EmailAddress in $EmailAddresses)
	{
		Write-Output "EmailAddress: $EmailAddress"

		if ($EmailAddress.indexof("SIP") -ge 0)
		{
			Write-Output "Writing $EmailAddress to SIP file"

			$Mailbox |
				Select-Object PrimarySMTPAddress,Alias,@{Label ='SIPAddress';Expression={$EmailAddress}} |
				Export-Csv $SIPFile -Append -NoTypeInformation
		}
	}
}

Invoke-HSCExitCommand -ErrorCount $Error.Count