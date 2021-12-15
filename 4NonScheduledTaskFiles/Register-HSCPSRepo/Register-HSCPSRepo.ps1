<#
.SYNOPSIS
    The purpose of this function is to register the HSC powershell 
    repository.

.EXAMPLE
    .\Register-HSCPSRepo.ps1

.NOTES
    Written by: Kevin Russell
    Last Updated: 6/9/21
    
    PS Version 5.1 Tested: 6/9/21
    PS Version 7.0.2 Tested:

    Needs to be run as admin

    You will get this you have to answer Y to:

    NuGet provider is required to continue
    PowerShellGet requires NuGet provider version '2.8.5.201' or newer to interact with NuGet-based 
    repositories. The NuGet provider must be available in 'C:\Program Files\PackageManagement\ProviderAssemblies'
    or 'C:\Users\kevinadmin\AppData\Local\PackageManagement\ProviderAssemblies'. You can also install
    the NuGet provider by running 'Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force'.
    Do you want PowerShellGet to install and import the NuGet provider now?
    [Y] Yes  [N] No  [S] Suspend  [?] Help (default is "Y"):
#>

[CmdletBinding()]
param(

    [string]$FileShareLocation = "\\hs-tools\tools\HSCCustomModules",

    $RepoParameters = @{
        Name = "HSCPSRepo"
        SourceLocation = $FileShareLocation
        PublishLocation = $FileShareLocation
        InstallationPolicy = 'Trusted'
    }
)

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    
    try {
        $HSRepoExist = Get-PSRepository -Name HSCPSRepo -ErrorAction Stop
        $HSRepoExist = $true
    }
    catch {
        $HSRepoExist = $false
    }

    if ($HSRepoExist) {
        Write-Output "HSCPSRepo is already installed"
    }
    else {
        Write-Output "Installing local Powershell repository HSCPSRepo"
        
        try {
            Register-PSRepository @RepoParameters -ErrorAction Stop
            Write-Output "`nHSCPSRepo installed"
        }
        catch {
            Write-Warning "There was a problem installing the repository"
            Write-Warning $error[0].Exception.Message
        }
    }    
}
else {
    Write-Warning "Please launch Powershell as administrator and run again"
}

#Add local share for HSCRepo to PSModulePath env variable.  Needed to use HSC modules
Write-Output "Adding $FileShareLocation to environmental variable PSModulePath"

$CurrentValue = [Environment]::GetEnvironmentVariable("PSModulePath", "Machine")
[Environment]::SetEnvironmentVariable("PSModulePath", $CurrentValue + [System.IO.Path]::PathSeparator + "$FileShareLocation", "Machine")

Write-Output "Value was successfully added"