# Get-ADGroupMemberCount.ps1
# Written by: Jeff Brusoe
# Last Updated: October 4, 2021
#
# This file records the number of members (non-recursive search)
# in a group for the AD migration project.

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$OutputFilePath = (Get-HSCGitHubRepoPath) +
                                "4ADMigrationProject\"
)

try {
    Set-HSCEnvironment -ErrorAction Stop

    $GroupCountLog = $OutputFilePath + "GroupCountInfo\" +
                        (Get-Date -Format yyyy-MM-dd) +
                        "-GroupCount.csv"

    New-Item -ItemType File -Path $GroupCountLog -ErrorAction Stop -Force
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    $ADGroups = Get-ADGroup -Filter * -ErrorAction Stop
}
catch {
    Write-Warning "Unable to get list of AD Groups"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($ADGroup in $ADGroups) {
    Write-Output $("Current Group: " + $ADGroup.Name)

    $ADGroupCountObject = [PSCustomObject]@{
        GroupName = $ADGroup.Name
        SamAccountName = $ADGroup.SamAccountName
    }

    try {
        $GetADGroupMemberParams = @{
            Identity = $ADGroup.DistinguishedName
            ErrorAction = "Stop"
        }

        $ADGroupCount = (Get-ADGroupMember @GetADGroupMemberParams | Measure-Object).Count

        $ADGroupCountObject = [PSCustomObject]@{
            GroupName = $ADGroup.Name
            SamAccountName = $ADGroup.SamAccountName
            GroupCount = $ADGroupCount
        }
    }
    catch {
        Write-Warning "Error Getting AD Group Count"

        $ADGroupCountObject = [PSCustomObject]@{
            GroupName = $ADGroup.Name
            SamAccountName = $ADGroup.SamAccountName
            GroupCount = "Error Getting Group Count"
        }
    }

    $ADGroupCountObject
    $ADGroupCountObject | Export-Csv $GroupCountLog -NoTypeInformation -Append

    Write-Output "******************************"
}