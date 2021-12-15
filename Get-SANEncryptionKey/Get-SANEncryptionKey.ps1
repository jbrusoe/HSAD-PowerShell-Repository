#Get-SANEncyrptionKey.ps1
#Written by: Jeff Brusoe
#Last Updated: May 8, 2020
#
#The purpose of this file is to backup the SAN encryption keys.

<#
	.SYNOPSIS
		This file backs up the SAN encryption keys and emails them out every morning.

	.DESCRIPTION
		The backups require the installation of Unisphere CLI found in
		this directory (UnisphereCLI-ForBackups.exe).

	.PARAMETER BackupDirectory
		Specifies which directory to store the lbb files in.

	.PARAMETER PwdFile
		This is the encrypted file that is used to store the password in order to send out the
		backup key emails.

	.NOTES
		Filename: Get-SANEncryptionKey.ps1
		Author: Jeff Brusoe
		Last Updated By: Jeff Brusoe
		Last Updated: October 28, 2020
#>

[CmdletBinding()]
param (
	[ValidateNotNullOrEmpty()]
	[string]$BackupDirectory = "$PSScriptRoot\EncryptionKeys\",

	[ValidateNotNullOrEmpty()]
	[string]$PwdFile = $((Get-HSCGitHubRepoPath) +
						"2CommonFiles\EncryptedFiles\GSE3.txt"),

	[switch]$Testing
)

try {
	Set-HSCEnvironment -ErrorAction Stop

	if ($Testing) {
		$Recipients = "jbrusoe@hsc.wvu.edu"
	}
	else {
		$Recipients = @(
			"jbrusoe@hsc.wvu.edu",
			"krodney@hsc.wvu.edu",
			"rnichols@hsc.wvu.edu",
			"microsoft@hsc.wvu.edu"
		)
	}
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$MailParams = @{
	To = $Recipients
	From = "microsoft@hsc.wvu.edu"
	Subject = "Error backing up encryption keys for 10.3.4.102"
	SmtpServer = "hssmtp.hsc.wvu.edu"
	Priority = "High"
	Verbose = $true
}

#Remove old key files
Write-Verbose "Removing old encryption keys"
Remove-HSCOldLogFile -LBB -Path $BackupDirectory -Days 14 -Verbose -Delete

#Configure email parameters


#The following block of code calls the Unisphere Command Line Interface (uemcli)
#and are based on an email from Kim. Documentation for the uemcli utility
#can be found here: https://www.emc.com/collateral/TechnicalDocument/docu69330.pdf.

#These are flags to indicate success/failure and are mainly used to generate the final email.
$Success102 = $false
$Success133 = $false

Write-Output -"`nBeginning to backup keys for 10.3.4.102"
Write-Output "Backup Directory: $BackupDirectory`n"

#Decrypt password to connect to SAN
$Password = Get-HSCPasswordFromSecureStringFile -PWFile $PwdFile

if ($Error.Count -gt 0) {
	$Error
	$Error.Clear()
}

Uemcli -d 10.3.4.102 -u Local/systems -p $Password -download -d $BackupDirectory encryption -type backupKeys |
	Tee-Object "102.txt"

if ($Error.Count -gt 0) {
	Write-Warning "There was an error generating encryption key for 10.3.4.102"
	$Error
}

if ($null -ne (select-string -path "102.txt" -Pattern "operation completed successfully"))
{
	Write-ColorOutput -ForegroundColor "Green" -Message "`nKeys backed up for 10.3.4.102.`n"
	$Success102 = $true
}
else
{
	Write-Warning "`nError backing keys up for 10.3.4.102`n"
	Send-MailMessage @MailParams
}

Write-ColorOutput -ForegroundColor "Green" -Message "`nBeginning to backup keys for 10.3.4.133"
Write-ColorOutput -ForegroundColor "Green" -Message $("Backup Directory: $BackupDirectory`n")

$Error.Clear()
Uemcli -d 10.3.4.133 -u Local/systems -p $Password -download -d $BackupDirectory encryption -type backupKeys |
	Tee-Object "133.txt"

if ($Error.Count -gt 0) {
	Write-Warning "There was an error generating encryption key for 10.3.4.133"
}

if ($null -ne (select-string -path "133.txt" -Pattern "operation completed successfully"))
{
	Write-ColorOutput -ForegroundColor "Green" -Message "`nKeys backed up for 10.3.4.133.`n"
	$Success133 = $true
}
else
{
	Write-Warning "`nError backing keys up for 10.3.4.133`n"

	$MailParams["Subject"] = "Error backing up encryption keys for 10.3.4.133"
	Send-MailMessage @MailParams
}

if ($Success102 -AND $Success133)
{
	Get-ChildItem -path $BackupDirectory
	$Attachments = Get-ChildItem -path $BackupDirectory |
		Sort-Object -Property LastWriteTime -Descending |
		Select-Object FullName -first 2 |
		ForEach-Object {$_.FullName}

	Write-Output "Attachements:"
	Write-Output $Attachments

	$Subject = (Get-Date -format yyyy-MM-dd) + " Successfully backed up SAN encryption keys"
	$MsgBody = "Encryption keys are stored on sysscript3 in $BackupDirectory " +
				"and are also attached to this email."

	try
	{
		$MailParams["Subject"] = $Subject
		$MailParams["Attachments"] = $Attachments
		$MailParams["Body"] = $MsgBody
		$MailParams["Priority"] = "Normal"

		Send-MailMessage @MailParams
		Write-Output "Successfully sent email"
	}
	catch
	{
		Write-Warning "There was an error attempting to send the email"
		Write-Output $Error | Format-List
	}
}

Write-Verbose "Cleaning up files."
Remove-Item "102.txt"
Remove-Item "133.txt"

Invoke-HSCExitCommand -ErrorCount $Error.Count