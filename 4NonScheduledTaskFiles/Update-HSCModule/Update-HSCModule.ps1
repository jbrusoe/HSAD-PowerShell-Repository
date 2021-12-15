<#
    .SYNOPSIS
		
    .DESCRIPTION

    .PARAMETER
		

    .INPUTS

    .OUTPUTS
        

    .EXAMPLE
		

    .EXAMPLE
        

    .LINK

    .NOTES
        Author: Kevin Russell
		Created: 11/03/21
        Last Updated: 
        Last Updated By:

#>

[CmdletBinding()]
param (
    [string]$NuGetPackagePath = "\\hs.wvu-ad.wvu.edu\Public\Tools\HSCCustomModules",

    [string]$HSCModuleLocation = "C:\users\krussell\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules",

    [array]$Module = @("HSC-TestingModule-Kevin"),

    [string]$HSRepo = "HSCPSRepo"
)

if (Test-Path -Path $NuGetPackagePath) {
    $Module | ForEach-Object {
        
        Write-Output "Preparing to remove:  $Module"
        
        try {
            Get-ChildItem -Path $NuGetPackagePath -Include $Module* -Recurse -ErrorAction Stop|
                Remove-Item

            Write-Output "$Module was successfully removed"
        }
        catch {
            Write-Output "There was a problem finding:  $Module"
            Write-Warning $error[0].Exception.Message
        }    
    
        Start-Sleep -Seconds 1.5
        
        Write-Output "Preparing to publish:  $Module"
        try {
            $HSCModuleParam = @{
            Path = "$HSCModuleLocation\$Module"
            Repository = $HSRepo
            NuGetApiKey = "AnyStringWillDo"
            }
    
            Publish-Module @HSCModuleParam -Force -ErrorAction Stop
            Write-Output "$Module successfully published"
        }
        catch {
            Write-Output "There was a problem publishing:  $Module"
            Write-Warning $error[0].Exception.Message
        }
    
        Write-Output "Preparing to uninstall:  $Module"
        try {
            Uninstall-Module -Name $Module -ErrorAction Stop
            Write-Output "$Module was successfully removed"
        }
        catch {
            Write-Output "There was a problem uninstalling:  $Module"
            Write-Warning $error[0].Exception.Message
        }
    
        Start-Sleep -Seconds 1.5
        
        Write-Output "Preparing to install:  $Module"
        try {
            Install-Module -Name $Module -Repository $HSRepo -ErrorAction Stop
            Write-Output "$Module was successfully installed"
        }
        catch {
            Write-Output "There was a problem installing:  $Module"
            Write-Warning $error[0].Exception.Message
        }
    }
    Write-Output "You will need to restart powershell to use the updated module"
}
 