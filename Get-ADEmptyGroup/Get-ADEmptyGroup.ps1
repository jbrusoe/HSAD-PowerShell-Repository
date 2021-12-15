# Get-ADEmptyGroup.ps1
# Written by: Jeff Brusoe
# Last Updated: December 2, 2021
#
# Gets a list of empty AD groups for the
# AD migration project

[CmdletBinding()]
param (
    [string]$OutputLogFile = (Get-HSCNetworkLogPath) +
                             "4ADMigrationProject\GroupEmpty\" +
                             (Get-Date -Format yyyy-MM-dd) +
                             "-EmptyGroups.csv"

)
try {
    Set-HSCEnvironment -ErrorAction Stop
 
    New-Item $OutputLogFile -ItemType File -Force
}
catch {
    Write-Warning "Unable to configure PowerShell environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Getting list of AD Groups"

    $GetADGroupParams = @{
        Filter = "*"
        Properties = "Members"
        ErrorAction = "Stop"
    }

    $ADGroups = Get-ADGroup @GetADGroupParams
}
catch {
    Write-Warning "Unable to get list of AD groups"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($ADGroup in $ADGroups)
{
    Write-Output "Current Group: $($ADGroup.Name)"

    $NumberOfMembers = ($ADGroup.Members | Measure-Object).Count
    Write-Output "Number of Members: $NumberOfMembers"

    if ($NumberOfMembers -eq 0) {
        Write-Output "Group is empty"
        $ADGroup |
            Export-Csv $OutputLogFile -Append -NoTypeInformation -ErrorAction Stop
    }

    Write-Output "*********************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count