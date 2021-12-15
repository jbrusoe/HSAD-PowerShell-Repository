<# 
License new account created in step 10

    Set-MsolUserLicense -UserPrincipalName <EmailAlias-NEW>@wvuhsc.onmicrosoft.com -AddLicenses "WVUHSC:STANDARDWOFFPACK_FACULTY"

A slight delay will be needed at this point.
Verify new mailbox is created. DO NOT PROCEED UNTIL THIS IS CREATED.

    Get-Mailbox <EmailAlias-NEW>

Get an object for the deleted mailbox. The email address to be used is the original one (such as rdtpuser@hsc.wvu.edu) since it should be in a soft deleted state.

    $mb = Get-Mailbox -SoftDeletedMailbox <EmailAddress>

Verify that a single new mailbox has been found. DO NOT PROCEED UNTIL A SINGLE CORRECT MAILBOX IS FOUND.

    $mb

Restore the old mailbox to the new one.

    New-MailboxRestoreRequest -SourceMailbox $mb.distinguishedname -TargetMailbox MailboxName-NEW@wvuhsc.onmicrosoft.com -AllowLegacyDNMismatch

Wait for the mailbox restore to finish. This can take time if a lot of email has to be moved.

    Get-MailboxRestoreRequestStatistics <EmailAlias-NEW>

After restore is finished, change the UPN of the newly created account to match the old one.

    Set-MsolUserPrincipalName -UserPrincipalName <EmailAlias-New>@wvuhsc.onmicrosoft.com -NewUserPrincipalName <EmailAlias>@wvuhsc.onmicrosoft.com

Verify that the UPN was changed successfully. DO NOT PROCEED UNTIL THE NEW UPN IS CORRECT.

    Get-MsolUser -UserPrincipalName <EmailAlias>@wvuhsc.onmicrosoft.com

Add the following email addresses.

    <EmailAlias>@hsc.wvu.edu - Set-MsolUser -UserPrincipalName <EmailAlias>@wvuhsc.onmicrosoft.com -AlternateEmailAddresses <EmailAlias>@hsc.wvu.edu
    <EmailAlias>@wvuhsc.onmicrosoft.com - Set-MsolUser -UserPrincipalName <EmailAlias>@wvuhsc.onmicrosoft.com -AlternateEmailAddresses <EmailAlias>@wvuhsc.onmicrosoft.com

Change the PrimarySMTPAddress of the account

    Set-Mailbox <EmailAlias> -WindowsEmalAddress <EmailAlias>@hsc.wvu.edu

Remove the <EmailAlias>-NEW@wvuhsc.onmicrosoft.com email address.

    Set-Mailbox <EmailAlias> -EmailAddresses @{Remove="<EmailAlias>-NEW@wvuhsc.onmicrosoft.com"}

Disable POP and IMAP access.
Set-CasMailbox <EmailAlias> -POPEnabled $false -IMAPEnabled $false

#>

[CmdletBinding()]
param (
	[string]$UserName
	)
	
$Error.Clear()

$users = import-csv Accounts2.csv

foreach ($user in $users)
{
	Write-Output $user.SamAccountName
	$UserName = $user.SamAccountName
	
	Write-Output "Mailbox Being Processed: $UserName"
<#
	#Step 1: Backup Mailbox and Calendar Permissions
	Write-Output "Backing up mailbox permissions"
	Get-MailboxPermission $UserName | Export-Csv $UserName-MailboxPermission.csv

	Write-Output "Backing up calendar permissions"
	Get-MailboxFolderPermission $($UserName + ":\Calendar") | Export-Csv $UserName-CalendarPermission.csv

	if ($Error.Count -gt 0)
	{
		#break
	}

	#Step 2: Backup Mailbox Rules
	Write-Output "Backing up inbox rules"
	Get-InboxRule -Mailbox $UserName | Export-Csv "$UserName-InboxRule.csv"

	if ($Error.Count -gt 0)
	{
		#break
	}

	#Step 3: Set extensionAttribute7="No365" in AD. This should already be done, but should be verified.
	$ADUser = Get-ADUser $UserName -Properties extensionAttribute7

	if (($ADUser | Measure).Count -eq 1)
	{
		if ($ADUser.extensionAttribute7 -eq $null)
		{	
			Write-Output "extensionAttribute7 is null"
		}
		else
		{
			Write-Output $("extensionAttribute7: " + $ADuser.extensionAttribute7)
			
			if ($ADUser.extensionAttribute7 -eq "No365")
			{
				Write-Output "extensionAttribute7 is already set"
			}
			else
			{
				return
			}
		}
	}
	else
	{
		Write-Warning "Too many users returned"
		return
	}

	Write-Output "End of step 3"
	
	#>
	
	#Step 4
	#Run an AD Sync. This is only if the MSOLUser object in the cloud hasn't been deleted yet.
	#Verify one unique deleted user object is found. DO NOT PROCEED IF MORE THAN ONE IS FOUND.
	#Get-MsolUser -SearchString <EmailAlias> -ReturnDeletedUsers
	
	#$MsolUser = Get-MsolUser -SearchString $Username -ReturnDeletedUsers
	
	#if ($MsolUser -ne $null -AND $Username -ne "ce")
	#{
	#	Return
	#}
	
	#New-MsolUser -UserPrincipalName $($Username + "-NEW@wvuhsc.onmicrosoft.com") -DisplayName $Username -LastName $Username -UsageLocation "US"
	#Start-Sleep -s 2
	
	if ($Error.Count -gt 0)
	{
		Return
	}
	Set-MsolUserLicense -UserPrincipalName $($Username + "-NEW@wvuhsc.onmicrosoft.com") -AddLicenses "WVUHSC:STANDARDWOFFPACK_FACULTY"
	
	Start-Sleep -s 2
}


