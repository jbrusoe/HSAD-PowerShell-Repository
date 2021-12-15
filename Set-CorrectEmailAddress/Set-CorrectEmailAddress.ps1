#Set-CorrectEmailAddress.ps1
#Written by: Jeff Brusoe
#Last Updated: January 6, 2021
#
#The purpose of this file is to correct any entries
#which have no.email@wvu.edu as an email attribute field in AD.

[CmdletBinding()]
param ()

#Configure environment
try {
	Set-HSCEnvironment -ErrorAction Stop

	$CSVSummaryFile = "$PSScriptRoot\Logs\" +
					(Get-Date -format yyyy-MM-dd-HH-mm) +
					"-MailAttributeSummary.csv"
	New-Item $CSVSummaryFile -ErrorAction Stop
	
	$ChangeCount = 0
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#Generate array of AD users with no.email@wvu.edu in mail field
try {
	Write-Output "Generating array of AD users"

	$Properties = @(
		"mail",
		"extensionAttribute6",
		"extensionAttribute15",
		"proxyAddresses"
	)

	$GetADuserParams = @{
		Filter = 'mail -eq "no.email@wvu.edu"'
		Properties = $Properties
		ErrorAction = "Stop"
	}

	$ADUsers = Get-ADUser @GetADUserParams
}
catch {
	Write-Warning "Unable to generate list of AD Users"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}



if (($ADUsers | Measure-Object).Count -eq 0) {
	Write-Output "`n`nNo users found.`n`n"
}
else
{
	foreach ($ADUser in $ADUsers)
	{
		[string]$MailAttribute = $null
		$ChangePrimarySMTP = $false

		Write-Output $("Current User: " + $ADUser.SamAccountName)
		Write-Output $("Current Mail Attribute: " + $ADUser.mail)
		Write-Output $("extensionAttribute6: " + $ADUser.extensionAttribute6)
		Write-Output $("Distinguished Name: " + $ADUser.DistinguishedName)

		if (($ADUser.ProxyAddresses | Measure-Object).Count -gt 0)
		{
			Write-Output "`nProxy Addresses:"
			foreach ($ProxyAddress in $ADuser.ProxyAddresses)
			{
				Write-Output "Examing Proxy Address: $ProxyAddress"

				if ($ProxyAddress -clike "SMTP:*")
				{
					Write-Output "Found Primary SMTP Address"
					$MailAttribute = $ProxyAddress
					$MailAttribute = $MailAttribute -replace "SMTP:",""
					$MailAttribute = $MailAttribute.Trim()

					if ($MailAttribute -eq "no.email@wvu.edu")
					{
						#This handles the case when this was incorrectly set 
						#as the primary SMTP address in the proxyaddresses.
						$ChangePrimarySMTP = $true
						$MailAttribute = $null
					}
				}
			}

			if ([string]::IsNullOrEmpty($MailAttribute)) {
				Write-Output "Primary SMTP Address was not found"
			}
			elseif ($ChangePrimarySMTP)
			{
				#This implies primary SMTP was set to no.email@wvu.edu
				$PrimarySMTPAddress = "SMTP:" + $ADUser.UserPrincipalName

				Write-Output "Current Primary SMTP: no.email@wvu.edu"
				Write-Output "New Primary SMTP: $PrimarySMTPAddress"

				try
				{
					$ADUser.ProxyAddresses.Remove("SMTP:no.email@wvu.edu")
					$ADUser.ProxyAddresses.Add($PrimarySMTPAddress)

					Set-ADUser -Instance $ADUser -ErrorAction Stop

					Write-Output "Successfully set new primary SMTP address"
				}
				catch {
					Write-Warning "Error cleaning up primary SMTP address"
				}
			}
		}
		else {
			Write-Output "ProxyAddress field is empty."
		}

		if ([string]::IsNullOrEmpty($MailAttribute))
		{
			Write-Output "`nPrimary SMTP Address not found. Examining extensionAttribute6"

			if ($ADUser.extensionAttribute6 -eq "EMPLOYEE") {
				$MailAttribute = $ADUser.SamAccountName + "@hsc.wvu.edu"
			}
			elseif ($ADUser.extensionAttribute6 -eq "STUDENT") {
				$MailAttribute = $ADUser.SamAccountName + "@mix.wvu.edu"
			}
			elseif ($ADUser.extensionAttribute6 -eq "HOSPITAL") {
				$MailAttribute = $ADUser.SamAccountName + "@wvumedicine.org"
			}
		}

		if ([string]::IsNullOrEmpty($MailAttribute)) {
			Write-Output "`nextensionAttribute6 is null. Setting mail attribute to be UPN"
			$MailAttribute = $ADUser.UserPrincipalName
		}

		if (![string]::IsNullOrEmpty($MailAttribute))
		{
			Write-Output "`n`nSetting Mail Attribute to $MailAttribute"

			try
			{
				$ADUser | Set-ADUser -EmailAddress $MailAttribute -ErrorAction Stop
				Write-Output "Done setting mail attribute"

				$MailAttributeInfo = New-Object -TypeName PSObject

				[string]$SamAccountName = $ADUser.SamAccountName
				[string]$UPN = $ADUser.UserPrincipalName

				$AddMemberParams = @{
					MemberType = "NoteProperty"
					Name = "SAMAccountName"
					Value = $SamAccountName
					ErrorAction = "Stop"
				}
				$MailAttributeInfo | Add-Member @AddMemberParams

				$AddMemberParams["Name"] = "UPN"
				$AddMemberParams["Value"] = $UPN
				$MailAttributeInfo | Add-Member @AddmemberParams

				$AddMemberParams["Name"] = "MailAttribute"
				$AddMemberParams["Value"] = $MailAttribute
				$MailAttributeInfo | Add-Member @AddMemberParams

				$MailAttributeInfo |
					Export-Csv $CSVSummaryFile -Append -ErrorAction Stop

				$ChangeCount++
				Write-Output "Change Count: $ChangeCount"
			}
			catch {
				Write-Warning "Unable to set mail attribute."
			}
		}

		Write-Output "************************************************"
	}
}

Invoke-HSCExitCommand -ErrorCount $Error.Count