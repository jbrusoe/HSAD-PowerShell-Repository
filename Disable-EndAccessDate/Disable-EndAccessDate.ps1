<#
	.SYNOPSIS
		This file looks for any accounts that have passed their end access date (ext1).
		For these accounts, performs the actions listed in the description section.

	.DESCRIPTION
		Requires
		1. Connection to the HSC tenant with AzureAD cmdlets ( Get-AzureADUser etc.)
		2. Connection to Exchange online and PowerShell cmdlets (Get-Mailbox etc.)
		3. Ability to search HS domain with the Microsoft Active Directory module (Get-ADUser etc.)

		This file searches Active Directory to determine when a user is past their
		end access date which is stored in extensionAttribute1. This field is
		populated by SailPoint and must be changed by that system. The following
		actions are taken based on the time between the current date and the end access date.
		1. End Access Date = Current Date
			a. AD account is disabled
			b. MAPI/OWA/ActiveSync are all disabled for mailbox
			c. Set out of office reply - "The HSC account for this person is no longer active."
		2. Account Disable Date + 7 days
			a. Account is hidden in the address book
			b. AD account is removed from AD groups
			c. Add AD groups to DB
			d. Send limit to 10 kb
			e. Remove user from One Drive Members groups
			f. Set block credential to true
		3. Account Disable Date + 30 Days
			a. extensionAttribute7 is set to "No365"
			b. AD account is moved to "Deleted Accounts"
			c. Move home folder to MS OneDrive
		4. Account Disable Date + 60 Days
			a. Account is deleted.

	.PARAMETER DeleteAccount
		Specifies whether accounts that are actually deleted of just written to a log file.

	.PARAMETER MaximumNewDisables
		This is a safety feature to prevent too many accounts from being disabled.

	.PARAMETER MaximumDeletes
		This is a safety feature to prevent too many accounts from being deleted.

	.PARAMETER Testing
		This flag indicates to the file that testing is going on which runs some extra
		logging/debugging/safety code.

	.PARAMETER TestingUsers
		Specifies the total number of users

	.PARAMETER TestingDelay
		This parameter introduces a small delay at times for debugging purposes.
		The value is in seconds.

	.PARAMETER SQLServer
		IP Address of the SQL server

	.PARAMETER DBName
		Name of the database to record user disable info to.

	.PARAMETER Step2DDays
		The delay (in days) before proceeding with the step 2 disable process

	.PARAMETER Step3Days
		The delay (in days) before proceeding with the step 3 disable process

	.PARAMETER Step4Days
		The delay (in days) before proceeding with the step 4 disable process

	.NOTES
		Author: Jeff Brusoe
		Last Updated by: Jeff Brusoe
		Last Udated: January 25, 2021
		Version: 2.0
#>

[CmdletBinding()]
param (
	#Safety Parameters
	[switch]$DeleteAccount,
	[int]$MaximumNewDisables = 50,
	[int]$MaximumDeletes = 20,

	#Test parameters
	[switch]$Testing,
	[int]$TestingUsers = 2000,
	[int]$TestingDelay = 2, #Seconds to pause when testing program

	#Database Parameters
	[string]$SQLServer = "hscpowershell.database.windows.net",
	[string]$DBName = "HSCPowerShell",
	[string]$DBUsername = "HSCPowerShell",
	[string]$DBTableName = "DisableEndAccessDate",

	#Parameters that control when various steps are performed.
	[Alias("Step2")][int]$Step2Days = 7,
	[Alias("Step3")][int]$Step3Days = 30,
	[Alias("Step4")][int]$DeleteDays = 60
)

#Configure Environment
try {
	Write-Verbose "Running Set-HSCEnvironment"
	Set-HSCEnvironment -ErrorAction Stop

	Write-Verbose "Connecting to AzureAD"
	Connect-HSCOffice365 -ErrorAction Stop

	Write-Verbose "Connecting to Exchange Online"
	Connect-HSCExchangeOnlineV1 -ErrorAction Stop

	#Variable initialization
	$DisableCount = 0
	$ErrorCount = 0
	$NewDisablesCount = 0
	$DeleteCount = 0
	$Count = 0 #This is the count to show where the search is.

	Write-Output "Successfully completed initial environment configuration"
}
catch {
	Write-Warning "Unable to configure environment. Program is exiting."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

# Set DomainCN to be a constant
Write-Verbose "Setting file constant values."

try
{
	#This is here to eliminate a cosmetic error that would occur if the same
	#session window was used to rerun this program.
	$SetVariableParams = @{
		Name = "DomainCN"
		Value = "DC=hs,DC=wvu-ad,DC=wvu,DC=edu"
		Option = "Constant"
		Scope = "Global"
		ErrorAction = "Stop"
	}
	Set-Variable @SetVariableParams
	Write-Verbose "Successfully set DomainCN"
}
catch [System.Management.Automation.SessionStateUnauthorizedAccessException] {
	#This is a cosmetic error that happens when trying to set
	#this multiple times during file testing.
	#It can be ignored.
	$Error.Clear()
}
catch {
	Write-Error "Unable to set domain CN value. Program is ending."
	Invoke-HSCExitCommand -ErrorAction Stop
}

Write-Output "DomainCN: $DomainCN"

############################
# Configure Log File Paths #
############################
$LogFilePath = "$PSScriptRoot\Logs\"
Write-Output "Log file directory: $LogFilePath"

$LogFilePrefix = (Get-Date -format yyyy-MM-dd-HH-mm) + "-"

#Initialize log files
$NotFoundFile = $LogFilePath + "\" + $LogFilePrefix + "NoEndAccessDateSet.csv" #No end access date
$CanBeDisabledFile = $LogFilePath + "\" +  $LogFilePrefix + "CanBeDisabled.csv"
$DoNotDisableFile = $LogFilePath + "\" + $LogFilePrefix + "DoNotDisable.csv"
$ErrorFile = $LogFilePath + "\" + $LogFilePrefix + "Error.txt" #This file should hopefully be empty after script execution.
$DeleteFile = $LogFilePath + "\" + $LogFilePrefix + "Delete.csv"
$LitigationHoldFile = $LogFilePath + "\" + $LogFilePrefix + "LitigationHold.csv"
$NewDisablesFile = $LogFilePath + "\" + $LogFilePrefix + "NewDisables.txt"
$ExcludedUserFile = $LogFilePath + "\" + $LogFilePrefix + "ExcludedUsers.csv"
$DirectoryMoveFIle = $LogFilePath + "\" + $LogFilePrefix + "DirectoryMove.txt"

Write-Output "Log File Paths:"
Write-Output "Not Found File: $NotFoundFile"
Write-Output "Can Be Disabled File: $CanBeDisabledFile"
Write-Output "Do Not Disable File: $DoNotDisableFile"
Write-Output "Error File: $ErrorFile"
Write-Output "Delete File: $DeleteFile"
Write-Output "Litigation Hold File: $LitigationHoldFile"
Write-Output "NewDisablesFile: $NewDisablesFile"
Write-Output "Directory Move File: $DirectoryMoveFile"
Write-Output "ExcludedUsersFile: $ExcludedUserFile`n`n"

try {
	#Create log files
	#-force parameter causes any existing files with the same names to be overwritten
	Write-Output "`nCreating Log Files"

	Write-Verbose "Creating Users to be Disabled File: $CanBeDisabledFile"
	New-Item $CanBeDisabledFile -type file -Force

	#This is for users who have a good end acces date.
	Write-Verbose "Creating Do Not Disable File: $LitigationHoldFile"
	New-Item $DoNotDisableFile -type file -Force

	Write-Verbose "Creating EAD Not Found File: $NotFoundFile"
	New-Item $NotFoundFile -type file -Force

	Write-Verbose "Creating Error File: $ErrorFile"
	New-Item $ErrorFile -type file -Force

	Write-Verbose "Creating Delete File: $DeleteFile"
	New-Item $DeleteFile -type file -Force

	Write-Verbose "Creating Litigation Hold File: $LitigationHoldFile"
	New-Item $LitigationHoldFile -type file -Force

	Write-Verbose "Creating New Disables File: $NewDisablesFile"
	New-Item $NewDisablesFile -type file -Force

	Write-Verbose "Creating Excluded User File: $ExcludedUserFile"
	New-Item $ExcludedUserFile -type file -Force
}
catch {
	write-Warning "Unable to create log files"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

##############################################
# End of log file initialization code block. #
##############################################

#Generate Litigation Hold list
Write-Output "`nGenerating litigation hold list"

$LitigationHold = @() #Array to hold litigation hold users

if (!$Testing)
{
	try {
		$LHs = Get-Mailbox -ResultSize Unlimited -ErrorAction Stop|
			Where-Object {$_.LitigationHoldEnabled -eq $true}

		Write-Output "Successfully generated litigation hold list"
	}
	catch {
		Write-Warning "Unable to generate litigation hold list"
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}

	foreach ($LH in $LHs)
	{
		Write-Output $("Litigation Hold: " + $LH.Alias)
		$LitigationHold += $LH.Alias
		$LH |
			Select-Object Alias,PrimarySMTPAddress,lit* |
			Export-Csv $LitigationHoldFile -Append -NoTypeInformation
	}
	#Finished generating litigation hold list and can loop through all domain users.
}

#Generate list of all HS users to search
Write-HSCColorOutput -ForegroundColor "Green" -Message "`n`nGenerating HS user list"

$PropertyArray = @(
		"MemberOf",
		"PasswordLastSet",
		"lastLogonDate",
		"msExchHideFromAddressLists",
		"proxyAddresses",
		"extensionAttribute1",
		"extensionAttribute3",
		"extensionAttribute7",
		"extensionAttribute10",
		"extensionAttribute11",
		"extensionAttribute12",
		"extensionAttribute15",
		"mail"
	)

try
{
	if ($Testing)
	{
		$ADUsers = Get-ADUser -SearchBase $DomainCN -Properties $PropertyArray  -Filter * |
			Where-Object {(![string]::IsNullOrEmpty($_.extensionAttribute1)) -AND
				($_.extensionAttribute10 -ne "Resource")} |
			Select-Object -First $TestingUsers
	}
	else
	{
		 $ADUsers = Get-ADUser -SearchBase $DomainCN -Properties $PropertyArray  -Filter * |
			 Where-Object {(![string]::IsNullOrEmpty($_.extensionAttribute1)) -AND
				($_.extensionAttribute10 -ne "Resource")}
	}

}
catch [Microsoft.ActiveDirectory.Management.ADServerDownException]
{
	#This handles an exception with the following error message:
	#"Get-ADUser : Unable to contact the server. This may be because this server does not exist,
	#it is currently down, or it does not have the Active Directory Web Services running."
	Write-Warning "Unable to contact Active Directory server. Program is exiting."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}
catch [Microsoft.ActiveDirectory.Management.ADException]
{
	Write-Warning "Active Directory query timed out. Program is exiting."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}
catch
{
	#More generic error
	Write-Error "Unable to query Active Directory. Program is exiting."

	Write-Output $Error

	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

##Safety code used in testing
if ((($ADUsers | Measure-Object).Count -ne $TestingUsers) -AND $Testing)
{
	Write-Warning "Program is exiting"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#This is the list of user names that will be skipped in the search.
try {
	Write-Output "Retrieving AD Exclusion List"
	$ADExclusionList = Get-HSCSPOExclusionList -ErrorAction Stop
}
catch {
	Write-Warning "Unable to generate AD Exclusion List"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output "`nExclusion List:"
$ADExclusionList

Write-Output "******************************`n"

$TotalUsers = ($ADUsers | Measure-Object).count
$StartTime = Get-Date

####################################################
# Attempt connection to SQL instance in office 365 #
####################################################

#Connect to database and get everybody who has passed security compliance training.
try {
	Write-Output "Generating SQL Connection String"
	$SQLPassword = Get-HSCSQLPassword -Verbose -ErrorAction Stop

	$GetHSCConnectionStringParams = @{
		DataSource = $SQLServer
		Database = $DBName
		Username = $DBUsername
		SQLPassword = $SQLPassword
		ErrorAction = "Stop"
	}

	$SQLConnectionString = Get-HSCSQLConnectionString @GetHSCConnectionStringParams

	$InvokeSQLCmdParams = @{
		ConnectionString = $SQLConnectionString
		ErrorAction = "Stop"
	}
}
catch {
	Write-Warning "Unable to generate connection string"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

##################################
# Beginning of main if/then loop #
##################################
foreach ($ADUser in $ADUsers)
{
	Write-Output "`nDisable Count: $DisableCount"
	Write-Output "New Disables Count: $NewDisablesCount`n"

	if ($Error.Count -gt 0 -AND $Testing)
	{
		Write-Output "Stopping program due to error"
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}
	elseif ($Testing) {
		Start-Sleep -s $TestingDelay #Used for testing purposes
	}

	$Count++ #This is just to indicate how far into processing the program is.
	Write-Output "Current User count: $Count"
	Write-Output "Total Users: $TotalUsers"
	Write-Output $("Current User: " + $ADUser.SamAccountName)

	try {
		$WriteProgressParams = @{
			Activity = $("Current User: " + $ADUser.UserPrincipalName)
			Status = ("Account $Count of $TotalUsers")
			PercentComplete = (($Count/$TotalUsers)*100)
			ErrorAction = "Stop"
		}

		Write-Progress @WriteProgressParams
	}
	catch {
		Write-Warning "Unable to display progress bar"
	}

	#Attempt to get end access date from ext1
	try
	{
		Write-Output "Getting end access date from ext1"
		[datetime]$EndAccessDate = $ADUser.extensionAttribute1
		Write-Output $("End Access Date: " + $EndAccessDate.toString("yyyy-MM-dd"))
		$EndAccessDateConversionError = $false
	}
	catch
	{
		#This would happen of ext1 is $null or a string.
		#It's a cosmetic error that just needs to be logged for now.
		Write-Output "Error converting ext1 to datetime."
		$EndAccessDateConversionError = $true

		$Error.Clear()
	}

	if ($ADExclusionList -contains $ADUser.samaccountname)
	{
		#Do Nothing - This is a safety measure to ensure our accounts won't be disabled and/or deleted.
		Write-Output $("SamAccountName: " + $ADUser.samaccountname)
		Write-HSCColorOutput -Message "User is in excluded list... Skipping this account..."

		$ADUser |
			Select-Object SamAccountName,Enabled,LastLogonDate,@{Name="EndAccessDate";Expression={Get-Date $EndAccessDate -format d}} |
			Export-Csv $ExcludedUserFile -Append
	}
	elseif ($EndAccessDateConversionError)
	{
		#This is the case that the End Access Date has not been set by SailPoint.
		#For the time being, these accounts are just being logged with no other action taken.
		#Some of these may be valid service accounts.

		$ADUser |
			Select-Object SamAccountName,Enabled,LastLogonDate,@{Name="EndAccessDate";Expression={"Not Set"}} |
			Export-Csv $NotFoundFile -Append

		Write-Output $("SamAccountName: " + $ADUser.SamAccountName)
		Write-Output $("AD Account is Enabled: " + $ADUser.Enabled)

		if ([string]::IsNullOrEmpty($ADUser.LastLogonDate)) {
			#user has never logged in
			Write-Output "Last Logon: User has never logged on"
		}
		else {
			Write-Output $("Last Logon: " + $ADUser.LastLogonDate)
		}

		Write-Output "End Access Date is not set"
	}
	else
	{
		#This is the case where a user has a date in ext1 which must be checked.
		Write-Output $("End Access Date: " + (Get-Date $EndAccessDate -format d))
		Write-Output $("SamAccountName: " + $ADUser.samaccountname)
		Write-Output $("AD Account is Enabled: " + $ADUser.Enabled)

        if ([string]::IsNullOrEmpty($ADUser.LastLogonDate)) {
			#User has never logged in
			Write-Output "Last Logon: User has never logged on"
		}
		else {
			Write-Output $("Last Logon: " + $ADUser.LastLogonDate)
		}

		if ($EndAccessDate -lt (Get-Date))
		{
			#The end access date is before the current date.
			#The acocunt can begin the process of being deleted.
			if ($NewDisablesCount -gt $MaximumNewDisables)
			{
				Write-Warning "Max new disable count has been exceeded. Program is exiting."

				Invoke-HSCExitCommand -ErrorCount $Error.Count
			}

			Write-Output $("Disabling: " + $ADUser.SamAccountName)

			$ADUser |
				Select-Object SamAccountName,Enabled,LastLogonDate,@{Name="EndAccessDate";Expression={Get-Date $EndAccessDate -format d}} |
				Export-Csv $CanBeDisabledFile -Append

			if ($ADUser.Enabled) {
				Write-Output "New user disable"
				$NewDisablesCount++
			}
			else {
				Write-Output "User is already disabled"
			}

			$DisableCount++

			#First check to see if user is already in db table
			$query = "select * from $DBTableName where SamAccountName = '" + $ADUser.SamAccountName + "'"
			Write-Output "Query: $query"

			$SQLData = Invoke-SQLCmd -Query $query -ConnectionString $SQLConnectionString

			#Determine Primary SMTP Address
			#To do: Add to AD module
			$ProxyAddresses = $ADUser.proxyAddresses

			if ($null -eq $ProxyAddresses) {
				Write-Output "No proxy addresses"
				$PrimarySMTPAddress = "None"
			}
			else
			{
				Write-Output "Proxy Addresses:"
				Write-Output $ProxyAddresses

				try
				{
					[string]$PrimarySMTPAddress = $ProxyAddresses -cmatch "SMTP:"
					$PrimarySMTPAddress = $PrimarySMTPAddress -replace "SMTP:",""
					Write-Output "PrimarySMTPAddress: $PrimarySMTPAddress"

					if ($PrimarySMTPAddress.indexOf('@') -lt 0) {
						#Verifies an actual email address is present
						$PrimarySMTPAddress = "None"
						Write-Output "Invalid email address found"
					}
					else {
						Write-Output "Valid email address found"
					}

					Write-Output "Primary SMTP Address: $PrimarySMTPAddress"

					if ([string]::IsNullOrEmpty($ADUser.mail) -AND $PrimarySMTPAddress -ne "None") {
						try {
							$ADUser | Set-ADUser -EmailAddress $PrimarySMTPAddress -ErrorAction Stop
						}
						catch {
							Write-Warning "Unable to configure email address"
						}

					}
				}
				catch
				{
					Write-Warning "Unable to find primary SMTP address"
					$PrimarySMTPAddress = "None"
				}
			}

			Write-Output "Primary SMTP Address: $PrimarySMTPAddress"
			#End block to find primary SMTP address

			[datetime]$AccountDisableDate = Get-Date

			#Check and verify information is written to DB
			if ($null -ne $SQLData)
			{
				Write-Output "User Found"
				Write-Output $("SamAccountName From DB: " + $SQLdata.SamAccountName)
				Write-Output $("Account Disable Date from DB: " + $SQLData.AccountDisableDate)

				if (($SQLData.PrimarySMTPAddress -is [DBnull]) -OR
					($SQLData.PrimarySMTPAddress.indexOf("@") -lt 0))
				{
					#Updates previous users
					$UpdateQuery = "UPDATE $DBTableName SET PrimarySMTPAddress " +
									"= '$PrimarySMTPAddress' WHERE SamAccountName = '" +
									$ADUser.SamAccountName + "'"

					try
					{
						Write-Output "Writing primary SMTP address to DB"
						Write-Output "Update Query:"
						Write-Output $UpdateQuery

						$InvokeSQLCmdParams = @{
							Query = $UpdateQuery
							ConnectionString = $SQLConnectionString
							ErrorAction = "Stop"
						}

						Invoke-SQLCmd @$InvokeSQLCmdParams
						Write-Output "Successfully wrote primary SMTP address to DB"
					}
					catch
					{
						Write-Warning "Error writing primary SMTP address to DB"
						Invoke-HSCExitCommand -ErrorCount $Error.Count

						##if ($Testing) {
						##	Write-Warning "Program is exiting"
						##	Invoke-HSCExitCommand -ErrorCount $Error.Count
						##}
					}
				}

				if ($SQLData.AccountDisableDate -isnot [DBNull])
				{
					$AccountDisableDate = [datetime]$SQLData.AccountDisableDate
				}
			}
			else
			{
				#Need to write user to DB
				Write-Output "User not found in DB. Adding user to DB table"

				$InsertQuery = "Insert into $DBTableName " +
								"(SamAccountName,EndAccessDate,AccountDisableDate,PrimarySMTPAddress) " +
								"Values ('$($ADUser.SamAccountName)','$($EndAccessDate.toString("yyyy-MM-dd"))'," +
								"'$(Get-Date -format yyyy-MM-dd)','$PrimarySMTPAddress')"
				Write-Output "Insert Query: $InsertQuery"

				$InvokeSQLCmdParams = @{
					Query = $InsertQuery
					ConnectionString = $SQLConnectionString
					ErrorAction = "Stop"
				}

				try {
					Invoke-SQLCmd @InvokeSQLCmdParams
				}
				catch {
					Write-Warning "Unable to add user to DB table"
					Invoke-HSCExitCommand -ErrorCount $Error.Count
				}

				if ($Testing) {
					Write-Output "Testing Delay"
					Start-Sleep -s $TestingDelay
				}
			}

			############################
			# Step 1a: Disable AD User #
			############################
			Write-Output "`n`nStep 1a: Disable AD Account"

			if ($ADUser.Enabled)
			{
				#User is enabled and will be disabled. They are being added
				#to $NewDisablesFile for logging and email alerts.
				Write-Output "Attempting to disable user"

				$ADUser |
					Select-Object SamAccountName,LastLogonDate,`
							@{Name="EndAccessDate";Expression={Get-Date $EndAccessDate -format d}} |
						Export-Csv $NewDisablesFile -Append

				try {
					$ADUser | Disable-ADAccount -ErrorAction Stop
					Write-Output "Successfully disabled user"
				}
				catch {
					Write-Warning "Error disabling users"
				}

			}
			else {
				Write-Output "User is already disabled"
			}
			###############
			# End Step 1a #
			###############

			##############################################
			# Step 1b: MAPI/OWA/ActiveSync set to $false #
			##############################################
			Write-Output "`n`nStep 1b: Disable MAPI/OWA/ActiveSync acccess to mailbox"

			#First try to find mailbox
			$O365Mailbox = $null

			try {
				$O365Mailbox = Get-Mailbox $ADUser.UserPrincipalName -ErrorAction Stop
				Write-Output "User mailbox found"
			}
			catch {
				Write-Warning $("Mailbox Not Found: " + $ADuser.UserPrincipalName)
			}

			if ($null -eq $O365Mailbox)
			{
				#Try using ext15@hsc.wvu.edu if UPN is not found
				try
				{
					[string]$ext15 = $ADUser.extensionAttribute15

					if (![string]::IsNullOrEmpty($ext15))
					{
						$Ext15Email = $ADUser.extensionAttribute15 + "@hsc.wvu.edu"
						Write-Output "Searching for: $Ext15Email"

						$O365Mailbox = Get-Mailbox $Ext15Email -ErrorAction Stop

						Write-Output "Successfully found email"
					}
					else {
						Write-Output "extensionAttribute15 is empty"
					}
				}
				catch {
					Write-Warning "Mailbox Not Found: $Ext15Email"
				}
			}

			#Add search through proxy addresses here too
			if ($null -eq $O365Mailbox) {
				#To Do: Write to DB
			}
			else
			{
				$DisableMailbox = $false

				$CasMailboxAttributes = @(
					"MAPIEnabled",
					"OWAEnabled",
					"ActiveSyncEnabled",
					"POPEnabled",
					"IMAPEnabled"
				)

				try {
					$CasMailbox = $O365Mailbox | Get-CasMailbox -ErrorAction Stop
				}
				catch {
					Write-Warning "Unable to pull user CasMailbox info"
				}

				foreach ($CasMailboxAttribute in $CasMailboxAttributes)
				{
					Write-Output $($CasMailboxAttribute+ ": " + $CasMailbox.$CasMailboxAttribute)

					if (($CasMailbox | Select-Object $CasMailboxAttribute).$CasMailboxAttribute) {
						$DisableMailbox = $true
					}
				}

				if ($DisableMailbox)
				{
					try {
						$SetCasMailboxParams = @{
							MAPIEnabled = $false
							OWAEnabled = $false
							ActiveSyncEnabled = $false
							POPEnabled = $false
							IMAPEnabled = $false
							ErrorAction = "Stop"
						}

						try {
							$O365Mailbox | Set-CasMailbox @SetCasMailboxParams

							Write-Output "Successfully set CasMailbox attributes"
						}
						catch {
							Write-Warning "Unable to set CasMailbox settings"
						}
					}
					catch {
						Write-Warning "Error setting CasMailbox"
					}
				}
				else {
					Write-Output "Mailbox is already disabled"
				}
			}
			##################
			# End of Step 1b #
			##################

			####################################
			# Step 1c: Set out of office reply #
			####################################
			Write-Output "`n`nStep 1c: Set out of office reply"

			try
			{
				$SetMailboxAutoReplyConfigParams = @{
					AutoReplyState = "Enabled"
					InternalMessage = "This account has been disabled."
					ExternalMessage = "This account has been disabled."
					ErrorAction = "Stop"
				}

				$O365Mailbox | Set-MailboxAutoReplyConfiguration @SetMailboxAutoReplyConfigParams
				Write-Output "Successfully set out of office reply"
			}
			catch {
				Write-Warning "Unable to set out of office reply"
				$Error.Clear()
			}

			##################
			# End of Step 1c #
			##################

			#########################################
			#########################################
			# Step 2: Account Disable Date + 7 days #
			#########################################
			#########################################

			if ($Step2Days -gt 0) {
				$Step2Days = -1 * $Step2Days
			}

			if ($Testing) {
				Write-Output "Longer delay before moving to step 2"
				Start-Sleep -s 20
			}

			if ($AccountDisableDate -lt (Get-Date).AddDays($Step2Days))
			{
				#########################################
				# Step 2a: Hide Mailbox in Address Book #
				#########################################

				Write-Output "`n`nStep 2a: Hide user from Global Address List"
				$HideSuccessful = $false

				if ($null -eq $ADUser.msExchHideFromAddressLists) {
					Write-Output "Hidden from address lists is null"
				}
				else {
					Write-Output $("Hidden from address lists: " + $ADUser.msExchHideFromAddressLists)
				}

				if (($null -eq $ADUser.msExchHideFromAddressLists) -OR
					(!$ADUser.msExchHideFromAddressLists))
				{
					try {
						$ADUser | Set-ADUser -Add @{msExchHideFromAddressLists=$true} -ErrorAction Stop
						$HideSuccessful = $true
					}
					catch
					{
						try {
							$ADUser | Set-ADUser -Replace @{msExchHideFromAddressLists=$true} -ErrorAction Stop
							$HideSuccessful = $true
						}
						catch {
							Write-Warning "Unable to hide user from address book"
						}
					}

					if ($HideSuccessful) {
						Write-Output "User has been hidden from address lists"
					}
					else {
						Write-Warning "Unable to hide user from address lists"
					}
				}
				else {
					Write-Output "User is already hidden in the address book"
				}

				##################
				# End of Step 2a #
				##################

				##################################
				# Step 2b: Remove from AD groups #
				# Step 2c: Add groups to DB      #
				##################################
				Write-Output "`n`nStep 2b: Remove user from AD groups"
				Write-Output "Step 2c: Add groups to DB (if needed)"

				Write-Output "Logging AD groups"
				$SelectQuery = "Select ADGroups from $DBTableName where SamAccountName = '" +
								$ADUser.SamAccountName + "'"
				Write-Output "Select Query: "
				Write-Output $SelectQuery

				$InvokeSQLCmdParams["Query"] = $SelectQuery
				try {
					$CurrentDBGroups = Invoke-SQLCmd @InvokeSQLCmdParams
				}
				catch {
					Write-Warning "Error reading db groups in database. Program is exiting."
					Invoke-HSCExitCommand -ErrorCount $Error.Count
				}

				$ADGroupsExist = $false

				try
				{
					[string]$ADGroups = $CurrentDBGroups.ADGroups.toString()

					if ($ADGroups.indexOf(";") -gt 0)
					{
						Write-Output "AD groups have been written to DB"
						$ADGroupsExist = $true
					}
				}
				catch
				{
					#Get here because AD groups have been written or DBNull.
					Write-Output "Error converting ADGroups to string"
					$Error.Clear()
				}

				if (($CurrentDBGroups.ADGroups -isnot [DBnull]) -OR ($ADGroupsExist))
				{
					#https://stackoverflow.com/questions/22285149/dealing-with-system-dbnull-in-powershell
					Write-Output "ADGroups have already been written to DB"
					Write-Output "Current Groups in DB:"
					Write-Output $CurrentDBGroups.ADGroups

					$ADUserGroups = $null
				}
				else
				{
					$ADUserGroups = $ADUser.MemberOf
					$UpdateQuery = $null

					if ($null -eq $ADUserGroups) {
						$UpdateQuery = "UPDATE $DBTableName SET ADGroups = " +
										"'No AD Groups' WHERE SamAccountName = '" +
										$ADUser.SamAccountName + "'"

						Write-Output "`n`nUpdate Query: $UpdateQuery"
					}
					else
					{
						$UserGroupArray = @()
						foreach ($ADUserGroup in $ADUserGroups)
						{
							$TempGroupName = $ADUserGroup.substring(0,$ADUserGroup.indexOf(","))
							$TempGroupName = $TempGroupName -replace "CN=",""

							Write-Output "Group name: $TempGroupName"

							$UserGroupArray += $TempGroupName
						}

						Write-Output "UserGroupArray: "
						Write-Output $UserGroupArray
						Write-Output $("UserGroupArray Count: " + $UserGroupArray.Length)

						$UserGroupString = $UserGroupArray -join ";"
						Write-Output $("User Group String Count: " + $UserGroupString.Count)
						Write-Output "User Group String:"
						Write-Output $UserGroupString

						$UpdateQuery = "UPDATE $DBTableName SET ADGroups = '" +
										($UserGroupArray -join ";") +
										"' WHERE SamAccountName = '" +
										$ADUser.SamAccountName + "'"

						Write-Output "`n`nUpdate Query: $UpdateQuery"
					}

					Write-Output "Adding AD groups to DB"

					try {
						$InvokeSQLCmdParams["Query"] = $UpdateQuery

						Invoke-SQLCmd @InvokeSQLCmdParams
						Write-Output "Successfully updated DB with AD groups"
					}
					catch {
						Write-Warning "Error writing AD groups to DB"
						Invoke-HSCExitCommand -ErrorCount $Error.Count
					}
				}

				#Now actually remove groups
				try
				{
					Write-Output "Removing user from AD groups"

					foreach ($ADUserGroup in $ADUserGroups)
					{
						Write-Output $("Removing user from group: $ADUserGroup")

						try {
							$RemoveADGroupMemberParams = @{
								Identity = $ADUserGroup
								Members = $ADUser.SamAccountName
								Confirm = $false
								ErrorAction = "Stop"
							}

							Remove-ADGroupMember @$RemoveADGroupMemberParams

							Write-Output "Successfully removed user from group"
						}
						catch {
							#This most likely is due to membership in WVU-AD groups
							Write-Warning "Error removing user from this group"
							$Error.Clear()
						}
					}

				}
				catch {
					Write-Warning "Error removing user from groups"
				}

				if ($Error.Count -gt 0 -AND $Testing)
				{
					$Error
					$ErrorCount++

					Invoke-HSCExitCommand -ErrorCount $Error.Count
				}

				#######################
				# End of Step 2b & 2c #
				#######################

				################################
				# Step 2d: Send limit to 10 kb #
				################################
				Write-Output "`n`n`Step 2d: Set mailbox send limit to 10 kb"

				if ($null -eq $O365Mailbox) {
					Write-Output "User mailbox doesn't exist"
				}
				else
				{
					try {
						$O365Mailbox | Set-Mailbox -MaxSendSize 10kb -ErrorAction Stop
						Write-Output "Successfully sent max send size"
					}
					catch {
						Write-Warning "Error setting max send size."
					}
				}

				##################
				# End of Step 2d #
				##################

				######################################################
				# Step 2e: Remove user from One Drive Members groups #
				######################################################
				Write-Output "`n`nStep 2e: Remove user from OneDrive member groups (OneDrive Members)"
				$GroupFound = $false

				try
				{
					Write-Output "Finding group"
					$GroupObjectId = (Get-AzureADGroup -SearchString "OneDrive Members").ObjectId
					Write-Output "Successfully found group"
					$GroupFound = $true
				}
				catch {
					Write-Warning "Unable to find group"
				}

				if ($GroupFound)
				{
					$UserFoundError = $false

					try
					{
						$UPN = $ADUser.UserPrincipalName
						Write-Output "UPN: $UPN"

						$AzureADUserObjectID = (Get-AzureADUser -SearchString $UPN).ObjectId
						Write-Output "Azure AD User ObjectId: $AzureADUserObjectID"
					}
					catch
					{
						Write-Warning "Error finding Azure AD user"
						$UserFoundError = $true
					}

					if (!$UserFoundError)
					{
						try
						{
							Write-Output "Attempting to remove user from One Drive members group"

							$RemoveAzureADGroupMemberParams = @{
								ObjectId = $GroupObjectId
								Memberid = $AzureADUserObjectID
								ErrorAction = "Stop"
							}

							Remove-AzureADGroupMember @RemoveAzureADGroupMemberParams
						}
						catch
						{
							Write-Warning "Error removing user from OneDrive Members group"
							$Error.Clear()
						}
					}
				}

				##################
				# End of Step 2e #
				##################

				#########################################
				# Step 2f. Set block credential to true #
				#########################################
				Write-Output "`n`nStep 2f: Set block credential to true"

				try {
					$AzureADUser = Get-AzureADUser -SearchString $ADUser.UserPrincipalName -ErrorAction Stop
					Write-Output "Successfully set block credential"
				}
				catch {
					Write-Warning "Unable to find AzureAD Object"
				}

				if ($null -ne $AzureADUser)
				{
					try {
						$AzureADUser | Set-AzureADUser -AccountEnabled $false -ErrorAction Stop
					}
					catch {
						Write-Warning "Error disabling Office 365 account"
					}
				}

				##################
				# End of Step 2f #
				##################

			}
			else
			{
				Write-Output "`n`nStep 2 will not be done due to account disable date."
				Write-Output "Account Disable Date: $AccountDisableDate"
			}## End of step 2

			################################################
			################################################
			# Begin Step 3: Account Disable Date + 30 Days #
			################################################
			################################################

			if ($Step3Days -gt 0) {
				$Step3Days = -1 * $Step3Days
			}

			if ($AccountDisableDate -lt (Get-Date).AddDays($Step3Days))
			{
				#############################################
				# Step 3a: Set extensionAttribute7 to No365 #
				#############################################
				Write-Output "`n`nStep 3a: Set extensionAttribute7 to No365 after 30 days"

				[datetime]$AccountDisableDate = $SQLData.AccountDisableDate

				Write-Output "Account Disable Date: $AccountDisableDate"
				Write-Output $("Account Disable Date + 30 days: " + $AccountDisableDate.AddDays(-1*$Step3Days))

				#if ((Get-Date) -gt $AccountDisableDate.AddDays($Step3Days))
				if ($AccountDisableDate -lt (Get-Date).AddDays($Step3Days))
				{
					Write-Output "Account disable date + 30 days has been exceeded"

					try {
						$ADUser | Set-ADUser -Replace @{extensionAttribute7 = "No365"} -ErrorAction Stop
						Write-Output "Successfully set extensionAttribute7 to No365"
					}
					catch {
						Write-Warning "There was an error setting extensionAttribute7"
					}
				}
				else {
					Write-Output "Account disable date + 30 days has not been exceeded yet."
				}

				###############
				# End Step 3a #
				###############

				######################################################
				# Step 3b. AD account is moved to "Deleted Accounts" #
				######################################################
				Write-Output "`n`n`Step 3b: Move user to deleted accounts OU"

				$CurrentDN = $ADUser.DistinguishedName.Trim()
				Write-Output "Current User OU: $CurrentDN"

				if ($CurrentDN.indexOf("OU=DeletedAccounts") -lt 0)
				{
					### Write current OU to DB table
					$CurrentOU = $CurrentDN.substring($CurrentDN.indexOf(",")+1).Trim()
					Write-Output "Parent OU: $CurrentOU"

					$UpdateQuery = "UPDATE $DBTableName SET OriginalOU" +
									" = '$CurrentOU' WHERE SamAccountName = '" +
									$ADUser.SamAccountName + "'"

					Write-Output `n`n"Update Query: $UpdateQuery"

					try {
						$InvokeSQLCmdParams["Query"] = $UpdateQuery
						Invoke-SQLCmd @InvokeSQLCmdParams

						Write-Output "Successfully updated DB with user's current OU"
					}
					catch
					{
						Write-Warning "Error writing users's current OU to DB"
						Invoke-HSCExitCommand -ErrorCount $Error.Count

						if ($Testing) {
							Invoke-HSCExitCommand -ErrorCount $Error.Count
						}
					}
				}
				else {
					Write-Output "User has already been moved to the deleted accounts OU"
				}
				### Current OU has now been written to DB

				[string]$DeletedAccountsOU = "OU=DeletedAccounts,DC=hs,DC=wvu-ad,DC=wvu,DC=edu"
				Write-Output "Deleted Accounts OU: $DeletedAccountsOU"

				if ($ADUser.DistinguishedName.indexOf("OU=DeletedAccounts") -lt 0)
				{
					try {
						$ADUser |
							Move-ADObject -TargetPath $DeletedAccountsOU -ErrorAction Stop

						Write-Output "Successfully moved AD user to $DeletedAccountsOU"
					}
					catch
					{
						Write-Warning "There was an error moving user to $DeletedAccountsOU"

						if ($Testing) {
							Invoke-HSCExitCommand -ErrorCount $Error.Count
						}
					}
				}
				else {
					Write-Output "User has already been moved to deleted accounts OU."
				}

				###############
				# End Step 3b #
				###############

				############################################
				# Step 3c. Move home folder to MS OneDrive #
				############################################

				#Testing is still going on for this step. Need to figure out how to uniquely determine
				#user directory as well as how to upload to OneDrive.

				Write-Output "`n`nStep 3c: Move home folder to MS OneDrive"

				Add-Content -Path $DirectoryMoveFile -Value $ADUser.SamAccountName

				try {
					Write-Output "Attempting to move user directory"
					#Need to figure this part out
					Write-Output "Home directory has been moved"
				}
				catch {
					Write-Warning "Error moving user directory"
				}

				###############
				# End Step 3c #
				###############
			}
			else {
				Write-Output "`n`n`Step 3 will not be run at this time due to the account disable date"
				Write-Output "Account Disable Date: $AccountDisableDate"

			}

			################################################
			################################################
			# Begin Step 4: Account Disable Date + 60 Days #
			################################################
			################################################

			Write-Output "`n`nStep 4: Deleting AD Account"

			if ($DeleteDays -gt 0) {
				$DeleteDays = -1*$DeleteDays
			}

			if ($AccountDisableDate -lt (Get-Date).AddDays($DeleteDays))
			{
				#############################
				# Step 4: Delete AD account #
				#############################

				$SamAccountName = $ADUser.SamAccountName

				Write-Output "Deleting: $SamAccountName"
				Add-Content -Path $DeleteFile -Value $SamAccountName

				try
				{
					#Add account delete date to DB
					$AccountDeleteDate = (Get-Date -format yyyy-MM-dd).toString()
					Write-Output "Account Delete Date: $AccountDeleteDate"

					$UpdateQuery = "UPDATE $DBTableName SET AccountDeleteDate " +
									"= '$AccountDeleteDate' WHERE SamAccountName = '" +
									$ADUser.SamAccountName + "'"

					Write-Output `n`n"Update Query: $UpdateQuery"

					Write-Output "Setting account delete date in DB"

					$InvokeSQLCmdParams["Query"] = $UpdateQuery
					Invoke-SQLCmd @InvokeSQLCmdParams

					Write-Output "Successfully updated account delete date"
				}
				catch
				{
					Write-Warning "Error writing users's account delete date"
					Invoke-HSCExitCommand -ErrorCount $Error.Count

					##if ($Testing) {
					##	Invoke-HSCExitCommand -ErrorCount $Error.Count
					##}
				}

				try
				{
					$DeleteCount++
					Write-Output "Delete Count: $DeleteCount"

					if ($DeleteCount -lt $MaximumDeletes)
					{
						if (!$Testing)
						{
							if ($DeleteAccount) {
								Write-Output "Attempting to delete AD user account"

								$ADUser #|
									#Remove-ADUser -ErrorAction Stop -Confirm:$false

								Write-Output "AD user account successfully deleted."
							}
							else {
								Write-Output "The delete switch wasn't used. Account will not be deleted."
							}
						}
						else {
							Write-Output "Testing switch was used. Account will not be deleted."
						}
					}
					else {
						Write-Output "Maximum deletes have been reached."
						Write-Output "User will not be deleted."
					}

					Write-Output "Successfully deleted AD account"
				}
				catch
				{
					Write-Warning "Error deleting AD account"

					if ($Testing) {
						Invoke-HSCExitCommand -ErrorCount $Error.Count
					}
				}
			}
			else
			{
				Write-Output "Account Disable Date: $AccountDisableDate"
				Write-Output "AD account will not be deleted at this time."
			}
		}
	}

	Write-Output "*******************************"

} #End of main for loop

$EndTime = Get-Date
$TotalTime = $EndTime - $StartTime

Write-Output "`nSummary Output"
Write-Output $("Processing took: " + $TotalTime.ToString("hh\:mm\:ss"))
Write-Output "Disable Count: $DisableCount"
Write-Output "New Disable Count: $NewDisablesCount"
Write-Output "Do Not Disable Count: $DoNotDisableCount"

Invoke-HSCExitCommand -ErrorCount $Error.Count