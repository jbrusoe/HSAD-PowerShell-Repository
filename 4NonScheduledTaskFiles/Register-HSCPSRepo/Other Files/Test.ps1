Function Publish-HSCModule {
    <#
        .SYNOPSIS
            The purpose of this script is to publish the HSC custom powershell 
            modules to the HSCPSRepo.  When modules publish they get stored at
            \\hs-tools\tools\HSCCustomModules as NUPKG files.
    
        .EXAMPLE
            Publish-HSCModule "C:\users\krussell\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules"

        .EXAMPLE
            Publish-HSCModule -HSCModulesLocation "C:\users\krussell\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules"

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
	[string]$HSCModulesLocation = "C:\users\krussell\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules"
    )

    $error.Clear()
    $HSCModules = @()
    $HSCModules = Get-ChildItem -Path $HSCModulesLocation -Name
    
    try {
        if ((Get-PSRepository).Name -contains "HSCPSRepo") {
            Write-Verbose "HSCPSRepo:  Installed"
        }
    }
    catch {
        Write-Verbose "HSCPSRepo is not installed."
    }
    
    Write-Verbose "Modules found:  $($HSCModules.Count)"

    ForEach ($Module in $HSCModules) {
        
        $HSCModuleParams = @{
            Path = "$HSCModulesLocation\$Module"
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
                    Publish-Module @HSCModuleParams -Force -ErrorAction Stop
                    Write-Verbose "$Module published fine"
                }
                catch {
                    Write-Verbose "There was an error trying to install $Module"
                    Write-Warning $error[0].Exception.Message
                }
            }    
        }
    }
}