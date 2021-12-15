<#
	.SYNOPSIS
		This module contains commonly used HSC SQL functions

	.DESCRIPTION
		Functions included here are:

	.NOTES
		Written by: Jeff Brusoe
		Last Updated: October 13, 2020
#>

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingUsernameAndPasswordParams","",Justification = "Password is a secure string")]
param ()

function Get-HSCSQLConnectionString
{
	[CmdletBinding()]
	[Alias("Get-HSCConnectionString")]
	[OutputType([string])]
	Param (

		[ValidateNotNullOrEmpty()]
		[string]$DataSource="sql01.hsc.wvu.edu",

		[ValidateNotNullOrEmpty()]
		[string]$Database = "BannerData",

		[ValidateNotNullOrEmpty()]
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

function Get-HSCSQLPassword
{
	<#
		.SYNOPSIS
			This function decrypts the SQL connection file.

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: September 9, 2020
	#>

	[CmdletBinding()]
	param (
		[ValidateNotNull()]
		[string]$SQLConnectionFile = (Get-HSCSQLSecureFile),

		[switch]$SOLEDB
	)

	begin
	{
		if ($SOLEDB)
		{
			$SQLConnectionFile = Get-HSCSQLSecureFile -SOLEDB
		}

		Write-Verbose "Preparing to decrtypt SQL Connection File"
		Write-Verbose "SQL Connection File: $SQLConnectionFile"

		[string]$SQLPassword = $null
	}

	process
	{
		if (($null -ne $SQLConnectionFile) -AND (Test-Path $SQLConnectionFile))
		{
			Write-Verbose "Connection file exists and is being decrypted"

			$PwdString = Convertto-SecureString -String (Get-Content $SQLConnectionFile)
			$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PwdString)
			$SQLPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
		}
		else {
			Write-Warning "Invalid SQL Connection File"
			$SQLConnectionFile = $null
		}
	}

	end
	{
		return $SQLPassword
	}
}

function Get-HSCSQLSecureFile
{
	<#
		.SYNOPSIS
			This function gets the path to the SQL Server connection file for that particular server.
			By default, it asssumes the connection should go to the HSC O365 SQL instance.

		.PARAMETER SOLEDB
			Indicates that the SQL connection file for SOLE should be used instead of the O365 instance

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: September 9, 2020
	#>

	[CmdletBinding()]
	param (
		[switch]$SOLEDB
	)

	begin
	{
		$ServerName = Get-HSCServerName
		Write-Verbose "ServerName: $ServerName"

		$ConnectionFile = Get-HSCEncryptedDirectoryPath
		Write-Verbose "Encrypted Directory Path: $ConnectionFile"
	}

	process
	{
		if ($ServerName -eq "HSVDIWIN10JB" -AND $SOLEDB)
		{
			$ConnectionFile += "SOLESQL-HSVDIWIN10JB.txt"
		}
		elseif ($ServerName -eq "HSVDIWIN10JB")
		{
			$ConnectionFile = $ConnectionFile + "O365SQLInstance-HSVDIWIN10JB.txt"
		}
		elseif ($ServerName -eq "DESKTOP-1MQ9DJO")
		{
			$ConnectionFile = $ConnectionFile + "O365SQLInstance-JeffSurface.txt"
		}
		else {
			$ServerNumber = $ServerName.substring($ServerName.Length-1)
			Write-Verbose "Server Number: $ServerNumber"

			if ($SOLEDB) {
				$ConnectionFile += "SOLESQL$ServerNumber.txt"
			}
			else {
				$ConnectionFile += "O365SqlInstance$ServerNumber.txt"
			}

			Write-Verbose "Connection File: $ConnectionFile"
		}
	}

	end
	{
		return $ConnectionFile
	}
}

#Export Functions
Export-ModuleMember -Function Get-HSCSQLConnectionString -Alias Get-HSCConnectionString
Export-ModuleMember -Function Get-HSCSQLPassword
Export-ModuleMember -Function Get-HSCSQLSecureFile