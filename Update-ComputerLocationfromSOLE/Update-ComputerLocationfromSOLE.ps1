<#
    .SYNOPSIS
        This file updates the AD computer location from a form submitted by the
        departmental CSCs.

    .DESCRIPTION
        The purpose of this file is to updated the location attribute in AD from
        a form submitted to SOLE when a computer changes departments
        Form URL: https://sole.hsc.wvu.edu/Form/5492/Public/Start/QuMQADQRC4bR

    .PARAMETER SearchDays
        Number of days to look through submitted form entries

    .PARAMETER SiteCode

    .PARAMETER ProviderMachineName
        The DNS name of the SCCM server to connect to.

    .PARAMETER SOLEView
        This is the name of the DB view that SOLE has created to query the information
        submitted on the form.

    .NOTES
        Originally Written by: Matt Logue
        Updated and Maintained by: Jeff Brusoe
        Last Updated: March 22, 2021
#>

[CmdletBinding()]
param(
    [int]$SearchDays = 7,

    [ValidateNotNullOrEmpty()]
    [string]$SiteCode = "HS1",

    [ValidateNotNullOrEmpty()]
    [string]$ProviderMachineName = "hssccm.hs.wvu-ad.wvu.edu",

    [ValidateNotNullOrEmpty()]
    [string]$SOLEView = "HSCITS_ComputerMoveFormData"
)

try {
    Set-HSCEnvironment -ErrorAction Stop

    #Get SOLE SQL instance connection string
    $SQLPassword = Get-HSCSQLPassword -SOLEDB -Verbose
    $SQLConnectionString = Get-HSCConnectionString -Password $SQLPassword

    if ($SearchDays -gt 0) {
        $SearchDays = -1*$SearchDays
    }

    Write-Output "Site Code: $SiteCode"
    Write-Output "Provider Machine Name: $ProviderMachineName"
    Write-Output "SOLE View: $SOLEView"
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Querying SQL..."

    $Query = "Select * From $SOLEView"
    Write-Output "Query: $Query"

    $InvokeSQLCmdParams = @{
        Query = $Query
        ConnectionString = $SQLConnectionString
        ErrorAction = "Stop"
    }

    $SQLResults = Invoke-SqlCmd @InvokeSQLCmdParams
}
catch {
    Write-Warning "Unable to query SOLE DB"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$UniqueSQLResults = $SQLResults |
                    Where-Object {$_.FormDate -gt (Get-Date).AddDays(-10)} |
                    Sort-Object -property SerialNumber -unique |
                    Sort-Object -Descending FormDate

Write-Output "`nResults from SQL:"
Write-Output $UniqueSQLResults

try {
    Write-Output "`n`nConnect to SCCM with Configuration Module"
    $initParams = @{}

    if($null -eq (Get-Module ConfigurationManager)) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams
    }
    if($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
        $Error.Clear()
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
    }

    Set-Location "$($SiteCode):\" @initParams
    Write-Output "Connected to SCCM"
}
catch {
    Write-Output "Error in connecting to SCCM.  Check to make sure SCCM powershell module exists on server."
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}
##End SCCM Connection

Write-Output "Getting Device List"
$SCCMDeviceList = Get-CMResource -Fast -ResourceType System |
    Select-Object Name,MacAddresses

Write-Output "Processing data from SQL and SCCM"
foreach ($UniqueSQLResult in $UniqueSQLResults)
{
    $DeviceName = $null
    $InputMAC = $UniqueSQLResult.SerialNumber
    Write-Output "Input MAC: $InputMAC"

    $InputMAC = $InputMAC.toUpper()
    $InputMAC = $InputMAC.Replace(" ","")
    $InputMAC = $InputMAC.replace("-",":")
    if ($InputMAC -notlike "*:*")
    {
        $count = 0
        while ($count -lt ($InputMAC.Length - 2)) {
            $InputMAC = $InputMAC.Insert(($count)+2,':')
            $count += 3
        }
    }
    #Searching SCCM device information to find Mac Address from SQL query
    $DeviceName = $SCCMDeviceList |
                    Where-Object -Property MacAddresses -like "*$InputMAC*" |
                    Select-Object -ExpandProperty Name

    #Check if device is not found
    if ($null -eq $DeviceName) {
        Write-Warning "Device with MAC Address = $InputMAC not found in SCCM"
    }
    else
    {
        try {
            #Finds computer name and sets location from SQL query
            $SetADComputerParams = @{
                Identity = $DeviceName
                Location = $UniqueSQLResult.NewLocation
                ErrorAction = "Stop"
            }

            Set-ADComputer @SetADComputerParams

            Write-Output "$DeviceName updated to $($UniqueSQLResult.NewLocation)"
        }
        catch {
            #Should never execute, but just in case device is in SCCM and not AD
            Write-Warning "$DeviceName not found in AD"
        }
    }
}

Invoke-HSCExitCommand -ErrorCount $Error.Count