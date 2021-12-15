# Get-ShareInformation.ps1
# Written by: Jeff Brusoe
# Last Updated: August 30, 2021

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$SharePath = "C:\Users\Jeff\Documents\GitHub\",

    [ValidateNotNullOrEmpty()]
    [string[]]$UsersToSearchFor = @(
                                 "cls00001",
                                 "sjm00019",
                                 "drg0025",
                                 "aadyer",
                                 "smdaily"
                                ),

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

Write-Output "Search Path: $SharePath"

[string[]]$GroupsToSearchFor = @()
foreach ($UserToSearchFor in $UsersToSearchFor)
{
    Write-Output "Getting groups for: $UserToSearchFor"

    $SQLQuery = "Select * from $DBTableName where " + 
                            "SamAccountName = '" + $UserToSearchFor + "'"
    Write-Output "SQL Query: $SQLQuery"

    $InvokeSQLCmdParams["Query"] = $SQLQuery
    $GroupInformation = Invoke-SQLCmd @InvokeSQLCmdParams

    $Groups = $GroupInformation.Groups
    foreach ($Group in $Groups) {
        #Write-Output "Adding: $Group"
        $GroupsToSearchFor += $Group -split ";"
    }
}

Write-Output "`nCleaning up list of groups to search for"
$GroupsToSearchFor = $GroupsToSearchFor | Sort-Object -Unique
$GroupsToSearchFor = $GroupsToSearchFor | Get-Unique

Write-Output "Groups to Search For:"
Write-Output $GroupsToSearchFor


$Directories = Get-ChildItem -Path $SharePath -Directory

foreach ($Directory in $Directories)
{
    $DirectoryAcl = Get-Acl $Directory.FullName

    $AccessRights = $DirectoryAcl.Access
    $UsersWithRights = @()
    foreach ($AccessRight in $AccessRights) {

        $SamAccountName = $AccessRight.IdentityReference.Value
        $SamAccountName = $SamAccountName -Replace "HS\\",""

        if ($UsersToSearchFor -Contains $SamAccountName) {
            if ($UserWithRights.Count -eq 0) {
                Write-Output $("Current Directory: " + $Directory.FullName)
            }

            Write-Output "User with rights: $SamAccountName"
            $UsersWithRights += $SamAccountName

            continue
        }
        elseif ($GroupsToSearchFor -Contains $SamAccountName) {
            if ($UserWithRights.Count -eq 0) {
                Write-Output $("Current Directory: " + $Directory.FullName)
            }
        }

        Write-Output "User with rights: $SamAccountName"
        $UsersWithRights += $SamAccountName
    }

    if ($UsersWithRights.Count -gt 0) {
        $DirectorySize = (Get-ChildItem $Directory.FullName -Recurse -ErrorAction "SilentlyContinue" | Measure-Object Length -Sum).Sum
        $DirectorySize = $DirectorySize/1GB
        $DirectorySize = [math]::Round($DirectorySize, 3)
        Write-Output $("Size: $DirectorySize GB")
    }

    if ($UsersWithRights.Count -gt 0) {
        Write-Output "************************"
    }
}
