#Get-ADUserInfo.ps1
#Written by: Jeff Brusoe
#Last Updated: January 23, 2020

[CmdletBinding()]
param (
	[string]$SQLServer = "hscpowershell.database.windows.net",
	[string]$DBName = "HSCPowerShell",
	[string]$DBUsername = "HSCPowerShell",
	[string]$DBTableName = "ADUserInfo"
)

try {
	Set-HSCEnvironment -ErrorAction Stop
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    $SQLPwd = Get-HSCSQLPassword -ErrorAction Stop

    $ConnectionStringParams = @{
        DataSource = $SQLServer
        Database = $DBName
        UserName = $DBUserName
        SQLPassword = $SQLPwd
		ErrorAction = "Stop"
    }

    $SQLConnectionString = Get-HSCSQLConnectionString @ConnectionStringParams
}
catch {
    Write-Warning "Unable to generate SQL connection string"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
	Write-Output "Getting total number of AD users"
	$TotalNumberOfUsers = Get-HSCADUserCount -ErrorAction Stop
	Write-Output "Total Number of Users: $TotalNumberOfUsers`n"
}
catch {
	Write-Warning "Unable to get total AD user count"
}

try {
	Write-Output "Getting NewUsers count"
	$TotalNewUsers = Get-HSCADUserCount -OrgUnit NewUsers
	Write-Output "Total New Users: $TotalNewUsers`n"
}
catch {
	Write-Warning "Unable to get NewUsers OU count"
}

try {
	Write-Output "Getting enabled user count"
	$TotalEnabledUsers = Get-HSCADUserCount -UserEnabled
	Write-Output "`Enabled User Count: $TotalEnabledUsers`n"
}
catch {
	Write-Warning "Unable to get enabled user count"
}

try {
	Write-Output "Get HSC OU Count"
	$TotalHSCOU = Get-HSCADUserCount -OrgUnit HSC
	Write-Output "`Total HSC Org Unit Count: $TotalHSCOU"
}
catch {
	Write-Warning "Unable to get HSC OU Count"
}

try {
	Write-Output "Getting FromNewUsers OU Count"
	$FromNewUsersOU = Get-HSCADUserCount -OrgUnit FromNewUsers
	Write-Output "`nTotal in FromNewsUsers: $FromNewUsersOU"
}
catch {
	Write-Warning "Unable to get FromNewUsers OU Count"
}

try {
	Write-Output "Writing Information to DB"

	$InsertQuery = "Insert into $DBTableName " +
					"(TotalADUserCount,NewUsersCount,EnabledUsersCount,HSCOUCount,FromNewUsersCount) " +
					"Values ($TotalNumberOfUsers,$TotalNewUsers,$TotalEnabledUsers,$TotalHSCOU,$FromNewUsersOU)"

	Write-Output "Insert Query:"
	Write-Output $InsertQuery

	Invoke-SQLCmd -Query $InsertQuery -ConnectionString $SQLConnectionString -ErrorAction Stop

	Write-Output "Finshied writing to DB"
}
catch {
	Write-Warning "Unable to write to DB"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count