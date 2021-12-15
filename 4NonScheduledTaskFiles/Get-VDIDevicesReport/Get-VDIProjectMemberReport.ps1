#VDI Project Member Report

# SCCM Site configuration
$SiteCode = "HS1" # Site code 
$ProviderMachineName = "hssccm.hs.wvu-ad.wvu.edu" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

### Do not change anything below this line
    # Import the ConfigurationManager.psd1 module 
    if((Get-Module ConfigurationManager) -eq $null) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
    }

    # Connect to the site's drive if it is not already present
    if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
    }

    # Set the current location to be the site code.
    Set-Location "$($SiteCode):\" @initParams
##### End change restriction

if (Test-Path D:\mlogue\Desktop\EndpointStatusLog.csv) {
    $forcepointcsv = Import-Csv D:\mlogue\Desktop\EndpointStatusLog.csv
    }
    else {
        $forcepoint = Read-Host "Enter Forcepoint Endpoint CSV export path"
        $forcepointcsv = Import-Csv $forcepoint
        if !(Test-Path $forcepoint) {
            Write-Host "Forcepoint CSV not found"
            Start-Sleep 5
            exit
        }
    }

$RDSH = Get-ADGroup -Filter * | Where-Object -Property Name -Like "HS VDI*"
$CTSI = Get-ADGroup -Filter * | Where-Object -Property Name -Like "HS CTSI*"

$rdmembers = $RDSH | ForEach-Object {write-output "`n`n$($_.Name):" ; Get-ADGroupMember $_ -Recursive | Where-Object -Property objectClass -match "user" | Select-Object SamAccountName}
$rdmembers | Out-File $env:userprofile\Desktop\RDSHProjects.txt
Write-Verbose "RDSH Groups and Membership Exported to Desktop"
$ctsimembers = $CTSI | ForEach-Object {write-output "`n`n$($_.Name):" ; Get-ADGroupMember $_ -Recursive | Where-Object -Property objectClass -match "user" | Select-Object SamAccountName}
$ctsimembers | Out-File $env:userprofile\Desktop\VDIProjects.txt
Write-Verbose "CTSI Groups and Membership Exported to Desktop"

foreach ($member in $rdmembers.SamAccountName | Sort-Object -Unique) {
    $results = New-Object -TypeName PSObject
    $prisccm =""
    $uda = ""
    $uda = Get-CMUserDeviceAffinity -UserName "HS\$member" | Select-Object ResourceName
    $primarysccm = $uda | ForEach-Object {Get-CMDevice -Name $_.ResourceName } | select Name,PrimaryUser
    foreach ($pridev in $primarysccm) {

        if ($pridev.PrimaryUser -eq "HS\$member") {
            $prisccm += "$($pridev.Name) "
            
        }
    }
    $members += $member
    if ($forcepointcsv.'Logged-in Users' -match $member) {
        $pc=""
        $pc = $forcepointcsv | Where-Object {$_."Logged-in Users" -match $member}
        $pc = $($pc.Hostname)
        
    }

    else {
        $pc="None"

    }

    Write-Output "$member,$pc,$prisccm"
    $udaout = $prisccm
    $pc = $pc -replace ".HS.wvu-ad.wvu.edu",""

$results | Add-Member -MemberType NoteProperty -Name User -Value $member
$results | Add-Member -MemberType NoteProperty -Name ForcepointEndpoints -Value $(($pc  -join ',') | Out-String).Trim()
$results | Add-Member -MemberType NoteProperty -Name SCCMPrimaryComputers -Value $(($udaout -join ',') | Out-String).Trim()

$results | Select-Object User,ForcepointEndpoints,SCCMPrimaryComputers | Export-Csv -Path $env:userprofile\Desktop\VDIUserForcepointSCCMDeviceList.csv -Append -Notypeinformation
}
Write-Host "Exported device list VDIUserForcepointSCCMDeviceList.csv to desktop"

