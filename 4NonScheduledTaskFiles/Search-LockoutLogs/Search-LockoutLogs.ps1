<#
.SYNOPSIS
 	      
    
.DESCRIPTION
 	      
 	
.PARAMETER
	    Paramter information.

.NOTES
	    Author: Kevin Russell
    	Last Updated by: Kevin Russell
	    Last Updated: 
		
		
#>

#Change PowerShell window title
$Host.UI.RawUI.WindowTitle = "Search-LockoutLogs.ps1"

$username = Read-Host "Type username or hit enter to return all"

#Find DC with the PDC emulator role.  All password authentication will come to this DC holding the PDCe role.
$pdce = (Get-ADDomain).PDCEmulator

#create array to store ADFS info
$AllUsernames = @()

#create hash table filter for adfs lockouts
$AdsfFilter = @{'LogName' = 'Security';'Id' = 516}
#create hash table filter for lock outs
$filter = @{'LogName' = 'Security';'Id' = 4740}


write-host "Retrieving ADFS security logs..." -ForegroundColor Green

#get security event log lockout info from ADFS1
$AdfsEvents = Get-WinEvent -ComputerName AZUREADFS1 -FilterHashTable $AdsfFilter
$AdsfValues = $AdfsEvents | Select-Object @{'Name' ='UserName'; Expression={$_.Properties[1].value.split("@")[0]}}, @{'Name' ='ClientIP';Expression={$_.Properties[2].value.split(",")[0]}} 

#store values from AzureADFS1 to speed up search
foreach ($AdsfValue in $AdsfValues)
{    
	$AllUsernames += $AdsfValue.UserName, $AdsfValue.ClientIP
}   


write-host "Retrieving"$pdce.split(".")[0]"security logs..." -ForegroundColor Green

#get security event log lockout info from PDCe
$events = Get-WinEvent -ComputerName $pdce -FilterHashTable $filter
$values = $events | Select-Object @{'Name' ='UserName'; Expression={$_.Properties[0].value}}, @{'Name' ='ComputerName';Expression={$_.Properties[1].value}} 

if ($username)
{
	Write-Host "Searching logs for $username..." -ForegroundColor Green
	
	if ($values.username.contains($username))
	{			
		$FindAllIndex = ($values | Select-String $username).LineNumber
		$Index = $FindAllIndex[0]

		if ($values.computername[$index-1] -eq 'AZUREADFS1')
		{
			if ($AllUsernames.contains($username))
			{
				$FindAllIndex = ($AllUsernames | Select-String $username).LineNumber
				$Index = $FindAllIndex[0]            
            
				Write-Host "User"$AllUsernames[$index-1]"was locked by"$AllUsernames[$index]				
			}
			else
			{
				Write-Host "User $username not found in ADFS1 security logs for Event ID 516"				
			}             
		}
        else
		{
			Write-Host "User"$values.username[$index-1]"was locked by"$values.computername[$index-1]
		}
	}
	else
	{			
		write-host "User $username was not found in security logs" -ForegroundColor Red
	}
}
else
{	
	Write-Host "Returning all lockouts from $pdce..." -ForegroundColor Green
	#loop through security lockout
	foreach ($value in $values)
	{		
		#handle blank device name returned
		if ([string]::IsNullorEmpty($value.ComputerName))
		{
			write-host "User"$value.UserName"is locked but device is not found" -ForegroundColor Magenta
		}
    
		#find ADFS info if AzureAdfs1 is device listed in lockout
		elseif ($value.ComputerName -eq 'AZUREADFS1')
		{        
			write-host ""
			write-host "User"$value.UserName"locked by"$value.ComputerName
			write-host "Searching ADFS security logs...." -ForegroundColor Green
        
        
			if ($AllUsernames.contains($value.UserName))
			{
				$FindAllIndex = ($AllUsernames | Select-String $value.Username).LineNumber
				$Index = $FindAllIndex[0]            
            
				Write-Host "User"$AllUsernames[$index-1]"was locked by"$AllUsernames[$index]
				Write-Host ""
			}
			else
			{
				Write-Host "User"$Value.UserName"not found in ADFS1 security logs for Event ID 516"
				Write-Host ""
			}             
		}
    
		#display dc lockout info
		else
		{
			write-host "User"$value.UserName"locked by"$value.ComputerName         
		}
	}	
}