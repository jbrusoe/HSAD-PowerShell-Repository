<#
	.SYNOPSIS
		This file imports mailboxes from the WVU Foundation tenant
		to the HSC tenant as mail contacts. Input to the file is provided from the
		Get-WVUFAddressBook.ps1 file.

	.PARAMETER DeleteOnly
		A value of true for this parameter tells the file to only delete contacts that are
		outdated instead of searching for changes.

	.NOTES
		Author: Jeff Brusoe
		Last Updated: February 2, 2021
#>

[CmdletBinding()]
param (
	[switch]$DeleteOnly,
	[string]$ImportFile = $null
)

try {
	Write-Verbose "Configuring Environment"
	Set-HSCEnvironment -ErrorAction Stop

	Write-Verbose "Connecting to Exchange Online"
	Connect-HSCExchangeOnline -ErrorAction Stop

	Write-Verbose "Determining Import File"
	if ($null -eq $ImportFile) {
		$ImportFile = Split-Path $PSScriptRoot -Parent
		$ImportFile = "$ImportFile\Get-WVUFAddressBook\Logs\" +
						(Get-Date -Format yyyy-MM-dd) +
						"-WVUFAddressBook.csv"
	}

	if (Test-Path $ImportFile) {
		Write-Output "Import File: $ImportFile"
	}
	else {
		Write-Warning "Import file doesn't exist."
		throw "Import File Doesn't Exist Exception"
	}

	Write-Verbose "Done configuring environment"
}
catch {
	Write-Warning "Unable to configure HSC Environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#Read export file from Get-MainCampusMailbox.ps1
try {
	$WVUFMailboxes = Import-Csv $ImportFile -ErrorAction Stop
}
catch {
	Write-Warning "Unable to open import file"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#####################
# Begin WVUF Import #
#####################
if (!$DeleteOnly)
{
	foreach ($WVUFMailbox in $WVUFMailboxes)
	{
		$PrimarySMTPAddress = $WVUFMailbox.PrimarySMTPAddress.Trim()
		$DisplayName = $WVUFMailbox.LastName + ", " + $WVUFMailbox.FirstName
		$Alias = $WVUFMailbox.Alias

		Write-Output "Primary SMTP Address: $PrimarySMTPAddress"
		Write-Output "Display Name: $DisplayName"
		Write-Output "Alias: $Alias"

		try {
			$NewMailContactParams = @{
				Name = $DisplayName
				ExternalEmailAddress = $PrimarySMTPAddress
				FirstName = $WVUFMailbox.FirstName
				LastName = $WVUFMailbox.LastName
				DisplayName = $DisplayName
				Alias = $Alias
				ErrorAction = "Stop"
			}

			New-MailContact  @NewMailContactParams

			Write-Output "Mail contact created"
			Start-Countdown -Seconds 5 -Message "Delay after creating new email contact"
		}
		catch {
			Write-Output "Mail contact already exists"
		}

		Write-ColorOutput -ForegroundColor "Cyan" -Message "Updating New Contact Information"

		$Department = "WVUF " + $WVUFMailbox.Department

		Write-Output "Setting Phone Number, Title, and Department"
		Write-Output $("Phone Number: " + $WVUFMailbox.Phone)
		Write-Output $("Title: " + $WVUFMailbox.Title)
		Write-Output "Department: $Department"

		try {
			$SetContactParams = @{
				Identity = $PrimarySMTPAddress
				Phone = $WVUFMailbox.Phone
				Title = $WVUFMailbox.Title
				Department = $WVUFMailbox.Department
				DisplayName = $DisplayName
				ErrorAction = "Stop"
			}

			Set-Contact @SetContactParams
		}
		catch {
			Write-Warning "Error updating contact fields"
		}

		try {
			Set-Mailcontact -Identity $PrimarySMTPAddress -Alias $Alias -ErrorAction Stop
		}
		catch {
			Write-Warning "Error updating alias field"
		}

		try {
			Write-Output "Setting CustomAttribute1 to WVU MainCampus"
			Write-Output "Setting CustomAttribute7 with TimeStamp"

			$SetMailContactParams = @{
				Identity = $PrimarySMTPAddress
				CustomAttribute1 = "WVUFoundation"
				CustomAttribute7 = $(Get-Date -format d) #Flag to track when import was done
				ErrorAction = "Stop"
			}

			Set-MailContact @SetMailContactParams
		}
		catch {
			Write-Warning "Unable to configure CustomAttribute1/7"
		}

		Write-Output "*****************************************"
	}
}

################################
# Begin Deleting WVUF Contacts #
################################
Write-Output "Beginning to remove old WVUF mail contact objects"

try {
	$WVUFMailContacts = Get-MailContact -ResultSize Unlimited -ErrorAction Stop |
		Where-Object {$_.PrimarySMTPAddress -like "*@wvuf.org*"}

	Write-Output "Successfully pulled list of WVUF Mail Contacts"
}
catch {
	Write-Warning "Unable to pull list of WVUF mail contacts"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output $("Number of WVUF Mail Contacts: " + $WVUFMailContacts.Count)

foreach ($WVUFMailContact in $WVUFMailContacts)
{
	Write-Output $("Current Mail Contact: " + $WVUFMailContact.PrimarySMTPAddress)
	if ($WVUFMailboxes.PrimarySMTPAddress -contains $WVUfMailContact.PrimarySMTPAddress){
		#Mail contact is in file and will not be deleted
		Write-Output "Mail contact will not be deleted"
	}
	else {
		#Mail contact is not in file and will be deleted
		Write-Output "Mail contact is being deleted"

		try {
			$WVUFMailContact | Remove-MailContact -Confirm:$false -ErrorAction Stop

			Write-Output "Successfully deleted mail contact"
			Start-Sleep -s 2
		}
		catch {
			Write-Warning "Unable to remove mail contact"
		}
	}

	Write-Output "*******************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count