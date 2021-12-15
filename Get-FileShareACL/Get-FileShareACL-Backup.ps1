# Get-FileShareACL.ps1
# Written by: Jeff Brusoe
# Last Updated: November 4, 2021
#
# This file creates a list of all directories in the AD
# file shares. This is needed as part of the AD migration project.
#
# https://github.com/PowerShell/PowerShell/issues/11817

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$DirectoryCSVPath = (Get-HSCGitHubLogPath) +
                                    "4ADMigrationProject\FileShareDirectory\",

    [int]$NumberOfThreads = 10
)

try {
    Set-HSCEnvironment -ErrorAction Stop

    if ((Get-HSCPowerShellVersion) -ge 7) {
        Write-Output "Correct PowerShell Version"
    }
    else {
        Write-Output "Incorrect PowerShell Version"
        throw
    }

    Write-Output "Number of Major Threads: $NumberOfMajorThreads"
    Write-Output "Number of Minor Threads: $NumberOfMinorThreads"

    Write-Output "Start Time:"
    Get-Date
}
catch {
    Write-Warning "Unable to configure PS environment"
    Invoke-HSCExitCommand -ErrorAction Stop
}

try {
    Write-Output "Getting list of directory CSV files"

    $NewestFileShareDirectory = Get-ChildItem $DirectoryCSVPath -ErrorAction Stop -Directory |
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
$OutputFilePath = (Get-HSCGitHubLogPath) +
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
        #Write-Output $("Inside Nested Loop - Output FIle Name: " + $using:OutputFileName)
        Write-Output $("Inside Nested Loop - Output FIle Name: " + $OutputFileName)
        
        #Get-Acl $Directory | Export-Csv  $using:OutputFileName -NoTypeInformation -Append
        Get-Acl $Directory | Export-Csv  $OutputFileName -NoTypeInformation -Append
    } #-ThrottleLimit $using:NumberOfMinorThreads

    Write-Output "*********************************"
} -ThrottleLimit $NumberOfThreads

Write-Output ("Finish Time:")
Get-Date

Invoke-HSCExitCommand -ErrorCount $Error.Count