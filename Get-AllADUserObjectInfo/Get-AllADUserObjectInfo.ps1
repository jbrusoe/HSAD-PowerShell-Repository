# Get-AllADUserObjectInfo.ps1
# Written by: Jeff Brusoe
# Last Updated: September 20, 2021
#
# Purpose: This script will retrieve all AD user objects
# and their properties.

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$OutputFilePath = (Get-HSCGitHubRepoPath) +
                                "4ADMigrationProject\"
)

try {
    Set-HSCEnvironment -ErrorAction Stop

    $ADUserLogFile = $OutputFilePath + "UserAllInfoUnfilterd\" +
                        (Get-Date -Format yyyy-MM-dd) +
                        ("-UserAllInfoUnfiltered.csv")

    $RequestedADInfoLogFile = $OutputFilePath + "UserAllInfo\" +
                                (Get-Date -Format yyyy-MM-dd) +
                                "-UserAllInfo.csv"

    New-Item -ItemType File -Path $ADUserLogFile -Force
    New-Item -ItemType File -Path $RequestedADInfoLogFile -Force
}
catch {
    Write-Warning "Unable to configure PS environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    $ADOrgUnits = Get-ADOrganizationalUnit -Filter * -ErrorAction Stop

    Write-Output $("AD Org Unit Count: " + $ADOrgUnits.Count)
}
catch {
    Write-Warning "Unable to generate list of AD org units"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($ADOrgUnit in $ADOrgUnits) {
    Write-Output $("AD Org Unit: " + $ADOrgUnit.Name)

    #All AD Properties
    try {
        $GetADUserParams = @{
            Filter = "*"
            SearchBase = $ADOrgUnit.DistinguishedName
            SearchScope = "OneLevel"
            Properties = "*"
            ErrorAction = "Stop"
        }

        $ADUsers = Get-ADUser @GetADUserParams

        try {
            $ExportCSVParams = @{
                Path = $ADUserLogFile
                NoTypeInformation = $true
                Append = $true
                Force = $true
                ErrorAction = "Stop"
            }

            $ADUsers |
                Export-Csv @ExportCSVParams
        }
        catch {
            Write-Warning "Unable to generate list of AD Users"
        }
    }
    catch {
        Write-Warning "Unable to generate list of AD users for this org unit"
    }

    #All AD Info being asked for
    foreach ($ADUser in $ADUsers)
    {
        $GetPasswordPolicyParams = @{
            Identity = $ADUser.SamAccountName
            ErrorAction = "Stop"
        }

        $ADUserPasswordPolicy = Get-ADUserResultantPasswordPolicy @GetPasswordPolicyParams

        try
        {
            $GetPasswordPolicyParams = @{
                Identity = $ADUser.SamAccountName
                ErrorAction = "Stop"
            }
    
            $ADUserPasswordPolicy = Get-ADUserResultantPasswordPolicy @GetPasswordPolicyParams

            if (($ADUser.AccountExpires -eq 0) -OR
                ($ADUser.AccountExpires -eq 9223372036854775807)) {
                $AccountExpires = "NotSet"
            }
            else {
                $AccountExpires = [datetime]::FromFileTime($ADUser.AccountExpires)
            }

            if (($ADUser.lastLogon -eq 0) -OR 
                ([string]::IsNullOrEmpty($ADUser.LastLogon))) {
                $LastLogon = "NotSet"
            }
            else {
                $LastLogon = [datetime]::FromFileTime($ADUser.LastLogon)
            }

            if (($ADUser.lastLogonTimestamp -eq 0) -OR
                ([string]::IsNullOrEmpty($ADUser.LastLogonTimestamp))) {
                $LastLogonTimestamp = "NotSet"
            }
            else {
                $LastLogonTimestamp = [datetime]::FromFileTime($ADUser.LastLogonTimestamp)
            }

            if (($ADUser.pwdLastSet -eq 0) -OR
                ([string]::IsNullOrEmpty($ADUser.PwdLastSet))) {
                $PwdLastSet = "NotSet"
            }
            else {
                $PwdLastSet = [datetime]::FromFileTime($ADUser.PwdLastSet)
            }

            $ADUserRequestedProperties = [PSCustomObject]@{
                SamAccountName = $ADUser.SamAccountName
                UserPrincipalName = $ADUser.UserPrincipalName
                whenCreated = $ADUser.whenCreated
                whenChanged = $ADUser.whenChanged
                AdminCount = $ADUser.adminCount
                ExtensionAttribute1 = $ADUser.extensionAttribute1
                ExtensionAttribute2 = $ADUser.extensionAttribute2
                ExtensionAttribute3 = $ADUser.extensionAttribute3
                ExtensionAttribute4 = $ADUser.extensionAttribute4
                ExtensionAttribute5 = $ADUser.extensionAttribute5
                ExtensionAttribute6 = $ADUser.extensionAttribute6
                ExtensionAttribute7 = $ADUser.extensionAttribute7
                ExtensionAttribute8 = $ADUser.extensionAttribute8
                ExtensionAttribute9 = $ADUser.extensionAttribute9
                ExtensionAttribute10 = $ADUser.extensionAttribute10
                ExtensionAttribute11 = $ADUser.extensionAttribute11
                ExtensionAttribute12 = $ADUser.extensionAttribute12
                ExtensionAttribute13 = $ADUser.extensionAttribute13
                ExtensionAttribute14 = $ADUser.extensionAttribute14
                ExtensionAttribute15 = $ADUser.extensionAttribute15
                Enabled = $ADUser.Enabled
                PasswordExpired = $ADUser.PasswordExpired
                PasswordLastSet = $ADUser.PasswordLastSet
                PasswordNeverExpires = $ADUser.PasswordNeverExpires
                PasswordNotRequired = $ADUser.PasswordNotRequired
                lastLogon = $LastLogon
                LastLogonDate = $ADUser.LastLogonDate
                lastLogonTimeStamp  = $LastLogonTimeStamp
                pwdLastSet = $PwdLastSet
                AccountExpirationDate = $ADUser.AccountExpirationDate
                accountExpires = $AccountExpires
                AccountLockoutTime = $ADUser.AccountLockoutTime
                memberOf = $ADUser.memberOf -join ";"
                objectSID = $ADUser.objectSID
                SIDHistory = $ADUser.SIDHistory -join ";"
                ComplexityEnabled = $ADUserPasswordPolicy.ComplexityEnabled
                LockoutDuration = $ADUserPasswordPolicy.LockoutDuration
                LockoutObservationWindow = $ADUserPasswordPolicy.LockoutObservationWindow
                LockoutThreshold = $ADUserPasswordPolicy.LockoutThreshold
                MaxPasswordAge = $ADUserPasswordPolicy.MaxPasswordAge
                MinPasswordAge = $ADUserPasswordPolicy.MinPasswordAge
                MinPasswordLength = $ADUserPasswordPolicy.MinPasswordLength
                PasswordHistoryCount = $ADUserPasswordPolicy.PasswordHistoryCount
                DistinguishedName = $ADUser.DistinguishedName
            }

            $ADUserRequestedProperties
            $ADUserRequestedProperties |
                Export-Csv -Path $RequestedADInfoLogFile -NoTypeInformation -Append -Force
        }
        catch {
            Write-Warning "Unable to generate list of AD users for this org unit"
        }
    }

    Write-Output "***********************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count