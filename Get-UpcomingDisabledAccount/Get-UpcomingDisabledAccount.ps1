<#
.SYNOPSIS
	 This file sends out an email with users who were disabled today or
	 will be disabled over the next week.

.PARAMETER Testing
	Used during file development as a safety measure at certain points.

.NOTES
	Get-UpcomingDisabledAccount.ps1
    Author: Jeff Brusoe
    Last Updated: August 5, 2020
#>

[CmdletBinding()]
param (
	[switch]$Testing
)

$Error.Clear()

try {
	Set-HSCEnvironment -ErrorAction Stop
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try
{
	Write-Output "Generating list of AD users that will be disabled"
	$users = Get-ADUser -filter * -Properties extensionAttribute1 |
			Where-Object {$_.extensionAttribute1 -AND
			[datetime]$_.extensionAttribute1 -ge (Get-Date).AddDays(-1) -AND
			[datetime]$_.extensionAttribute1 -le (Get-Date).AddDays(7)}

	$UsersFound = ($users | Measure-Object).Count
	Write-Output "Upcoming Disables: $UsersFound"

	if ($UsersFound -gt 0)
	{
		$OutputFile = "$PSScriptRoot\Logs\" +
						(Get-Date -Format yyyy-MM-dd) +
						"-UpcomingADDisables.csv"
		$users | Select-Object SamAccountName,extensionAttribute1,DistinguishedName |
			Sort-Object -Property extensionAttribute1 |
			Export-Csv $OutputFile -NoTypeInformation -Force

		Start-Sleep -Seconds 2 #Delay to make sure writing is complete before file is sent.
	}
}
catch {
	Write-Warning "Unable to get AD user list."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#Now send email
Write-Output "Preparing to send email..."
[string[]]$Recipients = $null

if ($Testing) {
	$Recipients = "jbrusoe@hsc.wvu.edu"
}
else {
	$Recipients = @("cbarnes@hsc.wvu.edu",
					"jbrusoe@hsc.wvu.edu",
					"mkondrla@hsc.wvu.edu",
					"microsoft@hsc.wvu.edu"
				)
}

$MsgBody = "This is the list of HSC AD accounts that will be disabled in the next week."
$Subject = (Get-Date -Format yyyy-MM-dd) + " Upcoming HSC AD Disables"

try {
	$Attachments = Get-ChildItem -path "$PSScriptRoot\Logs\" -ErrorAction Stop|
		Sort-Object -Property LastWriteTime -Descending |
		Select-Object FullName -First 1 |
		ForEach-Object {$_.FullName}
}
catch {
	Write-Warning "Unable to generate attachments list"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try
{
	$SendMailMessageParams = @{
		Body = $MsgBody
		To = $Recipients
		From = "microsoft@hsc.wvu.edu"
		Subject = $Subject
		Attachments = $Attachments
		SmtpServer = "hssmtp.hsc.wvu.edu"
		Verbose = $true
		ErrorAction = "Stop"
	}

	if ($UsersFound -gt 0) {
		Send-MailMessage @SendMailMessageParams
	}
	else {
		$MsgBody = "There are no accounts scheduled to be disabled over the next week."

		$SendMailMessageParams["Body"] = $MsgBody
		$SendMailMessageParams.Remove("Attachments")

		Send-MailMessage @SendMailMessageParams
	}

	Write-Output "Successfully sent email"
}
catch
{
	Write-Warning "There was an error attempting to send the email"
	Write-Output $Error | Format-List
}

Invoke-HSCExitCommand -ErrorCount $Error.Count