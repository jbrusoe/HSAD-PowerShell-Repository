<#
    .SYNOPSIS
        The purpose of this script is to install the HSC modules

    .EXAMPLE
        .\Install-HSCModule

    .EXAMPLE
        

    .NOTES
        Written by: Kevin Russell
        Written on: 6/7/21

        Last Updated by: Kevin Russell
        Last Updated on: 6/8/21
    
        PS Version 5 Tested: 6/8/21
        PS Version 7 Tested:
    
        Requires being run as admin
#>

[CmdletBinding()]
param(   
    [string[]]$HSCModule = @(    
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
)

ForEach ($Module in $HSCModule) {
    if ((Get-InstalledModule).Name -contains $Module) {
        Write-Verbose "$Module is already installed."
    }
    else {
        try {

            $InstallParam = @{
                Name = "$Module"
                Repository = "HSCPSRepo"
            }
            
            #Uninstall-Module @InstallParam -AllVersions -Force -ErrorAction Stop
            Install-Module @InstallParam -Force -AllowClobber -ErrorAction Stop
            Write-Output "$Module was installed successfully"
        }
        catch {
            Write-Warning $error[0].Exception.Message
        }
    }

    #This is for specific error that was happening
    if (Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\$Module\2.0.0") {

        Write-Verbose "An inconsistancy was found.  $module subfolder should be 2.0 not 2.0.0; renaming"
        
        try {
            $RenameParam = @{
                Path = "C:\Program Files\WindowsPowerShell\Modules\$Module\2.0.0"
                NewName = "2.0"
            }
            
            Rename-Item @RenameParam -ErrorAction Stop
            Write-Verbose "Subfolder successfully renamed 2.0" -ForegroundColor Green
        }
        catch {
            Write-Error "There was an error renaming folder."  
            Write-Error "Commands will not show up until you rename subfolder 2.0 from 2.0.0"
            Write-Error "Path is C:\Program Files\WindowsPowerShell\Modules\$Module\"
        }
    }
}
#End add module loop

#Check for and add EncryptedFiles folder    
if (Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\HSC-CommonCodeModule\EncryptedFiles") {

    Write-Verbose "EncryptedFiles folder already exists"
}
else {

    Write-Verbose "EncryptedFiles folder does not exist.  Adding."

    try {

        $ItemParam = @{
            Path = "C:\Program Files\WindowsPowerShell\Modules\HSC-CommonCodeModule\EncryptedFiles"
            ItemType = "Directory"
        }

        New-Item @ItemParam -ErrorAction Stop
        Write-Output "Folder created successfully"    
    }
    catch {

        Write-Error "There was an error creating the EncryptedFiles directory"
    }        
}
#End add EncryptedFiles folder