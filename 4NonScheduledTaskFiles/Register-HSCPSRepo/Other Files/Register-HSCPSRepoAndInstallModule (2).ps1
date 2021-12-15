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

#Declare variables
$RepoParameters = @{
Name = "HSCPSRepo"
SourceLocation = "\\hs-tools\tools\HSCCustomModules"
PublishLocation = "\\hs-tools\tools\HSCCustomModules"
InstallationPolicy = 'Trusted'
}
$HSCModule = @("HSC-CommonCodeModule","HSC-ActiveDirectoryModule","HSC-Office365Module")
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
#End variables

if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{    
    if (!(Get-Module -ListAvailable -Name ActiveDirectory))
    {
        Import-Module -Name ActiveDirectory
    }    
        
    #Add HSCPSRepo
    if (Get-PSRepository -Name HSCPSRepo)
    {
        Write-Host "The local HSC Powershell repository HSCPSRepo is already installed"
    }
    else 
    {
        Write-Host "Installing local Powershell repository HSCPSRepo"
        try 
        {
            Register-PSRepository @RepoParameters -ErrorAction Stop
            Start-Sleep -Seconds 2
            Write-Host "HSCPSRepo installed" -ForegroundColor Green 
        }
        catch
        {            
            Write-Error "There was a problem installing the repository.  Stopping program."
            Break
        }        
    }   
    #End add repo

    #Loop through and add modules
    foreach ($module in $HSCModule) 
    {
        if (Get-Module -ListAvailable -Name $module)    
        {
            Write-Host "$module is already installed."
        }
        else 
        {
            try 
            {
                Install-Module -Name $module -Repository HSCPSRepo -Force -AllowClobber -ErrorAction Stop
                Write-Host "$module was installed successfully" -ForegroundColor Green
                Start-Sleep -Seconds 2
            }
            catch 
            {                
                Write-Error "There was an error installing the $module"
            }
        }

        if (Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\$module\2.0.0")
        {
            Write-Host "An inconsistancy was found.  $module subfolder should be 2.0 not 2.0.0; renaming"
            try 
            {
                Rename-Item -Path "C:\Program Files\WindowsPowerShell\Modules\$module\2.0.0" -NewName "2.0" -ErrorAction Stop
                Write-Host "Subfolder successfully renamed 2.0" -ForegroundColor Green
            }
            catch 
            {
                Write-Error "There was an error renaming folder.  Commands will not show up until you rename subfolder 2.0 from 2.0.0"
                Write-Error "Path is C:\Program Files\WindowsPowerShell\Modules\$module\"
            }
            
        }
    }
    #End add module loop

    #Check for and add EncryptedFiles folder    
    if (Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\HSC-CommonCodeModule\EncryptedFiles")
    {
        Write-Host "EncryptedFiles folder already exists"
    }
    else 
    {
        Write-Host "EncryptedFiles folder does not exist.  Adding."
        try 
        {
            New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\HSC-CommonCodeModule\EncryptedFiles" -ItemType Directory -ErrorAction Stop
        }
        catch 
        {            
            Write-Error "There was an error creating the EncryptedFiles directory"
        }        
    }
    #End add EncryptedFiles folder
}
else
{
    Write-Host "Relaunch Powershell as Admin to install the module"
} 