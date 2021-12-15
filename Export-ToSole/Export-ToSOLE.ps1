#--------------------------------------------------------------------------------------------------
#Export-ToSOLE.ps1
#
#Originally Written by: Matt Logue
#
#Last Modified: May 7, 2020
#
#Version: 2.0
#
#Purpose: This file looks at Active directory.  Exports the users, obtains account status from Office365, and Exports it to SOLE SQL server
#
#This file assumes a connection to the HSC Office 365 tenant has been established. If it isn't, then it will 
#look for the Connect-ToOffice365-MS3.ps1 file to attempt a connection.
#--------------------------------------------------------------------------------------------------

[CmdletBinding()]
param (
	#Common HSC module parameters
	[switch]$NoSessionTranscript,
    [string]$LogFilePath = "$PSScriptRoot\Logs",
	[switch]$StopOnError, #$true is used for testing purposes
	[int]$DaysToKeepLogFiles = 5, #this value used to clean old log files

    #File specific parameters
    #[string]$sqlPasswordPath="C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSC-PowerShell-Modules\sql3.txt",
	[string]$sqlPasswordPath="C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSC-PowerShell-Modules\EncryptedFiles\sql3.txt",
	[bool]$CanDelete = $true, #set to false for testing - used to clear contents of table
	[string]$sqlDataSource = "sql01.hsc.wvu.edu", #SQL server name
	[string]$sqlUsername = "itsnetworking", #userid for SQL database
	[string]$sqlDatabase = "BannerData", #SQL database name
	#[string]$sqlTable = "HSADExportPS",
	[string]$sqlTable =	"HSADExportTemp", #SQL Table
	[int]$MinADUsers = 4500 #Ths is just a safety value
	)

$Error.Clear()

#############################
#Load HSC PowerShell Modules#
#############################

#Step 1: Build path to HSC PowerShell Modules
$PathToHSCPowerShellModules = $PSScriptRoot
$PathToHSCPowerShellModules = $PathToHSCPowerShellModules.substring(0,$PathToHSCPowerShellModules.lastIndexOf("\")+1)
$PathToHSCPowerShellModules += "1HSC-PowerShell-Modules"
Write-Output $PathToHSCPowerShellModules

#Step 4: Attempt to load HSC SQL Module
$SQLModule = $PathToHSCPowerShellModules + "\HSC-SQLModule-Ver2a.psm1"
Write-Output "Path to HSC SQL Module: $SQLModule"
Import-Module $SQLModule -Force

if ($Error.Count -gt 0)
{
	#Any errors at this point are from loading modules. Program must stop.
	Write-Warning "There was an error loading the required modules. Program is ending."
	return
}

###########################################################
#End of code block to load HSC PowerShell modules         #
#At this point, all modules should be loaded successfully.#
###########################################################

#############################
#Configure environment block#
#############################

Set-HSCEnvironment
Connect-HSCExchangeOnlineV1

#Decrypt SQL Password
$sqlSecureStringPassword = cat $sqlPasswordPath  | convertto-securestring
$sqlPassword = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($sqlSecureStringPassword))

if ($Error.Count -gt 0)
{
	#Any errors at this point are from enivronment configuration. Program must stop.
	Write-Warning "There was an error configuring the environment. Program is exiting."
	return
}

########################################
#End of environment configuration block#
########################################

##############################
#       MAIN PROGRAM         #
##############################
	
$count = 0
$i=0
$users = @()

#Generate list of AD users
Write-HSCColorOutput -Message "Getting User Accounts from Active Directory..." -ForegroundColor "Cyan"
$properties = "sAMAccountName","Enabled","DistinguishedName","userAccountControl","LockedOut","mail","givenName","initials","sn","Created","LastLogonDate","modified","extensionAttribute10","extensionAttribute11","extensionAttribute12","extensionAttribute3","proxyAddresses","extensionAttribute6","extensionAttribute14"

try
{
	$users = Get-ADUser -Filter * -SearchScope Subtree -SearchBase "OU=HSC,DC=HS,DC=wvu-ad,DC=wvu,DC=edu" -Properties $properties -ErrorAction Stop |  Where-Object {$_.extensionAttribute10 -ne "Resource"} | select $properties
}
catch
{
	Write-Warning "There was an error searcing AD. Program is exiting."
	Exit-Command
}

Write-Output $("AD User Count: " + $users.count)

if ($users.Count -lt $MinADUsers)
{
	Write-Warning "Too few AD users were returned. Program is exiting."
	Exit-Command
}
else
{
	Write-Output "Beginning to process AD users"
}

$MailboxEnabledFile = "$PSScriptRoot\Logs\" + (Get-Date -format yyyy-MM-dd-HH-mm) + "-MailboxesEnabled.csv"
New-Item -type file $MailboxEnabledFile -Force

$HaveMailboxesFile = "$PSScriptRoot\Logs\" + (Get-Date -format yyyy-MM-dd-HH-mm) + "-HaveMailboxes.csv"
New-Item -type file $HaveMailboxesFile -Force

#Calls function in HSC-CommonCodeModule to get Exchange/Office365 Info
Write-HSCColorOutput -Message "Getting Office365Information..." -ForegroundColor "Cyan"
$Office365Info = Get-HSCO365MailboxStatus -ExportFile $MailboxEnabledFile -Verbose
	
Write-HSCColorOutput -Message "Getting Active Mailboxes" -ForegroundColor "Yellow"
$MailboxInfo = Get-Mailbox -ResultSize Unlimited |
				Where-Object {($_.MaxReceiveSize -like "*MB*") -AND ($_.PrimarySMTPAddress -notlike "*rni.*" -AND $_.PrimarySMTPAddress -notlike "*wvurni*")} |
				Select-Object UserPrincipalName,MaxReceiveSize 
$MailboxInfo | Export-csv $HaveMailboxesFile
Write-Output "Active Mailbox Count:  $(($MailboxInfo.UserPrincipalName | Measure-Object).Count)"
	
foreach ($user in $users)
{	
	Write-Output $("Current User: " + $user.SamAccountName)
	
	Write-HSCColorOutput -Message "Editing User Information" -ForegroundColor "Cyan"
	
	#Add User OU
	Write-Output "Before Get-HSCADUserParentContainer"
	$UserOU = Get-HSCADUserParentContainer -SamAccountName $user.SamAccountName
	Write-Output "User OU: $UserOU"
	$user | Add-Member -MemberType NoteProperty -Name "OU" -Value $UserOU
	
	#Adds values needed to each entry for SQL query
	$user | Add-Member -MemberType NoteProperty -Name "resource" -Value $false
	$user | Add-Member -MemberType NoteProperty -Name "unsure" -Value $false
	$user | Add-Member -MemberType NoteProperty -Name "ruby" -Value $false
	$user | Add-Member -MemberType NoteProperty -Name "clinic" -Value $false
	$user | Add-Member -MemberType NoteProperty -Name "student" -Value $false
	$user | Add-Member -MemberType NoteProperty -Name "ExchangeEnabled" -Value $false
	$user | Add-Member -MemberType NoteProperty -Name "HasMailbox" -Value $false
	$user | Add-Member -MemberType NoteProperty -Name "SharedUser" -Value $false

	#Modifies blank values to no entry
	if ([string]::IsNullOrEmpty($user.extensionAttribute10))
	{
		   $user.extensionAttribute10 = "No Entry"
	}
	
	if ($user.extensionAttribute10 -eq "TRUE")
	{
		   $user.SharedUser = $true
	}

	if ([string]::IsNullOrEmpty($user.extensionAttribute11))
	{
			 $user.extensionAttribute11 = "No Entry"
	}

	if ([string]::IsNullOrEmpty($user.mail))
	{
			 $user.mail = "Not Found"
	}

	if ([string]::IsNullOrEmpty($user.extensionAttribute3))
	{
			 $user.extensionAttribute3 = "Not Found"
	}
	
	if ([string]::IsNullOrEmpty($user.extensionAttribute6))
	{
			 $user.extensionAttribute3 = "Not Found"
	}
	
	if ([string]::IsNullOrEmpty($user.extensionAttribute14))
	{
		$user.extensionAttribute14 = "0" #HSCHIPAA
	}
	elseif ($user.extensionAttribute14 -eq "HospitalHIPAA")
	{
		$user.extensionAttribute14 = "1"
	}
	else
	{
		$user.extensionAttribute14 = "0"
	}

	if ([string]::IsNullOrEmpty($user.givenName))
	{
			 $user.givenname = "Not Found"
			 $user | Add-Member -MemberType NoteProperty -Name "FirstName" -Value "Not Found"
	}
	else 
	{
		$user | Add-Member -MemberType NoteProperty -Name "FirstName" -Value $user.givenName
	}

	if ([string]::IsNullOrEmpty($user.sn))
	{
			 $user.sn = "Not Found"
			 $user | Add-Member -MemberType NoteProperty -Name "LastName" -Value "Not Found"
	}
	else 
	{
		$user | Add-Member -MemberType NoteProperty -Name "LastName" -Value $user.sn
	}

	$user | Add-Member -MemberType NoteProperty -Name "LogonEnabled" -Value $false

	if ($user.Enabled) {

		$user.LogonEnabled = $true
	}

	#Looks for resource account (extensionAttribute10) value or student value (extensionAttribute6)
	if ($user.extensionAttribute10.ToLower() -eq "resource")
	{
		$user.resource = $true
	}
	elseif ($user.extensionAttribute10.ToLower() -eq "unsure")
	{
		$user.unsure = $true
	}
	elseif ($user.extensionAttribute10.ToLower() -eq "ruby")
	{
		$user.ruby = $true
	}
	elseif ($user.extensionAttribute10.ToLower() -eq "clinic")
	{
		$user.clinic = $true
	}

	if ($user.extensionAttribute6 -eq "STUDENT")
	{
		$user.student = $true
	}

	#Looks for Office365 Enabled
	$proxies = $user.proxyaddresses
	$proxies = $proxies | where {$_ -like "*@hsc.wvu.edu"}
	$proxies = $proxies -replace "smtp:"
	$proxies = $proxies -replace "sip:"
	
	if ($Office365Info.O365EmailAddress -contains ($user.mail)) 
	{
		$user.ExchangeEnabled = $true
	}
	else 
	{
		foreach ($proxy in $proxies)
		{
			if ($Office365Info.O365EmailAddress -contains ($proxy)) 
			{
			   $user.ExchangeEnabled = $true
			}
		}
	}
	
	#looks for mailbox based on username
	if ($MailboxInfo.UserPrincipalName -contains "$($user.samaccountname)@hsc.wvu.edu")
	{
		$user.HasMailbox = $true
	}
	
	Write-Output "*******************"
} #end foreach to modify user info and adding items
	
	###########################
	#        SQL Upload       #
	###########################

	#SQL parameters defined at begining of script
	
	[string]$ConnectionString = $null
	try
	{
		$ConnectionString = Get-ConnectionString -SQLPassword $sqlPassword -ErrorAction Stop
	}
	catch
	{
		Write-Warning "Unable to generate connection string. Program is exiting."
		Exit-Command
	}
	

	if ($CanDelete)
	{
		$DeleteQuery = "DELETE from $sqlTable"
		Invoke-SqlCmd -Query $DeleteQuery -ConnectionString $ConnectionString
	}
	
foreach ($user in $users)
{
	#fixes apostrophe in LDAP string and last name for SQL query
	$LastName = $user.LastName
	$OU = $user.OU
	$FirstName = $user.FirstName
	$MiddleName = $user.Initials
	
	if (($user.OU -like "*'*"))
	{
		$OU = $OU -replace "'","''"
		$LastName = $LastName -replace "'","''"
		$FirstName = $FirstName -replace "'","''"
	}

	if ($user.LastName -like "*'*")
	{
		$LastName = $LastName -replace "'","''"
		#$OU = $OU -replace "'","''"
	}
	if ($user.FirstName -like "*'*")
	{
		$FirstName = $FirstName -replace "'","''"
		#$OU = $OU -replace "'","''"
	}
	if ($user.Initials -like "*'*")
	{
		$MiddleName = $MiddleName -replace "'","''"
	}

	$UpdateQuery = "INSERT INTO $sqlTable (samAccountName,OU,Enabled,ExchangeEnabled,FirstName,LastName,Email,AccountCreationDTM,LastLoginDTM,LastModifiedDTM,ResourceAccount,UID,Unsure,IsStudent,RubyAccount,HealthCareProvider,MiddleName,HasMailbox,WvumHipaaTraining,isSharedUser) VALUES ('$($user.samaccountname)','$OU','$($user.Enabled)','$($user.ExchangeEnabled)','$FirstName','$LastName','$($user.mail)','$($user.Created)','$($user.LastLogonDate)','$($user.modified)','$($user.resource)','$($user.ExtensionAttribute11)','$($user.unsure)','$($user.student)','$($user.ruby)','$($user.clinic)','$MiddleName','$($user.HasMailbox)','$($user.extensionAttribute14)','$($user.SharedUser)')"


	try {
		$InvokeSQLCmdParams = @{
			Query = $UpdateQuery
			ConnectionString = $ConnectionString
			ErrorAction = "Stop"
		}
		Invoke-SqlCmd @InvokeSQLCmdParams
	}
	catch {
		Write-Warning "Unable to run insert query"
		return
	}
	
	Write-Output "`n*************************"
	Write-Output "SQL Query:"
	Write-Output $UpdateQuery
	Write-Output "`n`nInserted into SQL Database:`nFirst Name: " +
					$FirstName + "`nLast Name: $LastName `nUsername: $($user.samAccountName)" +
					"`nEmail: $($user.mail)`nExchanged Enabled: $($user.HasMailbox)"
	Write-Output "*************************`n"
}

Write-Output "User data uploaded to temp database"

try
{
	$SQLConn = Connect-SQL -SQLPassword $sqlPassword
	Write-Output "Executing Stored Procedure"
	$sqlspcmd = New-Object System.Data.SqlClient.SqlCommand
	$sqlspcmd.CommandText = "sp_RebuildHSADExport"
	$sqlspcmd.Connection = $SQLConn
	$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
	$SqlAdapter.SelectCommand = $sqlspcmd
	$DataSet = New-Object System.Data.DataSet
	$SqlAdapter.Fill($DataSet)
}
catch
{
	Write-Warning "Error running sp_RebuildHSADExport"
}

try
{
	Write-Verbose "Attempting to close SQL Connection"
	$SQLConn.close()
	Write-Verbose "SQL Connection has been closed"
}
catch
{
	Write-Warning "Error closing SQL connection"
}

Invoke-HSCExitCommand