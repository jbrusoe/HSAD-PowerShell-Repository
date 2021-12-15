#Update-AddressList.ps1
#Written by: Jeff Brusoe
#Last Updated: May 18, 2021
#
#To do: Pull functions into module and add advanced functionality

[CmdletBinding()]
param ()

try {
	Set-HSCEnvironment -ErrorAction Stop
	Connect-HSCExchangeOnlineV1 -ErrorAction Stop
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#Attempting to set contact information
Function Set-HSCMailContact
{
	[CmdletBinding()]
	param()

	Write-Output "`n`nConfiguring Mail Contacts"

	try {
		Write-Output "Generating list of mail contacts"
		$Contacts = Get-Contact -ResultSize Unlimited -ErrorAction Stop
	}
	catch {
		Write-Warning "Unable to generate list of contacts"
		$Contacts = $null
	}

	$ContactCount = 0
	foreach ($Contact in $Contacts)
	{
		Write-Output $("Current Contact: " + $Contact.WindowsEmailAddress)
		Write-Output $("Current Simple Display Name: " + $Contact.SimpleDisplayName)
		Write-Output "Contact Count: $ContactCount"
		$ContactCount++

		try {
			$Contact | Set-Contact -SimpleDisplayName $Contact.SimpleDisplayName -ErrorAction Stop
			Write-Output "Successfully updated contact"
		}
		catch
		{
			Write-Warning "Error attempting to set mail contact. Trying again."

			try {
				$SetContactParams = @{
					Identity = $Contact.WindowsEmailAddress
					SimpleDisplayName = $Contact.SimpleDisplayName
					ErrorAction = "Stop"
				}

				Set-Contact @SetContactParams
				Write-Output "Successfully updated contact"
			}
			catch {
				Write-Error "Unable to set mail contact"
			}
		}

		Write-Output "*******************************"
	}

	Write-Output "Done setting mail contacts"
} #End mail contact function


Function Set-HSCMailbox
{
	Write-Output "`n`nConfiguring Mailboxes"

	try {
		Write-Output "Generating list of mailboxes"
		$Mailboxes = Get-Mailbox -ResultSize Unlimited -ErrorAction Stop
	}
	catch {
		Write-Warning "Unable to generate list of mailboxes"
		$Mailboxes = $null
	}

	$MailboxCount = 0
	foreach ($Mailbox in $Mailboxes)
	{
		Write-Output $( "Current Mailbox: " +$Mailbox.PrimarySMTPAddress)
		Write-Output "Mailbox Count: $MailboxCount"
		$MailboxCount++

		try {
			$Mailbox | Set-Mailbox -ApplyMandatoryProperties -ErrorAction Stop
			Write-Output "Successfully updated mailbox"
		}
		catch
		{
			Write-Warning "Error attempting to set mailbox. Trying again."

			try {
				Set-Mailbox -Identity $Mailbox.PrimarySMTPAddress -ApplyMandatoryProperties -ErrorAction Stop
				Write-Output "Successfully updated mailbox"
			}
			catch {
				Write-Error "Unable to set mailbox"
			}
		}

		Write-Output "********************************"
	}
} #End set mailbox function

Function Set-HSCMailUser
{
	Write-Output "`n`nSetting properties for mail users"
	try {
		Write-Output "Generatng list of mail users"
		$MailUsers = Get-MailUser -Resultsize Unlimited -ErrorAction Stop
	}
	catch {
		Write-Warning "Unable to generate list of mail users"
		$MailUsers = $null
	}

	$MailUserCount = 0
	foreach ($MailUser in $MailUsers)
	{
		Write-Output $("Current MailUser: " + $MailUser.PrimarySMTPAddress)
		Write-Output $("Current Simple Display Name: " + $MailUser.SimpleDisplayName)
		Write-Output "Mail User Count: $MailUserCount"
		$MailUserCount++

		try {
			$MailUser |
				Set-MailUser -SimpleDisplayName $MailUser.SimpleDisplayName -ErrorAction Stop
			Write-Output "Successfully updated mailuser"
		}
		catch
		{
			Write-Warning "Error attempting to set mailuser. Trying again."

			try {
				$SetMailUserParams = @{
					Identity = $MailUser.PrimarySMTPAddress
					SimpleDisplayName = $MailUser.SimpleDisplayName
					ErrorAction = "Stop"
				}
				Set-MailUser @SetMailUserParams

				Write-Output "Successfully updated mailuser"
			}
			catch {
				Write-Warning "Unable to set mailuser"
			}
		}

		Write-Output "**********************************"
	}
}

switch ((Get-Date).Day%3)
{
	0 { Set-HSCMailContact ; Set-HSCMailbox ; Set-HSCMailUser }
	1 { Set-HSCMailbox ; Set-HSCMailUser ; Set-HSCMailContact }
	2 { Set-HSCMailUser ; Set-HSCMailContact ; Set-HSCMailbox }
}

Invoke-HSCExitCommand -ErrorCount $Error.Count