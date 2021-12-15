# Get-FileShareDirectory.ps1
# Written by: Jeff Brusoe
# Last Updated: November 10, 2021
#
# This file creates a list of all directories in the AD
# file shares. This is needed as part of the AD migration project.
#
# The issue of accessing variables inside a nested loop is
# discussed here:
# https://github.com/PowerShell/PowerShell/issues/11817

[CmdletBinding()]
param(
    [ValidateRange(1,10)]
    [int]$NumberOfMajorThreads = 6,

    [ValidateRange(1,40)]
    [int]$NumberOfMinorThreads = 25
)

try {
    Write-Verbose "Configuring environment"

    Set-HSCEnvironment -ErrorAction Stop
    Test-HSCPowerShell7 -ErrorAction Stop

    $FileShareInfoCSV = "FileShares.csv"

    $OutputFilePath = (Get-HSCNetworkLogPath) +
                            "4ADMigrationProject\FileShareDirectory\" +
                            (Get-Date -Format yyyy-MM-dd) + "-Logs\"

    Write-Output "Output file path: $OutputFilePath"

    Write-Output "Number of Major Threads: $NumberOfMajorThreads"
    Write-Output "Number of Minor Threads: $NumberOfMinorThreads"

    Write-Output $("Start Time: " + (Get-Date))
}
catch {
    Write-Warning "Unable to configure PS environment"
    Invoke-HSCExitCommand -ErrorAction Stop
}

try {
    Write-Output "Generating list of file share paths"
    Write-Output "File Share Path: $FileShareInfoCSV"

    $FileShares = Import-Csv $FileShareInfoCSV -ErrorAction Stop
}
catch {
    Write-Warning "Unable to open file share CSV file."
    Invoke-HSCExitCommand -ErrorAction Stop
}

Write-Output "Beginning to generate directory paths"
[string]$FileName = $null

$FileShares | ForEach-Object -Parallel {
    $FileShare = $_.FileShare
    Write-Output "Current File Share: $FileShare"
    Get-Date

    $OutputFilePath = $using:OutputFilePath
    if (!(Test-Path $FileShare)) {
        Write-Warning "File Path Doesn't Exist"
        Write-Output "*********************************"

        continue
    }
    else {
        $FileName = $FileShare.Split('\\')[1]
        $FileName = $FileName.Replace("$", "DS")
        $FileName = $FileName.Replace('\',"-")
        $FileName = $FileName.Replace(' ',"")

        Write-Output "FileName: $FileName"

        $OutputFile = $using:OutputFilePath + "$FileName"
        Write-Output $OutputFile
    }

    New-Item -Path $($OutputFile + ".csv") -Type File -Force

    $RootLevelFolders = Get-ChildItem $FileShare -Directory
    $RootLevelFolders |
        Export-Csv $($OutputFile + ".csv") -Append -NoTypeInformation

    Write-Output "Root Level Folders:"
    $RootLevelFolders

    $RootLevelFolders | ForEach-Object -Parallel {
            Write-Output $("Currently Trying: " + $_.FullName)

            $FolderName = $_.Name.Replace(' ',"")
            $FolderName = $FolderName.Replace("$","DS")

            $OutputFile = $using:OutputFilePath +
                            $using:FileName +
                            "-" + $FolderName + ".csv"

            New-Item -Path $OutputFile -Type File -Force

            Write-Output "Output File: $OutputFile"
            Get-ChildItem $_.FullName -Directory -Recurse |
                Export-Csv $OutputFile -Force -NoTypeInformation

        } -ThrottleLimit 25

    Write-Output "Done with fileshare: $FileShare"
    Get-Date

    Write-Output "*********************************"
} -ThrottleLimit $NumberOfMajorThreads

Write-Output $("Finish Time: " + (Get-Date))

Invoke-HSCExitCommand -ErrorCount $Error.Count