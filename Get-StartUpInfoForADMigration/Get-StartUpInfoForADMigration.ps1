<#
	.SYNOPSIS
		This will run as a startup script in a GPO.  It captures:
        LastBootTime
        All Printer
        TCP/IP Printers
        All Network Drives
        Manually Mapped Drives

	.DESCRIPTION
		
	.EXAMPLE
		
	.NOTES
		
#>
[CmdletBinding()]
param(
[array]$NetworkDrive = @(),
[array]$IpPrinter = @(),
[array]$AllPrinter = @(),
[array]$ManualDriveCheck = @(),
[array]$ManualDrive = @(),
[string]$LastBootTime = "",
[string]$PCName = "$env:COMPUTERNAME",
[string]$UserName = "$env:USERNAME",
[string]$Date = (Get-Date -Format yyyy-MM-dd),
[string]$SavePath = "\\classfiles.hs.wvu-ad.wvu.edu\Collection\StartUpInfo.csv"
)

#Test share path
$VerifySavePath = Test-Path $SavePath
if ($VerifySavePath -eq $true) {
    #Last time the system was booted
    $LastBootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime

    #All printers
    $AllPrinter = Get-Printer

    #IP printers
    $IpPrinter = Get-CimInstance Win32_Printer |
            %{ $printer = $_.Name; $port = $_.portname; Get-CimInstance win32_tcpipprinterport |
            where { $_.Name -eq $port } |
            select @{name="printername";expression={$printer}}, @{name="port";expression={$port}}, hostaddress}

    #Default printer
    $DefaultPrinter = Get-CimInstance -Query " SELECT * FROM Win32_Printer WHERE Default=$true"

    #All network drives
    $NetworkDrive = Get-SMBMapping

    #Manually mapped
    $ManualDriveCheck = Get-ChildItem -Path 'HKCU:\Network'
    if ($ManualDriveCheck -ne $null) {
        foreach ($Key in $ManualDriveCheck) {
            $DriveLetter = (Get-ChildItem -Path 'HKCU:\Network').Name | Split-Path -Leaf 
            $ManualDrive += (Get-ItemProperty -Path "HKCU:\Network\$DriveLetter").RemotePath    
        }
    }  
    else {
        $ManualDrive = 'None'
    }

    [PSCustomObject]@{
        UserName = $UserName
        Date = $Date
        ComputerName = $PCName
        LastBootTime = $LastBootTime    
        Printer = $AllPrinter -join ';'
        IPPrinter = $Printer -join ';'
        DefaultPrinter = $DefaultPrinter
        NetworkDrive = $NetworkDrive -join ';'
        ManualNetworkDrive = $ManualDrive -join ';'
    } | Export-Csv -Path $SavePath -NoTypeInformation -Append -Force
}
else {
    #check if connected to VPN
    try{
        $PANGPNic = Get-NetAdapter -InterfaceDescription "PANGP Virtual Ethernet Adapter" -IncludeHidden -ErrorAction Stop
    }
    catch{
        Write-Warning "No information could be found on Palo Alto Networks Global Protect"
        Write-Warning $error[0].Exception.Message
    }

    if ($PANGPNic.Status -eq "Up"){
        Write-Host "You appear to be connected to the Palo Alto Networks Global Protect VPN"
    }
    if ($PANGPNic.Status -eq "Disabled") {
        Write-Warning "You do not appear to be connected to the VPN"
    }
    #end VPN section
    Exit
}