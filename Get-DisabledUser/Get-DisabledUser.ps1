#Get-DisabledUser.ps1
#Written by: Jeff Brusoe
#Last Updated: December 14, 2020

#The purpose of this file is to generate a report of disabled AD users.

[CmdletBinding()]
param ()

try {
    Set-HSCEnvironment -ErrorAction Stop 
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Generating list of AD Users"

    $ADUsers = Get-ADuser -Filter * -ErrorAction Stop |
        Where-Object {!$_.Enabled}
}
catch {
    Write-Warning "Unable to generate AD user list"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$ExportFile = "$PSScriptRoot\Logs\" +
                (Get-Date -format yyyy-MM-dd) +
                "-DisabledUserExport.csv"

$ADUsers | 
    Select-Object SamAccountName,DistinguishedName | 
    Export-Csv $ExportFile -NoTypeInformation

Invoke-HSCExitCommand -ErrorCount $Error.Count