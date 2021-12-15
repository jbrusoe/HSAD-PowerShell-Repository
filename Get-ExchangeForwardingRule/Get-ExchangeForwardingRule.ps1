#Get-ExchangeForwardingRule.ps1
#
#Written by: Jeff Brusoe
#Last Modified: January 5, 2021
#Version: 1.0
#
#Purpose: Get exchange forwarding rule reports

[CmdletBinding()]
param ()

#Configure Environment
try {
	Set-HSCEnvironment -ErrorAction Stop
	Connect-HSCExchangeOnline -ErrorAction Stop

	$Properties = @(
		"Name",
		"Description",
		"Enabled",
		"Priority",
		"ForwardTo",
		"ForwardAsAttachmentTo",
		"RedirectTo",
		"DeleteMessage"
	)

	$MailboxCount = 0

}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
	Write-Output "Generating user list"

	$Mailboxes = Get-Mailbox -ResultSize Unlimited |
		Where-Object {$_.PrimarySMTPAddress -notlike "*rni.*" -AND $_.PrimarySMTPAddress -notlike "*wvurni*"}

	Write-Output "Successfully generated user list."
}
catch {
	Write-Warning "An error has occurred getting mailbox list."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($Mailbox in $Mailboxes)
{
    Write-Output $("Current user: " + $Mailbox.PrimarySMTPAddress)

	Get-InboxRule -Mailbox $Mailbox.PrimarySMTPAddress  |
		Where-Object {($_.ForwardTo -ne $null) -or
			($_.ForwardAsAttachmentTo -ne $null) -or
			($_.RedirectTo -ne $null)} |
		Select-Object -Property $Properties |
		Export-Csv $InboxRuleFile -NoTypeInformation -Append

	$MailboxCount++
	Write-Output "Mailbox Count: $MailboxCount"

	Write-Output "*************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count