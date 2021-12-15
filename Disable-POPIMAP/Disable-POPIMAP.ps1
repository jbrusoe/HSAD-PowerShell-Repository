#Disable-POPIMAP.ps1
#
#Written by: Jeff Brusoe
#Last Modified: January 4, 2021
#
#This file ensures that POP and IMAP are disabled on all Exchange mailboxes
#in the HSC Office 365 tenant.

[CmdletBinding()]
param ()

try {
	Set-HSCEnvironment -ErrorAction Stop
	Connect-HSCExchangeOnline -ErrorAction Stop

	$UserNumber = 0
}
catch {
	Write-Warning "Unable to configure environment. Program is exiting."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
	Write-Output "`nGenerating list of mailboxes..."

	$Mailboxes = Get-ExoCasMailbox -ResultSize Unlimited -ErrorAction Stop |
		Where-Object {($_.IMAPEnabled -eq $true) -OR ($_.POPEnabled -eq $true)}
}
catch {
	Write-Warning "Unable to generate list of mailboxes"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

if (($Mailboxes | Measure-Object).Count -eq 0) {
	Write-Output "POP and IMAP are disabled on all mailboxes.`n"
}
else
{
	foreach ($Mailbox in $Mailboxes)
	{
		$UserNumber++
		#$Mailbox | Write-HSCCasMailboxSummary -UserName $UserNumber

		try
		{
			if ($Mailbox.PrimarySMTPAddress -like "FPAdmin*") {
				#This is an exclusion to allow IMAP on these mailboxes only
				Write-Output $($mailbox.PrimarySMTPAddress + " skipped - only disabling POP")
				$Mailbox | Disable-HSCPOP -ErrorAction Stop
			}
			else {
				$Mailbox.PrimarySMTPAddress | Disable-HSCIMAP -ErrorAction Stop
				$Mailbox.PrimarySMTPAddress | Disable-HSCPOP -ErrorAction Stop
			}
		}
		catch {
			Write-Warning "Error Disabling POP/IMAP"
		}
	}
}

Invoke-HSCExitCommand -ErrorCount $Error.Count