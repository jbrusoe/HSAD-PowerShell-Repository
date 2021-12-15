$parameters = @{
Name = "HSCPSRepo"
SourceLocation = "\\hs-tools\tools\HSCCustomModules"
PublishLocation = "\\hs-tools\tools\HSCCustomModules"
InstallationPolicy = 'Trusted'
}



$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    try
    {
        Get-PSRepository -Name HSCPSRepo -ErrorAction Stop
        Write-Host "The local HSC Powershell repository HSCPSRepo is already installed" -ForegroundColor Green    
    }
    catch 
    {
        Write-Host "Installing local Powershell repository HSCPSRepo"
        Register-PSRepository @parameters
        Start-Sleep -Seconds 3
    }

    Install-Module -Name HSC-CommonCodeModule -Repository HSCPSRepo -Force -AllowClobber
    Write-Host "HSC-CommonCodeModule installed successfully" -ForegroundColor Green
    Start-Sleep -Seconds 3

    Install-Module -Name HSC-ActiveDirectoryModule -Repository HSCPSRepo -Force -AllowClobber
    Write-Host "HSC-ActiveDirectoryModule installed successfully" -ForegroundColor Green
    Start-Sleep -Seconds 3
    
    Install-Module -Name HSC-Office365Module -Repository HSCPSRepo -Force -AllowClobber
    Write-Host "HSC-Office365Module installed successfully" -ForegroundColor Green
    
}
else
{
    Write-Host "Relaunch Powershell as Admin to install the module"
} 