# Move-SONDB.ps1
# Written by: Jeff Brusoe
# Last Updated: December 9, 2021

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$SQLTableFiles = "$PSScriptRoot\SQLTableFiles\",

    [ValidateNotNullOrEmpty()]
    [string]$SQLServer = "hscpowershell.database.windows.net",

    [ValidateNotNullOrEmpty()]
	[string]$DBName = "HSCPowerShell",

    [ValidateNotNullOrEmpty()]
	[string]$DBUsername = "HSCPowerShell",

    [ValidateNotNullOrEmpty()]
	[string]$DBTableName = "MailboxClutterInfo"
)

try {
    Set-HSCEnvironment -ErrorAction Stop
}
catch {
    Write-Warning "Unable to configure HSC environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Generating SQL Connection String for Azure SQL Instance"
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
    Write-Warning "Unable to generate SQL connection string"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Getting SQL Table Files"
}
catch {
    
}
Invoke-HSCExitCommand -ErrorCount $Error.Count