<#
    .SYNOPSIS
        The purpose of this function is to publish the HSC custom powershell 
        modules to the HSCPSRepo.  When modules publish they get stored at
        \\hs-tools\tools\HSCCustomModules as NUPKG files.

    .EXAMPLE
        .\Publish-HSCModule.ps1 "C:\users\krussell\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules" -Verbose

    .EXAMPLE
        .\Publish-HSCModule.ps1 -HSCModuleLocation "C:\users\krussell\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules"

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
    [Parameter(Mandatory=$true,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true)]	
    [string]$HSCModuleLocation,

    [array]$HSCModule = (Get-ChildItem -Path $HSCModuleLocation -Name)
)

$error.Clear()

try {
    if ((Get-PSRepository).Name -contains "HSCPSRepo") {
        Write-Verbose "HSCPSRepo:  Installed"
    }
}
catch {
    Write-Verbose "HSCPSRepo is not installed.  Exiting."
    Break
}

Write-Verbose "Modules found:  $($HSCModule.Count)"

ForEach ($Module in $HSCModule) {
    
    $HSCModuleParam = @{
        Path = "$HSCModuleLocation\$Module"
        Repository = "HSCPSRepo"
        NuGetApiKey = "AnyStringWillDo"
    }
    
    if (($Module -ne "EncryptedFiles") -AND ($Module -ne "MappingFiles") -AND ($Module -ne "README.md")) {
        
        Write-Verbose "Checking HSCPSRepo:  $Module"

        try {
            Find-Module -Name "$Module" -Repository "HSCPSRepo" -ErrorAction Stop | Out-Null

            Write-Verbose "$Module found.  Moving to next module."
        }
        catch {
            Write-Verbose "Attempting to publish:  $Module"

            try {
                Publish-Module @HSCModuleParam -Force -ErrorAction Stop
                Write-Verbose "$Module published fine"
            }
            catch {
                Write-Verbose "There was an error trying to install $Module"
                Write-Warning $error[0].Exception.Message
            }
        }    
    }
}