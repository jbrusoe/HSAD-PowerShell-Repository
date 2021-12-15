#Remove-ForwardingSMTPAddress.ps1
#Written by: Jeff Brusoe
#Last Updated: May 13, 2021
#
#The purpose of this file is to remove the forwarding SMTP address that
#may have been set by a user.

[CmdletBinding()]
param ()

try {
	Set-HSCEnvironment -ErrorAction Stop
	Connect-HSCExchangeOnline -ErrorAction Stop
}
catch {
	Write-Warning "Error configuring environment. Program is exiting."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
	$AllowedForwardingAddresses = Import-Csv AllowedForwardingAddresses.csv -ErrorAction Stop
}
catch {
	Write-Warning "Unable to open allowed forwarding file. Program is exiting"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output "`nGenerating list of mailboxes"

try {
	$Mailboxes = Get-EXOMailbox -ResultSize unlimited -ErrorAction Stop -Properties ForwardingSMTPAddress |
		Where-Object {$_.ForwardingSMTPAddress -AND
			$_.ForwardingSMTPAddress -notlike "*@hsc.wvu.edu*"}
}
catch {
	Write-Warning "Unable to get list of mailboxes. Program is exiting."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

if (($Mailboxes | Measure-Object).Count -gt 0)
{
	Write-Output $("Forwarding Rules Found: " +
					($Mailboxes | Measure-Object).Count.toString() + "`n`n")

	foreach ($Mailbox in $Mailboxes)
	{
		Write-Output $($Mailbox.PrimarySMTPAddress)
		Write-Output $($Mailbox.ForwardingSMTPAddress)

		if ($AllowedForwardingAddresses.HSCMailbox -contains $Mailbox.PrimarySMTPAddress) {
			Write-Output "This forwarding address is being ignored."
		}
		else
		{
			Write-Output "Removing forwarding SMTP address"
			try {
				$Mailbox | Set-Mailbox -ForwardingSMTPAddress $null -ErrorAction Stop
			}
			catch {
				Write-Warning "Error removing forwarding SMTP address"
			}
		}

		Write-Output "*********************************"
	}
}
else {
	Write-Output "No forwarding SMTP addresses found."
}

Invoke-HSCExitCommand -ErrorCount $Error.Count