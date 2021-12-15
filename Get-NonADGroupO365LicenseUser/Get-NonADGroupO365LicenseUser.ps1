#Get-NonADGroupO365LicenseUser.ps1
#Written By: Jeff Brusoe
#Last Updated: July 6, 2021

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$UsersToBeChangedFile = "$PSScriptRoot\Logs\" +
                                        (Get-Date -Format yyyy-MM-dd) +
                                        "-UsersToAddToGroup.csv"
)

try {
    Write-Output "Configuring Environment"
    Set-HSCEnvironment -ErrorAction Stop

    New-Item $UsersToBeChangedFile -ErrorAction Stop -Force
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Generating List of AD Users"

    $GetADUserParams = @{
        Filter = "*"
        SearchBase = "OU=HSC,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU"
        Properties = @(
            "extensionAttribute7",
            "memberOf"
        )
        ErrorAction = "Stop"
    }

    $ADUsers = Get-ADUser @GetADUserParams |
        Where-Object {$_.extensionAttribute7 -eq "Yes365" -AND
                        $_.Enabled}
}
catch {
    Write-Warning "Unable to generate list of AD users"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$UserCount = 1
foreach ($ADUser in $ADUsers)
{
    Write-Output $("Current AD User: " + $ADUser.SamAccountName)

    Write-Output "User Count: $UserCount"
    $UserCount++

    $ADUserGroups = $ADUser.memberOf
    $ADUserGroups

    $InO365LicenseGroup = $false
    foreach ($ADUserGroup in $ADUserGroups) {
        if ($ADUserGroup -like "*Office 365 Base Licensing*") {
            Write-Output "User is in Base Licensing Group"
            $InO365LicenseGroup = $true
        }
    }

    if (!$InO365LicenseGroup) {
        Write-Output "User is not in base licensing group"

        $ADUser |
            Select-Object SamAccountName,Enabled,extensionAttribute7,DistinguishedName |
            Export-Csv $UsersToBeChangedFile -NoTypeInformation -Append
    }

    Write-Output "***************************"
}

Write-Output "Finished Search"
Invoke-HSCExitCommand -ErrorCount $Error.Count