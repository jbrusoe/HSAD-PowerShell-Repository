Function Set-HSCRemoteSettings {
    <#
    .SYNOPSIS
        1. Check/Set fDenyTSConnetions value
        2. Enable remote desktop group in firewall rules
        3. Check/Set UserAuthentication value

    .PARAMETER
        $PCName

    .NOTES
        Author: Cody Barrick
        Last Updated By: Kevin Russell
        Last Updated: 7/7/2021

        Assumes user already created the password file from Create-SecurePwdFile
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                    ValueFromPipeline = $true)]
                    [string]$PCName,
        
        [string]$fDenyValuePath = "HKLM:\System\CurrentControlSet\Control\Terminal Server",

        [string]$UserAuthPath = "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
    )

    $error.Clear()
   
    #Step 1:  Check/Set fDenyTSConnections
    Write-Host "Checking fDenyTSConnetions value"
    try {
        $fDenyValue = (Get-ItemProperty -Path $fDenyValuePath -ErrorAction Stop).fDenyTSConnections

        if ($fDenyValue -eq 0){
            Write-Host "fDenyTSConnections value is already 0" -ForegroundColor Green
        }
        else {
            $fDenyParams = @{
                Path = $fDenyValuePath
                Name = "fDenyTSConnections"
                Value = 0
            }

            try{
                Set-ItemProperty @fDenyParams -ErrorAction Stop
                Write-Host "Value for fDenyTSConnections set" -ForegroundColor Green
            }
            catch{
                Write-Warning "There was an error setting fDenyTSConections"
                Write-Warning $error[0].Exception.Message
            }
        }
    }
    catch {
        Write-Warning "There was an error finding the value for fDenyTSConnections"
        Write-Warning "Value will not be altered"
        Write-Warning $error[0].Exception.Message
    }
    #End Step 1

    #Step 2:  Enable Remote Desktop group in firewall
    try{
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction Stop
        Write-Host "Firewall successfully enabled" -ForegroundColor Green
    }
    catch{
        Write-Warning "There was an error setting the firewall"
        Write-Warning $error[0].Exception.Message
    }
    #End Step 2

    #Step 3:  Check/Set UserAuthentication value
    try{
        $UserAuthValue = (Get-ItemProperty -Path $UserAuthPath -ErrorAction Stop).UserAuthentication

        if ($UserAuthValue -eq 1) {
            Write-Host "UserAuthentication is already set to 1" -ForegroundColor Green
        }
        else {
            $UserAuthParams = @{
            Path = $UserAuthPath
            Name = "UserAuthentication"
            Value = 1
            }

            try {
                Set-ItemProperty @UserAuthParams -ErrorAction Stop
                Write-Host "Userauthentication set" -ForegroundColor Green
            }
            catch {
                Write-Warning "There was an error setting user authentication"
                Write-Warning $error[0].Exception.Message
            }
        }        
    }
    catch{
        Write-Warning "There was an error finding the value for userauthentication"
        Write-Warning "Value will not be altered"
        Write-Warning $error[0].Exception.Message
    }
    #End Step 3
}



Function Set-HSCRemoteUser {
    <#
    .SYNOPSIS
        4. Check/Set UserAuthentication value
        5. Check/Add user in remote desktop users group

    .PARAMETER
        $PCName

    .NOTES
        Author: Kevin Russell
        Last Updated By: Kevin Russell
        Last Updated: 7/8/2021

        Assumes user already created the password file from Create-SecurePwdFile
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                    ValueFromPipeline = $true)]
                    [string]$UserName
    )
    
    $error.Clear()

    try {
        Add-LocalGroupMember -Group "Remote Desktop Users" -Member $UserName -ErrorAction Stop
        Write-Verbose "$UserName was added to Remote Desktop users group"
    }
    catch {
        Write-Warning "Something happened while adding $UserName to Remote Desktop Users group"
        Write-Warning $error[0].Exception.Message
    }
}

Function New-SecurePwdFile {
    <#
    .SYNOPSIS
        This function created a secure password file that will be used in other
        various HS helpdesk function calls.

    .PARAMETER
        $SaveLocation

    .PARAMETER
        $FileName

    .NOTES
        Author: Kevin Russell
        Maintained By: Kevin Russell
        Last Updated: 7/7/2021
    #>

    [CmdletBinding()]

    param(
        [string]$SaveLocation = "C:\Program Files\WindowsPowerShell\Modules\HSC-CommonCodeModule\EncryptedFiles",

        [string]$FileName = "DomainAdmin.txt"
    )

    $error.Clear()

    Write-Host "ENTER YOUR DOMAIN ADMIN CREDS" -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    
    try {
        (Get-Credential).password |
            ConvertFrom-SecureString |
            Set-Content "$SaveLocation\$FileName" -Force -ErrorAction Stop

        Write-Host "The file was generated successfully" -ForegroundColor Green
        Write-Host "File location:  $SaveLocation"
        Write-Host "File name:  $FileName"
    }
    catch {
        Write-Warning "There was an error creating the encrypted password file."
        Write-Warning $error[0].Exception.Message
    }
}


Function Get-HSCSCCMPrimaryPC {
    <#
        .SYNOPSIS
            The purpose of this function is to get the SCCM resource field
            that has the primary machine for a user	listed
    
        .DESCRIPTION
    
        .PARAMETER
            SiteCode - This the SCCM site code which is HS1
    
            ProviderMachineName - this is the SCCM server that has the provider
                                  machine role
    
            UserName - user you want to lookup
    
        .INPUTS
    
        .OUTPUTS
            Syntax.String
    
        .EXAMPLE
            PS C:\> Get-HSCSCCMPrimaryPC -UserName "krussell"
    
        .EXAMPLE
            PS C:\> Get-HSCSCCMPrimaryPC krussell
    
        .LINK
    
        .NOTES
            Author: Kevin Russell
            Created: 03/16/21
            Last Updated: 11/03/21
            Last Updated By:
    
        #>
    
        [CmdletBinding()]
        param (
            [Parameter(Mandatory=$true,
                        ValueFromPipelineByPropertyName,
                        Position=0)]
            [string]$UserName,
        
            [string]$SiteCode = "HS1",
    
            [string]$ProviderMachineName = "hssccm.hs.wvu-ad.wvu.edu",
    
            $initParams = @{},   
    
            [string]$CurrentLocation = (Get-Location)
        )
    
        # Import the ConfigurationManager.psd1 module 
        if((Get-Module ConfigurationManager) -eq $null) 
        {
            Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
        }
    
        # Connect to the site's drive if it is not already present
        if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) 
        {
            New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
        }
    
        # Set the current location to be the site code.
        Set-Location "$($SiteCode):\" @initParams
                
        #pass username to variable $user
        $User = "HS\" + $UserName
        $ComputerArray = @()
        $ComputerArray = (Get-CMUserDeviceAffinity -UserName $User).ResourceName
        #End Primary machine
    
    
        $PrimaryMachineObject = [PSCustomObject]@{
            UserName = $UserName
            PrimaryMachine = $ComputerArray
        }
    
        if ($ComputerArray.Count -eq 0) {
            $ComputerArray = "No Primary machine found"
        }
        elseif ($ComputerArray.Count -gt 1) {
            for ( $index = 0; $index -lt $ComputerArray.length; $index++) {
                $PrimaryMachineObject | add-member NoteProperty PrimaryMachine$index $ComputerArray[$index]
            }
        }
    
        $PrimaryMachineObject
    
        Set-Location $CurrentLocation
    }

