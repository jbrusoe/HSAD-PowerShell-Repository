#Export-ToSOLE.ps1
#Written by: Jeff Brusoe
#LastUpdated: May 27, 2021

[CmdletBinding()]
param (
	[bool]$CanDelete = $true, #set to false for testing - used to clear contents of table

	[ValidateNotNullOrEmpty()]
	[string]$sqlTable =	"HSADExportTemp", #SQL Table

	[ValidateRange(4000,10000)]
	[int]$MinADUsers = 4500 #Ths is just a safety value
)

try {
	Set-HSCEnvironment -ErrorAction Stop
	Connect-HSCExchangeOnlineV1 -ErrorAction Stop

	$SQLPassword = Get-HSCSQLPassword -SOLEDB -ErrorAction Stop
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

##############################
#       MAIN PROGRAM         #
##############################

#Generate list of AD users
Write-HSCColorOutput -Message "Getting User Accounts from Active Directory..." -ForegroundColor "Cyan"

$ADProperties = @(
			"sAMAccountName",
			"Enabled",
			"DistinguishedName",
			"userAccountControl",
			"LockedOut",
			"mail",
			"givenName",
			"initials",
			"sn",
			"Created",
			"LastLogonDate",
			"modified",
			"extensionAttribute3",
			"extensionAttribute6",
			"extensionAttribute10",
			"extensionAttribute11",
			"extensionAttribute12",
			"extensionAttribute14",
			"proxyAddresses"
		)

try {
	$GetADUserParams = @{
		Filter = "*"
		SearchScope = "Subtree"
		SearchBase = "OU=HSC,DC=HS,DC=wvu-ad,DC=wvu,DC=edu"
		Properties = $ADProperties
		ErrorAction = "Stop"
	}

	$ADUsers = Get-ADUser @GetADUserParams |
		Where-Object {$_.extensionAttribute10 -ne "Resource"} |
		Select-Object $ADProperties
}
catch {
	Write-Warning "There was an error searcing AD. Program is exiting."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output $("AD User Count: " + $ADUsers.count)

if ($ADUsers.Count -lt $MinADUsers) {
	Write-Warning "Too few AD users were returned. Program is exiting."
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}
else {
	Write-Output "Beginning to process AD users"
}

$MailboxEnabledFile = "$PSScriptRoot\Logs\" +
						(Get-Date -format yyyy-MM-dd-HH-mm) +
						"-MailboxesEnabled.csv"
New-Item -Type file $MailboxEnabledFile -Force

$HaveMailboxesFile = "$PSScriptRoot\Logs\" +
						(Get-Date -format yyyy-MM-dd-HH-mm) +
						"-HaveMailboxes.csv"
New-Item -Type file $HaveMailboxesFile -Force

#Calls function in HSC-CommonCodeModule to get Exchange/Office365 Info
Write-HSCColorOutput -Message "Getting Office365Information..." -ForegroundColor "Cyan"
#$Office365Info = Get-HSCO365MailboxStatus -ExportFile $MailboxEnabledFile -Verbose
$Office365Info = 

Write-HSCColorOutput -Message "Getting Active Mailboxes" -ForegroundColor "Yellow"

$MailboxInfo = Get-Mailbox -ResultSize Unlimited |
	Where-Object {($_.MaxReceiveSize -like "*MB*") -AND
					($_.PrimarySMTPAddress -notlike "*rni.*" -AND $_.PrimarySMTPAddress -notlike "*wvurni*")} |
					Select-Object UserPrincipalName,MaxReceiveSize
$MailboxInfo | Export-csv $HaveMailboxesFile

Write-Output "Active Mailbox Count:  $(($MailboxInfo.UserPrincipalName | Measure-Object).Count)"

foreach ($ADUser in $ADUsers)
{
	Write-Output $("Current User: " + $ADUser.SamAccountName)

	Write-HSCColorOutput -Message "Editing User Information" -ForegroundColor "Cyan"

	#Add User OU
	Write-Output "Before Get-HSCADUserParentContainer"
	$UserOU = Get-HSCADUserParentContainer -User $ADUser.SamAccountName
	Write-Output "User OU: $UserOU"
	$ADser | Add-Member -MemberType NoteProperty -Name "OU" -Value $UserOU

	#Adds values needed to each entry for SQL query
	$ADUser | Add-Member -MemberType NoteProperty -Name "resource" -Value $false
	$ADUser | Add-Member -MemberType NoteProperty -Name "unsure" -Value $false
	$ADUser | Add-Member -MemberType NoteProperty -Name "ruby" -Value $false
	$ADUser | Add-Member -MemberType NoteProperty -Name "clinic" -Value $false
	$ADUser | Add-Member -MemberType NoteProperty -Name "student" -Value $false
	$ADUser | Add-Member -MemberType NoteProperty -Name "ExchangeEnabled" -Value $false
	$ADUser | Add-Member -MemberType NoteProperty -Name "HasMailbox" -Value $false

	#Modifies blank values to no entry
	if ([string]::IsNullOrEmpty($ADUser.extensionAttribute10)) {
		   $ADUser.extensionAttribute10 = "No Entry"
	}

	if ([string]::IsNullOrEmpty($ADUser.extensionAttribute11)) {
			 $ADUser.extensionAttribute11 = "No Entry"
	}

	if ([string]::IsNullOrEmpty($ADUser.mail)) {
			 $ADUser.mail = "Not Found"
	}

	if ([string]::IsNullOrEmpty($ADUser.extensionAttribute3)) {
			 $ADUser.extensionAttribute3 = "Not Found"
	}

	if ([string]::IsNullOrEmpty($ADUser.extensionAttribute6)) {
			 $ADUser.extensionAttribute3 = "Not Found"
	}

	if ([string]::IsNullOrEmpty($ADUser.extensionAttribute14)) {
		$ADUser.extensionAttribute14 = "0" #HSCHIPAA
	}
	elseif ($ADUser.extensionAttribute14 -eq "HospitalHIPAA") {
		$ADUser.extensionAttribute14 = "1"
	}
	else {
		$ADUser.extensionAttribute14 = "0"
	}

	if ([string]::IsNullOrEmpty($ADUser.givenName)) {
			 $ADUser.givenName = "Not Found"
			 $ADUser | Add-Member -MemberType NoteProperty -Name "FirstName" -Value "Not Found"
	}
	else {
		$ADUser | Add-Member -MemberType NoteProperty -Name "FirstName" -Value $ADUser.givenName
	}

	if ([string]::IsNullOrEmpty($ADUser.sn)) {
			 $ADUser.sn = "Not Found"
			 $ADUser | Add-Member -MemberType NoteProperty -Name "LastName" -Value "Not Found"
	}
	else {
		$ADUser | Add-Member -MemberType NoteProperty -Name "LastName" -Value $ADUser.sn
	}

	$ADUser | Add-Member -MemberType NoteProperty -Name "LogonEnabled" -Value $false

	if ($ADUser.Enabled) {
		$ADUser.LogonEnabled = $true
	}

	#Looks for resource account (extensionAttribute10) value or student value (extensionAttribute6)
	if ($ADUser.extensionAttribute10.ToLower() -eq "resource") {
		$ADUser.resource = $true
	}
	elseif ($ADUser.extensionAttribute10.ToLower() -eq "unsure") {
		$ADUser.unsure = $true
	}
	elseif ($ADUser.extensionAttribute10.ToLower() -eq "ruby") {
		$ADUser.ruby = $true
	}
	elseif ($ADUser.extensionAttribute10.ToLower() -eq "clinic") {
		$ADUser.clinic = $true
	}

	if ($ADUser.extensionAttribute6 -eq "STUDENT") {
		$ADUser.student = $true
	}

	#Looks for Office365 Enabled
	$ProxyAddresses = $ADUser.proxyAddresses
	$ProxyAddresses = $ProxyAddresses | Where-Object {$_ -like "*@hsc.wvu.edu"}
	$ProxyAddresses = $ProxyAddresses -replace "smtp:"
	$ProxyAddresses = $ProxyAddresses -replace "sip:"

	if ($Office365Info.O365EmailAddress -contains ($ADUser.mail)) {
		$ADUser.ExchangeEnabled = $true
	}
	else
	{
		foreach ($ProxyAddress in $ProxyAddresses)
		{
			if ($Office365Info.O365EmailAddress -contains ($proxy)) {
			   $ADUser.ExchangeEnabled = $true
			}
		}
	}

	#looks for mailbox based on username
	if ($MailboxInfo.UserPrincipalName -contains "$($ADUser.samaccountname)@hsc.wvu.edu") {
		$user.HasMailbox = $true
	}

	Write-Output "*******************"
} #end foreach to modify user info and adding items
	
	###########################
	#        SQL Upload       #
	###########################

	#SQL parameters defined at begining of script
	
	[string]$ConnectionString = $null
	try {
		$ConnectionString = Get-HSCConnectionString -SQLPassword $SQLPassword -ErrorAction Stop
	}
	catch {
		Write-Warning "Unable to generate connection string. Program is exiting."
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}
	

	if ($CanDelete) {
		$DeleteQuery = "DELETE from $sqlTable"
		#Invoke-SqlCmd -Query $DeleteQuery -ConnectionString $ConnectionString
	}
	
foreach ($user in $users)
{
	#fixes apostrophe in LDAP string and last name for SQL query
	$LastName = $user.LastName
	$OU = $user.OU
	$FirstName = $user.FirstName
	$MiddleName = $user.Initials
	
	if (($user.OU -like "*'*")) {
		$OU = $OU -replace "'","''"
		$LastName = $LastName -replace "'","''"
		$FirstName = $FirstName -replace "'","''"
	}

	if ($user.LastName -like "*'*") {
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

	$UpdateQuery = "INSERT INTO $sqlTable (samAccountName,OU,Enabled,ExchangeEnabled,FirstName,LastName,Email,AccountCreationDTM,LastLoginDTM,LastModifiedDTM,ResourceAccount,UID,Unsure,IsStudent,RubyAccount,HealthCareProvider,MiddleName,HasMailbox,WvumHipaaTraining) VALUES ('$($user.samaccountname)','$OU','$($user.Enabled)','$($user.ExchangeEnabled)','$FirstName','$LastName','$($user.mail)','$($user.Created)','$($user.LastLogonDate)','$($user.modified)','$($user.resource)','$($user.ExtensionAttribute11)','$($user.unsure)','$($user.student)','$($user.ruby)','$($user.clinic)','$MiddleName','$($user.HasMailbox)','$($user.extensionAttribute14)')"

	#$sqlQuery = Invoke-SqlCmd -Query $UpdateQuery -ConnectionString $ConnectionString

	Write-Output "`n*************************"
	Write-Output "Inserted into SQL Database:`nFirst Name: $FirstName `nLast Name: $LastName `nUsername: $($user.samAccountName)`n Email: $($user.mail)`n Exchanged Enabled: $($user.HasMailbox)"
	Write-Output "*************************`n"
}

Write-Output "User data uploaded to temp database"

try
{
	Write-Output "Executing Stored Procedure"

	#Invoke-SQLCmd -ConnectionString $ConnectionString -Query "EXEC sp_RebuildHSADExport" -ErrorAction Stop
}
catch {
	Write-Warning "Error running sp_RebuildHSADExport"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count