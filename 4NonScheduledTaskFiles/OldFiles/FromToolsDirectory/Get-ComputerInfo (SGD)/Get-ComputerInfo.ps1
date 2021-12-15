#----------------------------------------------------------
#FindSGDInfo.ps1
#
#Written by: Kevin Russell
#
#Last Modified by: Kevin Russell
#
#Version: 2
#
#Purpose: The purpose of this script is to get various  
#         machine information for the end user to give 
#         to the tech's or fill out forms with
#         
#----------------------------------------------------------

#set variables
$today = get-date -Format "MM/dd/yyyy"
$user = $env:username
$Host.UI.RawUI.WindowTitle = "Computer Information for $user on $today"
 

Write-Host "`n`n            Computer Information" -foregroundcolor yellow
Write-Host "==============================================="

#Find Computer Name
$PC = $env:computername
Write-Host "Computer Name             :" $PC
$ComputerHW = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $PC | select Manufacturer,Model
Write-Host "Manufacturer              :" $ComputerHW.Manufacturer
Write-Host "Model                     :" $ComputerHW.Model
Write-Host "Domain DNS Name           :" $env:USERDNSDOMAIN
Write-Host "Local OneDrive            :" $env:OneDrive
Write-Host "Logon Server              :" $env:LogonServer
Write-Host "Processor                 :" $env:Processor_Identifier
#Find RAM
$InstalledRAM = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $PC
$InstalledRAM = [Math]::Round(($InstalledRAM.TotalPhysicalMemory/ 1GB))
Write-Host "Installed RAM             :"  $InstalledRam "GB"




Write-Host "`n`n            OS Information" -foregroundcolor yellow
Write-Host "==============================================="
# ForEach{$_.} to the end of each Get-CimInstance command to prevent the column header from being displayed.
Write-Host -NoNewLine "OS Version                : "
Get-CimInstance Win32_OperatingSystem | Select-Object  Caption | ForEach{ $_.Caption }
Write-Host -NoNewLine "Service Pack Version      : "  
Get-CimInstance Win32_OperatingSystem | Select-Object  ServicePackMajorVersion | ForEach{ $_.ServicePackMajorVersion }
Write-Host -NoNewLine "Build Number              : "
Get-CimInstance Win32_OperatingSystem | Select-Object  BuildNumber | ForEach{ $_.BuildNumber }
Write-Host -NoNewLine "OS Architecture           : "
Get-CimInstance Win32_OperatingSystem | Select-Object  OSArchitecture | ForEach{ $_.OSArchitecture }
Write-Host ""
Write-Host -NoNewLine "Install Date: "
Get-CimInstance Win32_OperatingSystem | Select-Object  InstallDate | ForEach{ $_.InstallDate }

	


Write-Host "`n`n            Drive Information" -foregroundcolor yellow
Write-Host "==============================================="
#Find HDD space
$HDDSpace = Get-WMIObject win32_logicaldisk -computername $PC | Select DeviceID, @{Name="SizeGB";Expression={$_.Size/1GB -as [int]}}, @{Name="FreeGB";Expression={[math]::Round($_.Freespace/1GB,2)}}
Write-Host "          Local Drives" -foregroundcolor Cyan
Write-Host "------------------------------------"
ForEach ($HDD in $HDDSpace)
{	
	$HDDDriveType = new-object system.io.driveinfo("$($HDD.DeviceID)\")
	
	if ($HDDDriveType.drivetype -eq "Fixed")
	{		
		Write-Host "Drive Letter              :"  $HDD.DeviceID -foregroundcolor Green
		Write-Host "Drive Size                :"  $HDD.SizeGB "GB"
		if ($HDD.FreeGB -gt 8)
		{			
			Write-Host "Free drive space          :" $HDD.FreeGB "GB"
		}
		else
		{
			Write-Host "Free drive space          :" $HDD.FreeGB "GB" -foregroundcolor red
		}
	}	
}

Write-Host "`n         Network Drives" -foregroundcolor Cyan
Write-Host "------------------------------------"
ForEach ($HDD in $HDDSpace)
{	
	$HDDDriveType = new-object system.io.driveinfo("$($HDD.DeviceID)\")
	
	if ($HDDDriveType.drivetype -eq "Network")
	{		
		Write-Host "Drive Letter              :"  $HDD.DeviceID -foregroundcolor Green
		Write-Host "Drive Size                :"  $HDD.SizeGB "GB"
		Write-Host "Free drive space          :" $HDD.FreeGB "GB"
	}
}

Write-Host "`n      Removable/Thumb Drives" -foregroundcolor Cyan
Write-Host "------------------------------------"
ForEach ($HDD in $HDDSpace)
{	
	$HDDDriveType = new-object system.io.driveinfo("$($HDD.DeviceID)\")
	
	if ($HDDDriveType.drivetype -eq "Removable")
	{		
		Write-Host "Drive Letter              :"  $HDD.DeviceID -foregroundcolor Green
		Write-Host "Drive Size                :"  $HDD.SizeGB "GB"
		Write-Host "Free drive space          :" $HDD.FreeGB "GB"
	}	
}	





Write-Host "`n`n            Network Information" -foregroundcolor yellow
Write-Host "==============================================="
#Find Mac Address
$NetworkAdaptor = Get-NetAdapter 
ForEach ($Mac in $NetworkAdaptor)
{
	if ($Mac.Status -eq "Up")
	{
		if ($Mac.Name -eq "Ethernet")
		{
			Write-Host "Ethernet Address          :"  $Mac.MacAddress
			Write-Host "Link Speed                :"  $Mac.LinkSpeed
			Write-Host "Card Type                 :"  $Mac.InterfaceDescription
		}
		if ($Mac.Name -eq "Wi-Fi")
		{
			Write-Host "Wi-Fi Address             :"  $Mac.MacAddress
			Write-Host "Link Speed                :"  $Mac.LinkSpeed
			Write-Host "Card Type                 :"  $Mac.InterfaceDescription
		}
	}
	else
	{}
}
#Find IP
$IPAddress = ([System.Net.Dns]::GetHostByName($PC).AddressList[0]).IpAddressToString 
Write-Host "Computer IP               :"  $IPAddress 




"`n`n"
Write-Host "Press any key to exit...." -foregroundcolor Green
[void][System.Console]::ReadKey($true)
