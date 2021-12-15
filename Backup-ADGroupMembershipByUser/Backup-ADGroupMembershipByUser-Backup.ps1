# Backup-ADGroupMembership.ps1
# Written by: Jeff Brusoe
# Last Updated: September 9, 2021
#
# The purpose of this file is to backup AD Group Membership.
# Backups are written to the O365 SQL Instance and is based on
# the user's SamAccountName.

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$LogDirectory = "$PSScriptRoot\Logs\",

    [ValidateNotNullOrEmpty()]
    [string]$SQLServer = "hscpowershell.database.windows.net",

    [ValidateNotNullOrEmpty()]
	[string]$DBName = "HSCPowerShell",

    [ValidateNotNullOrEmpty()]
	[string]$DBUsername = "HSCPowerShell",

    [ValidateNotNullOrEmpty()]
	[string]$DBTableName = "ADGroupMembershipByUser"
)

try {
    Set-HSCEnvironment -ErrorAction Stop

    $EmptyGroupLog = "$LogDirectory\" +
                        (Get-Date -Format yyyy-MM-dd-HH-mm) +
                        "-EmptyGroups.txt"
    New-Item -ItemType File -Force -Path $EmptyGroupLog

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

        $DeleteQuery = "DELETE FROM $DBTableName"
        $InvokeSQLCmdParams["Query"] = $DeleteQuery
        Invoke-SQLCmd @InvokeSQLCmdParams
    }
    catch {
        Write-Warning "Unable to generate SQL connection string"
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Getting list of AD Groups"

    $ADGroups = Get-ADGroup -Filter * -ErrorAction Stop

    Write-Output $("Total number of AD Groups: " + $ADGroups.Count)
}
catch {
    Write-Warning "Unable to get list of AD groups"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output "Getting list of AD Group Memberships"

foreach ($ADGroup in $ADGroups)
{
    Write-Output $("Group Name: " + $ADGroup.Name)
    Write-Output $("Distinguished Name: " + $ADGroup.DistinguishedName)

    try {
        $ADUsers = $ADGroup |
            Get-ADGroupMember -ErrorAction Stop -Recursive |
            Where-Object {$_.objectClass -eq "user"}

        if ($ADUsers.Count -eq 0) {
            Write-Output $("No users in group: " + $ADGroup.Name)

            Add-Content -Path $EmptyGroupLog -Value $ADGroup.Name -ErrorAction Stop
        }
        else {
            foreach ($ADUser in $ADUsers) {
                $SamAccountName = $ADUser.SamAccountName

                if ([string]::IsNullOrEmpty($SamAccountName)) {
                    Write-Output "Group Member has no SamAccountName"
                    continue
                }

                $ADUserDN = $ADUser.DistinguishedName
                $GroupName = $ADGroup.Name
                $GroupDN = $ADGroup.DistinguishedName

                Write-Output "Current user: $SamAccountName"
                Write-Output "Group Name: $GroupName"
                Write-Output "Group DN:"
                Write-Output $GroupDN

                $SQLQuery = "Select * from $DBTableName where " + 
                            "SamAccountName = '" + $SamAccountName + "'"
                Write-Output "SQL Query: $SQLQuery"

                $InvokeSQLCmdParams["Query"] = $SQLQuery
                $SQLUser = Invoke-SQLCmd @InvokeSQLCmdParams

                if ($null -eq $SQLUser) {
                    Write-Output "User not found in DB"

                    $InsertQuery = "Insert into $DBTableName Values ('" +
                                            "$SamAccountName','" +
                                            "$ADUserDN','" +
                                            "$GroupName" + "')"
                    Write-Output "SQL Insert Query: $InsertQuery"

                    $InvokeSQLCmdParams["Query"] = $InsertQuery
                    Invoke-SQLCmd @InvokeSQLCmdParams
                }
                else {
                    Write-Output "User found in DB"

                    $SamAccountName = $SQLUser.SamAccountName
                    Write-Output "SQL Sam Account Name: SamAccountName"

                    $SQLGroups = $SQLUser.Groups
                    $SQLGroups = $SQLGroups + ";" + $GroupName

                    Write-Output "Updated list of groups:"
                    Write-Output $SQLGroups

                    $UpdateQuery = "Update $DBTableName Set Groups = '" + $SQLGroups +
                                    "' where SamAccountName = '" + $SamAccountName + "'"
                    Write-Output "Update Query:"
                    Write-Output $UpdateQuery

                    $InvokeSQLCmdParams["Query"] = $UpdateQuery
                    Invoke-SQLCmd @InvokeSQLCmdParams
                }

                Write-Output "------------------------------"
            }
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADException]{
        if ($Error.Count -eq 1) {
            if ($Error.Exception -eq "The size limit for this request was exceeded") {
                Write-Warning "More than 5000 AD users are in group"
            }
            else {
                Write-Warning "AD Exception"
            }

            $Error.Clear()
            continue
        }
        else {
            Write-Warning "Multiple errors have occurred"
            Invoke-HSCExitCommand -ErrorCount $Error.Count
        }
    }
    catch {
        Write-Warning "Unable to get list of AD group members"
        $Error.Clear()
        continue
    }

    Write-Output "*******************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count