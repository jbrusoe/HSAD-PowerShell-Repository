# Get-ADUserSPN.ps1
# Writen by: Jeff Brusoe
# Last Updated: September 20, 2021
#
# Purpose: This file backs up the SPN of
# users who have non-null values for this attribute.

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$OutputFilePath = (Get-HSCGitHubRepoPath) +
                                "4ADMigrationProject\"
)

try {
    Set-HSCEnvironment -ErrorAction Stop

    $SPNLog = $OutputFilePath + "UserSPN\" +
                (Get-Date -format "yyyy-MM-dd") +
                "-SPNBackupLog.csv"

    New-Item $SPNLog -ItemType File -Force -ErrorAction Stop
}
catch {
    Write-Warning "Unable to configure PS environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$ADUserProperties = @(
                "SamAccountName",
                "userPrincipalName",
                "whenCreated",
                "whenChanged"
                "servicePrincipalName",
                "distinguishedName"
            )

try {
    Write-Output "Getting list of AD Users with non-null SPNs"

    $LDAPFilter = "(servicePrincipalName=*)"

    $GetADUserParams = @{
        LDAPFilter = $LDAPFilter
        Properties = $ADUserProperties
        ErrorAction = "Stop"
    }

    $ADUsers = Get-ADUser @GetADUserParams

    foreach ($ADUser in $ADUsers) {
        Write-Output $("Current AD User: " + $ADUser.SamAccountName)

        $ADUserInfoObject = [PSCustomObject]@{
            SamAccountName = $ADUser.SamAccountName
            UserPrincipalName = $ADUser.userPrincipalName
            AccountCreationDate = $ADUser.whenCreated
            AccountChangeDate = $ADUser.whenChanged
            ServicePrincipalName = $ADUser.servicePrincipalName -join ";"
            DistinguishedName = $ADUser.distinguishedName
        }

        $ADUserInfoObject |
            Export-Csv $SPNLog -NoTypeInformation -Append -ErrorAction Stop

        Write-Output "**************************"
    }
}
catch {
    Write-Warning "Unablle to get list of users with SPNs"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count