# Get-PossibleDisabledUser.ps1
# Written By: Jeff Brusoe
# Last Updated: October 12, 2021

[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]$SearchBase = "DC=hs,DC=wvu-ad,DC=wvu,DC=edu",

    [ValidateNotNullOrEmpty()]
    [string]$InactiveLogFile = "$PSScriptRoot\Logs\" +
                                    (Get-Date -Format yyyy-MM-dd) +
                                    "-ADPossibleInactiveUsers.csv",

    [ValidateNotNullOrEmpty()]
    [string]$ActiveLogFile = "$PSScriptRoot\Logs" +
                                (Get-Date -Format yyyy-MM-dd) +
                                "-ADActiveUsers.csv"
)

try {
    Set-HSCEnvironment -ErrorAction Stop

    New-Item $InactiveLogFile -ItemType File -Force
    New-Item $ActiveLogFile -ItemType File -Force
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count   
}

try {
    Write-Output "Getting list of AD org units under:"
    Write-Output $SearchBase

    $GetADOrgUnitParams = @{
        Filter = "*"
        SearchBase = $SearchBase
        ErrorAction = "Stop"
    }

    $ADOrgUnits = Get-ADOrganizationalUnit @GetADOrgUnitParams
}
catch {
    Write-Warning "Unable to generate list of AD org units"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($ADOrgUnit in $ADOrgUnits)
{
    Write-Output "Current AD Org Unit:"
    Write-Output $ADOrgUnit.DistinguishedName

    $ADUserProperties = @(
        "SamAccountName",
        "whenCreated",
        "whenChanged",
        "PasswordExpired",
        "PasswordLastSet",
        "AccountExpirationDate",
        "AccountExpires",
        "LastLogonDate",
        "Enabled",
        "extensionAttribute1",
        "extensionAttribute2",
        "extensionAttribute3",
        "extensionAttribute4",
        "extensionAttribute5",
        "extensionAttribute6",
        "extensionAttribute7",
        "extensionAttribute8",
        "extensionAttribute9",
        "extensionAttribute10",
        "extensionAttribute11",
        "extensionAttribute12",
        "extensionAttribute13",
        "extensionAttribute14",
        "extensionAttribute15",
        "DistinguishedName"
    )

    $GetADUserParams = @{
        Filter = "*"
        SearchBase = $ADOrgUnit.DistinguishedName
        Properties = $ADUserProperties
        SearchScope = "OneLevel"
        ErrorAction = "Stop"
    }

    try {
        Write-Output "Getting AD Users in Org Unit"
        $ADUsers = Get-ADUser @GetADUserParams
    }
    catch {
        Write-Warning "Unable to generate list of AD users"
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }

    foreach ($ADUser in $ADUsers)
    {
        Write-Output $("Current AD User: " + $ADUser.SamAccountName)
        Write-Output $("Password Last Set: " + $ADUser.PasswordLastSet)

        try {
            if ($null -eq $ADUser.LastLogonDate) {
                $LastLogonDate = "NeverLoggedOn"
            }
            else {
                $LastLogonDate = $ADUser.LastLogonDate
            }
        }
        catch {
            $LastLogonDate = "NeverLoggedOn"
        }

        Write-Output "Last Logon Date: $LastLogonDate"

        $ADUserObject = [PSCustomObject]@{
            SamAccountName = $ADUser.SamAccountName
            whenCreated = $ADUser.whenCreated
            whenChanged = $ADUser.whenChanged
            PasswordExpired = $ADUser.PasswordExpired
            PasswordLastSet = $ADUser.PasswordLastSet
            AccountExpirationDate = $ADUser.AccountExpirationDate
            AccountExpires = $ADUser.AccountExpires
            LastLogonDate = $LastLogonDate
            Enabled = $ADUser.Enabled
            extensionAttribute1 = $ADUser.extensionAttribute1
            extensionAttribute2 = $ADUser.extensionAttribute2
            extensionAttribute3 = $ADUser.extensionAttribute3
            extensionAttribute4 = $ADUser.extensionAttribute4
            extensionAttribute5 = $ADUser.extensionAttribute5
            extensionAttribute6 = $ADUser.extensionAttribute6
            extensionAttribute7 = $ADUser.extensionAttribute7
            extensionAttribute8 = $ADUser.extensionAttribute8
            extensionAttribute9 = $ADUser.extensionAttribute9
            extensionAttribute10 = $ADUser.extensionAttribute10
            extensionAttribute11 = $ADUser.extensionAttribute11
            extensionAttribute12 = $ADUser.extensionAttribute12
            extensionAttribute13 = $ADUser.extensionAttribute13
            extensionAttribute14 = $ADUser.extensionAttribute14
            extensionAttribute15 = $ADUser.extensionAttribute15
            DistinguishedName = $ADUser.DistinguishedName
        }

        if ($ADUser.PasswordLastSet -lt (Get-Date).AddYears(-1)) {
            Write-Output "Password was last set over a year ago"  
            
            $ADUserObject | Export-Csv -Path $InactiveLogFile -Append -NoTypeInformation
        }
        else {
            Write-Output "Password has been set within the last year"

            try {
                if (($LastLogonDate -ne "NeverLoggedOn") -AND 
                    ($LastLogonDate -gt (Get-Date).AddYears(-1)) -AND
                    ([datetime]$ADUser.extensionAttribute1 -gt (Get-Date))) {
                    Write-Output "Valid User"

                    $ADUserObject | Export-Csv -Path $ActiveLogFile -Append -NoTypeInformation
                }
            }
            catch {}

        }

        Write-Output "-------------------------"
    }

    Write-Output "****************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count