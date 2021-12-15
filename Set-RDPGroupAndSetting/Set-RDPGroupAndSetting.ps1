<#
	.SYNOPSIS
		Assumes you have rule setup sending emails to Remote Access request when they come in.  Reads email for
		username, pcname, room number and phone number.  Adds users to RDSH Default Apps group and PC to the
		HSC RDP Computers group then tries to create a pssession to add user to the remote desktop users
		group for that PC

	.DESCRIPTION
		1. Read Outlook to see if there are any new messages in the remote access request folder
		2. Get username/pcname/room/phone from email
		3. Verify username and check RDSH Default Apps group for user and add if they are not in it
		4. Verify pcname and check HSC RDP Computers group for pc and add if its not in group
		5. Use invoke-command to try to remotely connect to machine and check Remote Desktop Users
		   group for user and add if they are no in it
		6. Move email to completed folder

	.PARAMETER
		$UserGroup - this can be changed but is set to RDSH Default Apps group by default
		
		$PCGroup - this can be changed but is set to HSC RDP Computers group by default

	.EXAMPLE
		C:\Documents\GitHub>.\Set-RDPGroupAndSetting.ps1

	.NOTES
		Originally Written by: Kevin Russell
		Updated & Maintained by: Kevin Russell
		Last Updated by: Kevin Russell
		Last Updated: March 8, 2021
#>

[CmdletBinding()]
param (
	[ValidateNotNullOrEmpty()]
	[string]$UserGroup = "RDSH Default Apps",

	[ValidateNotNullOrEmpty()]
	[string]$PCGroup = "HSC RDP Computers"
)

try {
	Set-HSCEnvironment -ErrorAction Stop

	Write-Verbose "User Group:  $UserGroup"
	Write-Verbose "PC Group:  $PCGroup"
}
catch {
	Write-Warning "Unable to configure environmenet"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output "Checking emails..."

try {
	#initialize outlook
	Add-Type -AssemblyName microsoft.office.interop.outlook
	$OutlookFolders = "Microsoft.Office.Interop.Outlook.OlDefaultFolders" -as [type]
	$Outlook = New-Object -ComObject outlook.application
	$NameSpace = $Outlook.GetNameSpace("mapi")
	$Inbox = $NameSpace.getdefaultfolder($OutlookFolders::olFolderInbox)

	#set folders
	$SourceFolder = $inbox.Parent.Folders.Item("Cabinet").Folders.Item("Remote Access request")
	$TargetFolder = $inbox.Parent.Folders.Item("Cabinet").Folders.Item("Remote Access request").Folders.Item("Completed")
}
catch {
	Write-Warning "Unable to connect to Outlook"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#Check and process emails
if ($SourceFolder.items.count -eq 0) {
	Write-Output "No emails"
}
else #process emails
{
	$TotalEmails = $SourceFolder.items.count
	Write-Output "Emails to be processed:  $TotalEmails"
	$MessageNumber = 0
	$SourceFolder.items | ForEach-Object {

		$MessageNumber++
		$error.Clear()
		$Username = ""
		$PCName = ""

		Write-Output "Message number:  $MessageNumber of $TotalEmails"

		if ($_.Subject -eq "Remote Access request needs setup"){

			$mBody = $_.body

			#Split the line before any previous replies are loaded
			$mBodySplit = $mBody -split "From:"

			$mBodyLeft = $mbodySplit[0]

			$MessageBodyArray = $mBodyLeft.trim().split("`n")

			$Username = $MessageBodyArray[0].split("||@")[2]
			$PCName = $MessageBodyArray[2].split(" ")[3].trim()
			$PhoneNumber = $MessageBodyArray[4].split(" ")[3]
			$RoomNumber = $MessageBodyArray[6].split(" ")[3]

			Write-Output "`n`nReceived Email`n*************************"
			Write-Output "Username:  $Username"
			Write-Output "PC name :  $PCName"
			Write-Output "Phone   :  $PhoneNumber"
			Write-Output "Room    :  $RoomNumber"
		} #end data parse

		#check username and add to RDSH Default Apps Group
		try{
			$VerifyUsername = Get-ADUser $Username
			$VerifyUsername = $true
		}
		catch{
			$VerifyUsername = $false
			Write-Warning $error[0].Exception.Message
		}

		if ($VerifyUsername)
		{
			Write-Output "$Username is a valid username"
			Write-Output "Checking to see if $Username is part of RDSH Default Apps Group"

			try{
				$Usermembers = Get-ADGroupMember -Identity $UserGroup -Recursive |
					Select-Object -ExpandProperty Name
			}
			catch{
				Write-Output "There was an error getting group membership for $UserGroup"
				Write-Warning $error[0].Exception.Message
			}

			try{
				$User = Get-ADUser $Username -Properties cn
			}
			catch{
				Write-Output "There was an error getting CN for $Username"
				Write-Warning $error[0].Exception.Message
			}

			if ($Usermembers -contains $User.cn){
				Write-Output "$Username exists in the RDSH Default Apps group"
			}
			else{
				Write-Output "$Username does not exists in the group."
				Write-Output "Attempting to add user to RDSH Default Apps group"

				try {
					Add-ADGroupMember -Identity "RDSH Default Apps" -Members $Username
					Write-Output "User added to group"
				}
				catch {
					Write-Output "There was an error adding $Username to $UserGroup"
					Write-Warning $error[0].Exception.Message
				}
			}
		} #end verify username and add

		#Verify pc name and add to group HSC RDP Computers
		try{
			$VerifyPCName = Get-ADComputer $PCName
			$VerifyPCName = $true
		}
		catch{
			Write-Output "$PCName is not in ADComputers"
			Write-Warning $error[0].Exception.Message
			$VerifyPCName = $false
		}

		if ($VerifyPCName){

			Write-Output "$PCName is a valid computer name"

			try{
				$PCmembers = Get-ADGroupMember -Identity $PCGroup -Recursive |
					Select-Object -ExpandProperty Name
			}
			catch{
				Write-Output "There was an error getting group membership for $PCGroup"
				Write-Warning $error[0].Exception.Message
			}

			try{
				$PC = Get-ADComputer $PCName -Properties cn
			}
			catch{
				Write-Output "There was an error finding $PCName"
				Write-Warning $error[0].Exception.Message
			}

			if ($PCmembers -contains $PC.cn){
				Write-Output "$PCName exists in the $PCGroup group"
			}
			else
			{
				Write-Output "$PCName does not exists in $PCGroup"
				Write-Output "Attempting to add $PCName to $PCGroup group"

				try{
					$dN = Get-ADComputer $PCName -Properties distinguishedName |
						Select-Object distinguishedName
				}
				catch{
					Write-Output "There was an error finding the dN for $PCName"
					Write-Warning $error[0].Exception.Message
				}
				try{
					Add-ADGroupMember -Identity $PCGroup -Members $($dn.distinguishedName)
				}
				catch{
					Write-Output "There was an error adding $PCName to $PCGroup"
					Write-Warning $error[0].Exception.Message
				}
				Write-Output "Computer added to group"
			}
		} #end verify pc name

		#Connect to remote machine and add user
		$AdminUserName = 'kevinadmin'
    	$Password = Get-Content C:\AD-Development\SetRDPPassword.txt |
			ConvertTo-SecureString
			
    	$Credentials = New-Object System.Management.Automation.PSCredential $AdminUserName,$Password
		
		
		$RemoteParams = @{
			ComputerName = $PCName
			ArgumentList = $UserName,$PCName
			Credential = $Credentials
			ScriptBlock = {

				Param ($UserName,$PCName)

				Write-Output "Attempting to add $UserName to Remote Desktop Users group on $PCName"

				$AddLocalGroupParams = @{
					Group = "Remote Desktop Users"
					Member = $UserName
					#ErrorAction = SilentlyContinue
				}
				try	{
					Add-LocalGroupMember @AddLocalGroupParams
					Write-Output "$UserName successfully added to remote desktop users group"
				}
				catch{
					Write-Output "There was an error adding $UserName"
					Write-Warning $error[0].Exception.Message
				}
			}
		}

		try{
			Invoke-Command @RemoteParams -ErrorAction SilentlyContinue
		}
		catch{
			Write-Output "There was an error trying to connect to $PCName"
			Write-Warning $error[0].Exception.Message
		} #end connect to remote user

		#move email to compeleted
		try{
			Write-Output "Moving email..."
			$_.move($TargetFolder) | Out-Null
		}
		catch{
			Write-Output "Error moving email"
			Write-Warning $error[0].Exception.Message
		} #end move
	}
}
Invoke-HSCExitCommand -ErrorCount $Error.Count