<#
    .SYNOPSIS
        Updates the mailbox clutter status for a specified mailbox

    .DESCRIPTION
        This file will update the mailbox clutter status for a specified mailbox.
        It first goes through the mailboxes in O365 and compares that to the
        mailboxes that are in the DB.  If the mailbox is not in the DB, it will
        be added. If the mailbox is in the DB and not in O365, it will be removed.
        After that, it will randomly select mailboxes to update the status. Mailboxes are
        randomly selected instead of going through sequentially because of the time it takes
        to run the Get-Clutter cmdlet.

    .PARAMETER OutputFileName
        This is the path to the output summary log file

    .PARAMETER SQLServer
        The name of the SQL Server to connect to

    .PARAMETER DBName
        The name of the database used to store the mailbox clutter status

    .PARAMETER DBUserName
        The name of the database user to connect to the database

    .PARAMETER DBTableName
        The name of the table that stores the mailbox clutter status

    .PARAMETER TotalUpdates
        The total number of updates to try in one run.

    .PARAMETER SkipDBCheck
        If this is set to $true, the script will not check the DB/tenant mailboxes
        to see if there are any differences.

    .NOTES
        Written by: Jeff Brusoe
        Last Updated: July 26, 2021
#>
[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]$OutputFileName = "$PSScriptRoot\Logs\" +
                                (Get-Date -Format yyyy-MM-dd-HH-mm) +
                                "-MailboxClutterInfo.csv",

    [ValidateNotNullOrEmpty()]
    [string]$SQLServer = "hscpowershell.database.windows.net",

    [ValidateNotNullOrEmpty()]
	[string]$DBName = "HSCPowerShell",

    [ValidateNotNullOrEmpty()]
	[string]$DBUsername = "HSCPowerShell",

    [ValidateNotNullOrEmpty()]
	[string]$DBTableName = "MailboxClutterInfo",

    [ValidateNotNullOrEmpty()]
    [int]$TotalUpdates = 3000,

    [switch]$SkipDBComparison
)

try {
    Write-Output "Configuring Environment"

    Set-HSCEnvironment -ErrorAction Stop
    Connect-HSCExchangeOnline -ErrorAction Stop

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
        Write-Warning "Unable to generate SQL connection string"
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

if (!$SkipDBComparison) {
    try {
        Write-Output "Getting list of Office 365 mailboxes"

        $GetEXOMailbxParams = @{
            Properties = @("PrimarySMTPAddress")
            ResultSize = "Unlimited"
            ErrorAction = "Stop"
        }

        $O365Mailboxes = Get-EXOMailbox @GetEXOMailbxParams |
            Where-Object { $_.PrimarySMTPAddress -notlike "*rni.*" -AND
                            $_.PrimarySMTPAddress -notlike "*wvurni*" }

        $TotalMailboxCount = $O365Mailboxes.Count
        Write-Output "Total Number of Mailboxes: $TotalMailboxCount"
    }
    catch {
        Write-Warning "Unable to query Office 365 mailboxes"
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }

    try {
        Write-Output "Getting mailboxes from clutter mailbox database"

        $ClutterDBQuery = "SELECT * FROM $DBTableName"
        $InvokeSQLCmdParams["Query"] = $ClutterDBQuery

        $ClutterDBMailboxes = Invoke-SQLCmd @InvokeSQLCmdParams

        Write-Output $("Total Clutter DB Mailboxes: " + $ClutterDBMailboxes.Count)
    }
    catch {
        Write-Warning "Unable to query clutter DB"
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }

    try {
        Write-Output "Determining which mailboxes are not in both the DB and O365"

        $CompareObjectParams = @{
            ReferenceObject = $ClutterDBMailboxes.PrimarySMTPAddress
            DifferenceObject = $O365Mailboxes.PrimarySMTPAddress
            ErrorAction = "Stop"
        }
    $ListDifferences = Compare-Object @CompareObjectParams

    Write-Output "List Differences:"
    Write-Output $ListDifferences
    }
    catch {
        Write-Warning "Unable to compare arrays"
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }

    Write-Output "`n`nBeginning to update DB`n`n"

    foreach ($ListDifference in $ListDifferences)
    {
        if ($ListDifference.SideIndicator -eq "<=") {
            #This is the case where the mailbox is in the DB but not in the O365 mailbox list.
            #Need to remove it from the DB.

            try {
                Write-Output "Removing user from DB"

                $DeleteQuery = "Delete from MailboxClutterInfo where PrimarySMTPAddress = " + "'" +
                                $ListDifference.InputObject + "'"

                Write-Output "Delete Query: $DeleteQuery"

                $InvokeSQLCmdParams["Query"] = $DeleteQuery
                Invoke-SQLCmd @InvokeSQLCmdParams

                Write-Output "Successfully removed user from SQL DB"
            }
            catch {
                Write-Warning "Error remvoing user from DB"
            }
        }
        else {
            #This is the case where the mailbox is in the O365 mailbox list but not in the DB.
            #Need to add it to the DB.

            try {
                Write-Output "Attempting to add user to DB"
                Write-Output $("Primary SMTP: " + $ListDifference.InputObject)

                try {
                    Write-Output "Getting Mailbox Object"
                    $O365Mailbox = $O365Mailboxes |
                                    Where-Object {$_.PrimarySMTPAddress -eq $ListDifference.InputObject}

                    Write-Output $("Primary SMTP Address: " + $O365Mailbox.PrimarySMTPAddress)

                    $GetClutterParams = @{
                        Identity = $O365Mailbox.PrimarySMTPAddress
                        ErrorAction = "Stop"
                    }
                    $O365MailboxClutterInfo = Get-Clutter @GetClutterParams
                }
                catch {
                    Write-Warning "Unable to find mailbox"
                }

                if ($null -ne $O365Mailbox) {
                    $SQLQuery = "INSERT INTO $DBTableName VALUES ('" +
                                $ListDifference.InputObject + "','" +
                                $O365MailboxClutterInfo.IsEnabled + "','" +
                                (Get-Date -Format yyyy-MM-dd) + "')"

                    $InvokeSQLCmdParams["Query"] = $SQLQuery

                    Invoke-SQLCmd @InvokeSQLCmdParams

                    Write-Output "Successfully added user to DB"
                }
            }
            catch {
                Write-Warning "Unable to update clutter info in DB"
            }
        }

        Write-Output "*********************************"
    }
}

Write-Output "`n`nFinished with add/deletes to DB"
Write-Output "Now moving on to randomly select entries to update`n`n"

#Pull data from DB
$SQLQuery = "SELECT * FROM $DBTableName ORDER BY LastUpdated"

$InvokeSQLCmdParams["Query"] = $SQLQuery

try {
    $SQLData = Invoke-SQLCmd @InvokeSQLCmdParams

    Write-Output $("SQL Data Count: " + $SQLData.Count)
}
catch {
    Write-Warning "Unable to query DB to get update list"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$UpdateCount = 0
while ($UpdateCount -lt $TotalUpdates) {
    
    $SQLDBIndex = $UpdateCount
    $CanContinue = $true

    $PrimarySMTPAddress =  $SQLData[$SQLDBIndex].PrimarySMTPAddress
    Write-Output $("Primary SMTP Address: " + $PrimarySMTPAddress)
    Write-Output $("Last Updated: " + $SQLData[$SQLDBIndex].LastUpdated)   
    Write-Output "Mailbox is being updated in DB"

    try {
        $ClutterInfo = Get-Clutter -Identity $PrimarySMTPAddress -ErrorAction Stop
        Write-Output $("Clutter Enabled: " + $ClutterInfo.IsEnabled)
        Write-Output "Current Update Number: $UpdateCount"
    }
    catch {
        Write-Warning "Unable to pull Clutter Info from O365"
        CanContinue = $false
    }

    if ($CanContinue)
    {
        $UpdateCount++

        #Generate output log file
        $ClutterInfo |
            Select-Object @{Name="PrimarySMTPAddress";Expression={$SQLData[$SQLDBIndex].PrimarySMTPAddress}},IsEnabled |
            Export-Csv $OutputFileName -Append -NoTypeInformation

        Write-Output "User was found in DB"

        if ([bool]$SQLData[$SQLDBIndex].ClutterEnabled -eq $ClutterInfo.IsEnabled) {
            #Just need change the LastUpdated field
            $SQLQuery = "UPDATE MailboxClutterInfo SET LastUpdated = '" +
                        (Get-Date -Format yyyy-MM-dd) +
                        "' WHERE PrimarySMTPAddress = '" +
                        $SQLData[$SQLDBIndex].PrimarySMTPAddress + "'"
            Write-Output "SQL Query: $SQLQuery"

            $InvokeSQLCmdParams["Query"] = $SQLQuery

            try {
                Invoke-SQLCmd @InvokeSQLCmdParams
                Write-Output "Clutter info was updated"
            }
            catch {
                Write-Warning "Unable to update clutter info in DB"
            }
        }
        else
        {
            #Need to change the LastUpdated field and the ClutterEnabled field
            $SQLQuery = "Update MailboxClutterInfo Set LastUpdated = '" +
                        (Get-Date -Format yyyy-MM-dd) + "'," +
                        "ClutterEnabled = '" +
                        $ClutterInfo.IsEnabled +
                        "' WHERE PrimarySMTPAddress = '" +
                        $SQLData[$SQLDBIndex].PrimarySMTPAddress + "'"

            Write-Output "SQL Query: $SQLQuery"

            $InvokeSQLCmdParams["Query"] = $SQLQuery

            try {
                Invoke-SQLCmd @InvokeSQLCmdParams
                Write-Output "Clutter info was updated"
            }
            catch {
                Write-Warning "Unable to update clutter info in DB"
            }
        }
    }

    Write-Output "***************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count