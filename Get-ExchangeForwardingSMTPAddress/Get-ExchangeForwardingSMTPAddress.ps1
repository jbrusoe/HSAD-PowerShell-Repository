#Get-ExchangeForwardingSMTPAddress.ps1
#Written by: Jeff Brusoe
#Last Updated: April December 16, 2020
#
#Purpose: This file logs the Office 365 Exchange forwarding SMTP addresses

[CmdletBinding()]
param ()

try {
	Set-HSCEnvironment -ErrorAction Stop
	Connect-HSCExchangeOnline -ErrorAction Stop
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$LogFile = "$PSScriptRoot\Logs\" +
			(Get-Date -Format yyyy-MM-dd-HH-mm) +
			"-ForwardingSMTPAddress.csv"
New-Item -type file -Path $LogFile -Force

try
{
	Write-Output "`n`nGenerating list of mailboxes..."
	$Mailboxes = Get-Mailbox -ResultSize Unlimited -ErrorAction Stop |
		Where-Object {($_.PrimarySMTPAddress -notlike "*rni.*") -AND
			($_.PrimarySMTPAddress -notlike "*wvurni*")}
}
catch
{
	Write-Error "Unable to generate list of mailboxes. Program is exiting"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($Mailbox in $Mailboxes)
{
	Write-Output $("Current Mailbox: " + $Mailbox.PrimarySMTPAddress)

	if ([string]::IsNullOrEmpty($Mailbox.ForwardingSMTPAddress)) {
		Write-Output "No forwarding SMTP address"
	}
	else
	{
		Write-Output $("Forwarding SMTP Address: " + $Mailbox.ForwardingSMTPAddress)

		$Mailbox |
			Select-Object PrimarySMTPAddress,ForwardingSMTPAddress |
			Export-Csv $LogFile -Append
	}

	Write-Output "**********************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count