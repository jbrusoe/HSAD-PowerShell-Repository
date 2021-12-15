#--------------------------------------------------------------------------------
#
#  File:  HSC-SQLModule.psm1
#
#  Originally Written By:  Matt Logue
#  Last Updated: January 23, 2017
#
#  Last Modified By: Jeff Brusoe
#  Last Updated: September 24, 2019
#
#  Version:  2.0
#
#  Description: Contains various functions commonly used with querying for SQL.
#
#---------------------------------------------------------------------------------

<#
.SYNOPSIS
 	This file contains various functions used to query SQL servers
    
.DESCRIPTION
 	This function contains SQL methods used primarily for querying for account disables and enables in SOLE
 	
 	Functions currently in this file include:
 	1. Get-ConnectionString
 	
.PARAMETER
	Each function accepts certain parameters. See function comments to figure out what these are.

.NOTES
	Version History
	- September 24, 2019
		- Moved to work in GitHub directory
		- Changed function names to match PS approved verbs
		- Added function aliases
		- Added Export-ModuleMember
		- Added exception handling
		- Added option to do ExecuteReader or ExecuteNonQuery
		
	- May 7, 2020
		- 
#>

function Get-ConnectionString
{
	[CmdletBinding()]
	Param (
		[string]$DataSource="sql01.hsc.wvu.edu",
		[string]$Database = "BannerData",
		[string]$Username = "itsnetworking",
		
		[Parameter(Mandatory=$true)]
		[Alias("Password")]
		[string]$SQLPassword
	)
	
		$ConnectionString = "Data Source=$DataSource;Initial Catalog=$Database;User Id=$Username;Password=$SQLPassword;"
			
		$CleanedConnectionString = $ConnectionString.substring(0,$ConnectionString.lastIndexOf("=")+1) + "<PasswordRemoved>"
		Write-Output "Connection string: $CleanedConnectionString" | Out-Host
		
		return $ConnectionString
}

function Connect-SQLDatabase 
{
	<#
		.SYNOPSIS
			The purpose of this function is to establish a connection to a SQL Server Database
			
		.PARAMETER DataSource
			This is the IP address of the SQL Server.
			
		.PARAMETER Database
			The name of the database to connect to.
			
		.PARAMETER Username
			The username to use in the connection string
			
		.PARAMETER SQLPassword
			SQL password to use in the connection string
		
		.NOTES
			Last updated by: Jeff Brusoe
			Last updated: September 24, 2019
			
			See comments above for changes
	#>
	
	[CmdletBinding()]
	[Alias("Connect-SQL")]
	Param (
		[string]$DataSource="sql01.hsc.wvu.edu",
		[string]$Database = "BannerData",
		[string]$Username = "itsnetworking",
		
		[Parameter(Mandatory=$true)]
		[Alias("Password")]
		[string]$SQLPassword
	)
	
	if ([string]::IsNullOrEmpty($SQLPassword))
	{
		Write-Warning "No password supplied" | Out-Host
		return $null
	}
	else
	{
		try
		{
			$ConnectionString = "Data Source=$DataSource;Initial Catalog=$Database;User Id=$Username;Password=$SQLPassword;"
			
			$CleanedConnectionString = $ConnectionString.substring(0,$ConnectionString.lastIndexOf("=")+1) + "<PasswordRemoved>"
			Write-Output "Connection string: $CleanedConnectionString" | Out-Host
			
			$SQLConn = New-Object System.Data.SqlClient.SqlConnection
			$SQLConn.connectionstring = $ConnectionString
			$SQLConn.Open()

			return $SQLConn
		}
		catch
		{
			Write-Warning "There was an error opening connection to DB." | Out-Host
			return $null
		}
	}
}

function Close-SQLConnection
{
	<#
		.SYNOPSIS
			This function closes a connection to a SQL Server database.
			
		.PARAMETER SQLConn
			An object that is the (open) connection to the SQL database
			
		.OUTPUTS
			- True if connection is closed successfully
			- False if connection is not closed successfully
		
		.NOTES
			Last updated by: Jeff Brusoe
			Last updated: September 24, 2019
			
			See comments above for changes
	#>
	
	[CmdletBinding()]
	[Alias("Close-SQLQuery")]
	Param (
		[Parameter(Mandatory=$true)]
		[Alias("SQLConnection")]
		[System.Data.SqlClient.SqlConnection]$SqlConn
		)
	
	Write-Output "Attempting to close connection" | Out-Host
	
	try
	{
		$SqlConn.Close()
		
		if ($SQLConn.State -eq "Closed")
		{
			Write-Verbose "Successfully closed connection" | Out-Host
			return $true
		}
		else
		{
			Write-Verbose "Unable to close connection" | Out-Host
			return $false
		}
	}
	catch
	{
		Write-Warning "Unable to close connection" | Out-Host
		
		return $false
	}
}

#################
#Function Export#
#################
Export-ModuleMember -Function Get* -Alias Query*
Export-ModuleMember -Function Close* -Alias Close*
Export-ModuleMember -Function Connect* -Alias Connect*