<#
	.SYNOPSIS
		This script gets shared printer info that will be used for the HS to HSAD
        migration.  It will be running as a scheduled task on Sysscript5.

	.DESCRIPTION
		
	.EXAMPLE
		
	.NOTES
		
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$OutputFilePath = '\\hs.wvu-ad.wvu.edu\public\its\network and voice services\microsoft\HSC-Logs\' +
                              "4ADMigrationProject\",

    [array]$HSPrintServerList = @(
                        "HSPrint1"
                        "HSPrint2"
                        "HSPrint3"
                        "HSPrint4"
                    ),

    [array]$HSPrinterProperties = @(
                        "whenChanged"
                        "whenCreated"
                        "name"
                        "distinguishedName"
                        "SamAccountName"
                    ),

    [string]$Date = (Get-Date -Format yyyy-MM-dd),

    [array]$HSPrinterList = @(),

    [string]$HSPrinterOU = "OU=Printer Groups,OU=HSC,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU"
)

try {
	Set-HSCEnvironment -ErrorAction Stop    
}
catch {
	Write-Warning "Unable to configure environmenet"
	Write-Warning $error[0].Exception.Message
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#Get list of printers on each server for record keeping
foreach ($HSPrintServer in $HSPrintServerList) {    
    $PrinterListPerServerLogPath = $OutputFilePath + "PrintServerList\$Date-$HSPrintServer.csv"
    try {
        Get-Printer -ComputerName $HSPrintServer -ErrorAction Stop |
            Select-Object * |
            Export-CSV -Path $PrinterListPerServerLogPath -ErrorAction Stop -NoTypeInformation -Force
    }
    catch {
        $PrinterListServerFailedLogPath = $OutputFilePath + "PrintServerList\$Date-$HSPrintServer-Failed.csv"
        [PSCustomObject]@{
            PrinterName = $HSPrintServer
            Error = $error[0].Exception.Message
        } | Export-Csv -Path $PrinterListServerFailedLogPath -ErrorAction Stop -NoTypeInformation
    }
}
#Get list of Printer Security Groups
try {
    $HSPrinterList = Get-ADGroup -Filter * -SearchBase $HSPrinterOU -Properties $HSPrinterProperties

    foreach ($HSPrinter in $HSPrinterList) {        
        $HSPrinterLogFilePath = $OutputFilePath + "PrinterSecurityGroup\$Date-SecurityGroup.csv"
        
        [PSCustomObject]@{
            SecurityGroupName = $HSPrinter.Name
            whenCreated = $HSPrinter.whenCreated
            whenChanged = $HSPrinter.whenChanged
            SamAccountName = $HSPrinter.SamAccountName
            distinguishedName = $HSPrinter.distinguishedName
        } | Export-Csv -Path $HSPrinterLogFilePath -NoTypeInformation -Append   
    }
}
catch {
    Write-Warning "There was a problem getting the printer security group list"
    Write-Warning "Cannot continue.  Exiting..."
    Write-Warning $error[0].Exception.Message
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output "HSC Printer Count:  $($HSPrinterList.Count)"

#Loop through printer list and export ACL
foreach ($HSPrinterName in $HSPrinterList) {
    Write-Output "Getting ACL for:  $HSPrinterName"

    #Get printer information
    try {
        $HSPrinterInfo = Get-ADGroup -Identity $HSPrinterName -Properties $HSPrinterProperties -ErrorAction Stop
    }
    catch {
        Write-Warning "There was a problem getting group membership for $HSPrinterName"
	    Write-Warning $error[0].Exception.Message
        }
    
    $error.Clear()

    #Get group members
    try {
        $HSPrinterACLInfo = Get-ADGroupMember -Identity $HSPrinterName -ErrorAction Stop
    }
    catch {
        $FailedACLLogPath = $OutputFilePath + "PrinterACLInfo\$Date-FailedToGetACL.csv"
        [PSCustomObject]@{
            PrinterName = $HSPrinterInfo.Name
            whenCreated = $HSPrinterInfo.whenCreated
            whenChanged = $HSPrinterInfo.whenChanged
            SamAccountName = $HSPrinterInfo.SamAccountName
            distinguishedName = $HSPrinterInfo.distinguishedName
            Error = $error[0].Exception.Message
        } | Export-Csv -Path $FailedACLLogPath -NoTypeInformation -Append
    }

    if ($HSPrinterACLInfo -ne $null) {
        $PrinterACLInfoPath = $OutputFilePath + "PrinterACLInfo\$Date-PrinterACLInfo.csv"
        
        foreach ($HSUser in $HSPrinterACLInfo) {
            [PSCustomObject]@{
                PrinterName = $HSPrinterName.Name
                objectClass = $HSUser.objectClass
                Name = $HSUser.Name
                whenCreated = $HSUser.whenCreated
                whenChanged = $HSUser.whenChanged        
                SamAccountName = $HSUser.SamAccountName
                distinguishedName = $HSUser.distinguishedName    
            } | Export-Csv -Path $PrinterACLInfoPath -NoTypeInformation -Append
        }   
    }
    else { #These are the empty security groups
        $EmptyACLLogPath = $OutputFilePath + "PrinterACLInfo\$Date-EmptyACL.csv"
        
        [PSCustomObject]@{
            PrinterName = $HSPrinterInfo.Name
            whenCreated = $HSPrinterInfo.whenCreated
            whenChanged = $HSPrinterInfo.whenChanged
            SamAccountName = $HSPrinterInfo.SamAccountName
            distinguishedName = $HSPrinterInfo.distinguishedName
        } | Export-Csv -Path $EmptyACLLogPath -NoTypeInformation -Append
    }
}