# Get-FileShareICACLS.ps1
# Written by: Jeff Brusoe
# Last Updated: November 10, 2021
#
# This file uses the MS utility icacls.exe to generate
# a list of all the ACLs in the FileShares.csv file.

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$FileShareInfoCSV = "FileShares.csv",

    [ValidateNotNullOrEmpty()]
    [string]$OutputFilePath = (Get-HSCNetworkLogPath) +
                                "4ADMigrationProject\FileShareLogs\",

    [int]$NumberOfThreads = 6
)

try {
    Set-HSCEnvironment -ErrorAction Stop

    Write-Output "Output File Path: $OutputFilePath"
    Write-Output $("Start Time: " + (Get-Date))
}
catch {
    Write-Warning "Unable to configure PS environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    $FileShares = Import-Csv $FileShareInfoCSV -ErrorAction Stop
}
catch {
    Write-Warning "Unable to import file share file"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$FileShares | ForEach-Object  -Parallel {
    $FileShare = $_.FileShare
    Write-Output "Current file share: $FileShare"

    $OutputFilePath =  $using:OutputFilePath +
                        "\FileShareICACLS\" +
                        (Get-Date -Format "yyyy-MM-dd") +
                        "-Logs\"

    $FileName = $FileShare.Split('\\')[1]
    $FileName = $FileName.Replace("$", "DS")
    $FileName = $FileName.Replace('\',"-")
    $FileName = $FileName.Replace(' ',"")

    $OutputFileName = $OutputFilePath + $FileName + ".txt"
    Write-Output "Output File Name: $OutputFileName"

    New-Item $OutputFileName -ItemType File -Force -ErrorAction Stop
    Write-Output "Created log file"

    icacls.exe $FileShare /save $OutputFileName /t /c

    Write-Output "**************************"
} -ThrottleLimit $NumberOfThreads

Write-Output $("End Time: " + (Get-Datelse))

Invoke-HSCExitCommand -ErrorCount $Error.Count