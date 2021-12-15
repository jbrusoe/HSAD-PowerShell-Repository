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
$Host.UI.RawUI.WindowTitle = "MiscEmailCommands.ps1"

#change warning message color
$a = (Get-Host).PrivateData
$a.WarningBackgroundColor = "yellow"
$a.WarningForegroundColor = "red"

#Add references to file containing needed functions
. C:\AD-Development\5Misc-Functions.ps1
. C:\AD-Development\5Misc-Office365Functions.ps1

Invoke-Expression c:\ad-development\Connect-ToOffice365-MS1-Kevin.ps1


#check email status.  this allows you to pass in user and returns display name, primary email, activesync/owa/imap status along with max send/receive size and last logon date.
function Get-EmailStatus()
{	
[CmdletBinding()]
param 
(
[string]$user=$null
)
	try
	{
		if ($user -eq "$null")
		{
			$user = Read-Host "Please enter the full email address of user to check"
		}	
		
		$Mailbox = Get-Mailbox -Identity $user | Select-Object MaxReceiveSize,MaxSendSize
		$CASMailbox = Get-CASMailbox -Identity $user | Select-Object PrimarySMTPAddress, DisplayName, ActiveSyncEnabled, OWAEnabled, IMAPEnabled, MAPIEnabled
		$LastLogon = get-mailboxstatistics -identity $user | Select-Object LastLogonTime
		"`n"
		"`n"
		Write-Host "Display Name:       "$CASMailbox.DisplayName
		Write-Host "Primary Email:      "$CASMailbox.PrimarySMTPAddress
		Write-Host "Last Logon Time:    "$LastLogon.LastLogonTime
		Write-Host "ActiveSync Enabled: "$CASMailbox.ActiveSyncEnabled
		Write-Host "OWA Enabled:        "$CASMailbox.OWAEnabled
		Write-Host "MAPI Enabled:       "$CASMailbox.MAPIEnabled
		Write-Host "IMAP Enabled:       "$CASMailbox.IMAPEnabled	
		Write-Host "Max Receive Size:   "$Mailbox.MaxReceiveSize
		Write-Host "Max Send Size:      "$Mailbox.MaxSendSize
		"`n"		
	}	
	
	catch
	{
		Write-Warning "There was an error finding the user.  Make sure you entered the correct email address."
	}
}
#end get-emailstatus





#this function allows you to set the max send/receive size.  you can pass in the user,send,receive size.
function Set-MaxSendReceiveSize
{
[CmdletBinding()]
param 
(
[Parameter(Position=0)][string]$user = $null,
[Parameter][Int]$MaxSendSize = -1,
[Parameter][Int]$MaxReceiveSize = -1
)

	Try
	{		
		if ($user -eq "$null")
		{
			$user = Read-Host "Please enter the full email address of user to change"			
		}
		
		if ($MaxSendSize -eq "-1")
		{
			$MaxSendSize = Read-Host "Please enter the maximum send send size you wish to set"		
		}
		
		if ($MaxReceiveSize -eq "-1")
		{
			$MaxReceiveSize = Read-Host "Please enter the maximum receive size you wish to set"
		}
		
		Set-Mailbox -Identity $user -MaxSendSize "$MaxSendSize"mb
		Set-Mailbox -Identity $user -MaxReceiveSize "$MaxReceiveSize"mb			
	}
	Catch
	{
		Write-Warning "Something went wrong.  Max Send/Receive not set."
	}
}





#set owa/mapi/activesync status
function Set-EmailProperties()
{
[CmdletBinding()]
param 
(
[Parameter(Position=0)][string]$user=$null,
[Parameter()][ValidateSet('t','f')][string]$status=$null
)	
	Try
	{
		if ($user -eq "$null")
		{
			$user = Read-Host "Please enter the full email address for user to change"			
		}		
		
		if ($status -eq "$null")
		{
			$status = Read-Host "Would you like to set owa/mapi/activesync properties true or false? (t/f)"			
		}
		
		if ($status -eq "t")
		{			
			Write-Host "Setting OWA/MAPI/ActiveSync to true" -foregroundcolor green
			set-casmailbox $user -owaenabled $true -mapienabled $true -activesyncenabled $true
			Write-Host "Settings have been updated" -foregroundcolor green
		
			get-casmailbox $user | Format-List PrimarySMTPAddress, DisplayName, ActiveSyncEnabled, OWAEnabled, IMAPEnabled, MAPIEnabled | Out-Host		
		}
		
		if ($status -eq "f")
		{			
			Write-Host "Setting OWA/MAPI/ActiveSync to false" -foregroundcolor green
			set-casmailbox $user -owaenabled $false -mapienabled $false -activesyncenabled $false
			Write-Host "Settings have been updated" -foregroundcolor green
		
			 get-casmailbox $user | Format-List PrimarySMTPAddress, DisplayName, ActiveSyncEnabled, OWAEnabled, IMAPEnabled, MAPIEnabled | Out-Host			
		}
	}
	
	Catch
	{
		Write-Warning "It appears something went wrong.  Settings were not updated"
	}
}
#end set-emailproperties





#add calendar permissions - note to change/overwrite a specific users permissions use set-mailboxfolderpermission
function Add-CalendarPermission()
{
[CmdletBinding()]
param 
(
[Parameter(Position=0)][string]$user = $null,
[Parameter()][string]$UserToGetRights = $null,
[Parameter()][string]$LevelofRights = $null
)

	Try
	{
		if ($user -eq "$null")
		{
			$user = Read-Host "Please enter the full address for the user's whose calendar account is to be shared"
		}
		if ($UserToGetRights -eq "$null")
		{
			$UserToGetRights = Read-Host "Please enter the full address for the user to be granted permissions to calendar"
		}
		if ($LevelofRights -eq "$null")
		{
			$LevelofRights = Read-Host "`n Owner`n PublishingEditor`n Editor`n PublishingAuthor`n Author`n NonEditingAuthor`n Reviewer`n Contributor`n AvailabilityOnly`n LimitedDetails`n`n From the above list please enter level of rights to be given"
		}		
		
		Write-Host "Adding $LevelofRights to rights to $UserToGetRights for the calendar of $user" -foregroundcolor green
		Add-MailboxFolderPermission -Identity "$user`:\Calendar" -User $UserToGetRights -AccessRights $LevelOfRights		
		Get-MailboxFolderPermission -Identity "$user`:\Calendar" -User $UserToGetRights				
	}
	Catch
	{
		Write-Warning "It appears there was an error trying to assign rights.  Nothing has been added."
	}
}
#end add-calendarpermissons




#get calendar permissions.  when passing in specific user it requires a y or n, it will not accept any other value
function Get-CalendarPermission()
{
[CmdletBinding()]
param 
(
[Parameter(Position=0)][string]$user=$null,
[Parameter()][ValidateSet('y','n')][string]$SpecificUser=$null
)
	Try
	{
		if ($user -eq "$null")
		{
			$user = Read-Host "Please enter the full address for the account you are looking for permissions on"
		}
	
		if ($SpecificUser -eq "$null")
		{
			$SpecificUser = Read-Host "Are you looking for a specific users permissions? (y/n)"
		}
	
		if ($SpecificUser -eq 'y')
		{			
				$SecondUser = Read-Host "Please enter the full email of the user whose permissions you are looking for"
				get-MailboxFolderPermission -Identity "$user`:\calendar" -User $SecondUser
		}
		
		if ($SpecificUser -eq 'n')
		{
			get-MailboxFolderPermission "$user`:\calendar"
		}
	}
	Catch
	{
		Write-Warning "It appears something went wrong"
	}
}
#end get-calendarpermissons 






#remove calendar permissions
function Remove-CalendarPermission()
{
[CmdletBinding()]
param 
(
[Parameter()][string]$user = $null,
[Parameter()][string]$UserToRemove = $null
)
	Try
	{
		if ($user -eq "$null")
		{
			$user = Read-Host "Please enter the full address for the user to have calendar permissions changed"
		}
	
		if ($UserToRemove -eq "$null")
		{
			$UserToRemove = Read-Host "Please enter the full address for the user to be removed"
		}
		
		Write-Host "Removing permissions for $UserToRemove from $user" -foregroundcolor green
		Remove-MailboxFolderPermission -Identity "$user`:\Calendar" -User $UserToRemove		
		Get-MailboxFolderPermission -Identity "$user`:\calendar"		
	}
	Catch
	{
		Write-Warning "It appears there was an issue removing permission.  Nothing has been changed."
	}
}
#end remove calendar permission



#get mailbox folder permissions
function Get-MailboxFolderRights()
{
[CmdletBinding()]
param 
(
[Parameter(Position=0)][string]$user = $null,
[Parameter()][string]$FolderName = $null,
[Parameter()][ValidateSet('y','n')][string]$SpecificUser = $null
)
	Try
	{
		#make sure a user is specified 
		if ($user -eq "$null")
		{
			$user = Read-Host "Please enter the full address for the user whose mailbox you want to view folder permissions"
		}		
		
		if ($FolderName -eq "$null")
		{
			$FolderName = Read-Host "Please enter the name of the folder.  Use \FolderName and for subfolders \FolderName\Subfolder"
		}
		
		if ($SpecificUser -eq "$null")
		{
			$SpecificUser = Read-Host "Are you looking for a specific users rights? (y/n)"
		}
		
		if ($SpecificUser -eq 'y')
		{
			$SpecificUser = Read-Host "Please enter the full email address for the user to check rights for"
			Write-Host "Checking $SpecificUser rights to $user" -foregroundcolor green
			Get-MailboxFolderPermission -Identity "$user`:$FolderName" -User $SpecificUser
		}		
	
		if ($SpecificUser -eq 'n')
		{
			Get-MailboxFolderPermission -Identity "$user`:$FolderName"
		}
	}
	Catch
	{
		Write-Warning "It appears there was an error looking up the rights.  Please make sure you entered the email address correctly."
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



#remove mailbox folder permissions
function RemoveMailboxFolderPermission()
{
	$UserFolderPermission = Read-Host "Please enter the full address for the user whose mailbox you want to set folder permissions"
	$FolderName = Read-Host "Please enter the name of the folder.  Use \FolderName and for subfolders \FolderName\Subfolder"
	$UserToRemoveRights = Read-Host "Please enter the full address for the user who needs to have their permissions removed"
	
	Remove-MailboxFolderPermission -Identity "$UserFolderPermission`:$FolderName" -User $UserToRemoveRights
}




#get rules on the mailbox
function Get-InboxMailRules()
{
[CmdletBinding()]
param 
(
[Parameter(Position=0)][string]$user = $null,
[Parameter()][ValidateSet('y','n')][string]$SpecificRule = $null,
[Parameter()][string]$RuleName = $null
)
	
		#check to see if a email address was passed in and prompt if not
		if ($user -eq "$null")
		{
			$user = Read-Host "Please enter the full address for the user who's rules you would like to view"
		}
		
		#check to see if a specific rule was passed in and prompt if not
		if ($SpecificRule -eq "$null")
		{
			$SpecificRule = Read-Host "Are you looking for a specific rule? (y/n)"
		}	
		
		Try
		{
			if ($SpecificRule -eq "y")
			{
				if ($RuleName -eq "$null")
				{
					$RuleName = Read-Host "Please enter the rule name"
				}			
				Get-InboxRule $RuleName -Mailbox $user | Select Name, Identity, Enabled | Out-Host
			}
			
			if ($SpecificRule -eq "n")
			{
				Get-InboxRule -Mailbox $user | Select Name, Identity, Enabled | Out-Host
			}
		}
		Catch
		{
			Write-Warning "It appears there was a problem finding the rule.  Its possible the rule does not exist."
		}	
}
#end get mailbox rules




#Enable mailbox rule
function Enable-InboxMailRule()
{
[CmdletBinding()]
param 
(
[Parameter()][string]$user = $null,
[Parameter()][string]$RuleName = $null
)
	Try
	{
		if ($user -eq "$null")
		{
			$user = Read-Host "Please enter the full address for the user who's rule you would like to enable"
		}
		
		if ($RuleName -eq "$null")
		{
			$RuleName = Read-Host "What is the name of the rule?"
		}	
	
		Write-Host "Enabling rule $RuleName for $user" -foregroundcolor green
		Enable-InboxRule "$RuleName" -Mailbox "$user"		
		Get-InboxRule "$RuleName" -Mailbox $user | Select Name, Identity, Enabled | Out-Host		
	}
	Catch
	{
		Write-Warning "There was an error enabling rule.  Nothing was changed."
	}	
}
#end enable mailbox rule




#disable mailbox rule
function Disable-InboxMailRule()
{
[CmdletBinding()]
param 
(
[Parameter()][string]$user = $null,
[Parameter()][string]$RuleName = $null
)
	Try
	{
		if ($user -eq "$null")
		{
			$user = Read-Host "Please enter the full address for the user who's rule you would like to disable"
		}
		
		if ($RuleName -eq "$null")
		{
			$RuleName = Read-Host "What is the name of the rule?"
		}
	
		Write-Host "Disabling rule $RuleName for $user" -foregroundcolor green
		Disable-InboxRule "$RuleName" -Mailbox "$user" -confirm:$false
		Get-InboxRule "$RuleName" -Mailbox $user | Select Name, Identity, Enabled | Out-Host			
	}
	Catch
	{
		Write-Warning "There was an error enabling rule.  Nothing was changed."
	}	
}
#end disable mailbox rule




#remove inbox rules
function Remove-InboxMailRule()
{
[CmdletBinding()]
param 
(
[Parameter()][string]$user = $null,
[Parameter()][ValidateSet('y','n')][string]$RemoveAllRules = $null,
[Parameter()][string]$RuleName = $null
)
	if ($user -eq "$null")
	{
		$user = Read-Host "Please enter the full address for the user who's rules you would like to remove"
	}
	
	if ($RemoveAllRules -eq "$null")
	{
		$RemoveAllRules = Read-Host "Would you like to remove all rules for $user? (y/n)"
	}
	
	if ($RemoveAllRules -eq "y")
	{
		Write-Host "Removing all rules for $user" -foregroundcolor green
		Get-InboxRule -Mailbox "$user" | Remove-InboxRule
	}
	if ($RemoveAllRules -eq "n")
	{
		if ($RuleName = "$null")
		{
			$RuleName = Read-Host "What is the name of the rule?"
			Write-Host "Removing rule $RuleName for $user" -foregroundcolor green		
			Remove-InboxRule -Mailbox $user -Identity "$RuleName"
			Get-InboxRule -Mailbox $user | Select Name, Identity, Enabled | Out-Host
		}
	}
	
}
#end remove inbox rules



Do
{
	
	Write-Host "`n`n`n`nWhat would you like to do: `n--------------------------"
	$selection = Read-Host "`n (1)  Get-EmailStatus`n (2)  Set-EmailProperties`n (3)  Get-CalendarPermissions`n (4)  Add Calendar Permissions`n (5)  Set Calendar Permissions -Note- this will OVERWRITE users current permission level`n (6)  Remove-calendarpermission`n (7)  Get-mailboxfolderpermission`n (8)  Add mailbox folder permission`n (9)  Set mailbox folder permission -Note- this will OVERWRITE users current permission level`n (10) Remove mailbox folder permission`n (11) Get-InboxMailrules`n (12) Enable-InboxRule`n (13) Disable-Inboxrule`n (14) Remove-Inboxrules`n (15) Exit`n`nSelect"
	$options = 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	
	if ($selection -in $options)
	{		
		switch ($selection)
		{
			1  {Get-EmailStatus}
			2  {Set-EmailProperties}			
			3  {Get-CalendarPermission}
			4  {Add-CalendarPermission}
			5  {}
			6  {Remove-CalendarPermission}
			7  {Get-MailboxFolderRights}
			8  {AddMailboxFolderPermission}
			9  {}
			10 {RemoveMailboxFolderPermission}
			11 {Get-InboxMailRules}
			12 {Enable-InboxMailRule}
			13 {Disable-InboxMailRule}
			14 {Remove-InboxMailRule}
			15 {exit}
		}
	}
	
	else
	{
		write-warning "Please enter a valid selection"
	}
}
while ($true)