#Set-MailContactCompanyField.ps1
#Written by: Jeff Brusoe
#Last Updated: March 18, 2020
#
#The purpose of this file is to set the mail contact company field for MSOL contacts. It is not designed to run as a scheduled task because
#these are all being migrated over to AzureAD contacts.

$TranscriptLogFile = "$PSScriptRoot\Logs\" + (Get-Date -format yyyy-MM-dd-HH-mmm) + "-SessionTranscript.txt"
Start-Transcript $TranscriptLogFile

$InvalidEmailFile = "$PSScriptRoot\Logs\" + (Get-Date -format yyyy-MM-dd-HH-mmm) + "-InvalidEmailFile.txt"
New-Item $InvalidEmailFile -type file -Force

$CurrentUserCount = 1
$CompanyAddCount = 0
$MSOLContacts = Get-MsolContact -All

foreach ($MSOLContact in $MSOLContacts)
{
	$EmailAddress = $MSOLContact.EmailAddress
	Write-Output "Current User: $EmailAddress"
	
	$CompanyName = $MSOLContact.CompanyName
	Write-Output "Company Name: $CompanyName"

	if ([string]::IsNullOrEmpty($CompanyName) -AND ($EmailAddress -like "*@mail.wvu.edu*" -OR $EmailAddress -like "*@wvu.edu*"))
	{
		Set-Contact -Identity $EmailAddress -Company "WVU"
		$CompanyAddCount++
		
		Start-Sleep -s 3
	}
	elseif ([string]::IsNullOrEmpty($CompanyName) -AND ($EmailAddress -like "*wvuf.org"))
	{
		Set-Contact -Identity $EmailAddress -Company "WVUF"

		Start-Sleep -s 3
	}
	elseif ($EmailAddress -notlike "*mail.wvu.edu*" -AND $EmailAddress -notlike "*wvuf.org*" -AND $EmailAddress -notlike "*@wvu.edu*")
	{
		#This is here to ensure that no @gmail.com etc. type of contacts.
		Add-Content $InvalidEmailFile -Value $EmailAddress
	}
	
	Write-Output "Current User Count: $CurrentUserCount"
	$CurrentUserCount++
	
	Write-Output "Company Add Count: $CompanyAddCount"
	
	Write-Output "**********************"
}

Stop-Transcript
