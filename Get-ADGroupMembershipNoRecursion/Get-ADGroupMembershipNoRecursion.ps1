# Get-ADGroupMembershipNoRecursion.ps1
# Written by: Jeff Brusoe
# Last Updated: October 5, 2021
#
# Gets information about groups that have groups as members
# insteading of using the -Recursive switch

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$OutputFilePath = (Get-HSCNetworkLogPath) +
                                "4ADMigrationProject\"
)

try {
    Set-HSCEnvironment -ErrorAction Stop
}
catch {
    Write-Warning "Unable to configure PS environement"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    $ADGroups = Get-ADGroup -Filter * -ErrorAction Stop -Properties *
}
catch {
    Write-Warning "Unable to get group list"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($ADGroup in $ADGroups)
{
    Write-Output $("Group Name: " + $ADGroup.Name)
    $GroupMembershipLog = $OutputFilePath + "GroupMembershipLog\" +
                            (Get-Date -Format yyyy-MM-dd) + "-Logs\" +
                            $ADGroup.Name + ".csv"

    $GroupMembershipLog = $GroupMembershipLog -Replace "'",""
    $GroupMembershipLog = $GroupMembershipLog -Replace " ",""
    Write-Output "Group Membership Log: $GroupMembershipLog"

    New-Item -ItemType File -Path $GroupMembershipLog -Force

    Get-ADGroupMember -Identity $ADGroup.DistinguishedName -ErrorAction Stop |
        Export-Csv -Path $GroupMembershipLog -NoTypeInformation

    Write-Output "***************************"
}