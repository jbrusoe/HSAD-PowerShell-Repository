<#
    .SYNOPSIS
        The purpose of this file is to check for and install the local HSCPSRepo and after that
        is installed loop through and install all the HSC cutsome modules.  It also adds the 
        EncryptedFiles folder if that does not exist on the local machine
    .EXAMPLE
        .\Register-HSCPSRepoAndInstallModule.ps1
    .EXAMPLE
    .NOTES
        Written by: Kevin Russell
        Last Updated: 8/6/20
        
        PS Version 5.1 Tested: 8/6/20
        PS Version 7.0.2 Tested:
#>

[CmdletBinding()]
param()

$RepoParameters = @{
    Name = "HSCPSRepo"
    SourceLocation = "\\hs-tools\tools\HSCCustomModules"
    PublishLocation = "\\hs-tools\tools\HSCCustomModules"
    InstallationPolicy = 'Trusted'
}

$HSCModule = @(    
    "HSC-ActiveDirectoryModule",
    "HSC-CommonCodeModule",
    "HSC-GeneratedDocumentation",
    "HSC-MiscFunctions",
    "HSC-MSTeamsModule",
    "HSC-Office365Module",
    "HSC-PSADHealth",
    "HSC-SharePointOnlineModule",
    "HSC-SQLModule",
    "HSC-TestModule",
    "HSC-TestingModule-Kevin",
    "HSC-VMModule",
    "HSC-WindowsModule"
)

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    
    ### check for active directory module ###
    if (!(Get-Module -ListAvailable -Name ActiveDirectory)){

        try{
            Import-Module -Name ActiveDirectory -ErrorAction Stop
        }
        catch{
            Write-Warning "There was an error importing ActiveDirectory module"
            Write-Warning $error[0].Exception.Message
            Invoke-HSCExitCommand -ErrorCount $Error.Count
        }
    }
    ### end AD module check ###   
    
    #Add HSCPSRepo
    try {
        $HSRepoExist = Get-PSRepository -Name HSCPSRepo -ErrorAction Stop
        $HSRepoExist = $true
    }
    catch {
        $HSRepoExist = $false
    }
    
    
    if ($HSRepoExist){
        Write-Output "The local HSC Powershell repository HSCPSRepo is already installed"
    }
    else 
    {
        Write-Output "Installing local Powershell repository HSCPSRepo"
        
        try {
            Register-PSRepository @RepoParameters -ErrorAction Stop
            Start-Sleep -Seconds 2
            Write-Output "HSCPSRepo installed" 
        }
        catch {
            Write-Warning "There was a problem installing the repository"
            Write-Warning $error[0].Exception.Message
            Invoke-HSCExitCommand -ErrorCount $Error.Count
        }        
    }   
    #End add repo

    #Loop through and add modules
    foreach ($module in $HSCModule) {
        if (Get-Module -ListAvailable -Name $module) {

            Write-Output "$module is already installed."
        }
        else {
            try {
                Install-Module -Name $module -Repository HSCPSRepo -Force -AllowClobber -ErrorAction Stop
                Start-Sleep -Seconds 2
                Write-Output "$module was installed successfully"
            }
            catch {
                Write-Warning $error[0].Exception.Message
            }
        }

        if (Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\$module\2.0.0") {

            Write-Host "An inconsistancy was found.  $module subfolder should be 2.0 not 2.0.0; renaming"
            
            try {
                Rename-Item -Path "C:\Program Files\WindowsPowerShell\Modules\$module\2.0.0" -NewName "2.0" -ErrorAction Stop
                Write-Host "Subfolder successfully renamed 2.0" -ForegroundColor Green
            }
            catch {
                Write-Error "There was an error renaming folder.  Commands will not show up until you rename subfolder 2.0 from 2.0.0"
                Write-Error "Path is C:\Program Files\WindowsPowerShell\Modules\$module\"
            }
        }
    }
    #End add module loop

    #Check for and add EncryptedFiles folder    
    if (Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\HSC-CommonCodeModule\EncryptedFiles") {

        Write-Output "EncryptedFiles folder already exists"
    }
    else {

        Write-Output "EncryptedFiles folder does not exist.  Adding."

        try {
            try{
                New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\HSC-CommonCodeModule\EncryptedFiles" -ItemType Directory -ErrorAction Stop

                Write-Output "Folder created successfully"
            }
            catch{
                Write-Warning "There was an error making the directory"
            }
            
        }
        catch {

            Write-Error "There was an error creating the EncryptedFiles directory"
        }        
    }
    #End add EncryptedFiles folder
}
else {
    Write-Output "Relaunch Powershell as administrator"
} 