<#
.SYNOPSIS
 	      
    
.DESCRIPTION
 	      
 	
.PARAMETER
	    Paramter information.

.NOTES
	    Author: Kevin Russell
    	Last Updated by: Kevin Russell
	    Last Updated: 12/20/17
		
		Line 31 will need to be edited with the path to your connection file.
#>

#Change PowerShell window title
$Host.UI.RawUI.WindowTitle = "CheckEmail.ps1"

#change warning message color
$a = (Get-Host).PrivateData
$a.WarningBackgroundColor = "yellow"
$a.WarningForegroundColor = "red"

#Add references to file containing needed functions
. C:\AD-Development\5Misc-Functions.ps1
. C:\AD-Development\5Misc-Office365Functions.ps1

Invoke-Expression c:\ad-development\Connect-ToOffice365-MS1-Kevin.ps1

#check owa/mapi/activesync status
function CheckEmailStatus()
{	
	$EmailAddress  = Read-Host "Please enter the full email address of user"
	
	if ($EmailAddress -ne $null)
	{		
		$results = get-casmailbox $EmailAddress | Format-List PrimarySMTPAddress, DisplayName, ActiveSyncEnabled, OWAEnabled, IMAPEnabled, MAPIEnabled 
		$results
	}
}

#set owa/mapi/activesync status to true
function SetEmailPropertiesTrue()
{	
	$EmailAddress  = Read-Host "Please enter the full email address of user"
	
	if ($EmailAddress -ne $null)
	{
		Write-Host "Setting OWA/MAPI/ActiveSync to true" -foregroundcolor green
		set-casmailbox $EmailAddress -owaenabled $true -mapienabled $true -activesyncenabled $true
		Write-Host "Settings have been updated" -foregroundcolor green
		
		$results = get-casmailbox $EmailAddress | Format-List PrimarySMTPAddress, DisplayName, ActiveSyncEnabled, OWAEnabled, IMAPEnabled, MAPIEnabled 
		$results
	}
}

#set owa/mapi/activesync status to false
function SetEmailPropertiesFalse()
{	
	$EmailAddress  = Read-Host "Please enter the full email address of user"
	
	if ($EmailAddress -ne $null)
	{
		Write-Host "Setting OWA/MAPI/ActiveSync to true" -foregroundcolor green
		set-casmailbox $EmailAddress -owaenabled $false -mapienabled $false -activesyncenabled $false
		Write-Host "Settings have been updated" -foregroundcolor green
		
		$results = get-casmailbox $EmailAddress | Format-List PrimarySMTPAddress, DisplayName, ActiveSyncEnabled, OWAEnabled, IMAPEnabled, MAPIEnabled 
		$results
	}
}

#add calendar permissions - note to change/overwrite a specific users permissions use set-mailboxfolderpermission
function AddCalendarPermission()
{
	$CalEmailAddress = Read-Host "Please enter the full address for the calendar account to be shared"
	$UserToGetRights = Read-Host "Please enter the full address for the user to be granted permissions to calendar"
	$LevelOfRights = Read-Host "Owner`n PublishingEditor`n Editor`n PublishingAuthor`n Author`n NonEditingAuthor`n Reviewer`n Contributor`n AvailabilityOnly`n LimitedDetails`n`n From the above list please enter level of rights to be given"
	
	add-MailboxFolderPermission -Identity "$CalEmailAddress`:\Calendar" -User $UserToGetRights -AccessRights $LevelOfRights
}

#get calendar permissions
function GetCalendarPermission()
{
	$CalEmailAddress = Read-Host "Please enter the full address for the calendar account to be shared"
	$SpecificUser = Read-Host "Are you looking for a specific users calendar permissions? (y/n)"
	
	if ($SpecificUser -eq 'y')
	{
		$SecondUser = Read-Host "Please enter the full email of the user whose permissions you are looking for"
		get-MailboxFolderPermission -Identity "$CalEmailAddress`:\calendar" -User $SecondUser		
	}
	
	if ($SpecificUser -eq 'n')
	{
		get-MailboxFolderPermission "$CalEmailAddress`:\calendar"
	}
}

#set calendar permissions
function SetCalendarPermission()
{
	$CalEmailAddress = Read-Host "Please enter the full address for the calendar account to be shared"
	$UserToGetRights = Read-Host "Please enter the full address for the user to be granted permissions to calendar"
	$LevelOfRights = Read-Host "Owner`n PublishingEditor`n Editor`n PublishingAuthor`n Author`n NonEditingAuthor`n Reviewer`n Contributor`n AvailabilityOnly`n LimitedDetails`n`n From the above list please enter level of rights to be given"
	
	set-MailboxFolderPermission -Identity "$CalEmailAddress`:\Calendar" -User $UserToGetRights -AccessRights $LevelOfRights
}

#remove calendar permissions
function RemoveCalendarPermission()
{
	$CalEmailAddress = Read-Host "Please enter the full address for the calendar account to be changed"
	$UserToRemove = Read-Host "Please enter the full address for the user to be removed"

	Remove-MailboxFolderPermission -Identity "$CalEmailAddress`:\Calendar" -User $UserToRemove
}

#get mailbox folder permissions
function GetMailboxFolderPermission()
{
	$UserFolderPermission = Read-Host "Please enter the full address for the user whose mailbox you want to view folder permissions"
	$FolderName = Read-Host "Please enter the name of the folder.  Use \FolderName and for subfolders \FolderName\Subfolder"
	$SpecificUser = Read-Host "Are you looking for a specific users rights? (y/n)"
	
	if ($SpecificUser -eq 'y')
	{
		Get-MailboxFolderPermission -Identity "$UserFolderPermission`:$FolderName" -User $SpecificUser
	}
	
	if ($SpecificUser -eq 'n')
	{
		Get-MailboxFolderPermission -Identity "$UserFolderPermission`:$FolderName"
	}
}

#add mailbox folder permissions
function AddMailboxFolderPermission()
{
	$UserFolderPermission = Read-Host "Please enter the full address for the user whose mailbox you want to add folder permissions"
	$FolderName = Read-Host "Please enter the name of the folder.  Use \FolderName and for subfolders \FolderName\Subfolder"
	$UserToGetRights = Read-Host "Please enter the full address for the user who is supposed to get rights"
	$LevelOfRights = Read-Host "Owner`n PublishingEditor`n Editor`n PublishingAuthor`n Author`n NonEditingAuthor`n Reviewer`n Contributor`n`n From the above list please enter level of rights to be given"
	
	Add-MailboxFolderPermission -Identity "$UserFolderPermission`:$FolderName" -User $UserToGetRights -AccessRights $LevelOfRights
}

#set mailbox folder permissions
function SetMailboxFolderPermission()
{
	$UserFolderPermission = Read-Host "Please enter the full address for the user whose mailbox you want to set folder permissions"
	$FolderName = Read-Host "Please enter the name of the folder.  Use \FolderName and for subfolders \FolderName\Subfolder"
	$UserToGetRights = Read-Host "Please enter the full address for the user who is supposed to get rights"
	$LevelOfRights = Read-Host "Owner`n PublishingEditor`n Editor`n PublishingAuthor`n Author`n NonEditingAuthor`n Reviewer`n Contributor`n`n From the above list please enter level of rights to be given"
	
	Set-MailboxFolderPermission -Identity "$UserFolderPermission`:$FolderName" -User $UserToGetRights -AccessRights $LevelOfRights
}

#remove mailbox folder permissions
function RemoveMailboxFolderPermission()
{
	$UserFolderPermission = Read-Host "Please enter the full address for the user whose mailbox you want to set folder permissions"
	$FolderName = Read-Host "Please enter the name of the folder.  Use \FolderName and for subfolders \FolderName\Subfolder"
	$UserToRemoveRights = Read-Host "Please enter the full address for the user who needs to have their permissions removed"
	
	Remove-MailboxFolderPermission -Identity "$UserFolderPermission`:$FolderName" -User $UserToRemoveRights
}

#get rules on the mailbox
function GetInboxRules()
{
	$UserInboxRule = Read-Host "Please enter the full address for the user who's rules you would like to view"
	$SpecificRule = Read-Host "Are you looking for a specific rule? (y/n)"
	
	if ($SpecificRule -eq "y")
	{
		$RuleName = Read-Host "Please enter the rule name"
		Get-InboxRule $RuleName -Mailbox $UserInboxRule | Select Name, Identity, Enabled
	}
	if ($SpecificRule -eq "n")
	{
		Get-InboxRule -Mailbox $UserInboxRule | Select Name, Identity, Enabled
	}
}

#Enable/Disable mailbox rule
function EnableDisableInboxRule()
{
	$InboxRuleED = Read-Host "Are you wanting to enable or disable a rule? (e/d)"
	$UserInboxRule = Read-Host "Please enter the full address for the user who's rules you would like to enable/disable"
	$RuleName = Read-Host "What is the name of the rule?"
	
	if ($InboxRuleED -eq "e")
	{
		Enable-InboxRule "$RuleName" -Mailbox "$UserInboxRule"
	}
	if ($InboxRuleED -eq "d")
	{
		Disable-InboxRule "$RuleName" -Mailbox "$UserInboxRule"
	}
}

#remove inbox rules
function RemoveInboxRule()
{
	$UserInboxRule = Read-Host "Please enter the full address for the user who's rules you would like to remove"
	$RemoveAllRules = Read-Host "Would you like to remove all rules for $UserInboxRule? (y/n)"
	
	if ($RemoveAllRules -eq "y")
	{
		Get-InboxRule -Mailbox "$UserInboxRule" | Remove-InboxRule
	}
	if ($RemoveAllRules -eq "n")
	{
		$RuleName = Read-Host "What is the name of the rule?"
		Remove-InboxRule -Mailbox $UserInboxRule -Identity "$RuleName"
	}
	
}


Do
{
	
	Write-Host "`n`n`n`nWhat would you like to do: `n--------------------------"
	$selection = Read-Host "`n (1)  Lookup owa/mapi/activesync status`n (2)  Set owa/mapi/activesync True`n (3)  Set owa/mapi/activesync False`n (4)  Get Calendar Permissions`n (5)  Add Calendar Permissions`n (6)  Set Calendar Permissions -Note- this will OVERWRITE users current permission level`n (7)  Remove calendar permission`n (8)  Get mailbox folder permission`n (9)  Add mailbox folder permission`n (10) Set mailbox folder permission -Note- this will OVERWRITE users current permission level`n (11) Remove mailbox folder permission`n (12) Get Inbox rules`n (13) Enable/Disable Inbox rules`n (14) Remove Inbox rules`n (15) Exit`n`nSelect"
	$options = 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	
	if ($selection -in $options)
	{		
		switch ($selection)
		{
			1  {CheckEmailStatus}
			2  {SetEmailPropertiesTrue}
			3  {SetEmailPropertiesFalse}
			4  {GetCalendarPermission}
			5  {AddCalendarPermission}
			6  {SetCalendarPermission}
			7  {RemoveCalendarPermission}
			8  {GetMailboxFolderPermission}
			9  {AddMailboxFolderPermission}
			10 {SetMailboxFolderPermission}
			11 {RemoveMailboxFolderPermission}
			12 {GetInboxRules}
			13 {EnableDisableInboxRule}
			14 {RemoveInboxRule}
			15 {exit}
		}
	}
	
	else
	{
		write-warning "Please enter a valid selection"
	}
}
while ($true)