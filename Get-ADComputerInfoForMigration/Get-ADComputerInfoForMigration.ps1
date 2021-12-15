# Get-ADComputerInformationForMigration.ps1
# Written by: Jeff Brusoe
# Last Updated: September 28, 2021
#
# This file collects computer information from AD
# which is used to backup info for the AD migration project

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$OutputFilePath = (Get-HSCGitHubRepoPath) +
                                "4ADMigrationProject\ComputerLogs\"
)

try {
    Set-HSCEnvironment -ErrorAction Stop

    $OSInfoLog = $OutputFilePath + "ComputerOSInfo\" +
                    (Get-Date -Format yyyy-MM-dd) +
                    "-OSInfo.csv"

    $ExtensionAttributeLog = $OutputFilePath + "ComputerExtensionAttributes\" +
                                (Get-Date -Format yyyy-MM-dd) +
                                "-ADComputerExtensionAttributes.csv"

    $ADComputerCountLog = $OutputFilePath + "ComputerCount\" +
                            "ADComputerCount.csv"

    $EnabledDisabledLog = $OutputFilePath + "ComputerEnabledDisabled\" +
                            (Get-Date -Format yyyy-MM-dd) +
                            "-ADComputerEnabledDisabled.csv"

    $GroupMembershipLog = $OutputFilePath + "ComputerGroupMembership\" +
                            (Get-Date -Format yyyy-MM-dd) +
                            "-ADComputerGroupMembership.csv"

    $PasswordLog = $OutputFilePath + "ComputerPassword\" +
                    (Get-Date -Format yyyy-MM-dd) +
                    "-ADComputerPassword.csv"

    $LastLogonLog = $OutputFilePath + "ComputerLastLogon\" +
                        (Get-Date -Format yyyy-MM-dd) +
                        "-ADComputerLastLogon.csv"

    $SPNLog = $OutputFilePath + "ComputerSPN\" +
                (Get-Date -Format yyyy-MM-dd) +
                "-ADComputerSPN.csv"

    $AllComputerInfoLog = $OutputFilePath + "ComputerAllInfo\" +
                            (Get-Date -Format yyyy-MM-dd) +
                            "-AllComputerInfo.csv"

    $AllComputerInfoLogUnfiltered = $OutputFilePath + "ComputerAllInfo\" +
                                    (Get-Date -Format yyyy-MM-dd) +
                                    "-AllComputerInfoUnfiltered.csv"

    New-Item -ItemType File -Force -Path $OSInfoLog -ErrorAction Stop
    New-Item -ItemType File -Force -Path $ExtensionAttributeLog -ErrorAction Stop
    New-Item -ItemType File -Force -Path $EnabledDisabledLog -ErrorAction Stop
    New-Item -ItemType File -Force -Path $GroupMembershipLog -ErrorAction Stop
    New-Item -ItemType File -Force -Path $PasswordLog -ErrorAction Stop
    New-Item -ItemType File -Force -Path $LastLogonLog -ErrorAction Stop
    New-Item -ItemType File -Force -Path $SPNLog -ErrorAction Stop
    New-Item -ItemType File -Force -Path $AllComputerInfoLog -ErrorAction Stop
    New-Item -ItemType File -Force -Path $AllComputerInfoLogUnfiltered -ErrorAction Stop
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Getting list of AD Computers"

    $ADComputers = Get-ADComputer -Filter * -Properties *
}
catch {
    Write-Warning "Unable to get list of AD computers"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$ComputerCount = 1
foreach ($ADComputer in $ADComputers)
{
    Write-Output $("Current Computer: " + $ADComputer.Name)
    Write-Output "Computer Count: $ComputerCount"
    $ComputerCount++

    Write-Output "`nLogging Computer OS Info"
    $OSInfoObject = [PSCustomObject]@{
        SamAccountName = $ADComputer.SamAccountName
        ComputerName = $ADComputer.Name
        ComputerCreationDate = $ADComputer.whenCreated
        ComputerChanged = $ADComputer.whenChanged
        OperatingSystem = $ADComputer.OperatingSystem
        OperatingSystemVersion = $ADComputer.OperatingSystemVersion
        OperatingSystemServicePack = $ADComputer.OperatingSystemServicePack
        OperatingSystemHotfix = $ADComputer.OperatingSystemHotfix
        DistinguishedName = $ADComputer.DistinguishedName
    }

    $OSInfoObject

    try {
        $OSInfoObject |
            Export-Csv -Path $OSInfoLog -ErrorAction Stop -NoTypeInformation -Append
    }
    catch {
        Write-Warning "Unable to log computer OS ifno"
    }

    Write-Output "`n`nLogging Computer Extension Attributes"
    $ExtensionAttributeObject = [PSCustomObject]@{
        SamAccountName = $ADComputer.SamAccountName
        ComputerName = $ADComputer.Name
        ComputerCreationDate = $ADComputer.whenCreated
        ComputerChanged = $ADComputer.whenChanged
        extensionAttribute1 = $ADComputer.extensionAttribute1
        extensionAttribute2 = $ADComputer.extensionAttribute2
        extensionAttribute3 = $ADComputer.extensionAttribute3
        extensionAttribute4 = $ADComputer.extensionAttribute4
        extensionAttribute5 = $ADComputer.extensionAttribute5
        extensionAttribute6 = $ADComputer.extensionAttribute6
        extensionAttribute7 = $ADComputer.extensionAttribute7
        extensionAttribute8 = $ADComputer.extensionAttribute8
        extensionAttribute9 = $ADComputer.extensionAttribute9
        extensionAttribute10 = $ADComputer.extensionAttribute10
        extensionAttribute11 = $ADComputer.extensionAttribute11
        extensionAttribute12 = $ADComputer.extensionAttribute12
        extensionAttribute13 = $ADComputer.extensionAttribute13
        extensionAttribute14 = $ADComputer.extensionAttribute14
        extensionAttribute15 = $ADComputer.extensionAttribute15
        DistinguishedName = $ADComputer.DistinguishedName
    }

    $ExtensionAttributeObject

    try {
        $ExtensionAttributeObject |
            Export-Csv -Path $ExtensionAttributeLog -ErrorAction Stop -NoTypeInformation -Append
    }
    catch {
        Write-Warning "Unable to get computer extension attributes"
    }

    Write-Output "`n`nLogging Computer Enabled/Disabled Status"
    $EnabledDisabledObject = [PSCustomObject]@{
        SamAccountName = $ADComputer.SamAccountName
        ComputerName = $ADComputer.Name
        ComputerCreationDate = $ADComputer.whenCreated
        ComputerChanged = $ADComputer.whenChanged
        Enabled = $ADComputer.Enabled
        DistinguishedName = $ADComputer.DistinguishedName
    }

    $EnabledDisabledObject
    try {
        $EnabledDisabledObject |
            Export-Csv -Path $EnabledDisabledLog -ErrorAction Stop -NoTypeInformation -Append
    }
    catch {
        Write-Warning "Unable to get enabled/disabled status"
    }

    Write-Output "`n`nLogging Computer Group Membership"
    $GroupMembershipObject = [PSCustomObject]@{
        SamAccountName = $ADComputer.SamAccountName
        ComputerName = $ADComputer.Name
        ComputerCreationDate = $ADComputer.whenCreated
        ComputerChanged = $ADComputer.whenChanged
        GroupMembership = $ADComputer.MemberOf -join ";"
        DistinguishedName = $ADComputer.DistinguishedName
    }

    try {
        $GroupMembershipObject |
            Export-Csv -Path $GroupMembershipLog -ErrorAction Stop -NoTypeInformation -Append
    }
    catch {
        Write-Warning "Unable to get group membership information"
    }

    Write-Output "`n`nLogging Computer Password Info"
    $PasswordObject = [PSCustomObject]@{
        SamAccountName = $ADComputer.SamAccountName
        ComputerName = $ADComputer.Name
        ComputerCreationDate = $ADComputer.whenCreated
        ComputerChanged = $ADComputer.whenChanged
        LastBadPasswordAttempt = $ADComputer.LastBadPasswordAttempt
        PasswordExpired = $ADComputer.PasswordExpired
        PasswordLastSet = $ADComputer.PasswordLastSet
        PasswordNeverExpires = $ADComputer.PasswordNeverExpires
        PasswordNotRequired = $ADComputer.PasswordNotRequired
        DistinguishedName = $ADComputer.DistinguishedName
    }

    $PasswordObject
    try {
        $PasswordObject |
            Export-Csv -Path $PasswordLog -ErrorAction Stop -NoTypeInformation -Append
    }
    catch {
        Write-Warning "Unable to pull computer password info"
    }

    $LastLogonInfoObject = [PSCustomObject]@{
        SamAccountName = $ADComputer.SamAccountName
        ComputerName = $ADComputer.Name
        ComputerCreationDate = $ADComputer.whenCreated
        ComputerChanged = $ADComputer.whenChanged
        LastLogon = $ADComputer.LastLogonDate
        LastLogonTimeStamp = [DateTime]::FromFileTime($ADComputer.lastLogonTimeStamp)
        DistinguishedName = $ADComputer.DistinguishedName
    }

    $LastLogonInfoObject
    $LastLogonInfoObject |
        Export-Csv -Path $LastLogonLog -ErrorAction Stop -NoTypeInformation -Append

    $ComputerSPNObject = [PSCustomObject]@{
        SamAccountName = $ADComputer.SamAccountName
        ComputerName = $ADComputer.Name
        ComputerCreationDate = $ADComputer.whenCreated
        ComputerChanged = $ADComputer.whenChanged
        SPN = $ADComputer.servicePrincipalName -join ";"
        DistinguishedName = $ADComputer.DistinguishedName
    }

    $ComputerSPNObject
    $ComputerSPNObject |
        Export-Csv -Path $SPNLog -ErrorAction Stop -NoTypeInformation -Append

    $AllComputerInfoObject = [PSCustomObject]@{
        SamAccountName = $ADComputer.SamAccountName
        ComputerName = $ADComputer.Name
        ComputerCreationDate = $ADComputer.whenCreated
        ComputerChanged = $ADComputer.whenChanged
        Enabled = $ADComputer.Enabled
        OperatingSystem = $ADComputer.OperatingSystem
        OperatingSystemVersion = $ADComputer.OperatingSystemVersion
        OperatingSystemServicePack = $ADComputer.OperatingSystemServicePack
        OperatingSystemHotfix = $ADComputer.OperatingSystemHotfix
        extensionAttribute1 = $ADComputer.extensionAttribute1
        extensionAttribute2 = $ADComputer.extensionAttribute2
        extensionAttribute3 = $ADComputer.extensionAttribute3
        extensionAttribute4 = $ADComputer.extensionAttribute4
        extensionAttribute5 = $ADComputer.extensionAttribute5
        extensionAttribute6 = $ADComputer.extensionAttribute6
        extensionAttribute7 = $ADComputer.extensionAttribute7
        extensionAttribute8 = $ADComputer.extensionAttribute8
        extensionAttribute9 = $ADComputer.extensionAttribute9
        extensionAttribute10 = $ADComputer.extensionAttribute10
        extensionAttribute11 = $ADComputer.extensionAttribute11
        extensionAttribute12 = $ADComputer.extensionAttribute12
        extensionAttribute13 = $ADComputer.extensionAttribute13
        extensionAttribute14 = $ADComputer.extensionAttribute14
        extensionAttribute15 = $ADComputer.extensionAttribute15
        GroupMembership = $ADComputer.MemberOf -join ";"
        LastBadPasswordAttempt = $ADComputer.LastBadPasswordAttempt
        PasswordExpired = $ADComputer.PasswordExpired
        PasswordLastSet = $ADComputer.PasswordLastSet
        PasswordNeverExpires = $ADComputer.PasswordNeverExpires
        PasswordNotRequired = $ADComputer.PasswordNotRequired
        LastLogon = $ADComputer.LastLogonDate
        LastLogonTimeStamp = [DateTime]::FromFileTime($ADComputer.lastLogonTimeStamp)
        SPN = $ADComputer.servicePrincipalName -join ";"
        DistinguishedName = $ADComputer.DistinguishedName
    }

    $AllComputerInfoObject
    $AllComputerInfoObject |
        Export-Csv -Path $AllComputerInfoLog -ErrorAction Stop -NoTypeInformation -Append

    Write-Output "******************************"
}

Write-Output "Writing All Computer Info (Unfiltered)"
$ADComputers |
    Export-Csv -Path $AllComputerInfoLogUnfiltered 

Write-Output "Logging Count of AD Computer"
[PSCustomObject]@{
    Date = Get-Date -Format yyyy-MM-dd-HH-mm
    ADComputerCount = $ADComputers.Count
} | Export-Csv -Path $ADComputerCountLog -NoTypeInformation -Append

Invoke-HSCExitCommand -ErrorCount $Error.Count