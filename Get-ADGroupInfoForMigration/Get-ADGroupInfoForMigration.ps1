# Get-ADGroupInfoForMigration.ps1
# Written by: Jeff Brusoe
# Last Update: October 6, 2021
#
# This file collects AD group information needed for
# the AD migration project.

[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]$OutputFilePath = (Get-HSCNetworkLogPath) +
                                "4ADMigrationProject\"
)

try {
    Set-HSCEnvironment -ErrorAction Stop

    $GroupLog = $OutputFilePath + "GroupLog\" +
                    (Get-Date -Format yyyy-MM-dd) +
                    "-GroupInfo.csv"

    New-Item -ItemType File -Path $GroupLog -Force
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Getting AD group list"
    $ADGroups = Get-ADGroup -Filter * -Properties *
}
catch {
    Write-Warning "Unable to pull AD group info"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($ADGroup in $ADGroups) {
    Write-Output $("Current Group: " + $ADGroup.Name)

    $GroupDN = $ADGroup.DistinguishedName
    Write-Output "Group DN:"
    Write-Output $GroupDN

    $ParentOU = $GroupDN.substring($GroupDN.indexOf(",") + 1)
    Write-Output "Parent OU: $ParentOU"

    [PSCustomObject]@{
        GroupName = $ADGroup.Name
        GroupSamAccountName = $ADGroup.SamAccountName
        GroupDescription = $ADGroup.Description
        GroupCategory = $ADGroup.GroupCategory
        GroupScope = $ADGroup.GroupScope
        GroupSID = $ADGroup.objectSID
        SIDHIstory = $ADGroup.SIDHistory -join ";"
        GroupOU = $ParentOU
        GroupDN = $GroupDN
    } | Export-Csv $GroupLog -NoTypeInformation -Append

    Write-Output "******************************"

}

Invoke-HSCExitCommand -ErrorCount $Error.Count