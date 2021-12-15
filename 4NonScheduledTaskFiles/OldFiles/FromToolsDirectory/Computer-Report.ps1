#########################################################
# - List Computer Info
# - Check computer settings and change if necessary
# - Check for our basic applications
#
#
#########################################################

#Run powershell as an admin
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}

$Host.UI.RawUI.WindowTitle = "West Virginia University - Computer Report"

########################################################
#General Computer Info
########################################################
Write-Host "General Computer Information" -ForegroundColor Yellow

#Display the Computer Name
$ComputerName = hostname.exe
Write-Host "Computer Name: " -NoNewLine
Write-Host $ComputerName -ForegroundColor Green

#Display MAC Address
$MACAddress = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.ipenabled -EQ $true}).Macaddress | select-object -first 1
Write-Host "MAC Address: " -NoNewLine
Write-Host $MACAddress -ForegroundColor Green

#Display Windows 10 Version
$Win10Version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
If ($Win10Version -ge 1809)
{Write-Host "Windows 10: " -NoNewLine
Write-Host $Win10Version -ForegroundColor Green
}
Else{
Write-Host "Windows 10: " -NoNewLine
Write-Host $Win10Version -ForegroundColor Red
}

#Display the last update status
$UpdateSearch = (New-Object -com "Microsoft.Update.AutoUpdate"). Results.LastSearchSuccessDate
$UpdateSearchDate = $UpdateSearch.tostring('M/d/y')
$UpdateInstall = (New-Object -com "Microsoft.Update.AutoUpdate"). Results.LastInstallationSuccessDate
$UpdateInstallDate = $UpdateInstall.tostring('M/d/y')
#Check if Updates have been ran in last two months
$UpdateCompareDate = (get-Date).AddDays(-60).tostring('MM/dd/yyyy')
If ($UpdateSearchDate -ge $UpdateCompareDate)
{
Write-Host "Windows update last search: " -NoNewLine
Write-host $UpdateSearchDate -ForegroundColor Green
Write-host "Windows update last install: " -NoNewLine
Write-host  $UpdateInstallDate -ForegroundColor Green
}
Else{
Write-Host "Windows update last search: " -NoNewLine
Write-host $UpdateSearchDate " -Run Windows Update!" -ForegroundColor Red
Write-host "Windows update last install: " -NoNewLine
Write-host  $UpdateInstallDate " -Run Windows Update!" -ForegroundColor Red
}

########################################################
#Computer Settings
########################################################
Write-Host ""
Write-Host "Computer Settings" -ForegroundColor Yellow

#Display the TPM Status
$TPM = Get-wmiobject -Namespace ROOT\CIMV2\Security\MicrosoftTpm -Class Win32_Tpm
$TPMStatus = $Tpm.IsEnabled().isenabled
If ($TpmStatus -eq 'True')
{
Write-Host "TPM: " -NoNewLine
Write-Host "Enabled" -ForegroundColor Green
}
Else{
Write-Host "TPM: " -NoNewLine
Write-Host "NOT Enabled" -ForegroundColor Red
}

#Display the Encryption Status
$EncryptionStatus = Manage-bde -status c: | Select-String -Pattern 'Fully'
If ($EncryptionStatus -like '*Encrypted*')
{
Write-Host "Encryption Status: " -NoNewLine
Write-Host "Encrypted" -ForegroundColor Green
}
Else
{
Write-Host "Encryption Status: " -NoNewLine
Write-Host "NOT Encrypted" -ForegroundColor Green
}

#Display Remote Settings - Turn on if disabled
$RemoteSetting = (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections").fDenyTSConnections
If ($RemoteSetting -eq 1)
{
Write-Host "Remote Settings: " -NoNewLine
Write-Host "Enabled" -ForegroundColor Green
}
else {
(Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace root\CIMV2\TerminalServices -Authentication 6).SetAllowTSConnections(1,1)
Write-Host "Remote Settings: " -NoNewLine
Write-Host "Disabled " -NoNewLine -ForegroundColor Red
Write-Host "- Turned on Remote Settings for you." -ForegroundColor Green
}

#Power Settings
powercfg.exe -x -disk-timeout-ac 0
powercfg.exe -x -disk-timeout-dc 0
powercfg.exe -x -standby-timeout-ac 0
powercfg.exe -x -standby-timeout-dc 0
powercfg.exe -x -hibernate-timeout-ac 0
powercfg.exe -x -hibernate-timeout-dc 0
Write-Host "Power Settings: " -NoNewLine
Write-Host "Power Settings Set" -ForegroundColor Green


########################################################
#Check For Application Installs
########################################################
Write-Host ""
Write-Host "Basic Applications" -ForegroundColor Yellow
#Enter is program names you want to search for
$ProgramArray = ("Adobe Acrobat", "Citrix Receiver", "Dell Command", "Google Chrome", "LogMeIn", "MDOP MBAM", "Microsoft Office", "Mozilla Firefox", "Sophos Endpoint")
Foreach ($program in $ProgramArray)
{
$Result = (Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where { $_.DisplayName -like "*$Program*" }) -ne $null
    if ($Result) {
        Write-Host $program -NoNewLine		
		Write-Host ": Installed" -ForegroundColor Green
    } Else
	{
	Write-Host $program -NoNewLine		
		Write-Host ": NOT Installed" -ForegroundColor Red
}
}



Pause
