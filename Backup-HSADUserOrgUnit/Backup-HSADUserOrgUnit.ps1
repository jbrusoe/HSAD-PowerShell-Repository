#Backup-HSADUserOrgUnit.ps1
#Written by: Jeff Brusoe
#Last Updated: August 2, 2021

[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]$OutputDirectory = "$PSScriptRoot\OULogs\",

    [ValidateNotNullOrEmpty()]
    [string]$ADMigrationPath = (Get-HSCGitHubRepoPath) +
                                "4ADMigrationProject\"
)

try {
    Write-Output "Configuring Environment"

    Set-HSCEnvironment -ErrorAction Stop

    $OutputFile = $OutputDirectory +
                    (Get-Date -Format yyyy-MM-dd) +
                    "-ADUserOrgUnits.csv"
    New-Item -Path $OutputFile -ItemType File -Force -ErrorAction Stop

    $ADMigrationFile = $ADMigrationPath + "UserOU\" +
                        (Get-Date -Format yyyy-MM-dd) +
                        "-ADUserOrgUnits.csv"
    New-Item -Path $ADMigrationFile -ItemType File -Force -ErrorAction Stop
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorAction Stop
}

try {
    Write-Output "Getting AD Org Units"

    $ADOrgUnits = Get-ADOrganizationalUnit -Filter * -ErrorAction Stop
}
catch {
    Write-Warning "Unable to get list of AD org units"
    Invoke-HSCExitCommand -ErrorAction Stop
}

Write-Verbose "Looping through AD Org Units"
foreach ($ADOrgUnit in $ADOrgUnits)
{
    $GetADUserUserParams = @{
        Filter = "*"
        SearchBase = $ADOrgUnit.DistinguishedName
        SearchScope = "OneLevel"
        ErrorAction = "Stop"
        Properties = @(
            "whenCreated",
            "whenChanged"
        )
    }

    try {
        $ADUsers = Get-ADUser @GetADUserUserParams

        foreach ($ADUser in $ADUsers)
        {
            try {
                $ParentContainer = $ADUser |
                    Get-HSCADUserParentContainer -ErrorAction Stop

                Write-Verbose "Parent OU: $ParentContainer"
            }
            catch {
                Write-Warning "Unable to get user's Parent OU"
                continue
            }

            $ADUserOrgUnitInfo = [PSCustomObject]@{
                SamAccountName = $ADUser.SamAccountName
                UserPrincipalName = $ADUser.UserPrincipalName
                AccountCreationDate = $ADUser.whenCreated
                AccountChangedDate = $ADUser.whenChanged
                OrgUnit = $ParentContainer
                DistinguishedName = $ADUser.DistinguishedName
            }

            $ADUserOrgUnitInfo

            $ADUserOrgUnitInfo |
                Export-Csv $OutputFile -NoTypeInformation -Append -ErrorAction Stop 
            $ADUserOrgUnitInfo |
                Export-Csv $ADMigrationFile -NoTypeInformation -Append -ErrorAction Stop
        }
    }
    catch {
        Write-Warning "Unable to get list of AD users"
        continue
    }
}

Invoke-HSCExitCommand -ErrorCount $Error.Count