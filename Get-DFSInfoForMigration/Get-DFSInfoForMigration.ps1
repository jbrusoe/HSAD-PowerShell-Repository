# Get-DFSInfoForMigration.ps1
# Written by: Jeff Brusoe
# Last Updated: October 22, 2021
#
# This file backs up the DFS info which is needed
# for the AD migration project.

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$OutputFilePath = (Get-HSCGitHubRepoPath) +
                                "4ADMigrationProject\"
)

try {
    Set-HSCEnvironment -ErrorAction Stop

    $DFSLog = $OutputFilePath + "DFSSummary\" +
                (Get-Date -format "yyyy-MM-dd") +
                "-DFSSummaryLog.csv"

    New-Item $DFSLog -ItemType File -Force -ErrorAction Stop
}
catch {
    Write-Warning "Unable to configure PS environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Getting list of DFS Paths"
    $DFSPaths = Get-DFSNRoot -ErrorAction Stop

    Write-Output "`nDFS Paths:"
    Write-Output $DFSPaths

    $DFSPaths | Export-Csv $DFSLog -NoTypeInformation -Force -ErrorAction Stop
}
catch {
    Write-Warning "Unable to get DFS Paths"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}


foreach ($DFSPath in $DFSPaths)
{
    Write-Output $("Current DFS Path: " + $DFSPath.Path)

    Write-Output "************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count