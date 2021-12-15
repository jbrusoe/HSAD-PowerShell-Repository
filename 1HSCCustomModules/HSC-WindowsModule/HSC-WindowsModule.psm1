<#
.SYNOPSIS
	This module contains some common Active Directory functions that are used by many HSC PowerShell files.

.DESCRIPTION
	Windows functions included in this module include:
	
	1. Add-PSModulePath (To be written)
	2. Get-HSCPSModulePath
	3. Get-HSCRunAsAdministrator 

.NOTES
	HSC-WindowsModule.psm1
	Last Modified by: Jeff Brusoe
	Last Modified: July 22, 2020

	Version: 1.0
#>

[CmdletBinding()]
param ()

function Get-HSCPSModulePath
{
	<#
		.SYNOPSIS
			This function returns the PSModulePath for the local workstation
			
		.OUTPUTS
			A string array of the entries for the PSModulePath variable

		.EXAMPLE
			PS C:\Users\jbrus> Get-HSCPSModulePath
			C:\Users\jbrus\Documents\WindowsPowerShell\Modules
			C:\Program Files\WindowsPowerShell\Modules
			C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
			C:\Program Files (x86)\Microsoft SQL Server\120\Tools\PowerShell\Modules\
			C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules

		.NOTES
			Tested with the following version of PowerShell:
			1. 5.1.18362.752
			2. 7.0.2
			
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: May 24, 2021
	#>

	[CmdletBinding()]
	[OutputType([string[]])]
	param()

	try {
		[string[]]$ModulePath = (Get-ChildItem Env:\PSModulePath).Value -split ";"
		Write-Verbose ($ModulePath | Out-String)

		return $ModulePath
	}
	catch {
		Write-Warning "Error getting logged on user" | Out-Null

		return $null
	}
}

function Get-HSCRunAsAdministrator
{
	<#
		.SYNOPSIS
			This function determines if PowerShell is running as an administrator or not.
			
		.OUTPUTS
			A boolean value to indicate if PS is running as an administrator

		.EXAMPLE
			PS C:\WINDOWS\system32> Get-HSCRunAsAdministrator (Running as administrator)
			True

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-HSCRunAsAdministrator (Not running as administrator)
			False

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: July 20, 2020
	#>

	[CmdletBinding()]
	[OutputType([bool])]
	param()

	try {
		#Taken from: https://superuser.com/questions/749243/detect-if-powershell-is-running-as-administrator
		$RunAsAdministrator = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

		Write-Verbose "Run As Administrator: $RunAsAdministrator"

		return $RunAsAdministrator
	}
	catch {
		Write-Warning "Unable to determine if running as administrator"
		return $false
	}
}

####################
# Export Functions #
####################

#Add functions
#Export-ModuleMember -Function "Add-HSCPSModulePath"

#Get Functions
Export-ModuleMember -Function "Get-*"