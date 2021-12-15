
[CmdletBinding()]
    param(	
	[string]$ModuleName
    )

$LoggedOnUser = Get-WmiObject -Class Win32_ComputerSystem | Select-Object UserName #Needed to find logged on user while in elevated PS console
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$ModuleParamaters = @{
    Path = "C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\$ModuleName"
    Repository = 'HSCPSRepo'
    NuGetApiKey = 'AnyStringWillDo'
}

if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{    
    if (Test-Path -Path "C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\")
    {
        if (Get-PSRepository -Name HSCPSRepo)
        {
            try 
            {
                Publish-Module @ModuleParamaters -ErrorAction Stop
            }
            catch 
            {
                Write-Host "There was a problem:"
                $_.Exception.Message    
            }
        }
        else 
        {
            Write-Host "HSCPSRepo has not been found.  Register that repository on this system before continuing."
        }
    }
    else 
    {
        Write-Host "The path C:\Users\$($LoggedOnUser.Username.Split('\')[1])\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\ does not exist."
        Write-Host 'You will need to modify Path in the $ModuleParamters splat to where you store your custom modules'
    }
}
else
{
    Write-Host "Relaunch Powershell as Admin to publish the module"
} 
