<#
.SYNOPSIS
    Remove from SCCM and move in AD
.DESCRIPTION
    
.NOTES
    Author: Kevin Russell
.LINK 
    
.PARAMETER 
	
.EXAMPLE
	
#> 

#check PS version and for AD module
if ($PSVersionTable.PSVersion.Major -le 5)
{
	Write-Host "Checking for ActiveDirectory module..." -ForegroundColor Green
	
	if (Get-Module -ListAvailable -Name ActiveDirectory)
	{
		Write-Host "ActiveDirectory module already exists"  -ForegroundColor Green 
	}
	Else
	{	
		Try
		{
			Write-Host "Importing ActiveDirectory module..." -ForegroundColor Green
			Import-Module ActiveDirectory
			Write-Host "ActiveDirectory module successfully loaded" -ForegroundColor Green
		}
		Catch
		{
			Write-Host "Error importing ActiveDirectory module.  Reinstall module" -ForegroundColor Red
			Write-Host "Press any key to exit program...." -ForegroundColor Red
			[void][System.Console]::ReadKey($true)
			Exit
		}
	}
}
else
{
	Write-Host "Powershell core installed.  Checking for Windows Compatibility module..." -ForegroundColor Green
	if (Get-Module -ListAvailable -Name WindowsCompatibility)
	{
		Write-Host "WindowsCompatibility module already exists"  -ForegroundColor Green 
	}
	Else
	{	
		Try
		{
			Write-Host "Installing WindowsCompatibility module..." -ForegroundColor Green
			Install-Module WindowsCompatibility
			Write-Host "WindowsCompatibility module successfully installed" -ForegroundColor Green
		}
		Catch 
		{
			Write-Host "Error installing WindowsCompatibility module.  Reinstall module" -ForegroundColor Red
			Write-Host "Press any key to exit program...." -ForegroundColor Red
			[void][System.Console]::ReadKey($true)
			Exit
		}
		Try
		{
			Write-Host "Importing WindowsCompatibility module..." -ForegroundColor Green
			Import-Module WindowsCompatibility
			Write-Host "WindowsCompatibility module successfully loaded" -ForegroundColor Green
		}
		Catch
		{
			Write-Host "Error importing WindowsCompatibility module.  Reinstall module" -ForegroundColor Red
			Write-Host "Press any key to exit program...." -ForegroundColor Red
			[void][System.Console]::ReadKey($true)
			Exit
		}
	}
	if (Get-Module -ListAvailable -Name ActiveDirectory)
	{
		Write-Host "ActiveDirectory module already exists"  -ForegroundColor Green 
	}
	Else
	{		
		Try
		{
			Write-Host "Importing ActiveDirectory module..." -ForegroundColor Green
			Import-WinModule ActiveDirectory
			Write-Host "ActiveDirectory module successfully loaded" -ForegroundColor Green
		}
		Catch 
		{
			Write-Host "Error importing ActiveDirectory module.  Reinstall module" -ForegroundColor Red
			Write-Host "Press any key to exit program...." -ForegroundColor Red
			[void][System.Console]::ReadKey($true)
			Exit
		}		
	}	
}

#######################################################
#Find AD computers by OS, exclude InactiveComputers OU
#######################################################
Get-ADComputer -Filter 'OperatingSystem -like "*Windows 8*"' -Properties * -SearchBase 'OU=HS Computers,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU' | Where {($_.DistinguishedName -notlike "*OU=InactiveComputers,*") -And ($_.DistinguishedName -notlike "*OU=Student Laptops*")} | Select-Object Name,Enabled,DistinguishedName,OperatingSystemName | export-csv Windows8Machines.csv -Append -NoTypeInformation

################
#Import PC List
################



######################
#Find machine in SCCM
######################
$SCCMSite = "HS1"
$SCCMSitePath = $SCCMSite + ":"

#make sure sccm console installed
if (($env:SMS_ADMIN_UI_PATH) -ne $null)
{
	Write-Host "SCCM Environment path exists:" $env:SMS_ADMIN_UI_PATH -ForegroundColor Green
}
else
{
	Write-Host "You have not set up the SCCM Console.  Install SCCM console first and then re-run script." -ForegroundColor Red
	Write-Host "Press any key to exit program...." -ForegroundColor Red
	[void][System.Console]::ReadKey($true)
	Exit
}

#check to see if user acocunt has rights to SCCM
if ((Get-ADPrincipalGroupMembership -Identity $env:USERNAME |where name -eq "HD SCCM Users") )
{
    Write-Host "$env:USERNAME belongs to HD SCCM Users AD Group" -ForegroundColor Green
}
else
{
	Write-Host "You do not belong to the HD SCCM Users group. Gain access and then re-run script" -ForegroundColor Red
	Write-Host "Press any key to exit program...." -ForegroundColor Red
	[void][System.Console]::ReadKey($true)
	Exit
}

Write-Host "Trying to import SCCM module..." -ForegroundColor Green
Try
{
	Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1) -ErrorAction Stop
	
}
Catch
{
	Write-Host "There was an error importing the SCCM powershell module" -ForegroundColor Red
	Write-Host "Press any key to exit program...." -ForegroundColor Red
	[void][System.Console]::ReadKey($true)
	Exit	
}

#Set current directory to SCCM site
Set-Location -Path $SCCMSitePath

#check for machine in SCCM
$CheckSCCMname = Get-CMDevice -name $PCname

if ($CheckSCCMname -ne $null)
{
    $CheckSCCMname = $true
}
else 
{
    $CheckSCCMname = $false
}

#remove machine from SCCM
If ($CheckSCCMname)
{	

}
Else
{

}
