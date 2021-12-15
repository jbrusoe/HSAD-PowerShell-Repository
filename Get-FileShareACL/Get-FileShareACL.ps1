# Get-FileShareACL.ps1
# Written by: Jeff Brusoe
# Last Updated: November 19, 2021
#
# This file creates a list of all directories in the AD
# file shares. This is needed as part of the AD migration project.

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$DirectoryCSVPath = (Get-HSCNetworkLogPath) +
                                    "4ADMigrationProject\FileShareDirectory\",

    [int]$NumberOfThreads = 10
)

try {
    Write-Verbose "Configuring PowerShell environment"
    Set-HSCEnvironment -ErrorAction Stop
    Test-HSCPowerShell7 -ErrorAction Stop

    Write-Output "Number of Major Threads: $NumberOfThreads"

    Write-Output $("Start Time: " + (Get-Date))
}
catch {
    Write-Warning "Unable to configure PS environment"
    Invoke-HSCExitCommand -ErrorAction Stop
}

try {
    Write-Output "Getting list of directory CSV files"

    $GetChildItemsParams = @{
        Path = $DirectoryCSVPath
        Directory = $true
        ErrorAction = "Stop"
    }
    $NewestFileShareDirectory = Get-ChildItem @GetChildItemsParams |
                                    Sort-Object CreationTime -Descending |
                                    Select-Object -First 1

    $DirectoryCSVs = Get-ChildItem $NewestFileShareDirectory
}
catch {
    Write-Warning "Unable to open file share CSV file."
    Invoke-HSCExitCommand -ErrorAction Stop
}

Write-Output "Beginning to generate ACL files"

[string]$OutputFileName = $null
$OutputFilePath = (Get-HSCNetworkLogPath) +
                    "4ADMigrationProject\FileShareACL\" +
                    (Get-Date -Format "yyyy-MM-dd") +
                    ("-Logs\")

$DirectoryCSVs | ForEach-Object -Parallel {
    Write-Output ("Current CSV: " + $_.FullName)

    $Directories = Import-Csv $_.FullName

    $FileName = $_.Name
    $OutputFileName = $using:OutputFilePath + $FileName
    $OutputFileName = $OutputFileName.Replace(".csv", "")
    $OutputFileName = $OutputFileName + "-ACL.csv"
    Write-Output "Output File Name - Outer Loop: $OutputFileName"

    New-Item $OutputFileName -ItemType File -Force -ErrorAction Stop

    $Directories | ForEach-Object {
        $Directory = $_.FullName
        Write-Output "Current Directory: $Directory"

        Get-Acl $Directory |
            Export-Csv  $OutputFileName -NoTypeInformation -Append
    }

    Write-Output "*********************************"
} -ThrottleLimit $NumberOfThreads

Write-Output $("Finish Time: " + (Get-Date))

Invoke-HSCExitCommand -ErrorCount $Error.Count