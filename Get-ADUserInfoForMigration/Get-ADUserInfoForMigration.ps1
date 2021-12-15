# Get-ADUserInfoForMigration.ps1
# Written by: Jeff Brusoe
# Last Updated: September 24, 2021

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$OutputFilePath = (Get-HSCNetworkLogPath) +
                                "4ADMigrationProject\"
)

try {
    Set-HSCEnvironment -ErrorAction Stop

    $AdminCountLog = $OutputFilePath + "UserAdminCount\" +
                        (Get-Date -format "yyyy-MM-dd") +
                        "-AdminCount.csv"

    $EnabledLog = $OutputFilePath + "UserEnabled\" +
                        (Get-Date -format "yyyy-MM-dd") +
                        "-UserEnabled.csv"

    $SIDInfoLog = $OutputFilePath + "UserSIDInfo\" +
                        (Get-Date -format "yyyy-MM-dd") +
                        "-UserSIDInfo.csv"

    $PasswordInfoLog = $OutputFilePath + "UserPasswordInfo\" +
                        (Get-Date -format "yyyy-MM-dd") +
                        "-UserPasswordInfo.csv"

    $PasswordPolicyLog = $OutputFilePath + "UserPasswordPolicy\" +
                            (Get-Date -format "yyyy-MM-dd") +
                            "-UserPasswordPolicy.csv"

    $GroupMembershipLog = $OutputFilePath + "UserGroupMembership\" +
                            (Get-Date -format "yyyy-MM-dd") +
                            "-UserGroupMembership.csv"

    New-Item -ItemType File -Path $AdminCountLog -Force -ErrorAction Stop
    New-Item -ItemType File -Path $EnabledLog -Force -ErrorAction Stop
    New-Item -ItemType File -Path $SIDInfoLog -Force -ErrorAction Stop
    New-Item -ItemType File -Path $PasswordInfoLog -Force -ErrorAction Stop
    New-Item -ItemType File -Path $PasswordPolicyLog -Force -ErrorAction Stop
    New-Item -ItemType File -Path $GroupMembershipLog -Force -ErrorAction Stop
}
catch {
    Write-Warning "Unable to configure AD environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Getting list of AD Org Units"
    $ADOrgUnits = Get-ADOrganizationalUnit -Filter * -ErrorAction Stop
}
catch {
    Write-Warning "Unable to get list of AD Org Units"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($ADOrgUnit in $ADOrgUnits)
{
    $ADOrgUnitName = $ADOrgUnit.Name
    $ADOrgUnitDN = $ADOrgUnit.DistinguishedName

    Write-Output "Current AD Org Unit: $ADOrgUnitName"

    $GetADUserParams = @{
        Filter = "*"
        SearchBase = $ADOrgUnitDN
        SearchScope = "OneLevel"
        ErrorAction = "Stop"
        Properties = @(
            "adminCount",
            "objectSID",
            "SIDHistory",
            "PasswordExpired",
            "PasswordLastSet",
            "PasswordNeverExpires",
            "PasswordNotRequired",
            "AccountExpirationDate",
            "AccountExpires",
            "AccountLockoutTime",
            "whenCreated",
            "whenChanged",
            "memberOf",
            "pwdLastSet"
        )
    }

    try {
        $ADUsers = Get-ADUser @GetADUserParams
    }
    catch {
        Write-Warning "Unable to search org unit"
    }

    Write-Output "Getting User Information..."

    foreach ($ADUser in $ADUsers) {
        Write-Output $("Current SAM AccountName: " + $ADUser.SamAccountName)

        try {
            Write-Output "Generating Password Policy Log Information"

            $GetPasswordPolicyParams = @{
                Identity = $ADUser.SamAccountName
                ErrorAction = "Stop"
            }

            $PasswordPolicy = Get-ADUserResultantPasswordPolicy @GetPasswordPolicyParams

            $ADUserPasswordPolicy = [PSCustomObject]@{
                SamAccountName = $ADUser.SamAccountName
                UserPrincipalName = $ADUser.UserPrincipalName
                AccountCreationDate = $ADUser.whenCreated
                AccountChangeDate = $ADUser.whenChanged
                ComplexityEnabled = $PasswordPolicy.ComplexityEnabled
                LockoutDuration = $PasswordPolicy.LockoutDuration
                LockoutObservationWindow = $PasswordPolicy.LockoutObservationWindow
                LockoutThreshold = $PasswordPolicy.LockoutThreshold
                MaxPasswordAge = $PasswordPolicy.MaxPasswordAge
                MinPasswordAge = $PasswordPolicy.MinPasswordAge
                MinPasswordLength = $PasswordPolicy.MinPasswordLength
                PasswordHistoryCount = $PasswordPolicy.PasswordHistoryCount
                DistinguishedName = $ADUser.DistinguishedName
            }
    
            $ADUserPasswordPolicy
            $ADUserPasswordPolicy |
                Export-Csv $PasswordPolicyLog -NoTypeInformation -Append -ErrorAction Stop
        }
        catch {
            Write-Warning "Unable to get password policy"
        }
        

        try {
            Write-Output "Getting SID & SID History"

            $SIDHistory = $ADUser.SIDHistory -join ";"
            $SIDHistoryObject = [PSCustomObject]@{
                SamAccountName = $ADUser.SamAccountName
                UserPrincipalName = $ADUser.UserPrincipalName
                AccountCreationDate = $ADUser.whenCreated
                AccountChangeDate = $ADUser.whenChanged
                SID = $ADUser.objectSID
                SIDHistory = $SIDHistory
                DistinguishedName = $ADUser.DistinguishedName
            }
    
            $SIDHistoryObject
            $SIDHistoryObject | Export-Csv $SIDInfoLog -NoTypeInformation -Append -ErrorAction Stop
        }
        catch {
            Write-Warning "Unable to get SID & SID History"
        }
       

        try {
            #Account & Password Info
            Write-Output $("Account Expires: " + $ADUser.AccountExpires)

            #http://www.rlmueller.net/AccountExpires.html
            #These two values are used to indicate that the account
            #expiration field hasn't been set.
            if (($ADUser.AccountExpires -eq 0) -OR
                ($ADUser.AccountExpires -eq 9223372036854775807)) {
                $AccountExpires = "NotSet"
            }
            else {
                $AccountExpires = [datetime]::FromFileTime($ADUser.AccountExpires)
            }

            $ADUserObject = [PSCustomObject]@{
                SamAccountName = $ADUser.SamAccountName
                UserPrincipalName = $ADUser.UserPrincipalName
                AccountCreationDate = $ADUser.whenCreated
                AccountChangeDate = $ADUser.whenChanged
                PasswordExpired = $ADUser.PasswordExpired
                PasswordLastSet = $ADUser.PasswordLastSet
                PasswordNeverExpires = $ADUser.PasswordNeverExpires
                PasswordNotRequired = $ADUser.PasswordNotRequired
                PWDLastSet = $([string]$ADUser.pwdLastSet + "a")
                PWDLastSetCleaned = [datetime]::FromFileTime($ADUser.pwdLastSet)
                AccountExpirationDate = $ADUser.AccountExpirationDate
                AccountExpires = $AccountExpires
                AccountLockoutTime = $ADUser.AccountLockoutTime
                Enabled = $ADUser.Enabled
                DistinguishedName = $ADUser.DistinguishedName
            }

            $ADUserObject
            $ADUserObject |
                Export-Csv $PasswordInfoLog -NoTypeInformation -Append -ErrorAction Stop
        }
        catch {
            Write-Warning "Unable to generate password/account info"
        }

        try {
            #User Enabled Log
            $ADUserEnabledInfo = [PSCustomObject]@{
                SamAccountName = $ADUser.SamAccountName
                UserPrincipalName = $ADUser.UserPrincipalName
                AccountCreationDate = $ADUser.whenCreated
                AccountChangeDate = $ADUser.whenChanged
                Enabled = $ADUser.Enabled
                DistinguishedName = $ADUser.DistinguishedName
            }

            $ADUserEnabledInfo
            $ADUserEnabledInfo |
                Export-Csv $EnabledLog -NoTypeInformation -Append -ErrorAction Stop
        }
        catch {
            Write-Warning "Unable to pull user enabled information"
        }

        try {
            #Admin Count Log
            $AdminCountInfo = Get-HSCADUserAdminCount $ADUser.SamAccountName

            $AdminCountObject = [PSCustomObject]@{
                SamAccountName = $ADUser.SamAccountName
                UserPrincipalName = $ADUser.UserPrincipalName
                AccountCreationDate = $ADUser.whenCreated
                AccountChangeDate = $ADUser.whenChanged
                AdminCount = $AdminCountInfo.AdminCount
                DistinguishedName = $ADUser.DistinguishedName
            }

            $AdminCountObject
            $AdminCountObject |
                Export-Csv $AdminCountLog -NoTypeInformation -Append -ErrorAction Stop
        }
        catch {
            Write-Warning "Unable to pull admin count information"
        }


        try {
            #Group Membership
            $GroupMembershipObject = [PSCustomObject]@{
                SamAccountName = $ADUser.SamAccountName
                UserPrincipalName = $ADUser.UserPrincipalName
                AccountCreationDate = $ADUser.whenCreated
                AccountChangeDate = $ADUser.whenChanged
                GroupMembership = $ADUser.memberOf -join ";"
                DistinguishedName = $ADUser.DistinguishedName
            }

            $GroupMembershipObject
            $GroupMembershipObject |
                Export-Csv $GroupMembershipLog -NoTypeInformation -Append -ErrorAction Stop
        }
        catch {
            Write-Warning "Unable to pull group membership information"
        }        
    }
    Write-Output "***************************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count