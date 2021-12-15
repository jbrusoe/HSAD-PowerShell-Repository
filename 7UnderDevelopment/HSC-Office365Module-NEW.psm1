<#
	.SYNOPSIS
		This module contains functions that are commonly used to do administative work with the HSC Office 365 tenant.

	.DESCRIPTION
		The following functions are contained in this file. Ones with a * are not yet finished.

		Functions used for establishing connection to Office 365
		1. Connect-HSCOffice365 (AzureAD)
		2. Connect-HSCOffice365MSOL (MSOnline)
		3. Connect-MainCampusOffice365 (Connect to main campus tenant with AzureAD)
		4. Connect-MainCampusOffice365MSOL (Connect to main campus tenant with MSOL)
		5. Connect-WVUFoundationOffice365 (Connect to WVU Foundation tenant with AzureAD)
		6. Connect-WVUFoundationOffice365MSOL (Connect to WVU Foundation tenant with MSOL)
		7. Get-HSCConnectionAccount
		8. Test-HSCOffice365Connection
		9. Test-HSCConnectionRequirement

		Functions used to establish connection to Exchange Online
		1. Connect-HSCExchangeOnline (Exchange Online V2 & V1)
		2. Connect-HSCExchangeOnlineV1 (Exchange Online V1 Only)
		3. Connect-MainCampusExchangeOnline(Connect to main campus Exchange Online)
		4. Connect-WVUFoundationExchangeOnline (Connect to WVU Foundation Exchange Online)
		5. Test-HSCExchangeOnlineConnection
		6. Test-HSCExchangeOnlineConnectionRequirement

		Functions for AzureAD/MSOnline (* = Funcdtion to be implemented)
		1. Get-HSCAzureADDirectoryRoleName
		2. Get-HSCGlobalAdminMember
		3. Get-HSCQuarantineMessage
		4. Get-HSCRoleMember
		5. Get-HSCTenantName
		6. Get-HSCTenantNameMSOL
		7. Get-HSCUserLicense
		8. Get-HSCUserLicenseMSOL
		9. Set-HSCUserLicense
		10. Set-HSCBlockCredential (MSOL)
		11. Enable-HSCCloudUser (AzureAD) *
		12. Disable-HSCCloudUser (AzureAD) *

		Functions for ExchangeOnline (* = Function to be implemented)
		1. Get-O365MailboxStatus
		2. Get-HSCLitigationHold
		3. Get-HSCLitigationHoldV1
		2. Disable-HSCIMAP *
		3. Disable-HSCPOP
		4. Set-HSCCommonExchangeOnlineParameter *

	.NOTES
		HSC-Office365Module.psm1
		Written by: Jeff Brusoe
		Last Modified by: Jeff Brusoe
		Last Modified: July 6, 2020

		NONE of the AzureAD, MSOnline, or Exchange Online cmdlets will work with PowerShell core (versions 6 and 7).
#>


[CmdletBinding()]
param()

###########################################################
# Functions related to establishing Office 365 Connection #
###########################################################

function Connect-HSCOffice365
{
	<#
		.SYNOPSIS
			This function establishes a connection to the HSC Office 365 tenant with the AzureAD cmdlets.

		.DESCRIPTION
			This function establishes a connection to the HSC Office 365 tenant with the AzureAD cmdlets. It does this
			by looking at the logged on user and workstation name. The path to the encrypted file is then determined by
			the Get-HSCEncryptedFilePath function. A credential object is generated from that encrypted file and the username
			generated from Get-HSCConnectionAccount.

		.OUTPUTS
			True/False based on if connection was successful

		.PARAMETER EncryptedFilePath
			The path to the encrypted password file

		.PARAMETER UseSysscriptDefaults
			This is here as a way to maintain backward compatability.
			Do not use this for any future development.

		.PARAMETER MaxPowerShellVersion
			This parameter specifies the maximum PS version. It's here since this function
			does not currently work with the PS Core versions (6 & 7).

		.PARAMETER Account
			A null value for this uses Get-HSCConnectionAccount to build the credential object. Otherwise,
			the credential object is built using the value passed into this function.

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Connect-HSCOffice365
			Connection Account: jbrusoeadmin@hsc.wvu.edu
			Encrypted File Path: C:\Users\jbrusoeadmin\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\jbrusoeadmin-HSVDIWIN10JB.txt
			Connecting to Office 365...

			Authenticated to Office 365

			Account                  Environment TenantId                             TenantDomain           AccountType
			-------                  ----------- --------                             ------------           -----------
			jbrusoeadmin@hsc.wvu.edu AzureCloud  a2d1f95f-8510-4424-8ae1-5c596bdbd578 WVUHSC.onmicrosoft.com User
			True

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Connect-HSCOffice365 (Connecting from PowerShell 7)
			WARNING: This function doesn't run in PowerShell version 7

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: June 16, 2020
	#>

	[CmdletBinding()]
	[Alias("Connect-Office365")]
	[OutputType([bool])]
	param (
		[switch]$UseSysscriptDefault,
		[string]$EncryptedFilePath = $null,
		[float]$MaxPowerShellVersion = 5.1, #Due to issues with PS Core (Versions 6 & 7)
		[string]$Account = $null
	)
	
	begin
	{
		$Error.Clear()

		if ([string]::IsNullOrEmpty($Account)) {
			Write-Verbose "Getting Connection Account"
			$Account = Get-HSCConnectionAccount
			Write-Verbose "Connection Account: $Account"
		}
		
		#Determine path to encrypted file
		if ($UseSysscriptDefault)
		{
			$EncryptedFilePath = Get-HSCEncryptedFilePath -UseSysscriptDefault
		}
		else
		{
			$EncryptedFilePath = Get-HSCEncryptedFilePath	
		}

		if (Test-HSCConnectionRequirement -Account $Account -EncryptedFilePath $EncryptedFilePath -MaxPowerShellVersion $MaxPowerShellVersion)
		{
			Write-Output "Connection Account: $Account" | Out-Host
			Write-Output "Encrypted File Path: $EncryptedFilePath" | Out-Host
			Write-Output "Connecting to the HSC Office 365 tenant with AzureAD cmdlets..." | Out-Host
		}
		else
		{
			Write-Warning "Connection prequisites not met" | Out-Host
			Continue #Forces function to end with begin/process/end blocks	
		}
	}

	process
	{
		try 
		{
			Write-Verbose "Generating credential for $Account" | Out-Host

			$Password = cat $EncryptedFilePath  | ConvertTo-SecureString
			$Credential = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $Account, $Password

			Write-Verbose "Successfully generated credential object"
		}
		catch 
		{
			Write-Warning "Error generating credential. Unable to connect to Office 365 with AzureAD" | Out-Host
			return $false
		}
	
		try 
		{
			Connect-AzureAD -Credential $Credential -ErrorAction Stop
			Write-Output "Authenticated to Office 365`n" | Out-Host
	
			return $true
		}
		catch 
		{
			Write-Warning "Unable to authenticate to the Office 365 tenant with AzureAD cmdlets" | Out-Host
			return $false
		}
	}
}

function Connect-HSCOffice365MSOL
{
	<#
		.SYNOPSIS
			This function establishes a connection to the HSC Office 365 tenant with the MSOL cmdlets.

		.PARAMETER EncryptedFilePath
			The path to the encrypted password file

		.PARAMETER UseSysscriptDefaults
			This is here as a way to maintain backward compatability.
			Do not use this for any future development.

		.PARAMETER MaxPowerShellVersion
			This parameter specifies the maximum PS version. It's here since this function
			does not currently work with the PS Core versions (6 & 7).

		.PARAMETER Account
			A null value for this uses Get-HSCConnectionAccount to build the credential object. Otherwise,
			the credential object is built using the value passed into this function.

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Connect-HSCOffice365MSOL
			Connecting to Office 365 with MSOL cmdlets..
			Authenticated to Office 365 with MSOL cmdlets
			True

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Connect-HSCOffice365MSOL -Verbose
			Connecting to Office 365 with MSOL cmdlets..

			VERBOSE: UserName: jbrusoeadmin
			VERBOSE: Connection Account: jbrusoeadmin@hsc.wvu.edu
			Authenticated to Office 365 with MSOL cmdlets
			True
			
		.EXAMPLE
			PS C:\Users\microsoft> Connect-HSCOffice365MSOL (Connecting from PowerShell 7)
			WARNING: This function doesn't run in PowerShell version 7
			WARNING: Connection prequisites not met

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 1, 2020

			PS Version 5.1 Tested: June 30, 2020 
			Does not work on PS Version 7.0.2 - June 30, 2020
	#>

	[CmdletBinding()]
	[Alias("Connect-Office365MSOL")]
	[OutputType([bool])]
	param (
		[switch]$UseSysscriptDefault,
		[string]$EncryptedFilePath = $null,
		[float]$MaxPowerShellVersion = 5.1,
		[string]$Account = $null
	)

	begin
	{
		$Error.Clear()

		if ([string]::IsNullOrEmpty($Account)) {
			Write-Verbose "Getting Connection Account"
			$Account = Get-HSCConnectionAccount
			Write-Verbose "Connection Account: $Account"
		}

		#Determine path to encrypted file
		if ($UseSysscriptDefault)
		{
			$EncryptedFilePath = Get-HSCEncryptedFilePath -UseSysscriptDefault
		}
		else
		{
			$EncryptedFilePath = Get-HSCEncryptedFilePath	
		}

		if (Test-HSCConnectionRequirement -Account $Account -EncryptedFilePath $EncryptedFilePath -MaxPowerShellVersion $MaxPowerShellVersion)
		{
			Write-Output "Connection Account: $Account" | Out-Host
			Write-Output "Encrypted File Path: $EncryptedFilePath" | Out-Host
			Write-Output "Connecting to the HSC Office 365 tenant with MSOL cmdlets..." | Out-Host
		}
		else
		{
			Write-Warning "Connection prequisites not met" | Out-Host
			Continue #Forces function to end with begin/process/end blocks	
		}
	}

	process
	{
		try {
			Write-Verbose "Generating credential for $Account" 

			$Password = cat $EncryptedFilePath  | ConvertTo-SecureString
			$Credential = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $Account, $Password

			Write-Verbose "Successfully generated credential object"
		}
		catch {
			Write-Warning "Error generating credential. Unable to connect to Office 365 with MSOnline cmdlets" | Out-Host
			return $false
		}
	
		try 
		{
			Connect-MSOLService -Credential $Credential -ErrorAction Stop
			Write-Output "Authenticated to Office 365 with MSOL cmdlets`n" | Out-Host
	
			return $true
		}
		catch 
		{
			Write-Warning "Unable to authenticate to the Office 365 tenant with MSOL cmdlets" | Out-Host
			return $false
		}
	}
}

function Connect-MainCampusOffice365
{
	<#
		.SYNOPSIS
			This function establishes a connection to the main campus tenant with AzureAD cmdlets

		.PARAMETER Account
			The username to use when authenticating to the main campus Office 365 tenant

		.PARAMETER EncryptedFilePath
			Path to the encrypted file needed to connect to the tenant

		.PARAMETER MaxPowerShellVersion
			This parameter specifies the maximum PS version. It's here since this function
			does not currently work with the PS Core versions (6 & 7).
			
		.EXAMPLE
			PS C:\Windows\system32> Connect-MainCampusOffice365
			Encrypted File Path: C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\mc3.txt
			Connection Account: hsccampusit@westvirginiauniversity.onmicrosoft.com
			Encrypted File Path: C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\mc3.txt
			Connecting to the main campus HSC Office 365 tenant with AzureAD cmdlets...

			Authenticated to main campus Office 365 with AzureAD cmdlets

			Account                                            Environment TenantId                             TenantDomain
			-------                                            ----------- --------                             ------------
			HSCCampusIT@WestVirginiaUniversity.onmicrosoft.com AzureCloud  a7531e18-3e5d-4145-ae4c-336d320ca7e4 WestVirginiaUniv...
			True
			
		.EXAMPLE
			PS C:\Users\microsoft> Connect-MainCampusOffice365 (Connecting from Windows 7)
			Encrypted File Path: C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\mc3.txt
			WARNING: This function doesn't run in PowerShell version 7
			WARNING: Connection prequisites not met

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 2, 2020

			PS Version 5.1 Tested: July 2, 2020 
			Does not work on PS Version 7.0.2 - July 2, 2020
	#>
	[CmdletBinding()]
	[OutputType([bool])]
	param (
		[string]$Account = "hsccampusit@westvirginiauniversity.onmicrosoft.com",
		[string]$EncryptedFilePath = $null,
		[float]$MaxPowerShellVersion = 5.1 #Due to issues with PS Core (Versions 6 & 7)
	)

	begin
	{
		$Error.Clear()

		#Get encrypted file path
		if ([string]::IsNullOrEmpty($EncryptedFilePath))
		{
			$ServerName = Get-HSCServerName -MandatoryServerNames
			$ServerNumber = $ServerName.substring($ServerName.Length - 1)
			$EncryptedFilePath = (Get-HSCEncryptedDirectoryPath) + "mc$ServerNumber.txt"

			Write-Output "Encrypted File Path: $EncryptedFilePath" | Out-Host
		}

		if (Test-HSCConnectionRequirement -Account $Account -EncryptedFilePath $EncryptedFilePath -MaxPowerShellVersion $MaxPowerShellVersion)
		{
			Write-Output "Connection Account: $Account" | Out-Host
			Write-Output "Encrypted File Path: $EncryptedFilePath" | Out-Host
			Write-Output "Connecting to the main campus HSC Office 365 tenant with AzureAD cmdlets..." | Out-Host
		}
		else
		{
			Write-Warning "Connection prequisites not met" | Out-Host
			Continue #Forces function to end with begin/process/end blocks	
		}
	}

	process
	{
		try {
			$Password = cat $EncryptedFilePath  | ConvertTo-SecureString
			$Credential = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $Account, $Password
		}
		catch {
			Write-Warning "Error generating user credential. Unable to connect to main campus tenant with AzureAD cmdlets" | Out-Host
			return $false
		}
		
		try 
		{
			Connect-AzureAD -Credential $Credential -ErrorAction Stop
			Write-Output "Authenticated to main campus Office 365 with AzureAD cmdlets`n" | Out-Host
	
			return $true
		}
		catch 
		{
			Write-Warning "Unable to authenticate to the main campus Office 365 tenant with AzureAD cmdlets" | Out-Host
			return $false
		}
	}
}

function Connect-MainCampusOffice365MSOL
{
	<#
		.SYNOPSIS
			This function establishes a connection to the main campus tenant with AzureAD cmdlets

		.PARAMETER ACCOUNT
			The username to connect to the tenant with
			
		.PARAMETER EncryptedFilePath
			Path to the encrypted file needed to connect to the tenant

		.PARAMETER MaxPowerShellVersion
			This parameter specifies the maximum PS version. It's here since this function
			does not currently work with the PS Core versions (6 & 7).

		.EXAMPLE
			PS C:\Windows\system32> Connect-MainCampusOffice365MSOL
			Encrypted File Path: C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\mc3.txt
			Connection Account: hsccampusit@westvirginiauniversity.onmicrosoft.com
			Encrypted File Path: C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\mc3.txt
			Connecting to the main campus HSC Office 365 tenant with MSOnline cmdlets...
			Authenticated to main campus Office 365 with MSOnline cmdlets
			True
			
		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 2, 2020

			PS Version 5.1 Tested: July 2, 2020 
			Does not work on PS Version 7.0.2 - July 1, 2020
	#>

	[CmdletBinding()]
	[OutputType([bool])]
	param (
		[string]$Account = "hsccampusit@westvirginiauniversity.onmicrosoft.com",
		[string]$EncryptedFilePath = $null,
		[float]$MaxPowerShellVersion = 5.1 #Due to issues with PS Core (Versions 6 & 7)
	)

	begin
	{
		$Error.Clear()

		#Get encrypted file path
		if ([string]::IsNullOrEmpty($EncryptedFilePath))
		{
			$ServerName = Get-HSCServerName -MandatoryServerNames
			$ServerNumber = $ServerName.substring($ServerName.Length - 1)
			$EncryptedFilePath = (Get-HSCEncryptedDirectoryPath) + "mc$ServerNumber.txt"

			Write-Output "Encrypted File Path: $EncryptedFilePath" | Out-Host
		}

		if (Test-HSCConnectionRequirement -Account $Account -EncryptedFilePath $EncryptedFilePath -MaxPowerShellVersion $MaxPowerShellVersion)
		{
			Write-Output "Connection Account: $Account" | Out-Host
			Write-Output "Encrypted File Path: $EncryptedFilePath" | Out-Host
			Write-Output "Connecting to the main campus Office 365 tenant with MSOnline cmdlets..." | Out-Host
		}
		else
		{
			Write-Warning "Connection prequisites not met" | Out-Host
			Continue #Forces function to end with begin/process/end blocks	
		}
	}

	process
	{
		try {
			$Password = cat $EncryptedFilePath  | ConvertTo-SecureString
			$Credential = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $Account, $Password
		}
		catch {
			Write-Warning "Error generating user credential. Unable to connect to main campus tenant with MSOnline cmdlets" | Out-Host
			return $false
		}
		
		try 
		{
			Connect-MSOLService -Credential $Credential -ErrorAction Stop
			Write-Output "Authenticated to main campus Office 365 with MSOnline cmdlets`n" | Out-Host
	
			return $true
		}
		catch 
		{
			Write-Warning "Unable to authenticate to the main campus Office 365 tenant with MSOnline cmdlets" | Out-Host
			return $false
		}
	}
}

function Connect-WVUFoundationOffice365
{
	<#
		.SYNOPSIS
			This function establishes a connection to the WVU Founcation tenant with AzureAD cmdlets.

		.PARAMETER Account
			The username needed to establish the connection to the WVU Foundation tenant
			
		.PARAMETER EncryptedFilePath
			Path to the encrypted file needed to connect to the tenant

		.PARAMETER MaxPowerShellVersion
			This parameter specifies the maximum PS version. It's here since this function
			does not currently work with the PS Core versions (6 & 7).
		
		.EXAMPLE
			PS C:\Windows\system32> Connect-WVUFoundationOffice365
			Encrypted File Path: C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\WVUF3.txt
			Connection Account: dirsync@wvufoundation.onmicrosoft.com
			Encrypted File Path: C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\WVUF3.txt
			Connecting to the WVU Founation Office 365 tenant with AzureAD cmdlets...	

			Authenticated to WVUFoundation Office 365 with AzureAD cmdlets

			Account                               Environment TenantId                             TenantDomain                  
			-------                               ----------- --------                             ------------                  
			dirsync@wvufoundation.onmicrosoft.com AzureCloud  d8feb9ee-a7bd-4441-8a99-6cee12dfdd46 wvufoundation.onmicrosoft.com
			True

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 2, 2020

			PS Version 5.1 Tested: July 2, 2020 
			Does not work on PS Version 7.0.2 - July 1, 2020
	#>

	[CmdletBinding()]
	[OutputType([bool])]
	param (
		[string]$Account = "dirsync@wvufoundation.onmicrosoft.com",
		[string]$EncryptedFilePath = $null,
		[float]$MaxPowerShellVersion = 5.1 #Due to issues with PS Core (Versions 6 & 7)
	)

	begin
	{
		$Error.Clear()

		#Get encrypted file path
		if ([string]::IsNullOrEmpty($EncryptedFilePath))
		{
			$ServerName = Get-HSCServerName -MandatoryServerNames
			$ServerNumber = $ServerName.substring($ServerName.Length - 1)
			$EncryptedFilePath = (Get-HSCEncryptedDirectoryPath) + "WVUF$ServerNumber.txt"

			Write-Output "Encrypted File Path: $EncryptedFilePath" | Out-Host
		}

		if (Test-HSCConnectionRequirement -Account $Account -EncryptedFilePath $EncryptedFilePath -MaxPowerShellVersion $MaxPowerShellVersion)
		{
			Write-Output "Connection Account: $Account" | Out-Host
			Write-Output "Encrypted File Path: $EncryptedFilePath" | Out-Host
			Write-Output "Connecting to the WVU Founation Office 365 tenant with AzureAD cmdlets..." | Out-Host
		}
		else
		{
			Write-Warning "Connection prequisites not met" | Out-Host
			Continue #Forces function to end with begin/process/end blocks	
		}
	}

	process
	{
		try {
			$Password = cat $EncryptedFilePath  | ConvertTo-SecureString -ErrorAction Stop
			$Credential = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $Account, $Password -ErrorAction Stop
		}
		catch {
			Write-Warning "Unable to genereate credential object" | Out-Host
			return $false
		}
	
		try 
		{
			Connect-AzureAD -Credential $Credential -ErrorAction Stop
			Write-Output "Authenticated to WVUFoundation Office 365 with AzureAD cmdlets`n" | Out-Host
	
			return $true
		}
		catch 
		{
			Write-Warning "Unable to authenticate to the WVU Foundation Office 365 tenant with AzureAD cmdlets" | Out-Host
			return $false
		}
	}
}

function Connect-WVUFoundationOffice365MSOL
{
	<#
		.SYNOPSIS
			This function establishes a connection to the WVU Founcation tenant with MSOnline cmdlets

		.PARAMETER Account
			The actual username to use when connecting to the WVU Founation tenant
			
		.PARAMETER EncryptedFilePath
			Path to the encrypted file needed to connect to the tenant

		.PARAMETER MaxPowerShellVersion
			This parameter specifies the maximum PS version. It's here since this function
			does not currently work with the PS Core versions (6 & 7).

		.EXAMPLE
			PowerShell Version: 5.1.14393.3471

			PS C:\Windows\system32> Connect-WVUFoundationOffice365MSOL
			Encrypted File Path: C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\WVUF3.txt
			Connection Account: dirsync@wvufoundation.onmicrosoft.com
			Encrypted File Path: C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\WVUF3.txt
			Connecting to the WVU Founation Office 365 tenant with MSOL cmdlets...
			Authenticated to WVU Foundation Office 365 with MSOL cmdlets
			True

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 1, 2020

			PS Version 5.1 Tested: July 2, 2020 
			Does not work on PS Version 7.0.2 - July 1, 2020
	#>

	[CmdletBinding()]
	[OutputType([bool])]
	param (
		[string]$Account = "dirsync@wvufoundation.onmicrosoft.com",
		[string]$EncryptedFilePath = $null,
		[float]$MaxPowerShellVersion = 5.1 #Due to issues with PS Core (Versions 6 & 7)
	)

	begin
	{
		$Error.Clear()

		#Get encrypted file path
		if ([string]::IsNullOrEmpty($EncryptedFilePath))
		{
			$ServerName = Get-HSCServerName -MandatoryServerNames
			$ServerNumber = $ServerName.substring($ServerName.Length - 1)
			$EncryptedFilePath = (Get-HSCEncryptedDirectoryPath) + "WVUF$ServerNumber.txt"

			Write-Output "Encrypted File Path: $EncryptedFilePath" | Out-Host
		}

		if (Test-HSCConnectionRequirement -Account $Account -EncryptedFilePath $EncryptedFilePath -MaxPowerShellVersion $MaxPowerShellVersion)
		{
			Write-Output "Connection Account: $Account" | Out-Host
			Write-Output "Encrypted File Path: $EncryptedFilePath" | Out-Host
			Write-Output "Connecting to the WVU Founation Office 365 tenant with MSOL cmdlets..." | Out-Host
		}
		else
		{
			Write-Warning "Connection prequisites not met" | Out-Host
			Continue #Forces function to end with begin/process/end blocks	
		}
	}

	process
	{
		try {
			$Password = cat $EncryptedFilePath  | ConvertTo-SecureString
			$Credential = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $Account, $Password	
		}
		catch {
			Write-Warning "Unable to generate account credentials" | Out-Host
			return $false
		}
		
		try 
		{
			Connect-MSOLService -Credential $Credential -ErrorAction Stop
			Write-Output "Authenticated to WVU Foundation Office 365 with MSOL cmdlets`n" | Out-Host
	
			return $true
		}
		catch 
		{
			Write-Warning "Unable to authenticate to the WVU Foundation Office 365 tenant with MSOL cmdlets" | Out-Host
			return $false
		}
	}
}

function Get-HSCConnectionAccount
{
	<#
		.SYNOPSIS
			Randomly determines which of the microsoft accounts will be used to connected to the HSC Office 365 tenant

		.OUTPUTS
			A string that contains the microsoft<number>@hsc.wvu.edu account to use or the username of the currently
			logged on user. If logged in with the microsoft account, a randomly generated account (1, 2, 3, or 4) will
			be used instead.

		.EXAMPLE
			PS C:\Users\jbrus> Get-HSCConnectionAccount
			Connection Account: jbrusoeadmin@hsc.wvu.edu
			jbrusoeadmin@hsc.wvu.edu

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: June 30, 2020

			PS Version 5.1 Tested: June 30, 2020 
			PS Version 7.0.2 Tested: June 30, 2020
	#>
	
	[CmdletBinding()]
	[alias("Get-ConnectionAccount")]
	[OutputType([String])]
	param ()
	
	begin
	{
		$UserName = (Get-HSCLoggedOnUser).UserName
		Write-Verbose "UserName: $UserName" | Out-Host
	}
	
	process
	{
		try
		{
			if ($UserName -eq "microsoft")
			{
				Write-Verbose "Randomly generating microsoft account number" | Out-Host

				$AccountNumber = Get-Random -Minimum 1 -Maximum 5
				$ConnectionAccount = "microsoft$AccountNumber@hsc.wvu.edu"
			}
			else
			{
				$ConnectionAccount = $UserName + "@hsc.wvu.edu"
			}
		}
		catch
		{
			Write-Warning "Error generating connection account" | Out-Host
			$ConnectionAccount = $null
		}
	}

	end
	{
		Write-Verbose "Connection Account: $ConnectionAccount" | Out-Host
		Return $ConnectionAccount
	}
}

function Test-HSCOffice365Connection
{
	<#
		.SYNOPSIS
			This function determines if a connection to Office 365 has been estabalished

		.OUTPUTS
			A PSObject that contains boolean values for AzureAD and MSOnline connections. This object
			also includes 

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Test-HSCOffice365Connection

			AzureAD AzureADTenantName MSOnline MSOLTenantName
			------- ----------------- -------- --------------
			False                      False
			
		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Connect-HSCOffice365
			PS C:\Users\jbrusoeadmin> Test-HSCOffice365Connection

			AzureAD AzureADTenantName MSOnline MSOLTenantName
			------- ----------------- -------- --------------	
			True WVUHSC               False
			
		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Connect-HSCOffice365MSOL
			PS C:\Users\jbrusoeadmin> Test-HSCOffice365Connection

			AzureAD AzureADTenantName MSOnline MSOLTenantName
			------- ----------------- -------- --------------
			  False                       True WVUHSC

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Connect-HSCOffice365MSOL
			PS C:\Users\jbrusoeadmin> Connect-HSCOffice365
			PS C:\Users\jbrusoeadmin> Test-HSCOffice365Connection

			AzureAD AzureADTenantName MSOnline MSOLTenantName
			------- ----------------- -------- --------------
			   True WVUHSC                True WVUHSC
			
		.NOTES
			Written by: Jeff Brusoe
			Last Updated: June 30, 2020

			PS Version 5.1 Tested: July 1, 2020 
			Does not work on PS Version 7.0.2 - July 1, 2020
	#>

	[CmdletBinding()]
	[OutputType([PSObject])]
	param()

	begin
	{
		Write-Verbose "Determing if cloud connection has been estbalished" | Out-Host

		$ConnectionInformation = New-Object -TypeName PSObject
	}

	process
	{
		#Testing AzureAD Connection
		try 
		{
			Write-Verbose "Testing AzureAD connection..." | Out-Host
			Get-AzureADTenantDetail -ErrorAction Stop | Out-Null
			Write-Verbose "Connected with AzureAD" | Out-Host

			$ConnectionInformation | Add-Member -MemberType NoteProperty -Name AzureAD -Value $true
			$ConnectionInformation | Add-Member -MemberType NoteProperty -Name AzureADTenantName -Value (Get-HSCTenantName)
		}
		catch
		{
			Write-Verbose "Not connected with AzureAD" | Out-Host
			$ConnectionInformation | Add-Member -MemberType NoteProperty -Name AzureAD -Value $false
			$ConnectionInformation | Add-Member -MemberType NoteProperty -Name AzureADTenantName -Value $null
		}

		#Testing MSOL Connection
		try 
		{
			Write-Verbose "Testing MSOnline connection..." | Out-Host
			Get-MSOLAccountSku -ErrorAction Stop | Out-Null
			Write-Verbose "Connected with MSOnline" | Out-Host

			$ConnectionInformation | Add-Member -MemberType NoteProperty -Name MSOnline -Value $true
			$ConnectionInformation | Add-Member -MemberType NoteProperty -Name MSOLTenantName -Value (Get-HSCTenantNameMSOL)
		}
		catch
		{
			Write-Verbose "Not connected with MSOnline" | Out-Host
			$ConnectionInformation | Add-Member -MemberType NoteProperty -Name MSOnline	 -Value $false
			$ConnectionInformation | Add-Member -MemberType NoteProperty -Name MSOLTenantName -Value $null
		}
	}

	end
	{
		return $ConnectionInformation
	}
}

function Test-HSCConnectionRequirement
{
	<#
		.SYNOPSIS
			The purpose of this function is to ensure that the calling file has met the necessary
			requirements in order to connect to an Office 365 tenant.

		.DESCRIPTION
			Tests performed by this function include:
			1. PowerShell Version
			2. Load AzureAD or MSOnline
			3. Test for null value of account
			4. Test for null value and existence of encrypted file path

		.PARAMETER MaxPowerShellVersion
			Used to determine if the callng function can run in PowerShell Core(Versions 6 and 7)

		.PARAMETER MSOnline
			A flag to indicate that MSOnline should be loaded instead of AzureAD

		.PARAMETER Account
			The account being used to connect to Office 365.

		.PARAMETER EncryptedFilePath
			Path to encrypted secure string file

		.PARAMETER ExchangeOnline
			This is a flag to indicate that the function is used to check an Exchange Online connection and doesn't need
			to load the AzureAD/MSOnline module.

		.OUTPUTS
			A boolean value indicating if the tests listed in the description were all passed or if any failed.

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Test-HSCConnectionRequirement -Verbose -Account $Account -EncryptedFilePath $EncryptedFilePath -MaxPowerShellVersion $MaxPowerShellVersion
			VERBOSE: UserName: jbrusoeadmin
			VERBOSE: Connection Account: jbrusoeadmin@hsc.wvu.edu
			VERBOSE: PowerShell Version: 5.1
			VERBOSE: Correct version of PowerShell detected
			VERBOSE: Loading AzureAD Module
			VERBOSE: Loading module from path 'C:\Program Files\WindowsPowerShell\Modules\AzureAD\2.0.2.31\AzureAD.psd1'.
			VERBOSE: Loading 'FormatsToProcess' from path 'C:\Program Files\WindowsPowerShell\Modules\AzureAD\2.0.2.31\AzureAD.Format.ps1xml'.
			VERBOSE: Populating RepositorySourceLocation property for module AzureAD.
			VERBOSE: All connection prequistite tests have passed
			
		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 2, 2020
	#>

	[CmdletBinding()]
	[OutputType([bool])]
	param (
		[float]$MaxPowerShellVersion = 5.1, #Used to verify correct version of PS is being used.
		[switch]$MSOnline,
		[string]$Account,
		[string]$EncryptedFilePath,
		[switch]$ExchangeOnline
	)

		#1. Check on PowerShell version
		#This function doesn't work with PS version 7
		$PSVersion = ((Get-HSCPowerShellVersion) -as [float])
		Write-Verbose "PowerShell Version: $PSVersion" | Out-Host

		if ($PSVersion -gt $MaxPowerShellVersion)
		{
			Write-Warning "This function doesn't run in PowerShell version $PSVersion" | Out-Host
			return $false
		}
		else
		{
			Write-Verbose "Correct version of PowerShell detected" | Out-Host
		}

		#2. Load AzureAD or MSOnline module
		if (!$ExchangeOnline)
		{
			try 
			{
				if ($MSOnline)
				{
					Write-Verbose "Loading MSOnline Module" | Out-Host
					Import-Module MSOnline -ErrorAction Stop
				}
				else
				{
					Write-Verbose "Loading AzureAD Module" | Out-Host
					Import-Module AzureAD -ErrorAction Stop
				}
			}
			catch
			{
				if ($MSOnline)
				{
					Write-Warning "Error loading the MSOnline module" | Out-Host
				}
				else
				{
					Write-Warning "Error loading AzureAD module" | Out-Host
				}
	
				return $false
			}
		}
		else {
			Write-Verbose "Skipping AzureAD/MSOnline check because of ExchangeOnline flag..." | Out-Host
		}

		#3. Test for null value of account (used to logon to cloud with)
		if ([string]::IsNullOrEmpty($Account))
		{
			Write-Warning "Account is null" | Out-Host
			return $false
		}

		#4. Test for existence and non-null value of $EncryptedFilePath
		try
		{
			Test-Path $EncryptedFilePath -ErrorAction Stop	
		}
		catch
		{
			Write-Warning "Invalid encrypted file path" | Out-Host
			return $false
		}

		Write-Verbose "All connection prequistite tests have passed" | Out-Host
		return $true
}

################################################################
# Functions related to establishing Exchange Online Connection #
################################################################

function Connect-HSCExchangeOnline
{
	<#
		.SYNOPSIS
			This function establishes a connection to ExchangeOnline with V2 of the Exchange Online cmdlets

		.DESCRIPTION
			In addition to using the V2 Exchange Online cmdlets, the V1 cmdlets are also downloaded when
			establishing the connection.

		.OUTPUTS
			Returns a boolean value to indicate if the connection was successful or not.

		.PARAMETER UseSysscriptDefaults
			This is provided only for backwards compatability. Do not use this for any new files.

		.PARAMETER EncryptedFilePath
			The path to the encrypted file. If it's blank, the value from Get-HSCEncryptedFilePath will be used.
		
		.PARAMETER MaxPowerShellVersoin
			Used to ensure that the correct version of PowerShell is running since some functions don't work with PS Core (Versions 6 & 7)
		
		.EXAMPLE
			PS C:\Windows\system32> Connect-HSCExchangeOnline
			Connection Account: microsoft1@hsc.wvu.edu
			Encrypted File Path: C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\microsoft-SYSSCRIPT3.txt
			Connecting to HSC Exchange Online with V2 cmdlets...

			----------------------------------------------------------------------------
			The module allows access to all existing remote PowerShell (V1) cmdlets in addition to the 9 new, faster, and more reliable cmdlets.

			|--------------------------------------------------------------------------|
			|    Old Cmdlets                    |    New/Reliable/Faster Cmdlets       |
			|--------------------------------------------------------------------------|
			|    Get-CASMailbox                 |    Get-EXOCASMailbox                 |
			|    Get-Mailbox                    |    Get-EXOMailbox                    |
			|    Get-MailboxFolderPermission    |    Get-EXOMailboxFolderPermission    |
			|    Get-MailboxFolderStatistics    |    Get-EXOMailboxFolderStatistics    |
			|    Get-MailboxPermission          |    Get-EXOMailboxPermission          |
			|    Get-MailboxStatistics          |    Get-EXOMailboxStatistics          |
			|    Get-MobileDeviceStatistics     |    Get-EXOMobileDeviceStatistics     |
			|    Get-Recipient                  |    Get-EXORecipient                  |
			|    Get-RecipientPermission        |    Get-EXORecipientPermission        |
			|--------------------------------------------------------------------------|

			To get additional information, run: Get-Help Connect-ExchangeOnline or check https://aka.ms/exops-docs

			Send your product improvement suggestions and feedback to exocmdletpreview@service.microsoft.com. For issues related to the module, contact Microsoft support. Don't use the feedback alias for problems or support issues.
			----------------------------------------------------------------------------

			Successfully authenticated to Exchange Online with V2 cmdlets
			True

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 2, 2020

			PS Version 5.1 Tested: July 1, 2020 
			Does not work on PS Version 7.0.2 - July 1, 2020
	#>

	[CmdletBinding()]
	[OutputType([bool])]
		param (
		[switch]$UseSysscriptDefault,
		[string]$EncryptedFilePath = $null,
		[float]$MaxPowerShellVersion = 5.1 #Used to verify correct version of PS is being used.
	)

	begin
	{
		$Error.Clear()
		$Account = Get-HSCConnectionAccount

		#Determine path to encrypted file
		if ($UseSysscriptDefault)
		{
			$EncryptedFilePath = Get-HSCEncryptedFilePath -UseSysscriptDefault
		}
		else
		{
			$EncryptedFilePath = Get-HSCEncryptedFilePath	
		}

		if (Test-HSCConnectionRequirement -Account $Account -EncryptedFilePath $EncryptedFilePath -MaxPowerShellVersion $MaxPowerShellVersion -ExchangeOnline)
		{
			Write-Output "Connection Account: $Account" | Out-Host
			Write-Output "Encrypted File Path: $EncryptedFilePath" | Out-Host
			Write-Output "Connecting to HSC Exchange Online with V2 cmdlets..." | Out-Host
		}
		else
		{
			Write-Warning "Connection prequisites not met" | Out-Host
			Continue #Forces function to end with begin/process/end blocks	
		}
	}

	process
	{
		try {
			$Password = cat $EncryptedFilePath | ConvertTo-SecureString
			$Credential = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $Account, $Password
		}
		catch {
			Write-Warning "Error generating credential object" | Out-Host
			return $false
		}
	
		try 
		{
			Connect-ExchangeOnline -Credential $Credential -ShowProgress $true -ErrorAction Stop
			
			Write-Output "`nSuccessfully authenticated to Exchange Online with V2 cmdlets`n"
			return $true
		}
		catch
		{
			Write-Warning "There was an error connecting to Exchange online with V2 cmdlets.`n"
			return $false
		}
	}
}

function Connect-HSCExchangeOnlineV1
{
	<#
		.SYNOPSIS
			This function establishes a connection to ExchangeOnline using the older Exchange cmdlets

		.DESCRIPTION
			The V1 Exchange cmdlets are used to establish a connect to HSC Exchange Online wit this function.
			This will prevent any of the newer cmdlets such as Get-EXOMailbox or Get-EXOCasMailbox from being used.

		.OUTPUTS
			Returns a boolean value to indicate if the connection was successful or not.

		.PARAMETER UseSysscriptDefaults
			This is provided only for backwards compatability. Do not use this for any new files.

		.PARAMETER EncryptedFilePath
			The path to the encrypted file. If it's blank, the value from Get-HSCEncryptedFilePath will be used.
		
		.PARAMETER MaxPowerShellVersoin
			Used to ensure that the correct version of PowerShell is running since some functions don't work with PS Core (Versions 6 & 7)

		.EXAMPLE
			PS C:\Windows\system32> Connect-HSCExchangeOnlineV1
			Connection Account: microsoft2@hsc.wvu.edu
			Encrypted File Path: C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\microsoft-SYSSCRIPT3.txt
			Connecting to HSC Exchange Online with V1 cmdlets...
			WARNING: Your connection has been redirected to the following URI:
			"https://ps.outlook.com/PowerShell-LiveID?PSVersion=5.1.14393.3471 "
			WARNING: The names of some imported commands from the module 'tmp_qnavyowt.5ec' include unapproved verbs that might
			make them less discoverable. To find the commands with unapproved verbs, run the Import-Module command again with the
			Verbose parameter. For a list of approved verbs, type Get-Verb.

			Successfully authenticated to Exchange Online and downloadeded PowerShell V1 cmdlets
			True
			
		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 2, 2020

			PS Version 5.1 Tested: July 1, 2020 
			Does not work on PS Version 7.0.2 - July 1, 2020
	#>

	[CmdletBinding()]
	[Alias("Connect-ExchangeOnlineV1")]
	[OutputType([bool])]

	param (
		[switch]$UseSysscriptDefault,
		[string]$EncryptedFilePath = $null,
		[float]$MaxPowerShellVersion = 5.1 #Used to verify correct version of PS is being used.
	)

	begin
	{
		$Error.Clear()
		$Account = Get-HSCConnectionAccount

		#Determine path to encrypted file
		if ($UseSysscriptDefault)
		{
			$EncryptedFilePath = Get-HSCEncryptedFilePath -UseSysscriptDefault
		}
		else
		{
			$EncryptedFilePath = Get-HSCEncryptedFilePath	
		}

		if (Test-HSCConnectionRequirement -Account $Account -EncryptedFilePath $EncryptedFilePath -MaxPowerShellVersion $MaxPowerShellVersion -ExchangeOnline)
		{
			Write-Output "Connection Account: $Account" | Out-Host
			Write-Output "Encrypted File Path: $EncryptedFilePath" | Out-Host
			Write-Output "Connecting to HSC Exchange Online with V1 cmdlets..." | Out-Host
		}
		else
		{
			Write-Warning "Connection prequisites not met" | Out-Host
			Continue #Forces function to end with begin/process/end blocks	
		}
	}

	process
	{
		try {
			$Password = cat $EncryptedFilePath  | ConvertTo-SecureString
			$Credential = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $Account, $Password
		}
		catch {
			Write-Warning "Unable to generate credential object" | Out-Host
			return $false
		}
		
		try 
		{
			$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Credential -Authentication Basic -AllowRedirection -ErrorAction Stop
			Import-Module (Import-PSSession -Session $Session -AllowClobber -DisableNameChecking -Verbose:$false) -Global
			#Import-PSSession $Session
			
			Export-ModuleMember -Variable $Session
			
			Write-Output "`nSuccessfully authenticated to Exchange Online and downloadeded PowerShell V1 cmdlets`n"
			return $true
		}
		catch
		{
			Write-Warning "There was an error connecting to Exchange online with the V1 cmdlets.`n"
			return $false
		}
	}
}

function Connect-MainCampusExchangeOnline
{
		<#
		.SYNOPSIS
			This function establishes a connection to the main campus Exchange Online environment

		.PARAMETER Account
			The username to use when authenticating to the main campus Office 365 tenant

		.PARAMETER EncryptedFilePath
			Path to the encrypted file needed to connect to the tenant

		.PARAMETER MaxPowerShellVersion
			This parameter specifies the maximum PS version. It's here since this function
			does not currently work with the PS Core versions (6 & 7).
			
		.EXAMPLE
			PS C:\Windows\system32> Connect-MainCampusExchangeOnline
			Connection Account: hsccampusit@westvirginiauniversity.onmicrosoft.com
			Encrypted File Path: C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\mc3.txt
			Connecting to the main campus Exchange Online system...

			----------------------------------------------------------------------------
			The module allows access to all existing remote PowerShell (V1) cmdlets in addition to the 9 new, faster, and more relia
			ble cmdlets.

			|--------------------------------------------------------------------------|
			|    Old Cmdlets                    |    New/Reliable/Faster Cmdlets       |
			|--------------------------------------------------------------------------|
			|    Get-CASMailbox                 |    Get-EXOCASMailbox                 |
			|    Get-Mailbox                    |    Get-EXOMailbox                    |
			|    Get-MailboxFolderPermission    |    Get-EXOMailboxFolderPermission    |
			|    Get-MailboxFolderStatistics    |    Get-EXOMailboxFolderStatistics    |
			|    Get-MailboxPermission          |    Get-EXOMailboxPermission          |
			|    Get-MailboxStatistics          |    Get-EXOMailboxStatistics          |
			|    Get-MobileDeviceStatistics     |    Get-EXOMobileDeviceStatistics     |
			|    Get-Recipient                  |    Get-EXORecipient                  |
			|    Get-RecipientPermission        |    Get-EXORecipientPermission        |
			|--------------------------------------------------------------------------|

			To get additional information, run: Get-Help Connect-ExchangeOnline or check https://aka.ms/exops-docs
			Send your product improvement suggestions and feedback to exocmdletpreview@service.microsoft.com. For issues related to the module, contact Microsoft support. Don't use the feedback alias for problems or support issues.
			----------------------------------------------------------------------------

			Successfully authenticated to the main campus Exchange Online system
			True

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 2, 2020

			PS Version 5.1 Tested: July 2, 2020 
			Does not work on PS Version 7.0.2 - July 2, 2020
	#>
	
	[CmdletBinding()]
	[OutputType([bool])]
	param (
		[string]$Account = "hsccampusit@westvirginiauniversity.onmicrosoft.com",
		[string]$EncryptedFilePath = $null,
		[float]$MaxPowerShellVersion = 5.1 #Due to issues with PS Core (Versions 6 & 7)
	)

	begin
	{
		$Error.Clear()

		#Get encrypted file path
		if ([string]::IsNullOrEmpty($EncryptedFilePath))
		{
			$ServerName = Get-HSCServerName -MandatoryServerNames
			$ServerNumber = $ServerName.substring($ServerName.Length - 1)
			$EncryptedFilePath = (Get-HSCEncryptedDirectoryPath) + "mc$ServerNumber.txt"

			Write-Verbose "Encrypted File Path: $EncryptedFilePath" | Out-Host
		}

		if (Test-HSCConnectionRequirement -Account $Account -EncryptedFilePath $EncryptedFilePath -MaxPowerShellVersion $MaxPowerShellVersion -ExchangeOnline)
		{
			Write-Output "Connection Account: $Account" | Out-Host
			Write-Output "Encrypted File Path: $EncryptedFilePath" | Out-Host
			Write-Output "Connecting to the main campus Exchange Online system..." | Out-Host
		}
		else
		{
			Write-Warning "Connection prequisites not met" | Out-Host
			Continue #Forces function to end with begin/process/end blocks	
		}
	}	
	
	process
	{
		try {
			$Password = cat $EncryptedFilePath | ConvertTo-SecureString
			$Credential = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $Account, $Password
		}
		catch {
			Write-Warning "Error generating credential object" | Out-Host
			return $false
		}
	
		try 
		{
			Connect-ExchangeOnline -Credential $Credential -ShowProgress $true -ErrorAction Stop
			
			Write-Output "`nSuccessfully authenticated to the main campus Exchange Online system`n" | Out-Host
			return $true
		}
		catch
		{
			Write-Warning "There was an error connecting to main campus Exchange online system`n" | Out-Host
			return $false
		}
	}
}

function Connect-WVUFoundationExchangeOnline
{
	<#
		.SYNOPSIS
			This function establishes a connection to the WVU Founcation Exchange Online environment

		.PARAMETER Account
			The username needed to establish the connection to the WVU Foundation tenant
			
		.PARAMETER EncryptedFilePath
			Path to the encrypted file needed to connect to the tenant

		.PARAMETER MaxPowerShellVersion
			This parameter specifies the maximum PS version. It's here since this function
			does not currently work with the PS Core versions (6 & 7).
		
		.EXAMPLE
			PS C:\Windows\system32> Connect-WVUFoundationExchangeOnline
			Connection Account: dirsync@wvufoundation.onmicrosoft.com
			Encrypted File Path: C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\WVUF3.txt
			Connecting to the WVU Foundation Office 365 tenant...

			----------------------------------------------------------------------------
			The module allows access to all existing remote PowerShell (V1) cmdlets in addition to the 9 new, faster, and more reliable cmdlets.

			|--------------------------------------------------------------------------|
			|    Old Cmdlets                    |    New/Reliable/Faster Cmdlets       |
			|--------------------------------------------------------------------------|
			|    Get-CASMailbox                 |    Get-EXOCASMailbox                 |
			|    Get-Mailbox                    |    Get-EXOMailbox                    |
			|    Get-MailboxFolderPermission    |    Get-EXOMailboxFolderPermission    |
			|    Get-MailboxFolderStatistics    |    Get-EXOMailboxFolderStatistics    |
			|    Get-MailboxPermission          |    Get-EXOMailboxPermission          |
			|    Get-MailboxStatistics          |    Get-EXOMailboxStatistics          |
			|    Get-MobileDeviceStatistics     |    Get-EXOMobileDeviceStatistics     |
			|    Get-Recipient                  |    Get-EXORecipient                  |
			|    Get-RecipientPermission        |    Get-EXORecipientPermission        |
			|--------------------------------------------------------------------------|

			To get additional information, run: Get-Help Connect-ExchangeOnline or check https://aka.ms/exops-docs
			Send your product improvement suggestions and feedback to exocmdletpreview@service.microsoft.com. For issues related to the module, contact Microsoft support. Don't use the feedback alias for problems or support issues.
			----------------------------------------------------------------------------

			Successfully authenticated to the WVU Founation Exchange Online system
			True
			
		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 2, 2020

			PS Version 5.1 Tested: July 2, 2020 
			Does not work on PS Version 7.0.2 - July 1, 2020
	#>

	[CmdletBinding()]
	[OutputType([bool])]
	param (
		[string]$Account = "dirsync@wvufoundation.onmicrosoft.com",
		[string]$EncryptedFilePath = $null,
		[float]$MaxPowerShellVersion = 5.1 #Due to issues with PS Core (Versions 6 & 7)
	)

	begin
	{
		$Error.Clear()

		#Get encrypted file path
		if ([string]::IsNullOrEmpty($EncryptedFilePath))
		{
			$ServerName = Get-HSCServerName -MandatoryServerNames
			$ServerNumber = $ServerName.substring($ServerName.Length - 1)
			$EncryptedFilePath = (Get-HSCEncryptedDirectoryPath) + "WVUF$ServerNumber.txt"

			Write-Verbose "Encrypted File Path: $EncryptedFilePath" | Out-Host
		}

		if (Test-HSCConnectionRequirement -Account $Account -EncryptedFilePath $EncryptedFilePath -MaxPowerShellVersion $MaxPowerShellVersion -ExchangeOnline)
		{
			Write-Output "Connection Account: $Account" | Out-Host
			Write-Output "Encrypted File Path: $EncryptedFilePath" | Out-Host
			Write-Output "Connecting to the WVU Foundation Office 365 tenant..." | Out-Host
		}
		else
		{
			Write-Warning "Connection prequisites not met" | Out-Host
			Continue #Forces function to end with begin/process/end blocks	
		}
	}

	process
	{
		try {
			$Password = cat $EncryptedFilePath | ConvertTo-SecureString
			$Credential = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $Account, $Password
		}
		catch {
			Write-Warning "Error generating credential object" | Out-Host
			return $false
		}
	
		try 
		{
			Connect-ExchangeOnline -Credential $Credential -ShowProgress $true -ErrorAction Stop
			
			Write-Output "`nSuccessfully authenticated to the WVU Founation Exchange Online system`n" | Out-Host
			return $true
		}
		catch
		{
			Write-Warning "There was an error connecting to the WVU Foundation Exchange online system`n" | Out-Host
			return $false
		}
	}	
}

function Test-HSCExchangeOnlineConnection
{
	<#
		.SYNOPSIS
			This function determines if a connection to ExchangeOnline has been estabalished

		.OUTPUTS
			A PSObject that contains boolean values for ExchangeOnline V1 and V2 connections.

		.EXAMPLE
			PS C:\Users\jbrus> Test-HSCExchangeOnlineConnection

			ExchangeOnlineV2Connection ExchangeOnlineV1Connection
			-------------------------- --------------------------
								False                      False

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Connect-HSCExchangeOnline
			PS C:\Users\jbrusoeadmin> Test-HSCExchangeOnlineConnection

			ExchangeOnlineV2Connection ExchangeOnlineV1Connection
			-------------------------- --------------------------
								  True                      True
					  
		.NOTES
			Written by: Jeff Brusoe
			Last Updated: June 30, 2020

			PS Version 5.1 Tested: July 1, 2020 
			Does not work on PS Version 7.0.2 - July 1, 2020
	#>

	[CmdletBinding()]
	[OutputType([PSCustomObject])]
	param()

	begin
	{
		Write-Verbose "Determing if Exchange Online has been estbalished" | Out-Host
	}

	process{
		#Try V2 Connection
		try {
			$V2Users = Get-EXOMailbox -ErrorAction Stop -ResultSize 5 -WarningAction Ignore

			if (($V2Users | Measure).Count -gt 0) {
				Write-Verbose "Connected with Exchange Online V2"
				$ExchangeOnlineV2 = $true
			}
			else {
				$ExchangeOnlineV2 = $false
			}
		}
		catch {
			Write-Verbose "Unable to query with V2 cmdlets" | Out-Host
			$ExchangeOnlineV2 = $false
		}

		#Try V1 cmdlet connection
		try {
			$V1Users = Get-Mailbox -ErrorAction Stop -ResultSize 5 -WarningAction Ignore

			if (($V1Users | Measure).Count -gt 0) {
				Write-Verbose "Connected with Exchange Online V1"
				$ExchangeOnlineV1 = $true
			}
			else {
				$ExchangeOnlineV1 = $false
			}
		}
		catch {
			Write-Verbose "Unable to query with V1 cmdlets" | Out-Host
			$ExchangeOnlineV1 = $false
		}
	}

	end
	{
		$ExchangeConnectionInformation=[PSCustomObject]@{
			ExchangeOnlineV2Connection = $ExchangeOnlineV2
			ExchangeOnlineV1Connection = $ExchangeOnlineV1
		}

		return $ExchangeConnectionInformation
	}
}

#########################################
# Functions related to AzureAD/MSOnline #
#########################################
function Get-HSCDirectoryRoleName
{
		<#
		.SYNOPSIS
			This function returns an array of the display names for the AzureAD directory roles.

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-HSCDirectoryRoleName
			External Identity Provider Administrator
			Company Administrator
			Exchange Service Administrator
			Conditional Access Administrator
			...
			
		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-HSCDirectoryRoleName -verbose                                                             
			VERBOSE: Generating list of display names
			VERBOSE: Successfully generated array of role display names
			VERBOSE: External Identity Provider Administrator
			...
			External Identity Provider Administrator
			Company Administrator
			Exchange Service Administrator
			Conditional Access Administrator		
			...
			
		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 8, 2020

			PS Version 5.1 Tested: July 8, 2020 
			Does not work on PS Version 7.0.2 - July 8, 2020
	#>

	[CmdletBinding()]
	[Alias("Get-GlobalAdminMember")]
	[OutputType([string[]])]
	param()

	try {
		Write-Verbose "Generating list of display names"
		[string[]]$DirectoryRoleDisplayNames = (Get-AzureADDirectoryRole -ErrorAction Stop).DisplayName
		
		Write-Verbose "Successfully generated array of role display names"
		Write-Verbose ($DirectoryRoleDisplayNames | Out-String)
		
		return $DirectoryRoleDisplayNames
	}
	catch {
		Write-Warning "Unable to generate list of AzureAD Directory Role Names"
		return $null	
	}
}

function Get-HSCGlobalAdminMember
{
	<#
		.SYNOPSIS
			This function returns an array of AzureADUsers that are Global Admins in the HSC Office 365 Tenant.

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-HSCGlobalAdminMember
			WARNING: Unable to get list of global admins
			
		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Connect-HSCOffice365
			PS C:\Users\jbrusoeadmin> Get-HSCGlobalAdminMember

			ObjectId                             DisplayName            UserPrincipalName                            UserType
			--------                             -----------            -----------------                            --------
			cd4335d9-a591-473c-819e-65c981122a93 kjr Admin              kadmin@hsc.wvu.edu                           Member
			78296dfb-b7b5-462f-bd5c-fd4958e6b466 Jackie A Nesselrodt    j.nesselrodt@hsc.wvu.edu                     Member
			3be1d1f8-5f35-448d-b448-8171f0719f0f Murray, Jeremy E.      jeremy.murray@wvumedicine.org                Member
			63241ce1-dfdf-4771-8eb5-86f4107d74d6 Mkondrla Admin         mlkadmin@hsc.wvu.edu                         Member
			fee5ca2a-3901-4670-b15a-d4af0d86cc78 Matt Admin             mattadmin@hsc.wvu.edu                        Member
			170ba3c9-a44f-4c90-8df4-22e5edd4f0db Jbrusoe Admin          jbrusoeadmin@hsc.wvu.edu                     Member
			35cac010-9f21-4fce-a965-98a37afc9866 jbrusoe cloudonlyadmin jbrusoecloudonlyadmin@WVUHSC.onmicrosoft.com Member
			4b364481-d9d3-4ad9-832d-e9c242e01fd9 WVUH ITS               wvuh@WVUHSC.onmicrosoft.com                  Member
			cd481eed-e7e0-46de-84eb-cd891c7b7d45 WVU HSC ITS            microsoft@WVUHSC.onmicrosoft.com
			f9270a0e-9091-4897-9381-ed633afa5eeb duffypoa               duffypoa@wvuhs.com                           Member
			e55e7e6d-3be0-4675-b854-01f7d9759d5c WVUM-SPFAM             WVUM-SPFAM@WVUHSC.onmicrosoft.com            Member
			8c1ff48e-ee49-4de9-a219-eaf7146bc3a1 ghermancoa             ghermancoa@wvuhs.com                         Member
			a905a27e-6659-4356-ba70-bf614c7825cf phillipssOA            phillipssoa@wvuhs.com                        Member
			1e48a9ca-93aa-4fd3-b460-a2ea6c37bfc2 reevesjoa              reevesjoa@wvuhs.com                          Member
			1600c603-520c-4fa4-9712-8bc99f6242ae murrayjOA              murrayjOA@wvuhs.com                          Member
			df06d435-33f2-41d8-932e-2afce4f63697 georgemOA              georgemOA@wvuhs.com                          Member
			7962a104-1f2b-4086-98ca-bce3680f0864 Yoak, Erik             yoakeoa@wvuhs.com                            Member

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: June 18, 2020

			PS Version 5.1 Tested: July 1, 2020 
			Does not work on PS Version 7.0.2 - July 1, 2020
	#>

	[CmdletBinding()]
	[Alias("Get-GlobalAdminMember")]
	[OutputType([PSObject[]])]
	param()
	
	process
	{
		try
		{
			#Company Administrator = Global Admin role
			$GlobalAdminRole = Get-AzureADDirectoryRole | where {$_.DisplayName -like "Company Administrator"} -ErrorAction Stop
	
			$GlobalAdmins = Get-AzureADDirectoryRoleMember -ObjectId $GlobalAdminRole.ObjectID -ErrorAction Stop
			return $GlobalAdmins
		}
		catch 
		{
			Write-Warning "Unable to get list of global admins" | Out-Host
			return $null
		}
	}
}

function Get-HSCQuarantineMessage 
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[string]$RecipientEmail
	)

	try {
		
	}
	catch {
		
	}
}

function Get-HSCRoleMember
{
	<#
		.SYNOPSIS
			This function returns an array of AzureADUsers that are members of a specified role in AzureAD.

		.PARAMETER DisplayName
			The display name of the role to get the membership of

		.OUTPUTS
			Returns an array of AzureaD users that are role members

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-HSCRoleMember -DisplayName "Helpdesk Administrator"

			ObjectId                             DisplayName        UserPrincipalName             UserType
			--------                             -----------        -----------------             --------
			6e914c83-1a1c-42a6-b521-6ccd06fdfc3f Kondrla, Michele   mkondrla@hsc.wvu.edu
			781c6f1b-a48e-4b72-923a-c55360d9d63e Nesselrodt, Jackie jnesselrodt@hsc.wvu.edu       Member
			29826516-dc7a-469a-a1d8-48b5f4c74f57 Brusoe, Jeff       jbrusoe@hsc.wvu.edu
			971bde55-2eab-4e93-973b-eeaef869c3cf Rodney, Kim        krodney@hsc.wvu.edu
			9ba2fa63-ef30-4396-859a-efd98318cd4b White, Jessica     jewhite@hsc.wvu.edu
			3a66b829-bd07-4bdd-bd05-13eb5abd82d0 Nichols, Ricky     rnichols@hsc.wvu.edu
			78ab955f-a2d7-40c9-9b5b-7a70481888d4 Reyes, Shane       sreyes@hsc.wvu.edu
			f07f4c1c-750b-49f8-be5b-01ed8cf6db84 Huff, Bobby        rhuff@hsc.wvu.edu
			38fc41d7-cd2f-4103-bdaa-9380b89d25df Bridges, Josh      jgbridges@hsc.wvu.edu
			4a5e4e6a-4a74-48a7-b3a4-0ad7047e1a37 Leatherman, Aaron  aleathe2@hsc.wvu.edu          Member
			a8eeca02-9a34-4c7e-b6c1-1a232e3f8a9c Logue, Matt        mlogue@hsc.wvu.edu            Member
			354edf50-0b4e-47a2-ab4f-c3a9387bb7a7 Microsoft1         microsoft1@hsc.wvu.edu        Member
			d53d0940-143d-4e2c-91cb-6402d8d27231 Microsoft2         microsoft2@hsc.wvu.edu        Member
			26adc143-8717-4f85-b314-a75aaf48c508 Microsoft3         microsoft3@hsc.wvu.edu        Member
			fa2479e6-d8ff-4c50-b19c-05b1588f1f62 Microsoft4         microsoft4@hsc.wvu.edu        Member
			3be1d1f8-5f35-448d-b448-8171f0719f0f Murray, Jeremy E.  jeremy.murray@wvumedicine.org Member
			ab5367fd-de49-4e32-8185-bd29d25a0e95 Dodd, Ashman       adodd4@hsc.wvu.edu            Member
			ffd9fb6b-a73d-45c1-aed7-105d1db46dcd Yoak, Erik D.      erik.yoak@wvumedicine.org     Member
			cded56b8-21e2-4f09-9faf-ed766407d666 Buttermore, James  jwbuttermore@hsc.wvu.edu
			9230bb08-1cc3-4f0d-ba51-38b78dd8c8e2 Patterson, Zach    zpatter1@hsc.wvu.edu          Member
			071eafa2-fc4d-45e3-aa44-7657400199df Barrick, Cody      cobarrick@hsc.wvu.edu         Member
			04b05a3a-f242-48ed-9570-0ef52fe272fa Richard A. Nichols r.nichols@hsc.wvu.edu         Member
			749bef9d-3dd9-4dc9-b1fd-75de0ea512bd sar_da             sar_da@hsc.wvu.edu            Member
			3fb9d022-2371-411b-bf98-11028943b547 saurbornjoa        saurbornjoa@wvuhs.com         Member
			3c2f5281-fc36-4f47-b029-de425028f0de stumpjOA           stumpjOA@wvuhs.com            Member

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 2, 2020
	#>

	[CmdletBinding()]
	[OutputType([PSObject[]])]
	param(
		[ValidateSet("Company Administrator","Exchange Service Administrator","Conditional Access Administrator",
		"Desktop Analytics Administrator","Application Administrator","License Administrator","Directory Writers",
		"Kaizala Administrator","Message Center Reader","Intune Service Administrator","Network Administrator",
		"Application Developer","Reports Reader","Password Administrator","Teams Service Administrator","Printer Technician",
		"Message Center Privacy Reader","User Account Administrator","Authentication Administrator","Lync Service Administrator",
		"Device Administrators","Azure Information Protection Administrator","Billing Administrator","Security Reader",
		"Helpdesk Administrator","Security Operator","Hybrid Identity Administrator","Search Administrator","Privileged Role Administrator",
		"Directory Synchronization Accounts","Groups Administrator","Search Editor","Office Apps Administrator","Privileged Authentication Administrator",
		"Customer LockBox Access Approver","Power Platform Administrator","SharePoint Service Administrator","Cloud Application Administrator",
		"Cloud Device Administrator","Compliance Administrator","Guest Inviter","Service Support Administrator","Directory Readers",
		"CRM Service Administrator","Teams Communications Support Engineer","Global Reader","Security Administrator",
		"Printer Administrator","Teams Communications Support Specialist","Power BI Service Administrator",
		"Teams Communications Administrator","Compliance Data Administrator","External Identity Provider Administrator")]
		[parameter(Mandatory=$true)]
		[string]$DisplayName
		#To do: Look into making this a dynamic parameter to populate this
		#https://powershell.org/forums/topic/how-to-create-dynamic-parameters/
	)

	begin
	{
		Write-Verbose "Search for: $DisplayName" | Out-Host
	}
	
	process
	{
		try 
		{
			$HSCRole = Get-AzureADDirectoryRole | where {$_.DisplayName -eq $DisplayName} -ErrorAction Stop

			$HSCRoleMembers = Get-AzureADDirectoryRoleMember -ObjectId $HSCRole.ObjectID -ErrorAction Stop
			return $HSCRoleMembers
		}
		catch 
		{
			Write-Warning "Unable to get member list" | Out-Host
			rteturn $null
		}
	}
}

function Get-HSCTenantName
{
	<#
		.SYNOPSIS
			Returns the name of the currently logged in tenant with AzureAD

		.OUTPUTS
			Returns a string with the tenant name or $null if there is an error determining it

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-HSCTenantName
			WVUHSC

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-HSCTenantName -Verbose
			VERBOSE: Verified Domain: WVUHSC.onmicrosoft.com
			VERBOSE: Tenant Name: WVUHSC
			WVUHSC

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: June 22, 2020
	#>

	[CmdletBinding()]
	[Alias("Get-TenantName")]
	[OutputType([string])]
	param ()

	try 
	{
		$TenantDetail = Get-AzureADTenantDetail -ErrorAction Stop
	}
	catch
	{
		Write-Warning "Unable to get AzureAD tenant information" | Out-Host
		return $null
	}
	
	try 
	{
		$TenantName = ($TenantDetail.VerifiedDomains | where {$_.Initial}).Name
		Write-Verbose "Verified Domain: $TenantName" | Out-Host

		$TenantName = $TenantName -replace ".onmicrosoft.com"
		Write-Verbose "Tenant Name: $TenantName" | Out-Host

		return $TenantName
	}
	catch 
	{
		Write-Warning "Error reading tenant name with MSOnline" | Out-Host	
		return $null
	}

	return $null
}

function Get-HSCTenantNameMSOL
{
	<#
		.SYNOPSIS
			Returns the name of the currently logged in tenant with MSOnline

		.OUTPUTS
			Returns a string with the tenant name or $null if there is an error determining it

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-HSCTenantNameMSOL
			WVUHSC

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-HSCTenantNameMSOL -Verbose
			VERBOSE: Tenant Name: WVUHSC
			WVUHSC

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: June 22, 2020
	#>

	[CmdletBinding()]
	[Alias("Get-TenantNameMSOL")]
	[OutputType([string])]
	param ()

	try 
	{
		$TenantName = (Get-MsolDomain | where {($_.Name.Split(".").Length -eq 3) -AND ($_.Name -like "*onmicrosoft.com*")}).Name
		$TenantName = $TenantName.Split(".")[0]
		
		Write-Verbose "Tenant Name: $TenantName" | Out-Host

		return $TenantName
	}
	catch
	{
		Write-Warning "Unable to get MSOL tenant name" | Out-Host
		return $null
	}
}

function Set-HSCBlockCredential
{
	<#
		.SYNOPSIS
			Sets the block credential using MSOnline for a MSOL User

		.OUTPUTS
			This function returns a boolean value depending on the success/failure
			of setting the user's block credential

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-MsolUser -SearchString jbrusoe@hsc.wvu.edu | Select BlockCredential
			BlockCredential
			---------------
					False

			PS C:\Users\jbrusoeadmin> Set-HSCBlockCredential -Account jbrusoe@hsc.wvu.edu -DisableAccount
			True
			PS C:\Users\jbrusoeadmin> Get-MsolUser -SearchString jbrusoe@hsc.wvu.edu | Select BlockCredential
			BlockCredential
			---------------
					True

			PS C:\Users\jbrusoeadmin> Set-HSCBlockCredential -Account jbrusoe@hsc.wvu.edu
			True
			PS C:\Users\jbrusoeadmin> Get-MsolUser -SearchString jbrusoe@hsc.wvu.edu | Select BlockCredential
			BlockCredential
			---------------
					False

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Set-HSCBlockCredential -Account jbrusoe@hsc.wvu.edu -WhatIf
			What if: Performing the operation "Set-HSCBlockCredential" on target "Setting Block Credential".
		
		.PARAMETER Account
			This is the account that will have its block credential enabled/disabled.

		.PARAMETER DisableAccount
			By default, this function enables the MSOL account. This parameter is $false by default.

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 6, 2020
	#>

	[CmdletBinding(SupportsShouldProcess,ConfirmImpact="Medium")]
	[OutputType([bool])]
	param (
		[Parameter(Mandatory=$true)]
		[string]$Account,
		[switch]$DisableAccount #Note: Default is to enable account
	)

	begin
	{
		Write-Verbose "Searching for MSOL User: $Account" | Out-Host
	}

	process
	{
		#First find user
		try {
			$MSOLUser = Get-MsolUser -SearchString $Account
			
			if ($null -eq $MSOLUser) {
				Write-Warning "Unable to find MSOLUser" | Out-Host
				return $false
			}
			else {
				Write-Verbose "User successfully found" | Out-Host
			}
		}
		catch {
			Write-Warning "Unable to find MSOLUser" | Out-Host
			return $false
		}

		#Verify only one user was found
		if (($MSOLUser | Measure).Count -gt 1)
		{
			Write-warning "More than one unique user was found. Unable to process account" | Out-Host
			return $false
		}

		#Now set block credential
		try {

			#This first if statement is used to handle this error. I'm not sure why it comes up, since
			#the switch parameter should default to $false and be treated as a boolean.
			#Set-MsolUser : Cannot convert 'System.Management.Automation.SwitchParameter' to the type
			#'System.Nullable`1[System.Boolean]' required by parameter 'BlockCredential'.
			$bDisableAccount = $false
			if ($DisableAccount)
			{
				$bDisableAccount = $true
			}
	
			if ($PScmdlet.ShouldProcess("Setting Block Credential"))
			{
				$MSOLUser | Set-MSOLUser -BlockCredential $bDisableAccount

				Write-Verbose "Set block credential to $bDisableAccount" | Out-Host
				return $true
			}
		}
		catch {
			Write-Warning "Unable to set block credential" | Out-Host
			return $false
		}
	}
}

function Enable-HSCCloudUser
{
	<#
		.SYNOPSIS
			Enables a user with AzureAD

		.DESCRIPTION
			This function enables an AzureAD user account by setting the Enabled
			field of an AzureAD user account. 

		.PARAMETER Account
			This is the account that will have its block credential enabled/disabled

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: June 22, 2020
	#>

	[CmdletBinding()]
	[OutputType([bool])]
	param (
		[Parameter(Mandatory=$true)]
		[param]$Account
	)

	begin
	{
		Write-Verbose "Enabling HSC AzureAD User: $Account" | Out-Host
	}

	process
	{
		return $false
	}
}

function Disable-HSCCloudUser
{
	<#
		.SYNOPSIS
			Enables a user with AzureAD

		.DESCRIPTION
			This function enables an AzureAD user account by setting the Enabled
			field of an AzureAD user account. 

		.PARAMETER Account
			This is the account that will have its block credential enabled/disabled

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: June 22, 2020
	#>

	[CmdletBinding()]
	[OutputType([bool])]
	param (
		[Parameter(Mandatory=$true)]
		[param]$Account
	)

	begin
	{
		Write-Verbose "Disabling HSC AzureAD User: $Account" | Out-Host
	}

	process
	{
		return $false
	}
}

function Get-HSCUserLicense
{
	<#
		.SYNOPSIS
			Returns the licese information for a user with AzureAD

		.OUTPUTS
			A string array with the user licenses in it

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-HSCUserLicense -UserName jbrusoe@hsc.wvu.edu

			SkuPartNumber
			-------------
			EMS
			ENTERPRISEPACKPLUS_FACULTY

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-HSCUserLicense -UserName jbrusoe
			WARNING: Unable to find one unique user

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 2, 2020
	#>

	[CmdletBinding()]
	[OutputType([string])]
	param(
		[parameter(Mandatory=$true)]
		[string]$UserName
	)

	begin
	{
		Write-Verbose "Getting license information for: $UserName" | Out-Host

		#First get AzureAD user
		try 
		{
			$AzureADUser = Get-AzureADUser -SearchString $UserName -ErrorAction Stop
			
			if (($AzureADUser | Measure).Count -eq 0)
			{
				Write-Warning "Unable to find AzureAD user" | Out-Host
				Continue
			}
			elseif (($AzureADUser | Measure).Count -gt 1) {
				Write-Warning "Unable to find one unique user" | Out-Host
				Continue
			}
			else {
				Write-Verbose "Successfully found user" | Out-Host
			}
		}
		catch
		{
			Write-Warning "Unable to find AzureAD user: $UserName" | Out-Host
			return $null
		}
	}

	process
	{
		#Now find user license info
		try {
			$UserLicenses = Get-AzureADUserLicenseDetail -ObjectId $AzureADUser.ObjectId | Select SkuPartNumber
			
			Write-Verbose "Successfully generated user licenses" | Out-Host

			return $UserLicenses
		}
		catch {
			Write-Warning "Unable to retrieve AzureAD user license information" | Out-Host
			return $null
		}
	}
}

function Get-HSCUserLicenseMSOL
{
	<#
		.SYNOPSIS
			Returns the licese information for a user with MSOnline

		.OUTPUTS
			A string array with the user licenses in it

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-HSCUserLicenseMSOL -UserName jbrusoe@hsc.wvu.edu
			WVUHSC:EMS
			WVUHSC:ENTERPRISEPACKPLUS_FACULTY

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-HSCUserLicenseMSOL -UserName jbrusoe@hsc.wvu.edu -Verbose
			VERBOSE: Getting license information for: jbrusoe@hsc.wvu.edu
			VERBOSE: Successfully found user
			VERBOSE: Successfully generated user licenses
			WVUHSC:EMS
			WVUHSC:ENTERPRISEPACKPLUS_FACULTY

		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Get-HSCUserLicenseMSOL -UserName jbrusoe -Verbose
			VERBOSE: Getting license information for: jbrusoe
			WARNING: Unable to find one unique user

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 6, 2020
	#>

	[CmdletBinding()]
	[OutputType([string[]])]
	param(
		[parameter(Mandatory=$true)]
		[string]$UserName
	)

	begin
	{
		Write-Verbose "Getting license information for: $UserName" | Out-Host

		#First get AzureAD user
		try 
		{
			$MSOLUser = Get-MsolUser -SearchString $UserName -ErrorAction Stop
			
			if (($MSOLUser | Measure).Count -eq 0)
			{
				Write-Warning "Unable to find AzureAD user" | Out-Host
				Continue
			}
			elseif (($MSOLUser | Measure).Count -gt 1) {
				Write-Warning "Unable to find one unique user" | Out-Host
				Continue
			}
			else {
				Write-Verbose "Successfully found user" | Out-Host
			}
		}
		catch
		{
			Write-Warning "Unable to find MSOL user: $UserName" | Out-Host
			return $null
		}
	}

	process
	{
		#Now find MSOL user license info
		try {
			[string[]]$UserLicenses = $null
			foreach ($License in $MSOLUser.Licenses)
			{
				$UserLicenses += $License.AccountSkuId
			}
			
			Write-Verbose "Successfully generated user licenses" | Out-Host

			return $UserLicenses
		}
		catch {
			Write-Warning "Unable to retrieve MSOL user license information" | Out-Host
			return $null
		}
	}
}

function Set-HSCUserLicense
{
		<#
		.SYNOPSIS
			This function used to set the HSC Office 365 tenant licenses.
			
		.DESCRIPTION
			This function used to set the HSC Office 365 tenant licenses. This is handled by the
			Add-UserToLicenseGroup function in the HSC-ActiveDirectoryModule. This function is still
			here for backwards compatability and to ensure a $null value is returned.

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 6, 2020
	#>
	[CmdletBinding()]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions","",Justification = "Not needed for backwards compatability")]
	param ()
	
	Write-Warning "This function is now handled by the Set-HSCADLicenseGroup in the HSC-ActiveDirectoryModule.psm1 module" | Out-Host
	return $null
}

#######################################
# Functions related to ExchangeOnline #
#######################################
Function Get-HSCO365MailboxStatus 
{
	<#
		.SYNOPSIS
			This function gets the OWAEnabled, MAPIEnabled, and ActiveSyncEnabled values from O365 of all mailboxes.
			It also exports to a CSV and returns an array of these values.

		.NOTES
			Needed for Export-ToSole.ps1
			Originally Written by: Matt Logue(?)
			Last Updated by: Jeff Brusoe
			Last Updated: May 27, 2021
	#>

	[CmdletBinding()]
	[Alias("Get-O365MailboxStatus")]
	[OutputType([PSObject])]
	param (
		[string]$ExportFile = $((Get-HSCGitHubRepoPath) + 
								"2CommonFiles\MailboxFiles\" +
								(Get-Date -Format yyyy-MM-dd-HH-mm) +
								"-O365MailboxStatus.csv")
	)
	
    if (Test-Path $ExportFile) {
        Write-Verbose "Remvoing Old Export File"
        Remove-Item -Path $ExportFile -Force
    }

	try {
		Write-Verbose "Getting Mailboxes in Office 365"
		$CASMailboxes = Get-CASMailbox -ResultSize Unlimited -ErrorAction Stop |
			Where-Object { $_.PrimarySMTPAddress -notlike "*rni.*" -AND
							$_.PrimarySMTPAddress -notlike "*wvurni" }
	}
	catch {
		Write-Warning "Unable to generate CASMailbox list"
		return $null
	}

    [PSObject[]]$MailboxStatus = @()
    [PSObject[]]$M365Enabled = @()

    Write-Verbose "Getting information for users with SIP addresses...."
    foreach ($CASMailbox in $CASMailboxes)
    {
        $M365UserArray = New-Object -TypeName psobject
        
		if ($CASMailbox.EmailAddresses -clike "SMTP:*")
        {
            $UserSMTP = $CASMailbox.EmailAddresses -clike "SMTP:*" | Select-String 'SMTP:'
            $UserSMTP = $UserSMTP -replace "SMTP:"
            $UserSMTP = $UserSMTP.ToLower()

            $M365UserArray | Add-Member -Name "O365EmailAddress" -Value $UserSMTP -MemberType NoteProperty
            $M365UserArray | Add-Member -Name "OWAEnabled" -Value $CASMailbox.OWAEnabled -MemberType NoteProperty
            $M365UserArray | Add-Member -Name "MAPIEnabled" -Value $CASMailbox.MAPIEnabled -MemberType NoteProperty
            $M365UserArray | Add-Member -Name "ActiveSyncEnabled" -Value $CASMailbox.ActiveSyncEnabled -MemberType NoteProperty
            $MailboxStatus += $M365UserArray
			
            if (($M365UserArray.OWAEnabled -eq $true) -AND
				($M365UserArray.MAPIEnabled -eq $true) -AND
				($M365UserArray.ActiveSyncEnabled -eq $true)) {
                $M365Enabled += $M365UserArray
            }
        
        }
        elseif ($CASMailbox.EmailAddresses -clike "SIP:*")
        {
            $usersip = $CASMailbox.EmailAddresses | Select-String 'sip:'
            $usersip = $usersip -replace "sip:"
            $usersip = $usersip.ToLower()

            $M365UserArray | Add-Member -Name "O365EmailAddress" -Value $usersip -MemberType NoteProperty
            $M365UserArray | Add-Member -Name "OWAEnabled" -Value $user.OWAEnabled -MemberType NoteProperty
            $M365UserArray | Add-Member -Name "MAPIEnabled" -Value $user.MAPIEnabled -MemberType NoteProperty
            $M365UserArray | Add-Member -Name "ActiveSyncEnabled" -Value $user.ActiveSyncEnabled -MemberType NoteProperty
			
            $MailboxStatus += $M365UserArray
			
            if (($M365UserArray.OWAEnabled -eq $true) -AND
				($M365UserArray.MAPIEnabled -eq $true) -AND
				($M365UserArray.ActiveSyncEnabled -eq $true)) {
                $M365Enabled += $M365UserArray
            }
        }
    }
	
    Write-Verbose '$MailboxStatus Array created, Exporting to CSV' 
	$MailboxStatus |
		Select-Object o365emailaddress,owaenabled,mapienabled,activesyncenabled |
		Export-Csv -Path $ExportFile -NoTypeInformation

    Write-Verbose "CSV Exported - Mailbox Count: $(($MailboxStatus.O365EmailAddress | Measure-Object).Count)"
	
    return $O365Enabled
}

function Get-HSCLitigationHold
{
	<#
		.SYNOPSIS
			This function returns a string array of users with the
			litigation hold flag set usin the V2 Exchange cmdlets.

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: September 10, 2020
	#>

	[CmdletBinding()]
	[OutputType([string[]])]
	param ()

	Write-Verbose "`nGenerating litigation hold list with V2 cmdlets"

	$LitigationHold = @() #Array to hold litigation hold users

	try {
		$LHs = Get-ExoMailbox -Properties LitigationHoldEnabled -ResultSize Unlimited -ErrorAction Stop | 
			Where {$_.LitigationHoldEnabled -eq $true}
	}
	catch {
		Write-Warning "Unable to get litigation hold information"
		return $null
	}
	
	foreach ($LH in $LHs)
	{
		Write-Verbose $("Litigation Hold: " + $LH.Alias)
		$LitigationHold += $LH.Alias
		$LH | select Alias,PrimarySMTPAddress,lit* | 
			Export-Csv $LitigationHoldFile -Append -NoTypeInformation
	}

	return $LitigationHold
}

function Get-HSCLitigationHoldV1
{
	<#
		.SYNOPSIS
			This function returns a string array of users with the
			litigation hold flag set using the V1 Exchange cmdlets.

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: September 10, 2020
	#>

	[CmdletBinding()]
	[OutputType([string[]])]
	param ()

	Write-Verbose "`nGenerating litigation hold list with V1 cmdlets"

	$LitigationHold = @() #Array to hold litigation hold users

	try {
		$LHs = Get-Mailbox -ResultSize Unlimited -ErrorAction Stop | 
			Where {$_.LitigationHoldEnabled -eq $true}
	}
	catch {
		Write-Warning "Unable to get litigation hold information"
		return $null
	}

	foreach ($LH in $LHs)
	{
		Write-Verbose $("Litigation Hold: " + $LH.Alias)
		$LitigationHold += $LH.Alias
		$LH | select Alias,PrimarySMTPAddress,lit* |
			Export-Csv $LitigationHoldFile -Append -NoTypeInformation
	}

	return $LitigationHold
}

function Disable-HSCPOP
{
	<#
		.SYNOPSIS
			This function disables POP on a user account

		.PARAMETER Account
			The account that will have POP disabled on it.

		.INPUTS
			This funcdtion requires a string array as an input. It can be passed from the pipeline 
		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Disable-HSCPOP jbrusoe                                                                        
			UserName POPDisabled
			-------- -----------
			jbrusoe         True
			
		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Disable-HSCPOP jbrusoe,krussell,abcdefg                                                      
			WARNING: abcdefg wasn't found
			UserName POPDisabled
			-------- -----------
			jbrusoe         True
			krussell        True
			abcdefg        False
			
		.EXAMPLE
			PS C:\Users\jbrusoeadmin> "jbrusoe","krussell","abcdefg" | Disable-HSCPOP                                               
			WARNING: abcdefg wasn't found

			UserName POPDisabled
			-------- -----------
			jbrusoe         True
			krussell        True
			abcdefg        False
			
		.NOTES
			Last Updated by: Jeff Brusoe
			Last Updated: July 8, 2020
	#>
	
	[CmdletBinding()]
	[OutputType([PSObject])]
	param (
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[string[]]$Accounts
	)
	
	begin
	{
		[PSObject[]]$POPUserArray = @()
	}

	process
	{	
		foreach ($Account in $Accounts)
		{
			Write-Verbose "Disbling POP for $Account" | Out-Host
			$DisableUserSummary = New-Object -TypeName psobject
			
			#First attempt to find user wtih V1 or V2 cmdlets
			$FoundUser = $false

			try {
				$Mailbox = Get-EXOMailbox $Account -ErrorAction Stop

				if ($null -ne $Mailbox)
				{
					$FoundUser = $true
					Write-Verbose "Found user with V2 Exchange cmdlets" | Out-Host
				}
			}
			catch {
				Write-Verbose "Unable to find user mailbox for $Account with V2 Exchange cmdlets" | Out-Host
			}

			if (!$FoundUser)
			{
				#Attempt to find user with V1 Exchange cmdlets
				try {
					$Mailbox = Get-Mailbox $Account -ErrorAction Stop

					if ($null -ne $Mailbox)
					{
						$FoundUser = $true
						Write-Verbose "Found user with V1 Exchange cmdlets" | Out-Host
					}
				}
				catch {
					Write-Verbose "Unable to find user mailbox for $Account with V1 Exchange cmdlets" | Out-Host
				}
			}
			
			if ($FoundUser)
			{
				try {
					Set-CasMailbox -Identity $Mailbox.PrimarySMTPAddress -POPEnabled $false -ErrorAction Stop -WarningAction SilentlyContinue
					Write-Verbose "Successfully disabled POP for account" | Out-Host
					
					$DisableUserSummary | Add-Member -MemberType NoteProperty -Name "UserName" -Value $Account
					$DisableUserSummary | Add-Member -MemberType NoteProperty -Name "POPDisabled" -Value $true
				}
				catch {
					Write-Warning "Error disabling POP" | Out-Host
					$DisableUserSummary | Add-Member -MemberType NoteProperty -Name "UserName" -Value $Account 
					$DisableUserSummary | Add-Member -MemberType NoteProperty -Name "POPDisabled" -Value $false
				}
			}
			else
			{
				Write-Warning "$Account wasn't found"
				$DisableUserSummary | Add-Member -MemberType NoteProperty -Name "UserName" -Value $Account 
				$DisableUserSummary | Add-Member -MemberType NoteProperty -Name "POPDisabled" -Value $false
			}

			$POPUserArray += $DisableUserSummary
		}
	}

	end
	{
		Write-Verbose "Done processing users"
		return $POPUserArray
	}
}

function Disable-HSCIMAP
{
	<#
		.SYNOPSIS
			This function disable s IMAP on a user account

		.NOTES
			Last Updated by: Jeff Brusoe
			Last Updated: June 17, 2020
	#>
	
	[CmdletBinding()]
	[OutputType([bool])]
	param (
		[Parameter(Mandatory=$true)]
		[string]$Account
	)
	
	begin
	{
		Write-Verbose "Disbling IMAP for $Account" | Out-Host

		#First attempt to find user wtih V1 or V2 cmdlets
		$FoundUser = $false

		try {
			$Mailbox = Get-EXOMailbox $Account -ErrorAction Stop

			if ($null -ne $Mailbox)
			{
				$FoundUser = $true
				Write-Verbose "Found user with V2 Exchange cmdlets" | Out-Host
			}
			
		}
		catch {
			Write-Verbose "Unable to find user mailbox for $Account with V2 Exchange cmdlets" | Out-Host
		}

		if (!$FoundUser)
		{
			#Attempt to find user with V1 Exchange cmdlets
			try {
				$Mailbox = Get-Mailbox $Account -ErrorAction Stop

				if ($null -ne $Mailbox)
				{
					$FoundUser = $true
					Write-Verbose "Found user with V1 Exchange cmdlets" | Out-Host
				}
			}
			catch {
				Write-Verbose "Unable to find user mailbox for $Account with V1 Exchange cmdlets" | Out-Host
			}
		}
	}
	
	process
	{
		if ($FoundUser)
		{
			try {
				$Mailbox | Set-CasMailbox -IMAPEnabled $false -ErrorAction Stop
				Write-Verbose "Successfully disabled IMAP for account" | Out-Host
				return $true
			}
			catch {
				Write-Warning "Error disabling IMAP" | Out-Host
				return $false
			}
		}
	}
}

<# To be implemented
function Set-HSCExchangeOnlineCommonParameter
{
	<#
		.SYNOPSIS
			Sets common settings on an Exchange Online mailbox

		.DESCRIPTION
			The following settings are configured:
			1. POP = False
			2. IMAP = False
			3. Mailbox Enabled
			4. CasMailbox Settings (MAPI/OWA/ActiveSync all enabled)
			5. Mailbox visible in address book

		.NOTES
			Last Updated by: Jeff Brusoe
			Last Updated: July 6, 2020
	#>
	<#
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact="Medium")]
	param (
		[Parameter(Mandatory=$true)]
		[string]$Account
	)

	return $null
}
#>

####################
# Export Functions #
####################
<#
#Connect Fuctions
Export-ModuleMember -Function "Connect-HSCOffice365" -Alias "Connect-Office365"
Export-ModuleMember -Function "Connect-HSCOffice365MSOL" -Alias "Connect-Office365MSOL"
Export-ModuleMember -Function "Connect-MainCampusOffice365"
Export-ModuleMember -Function "Connect-MainCampusOffice365MSOL"
Export-ModuleMember -Function "Connect-WVUFoundationOffice365"
Export-ModuleMember -Function "Connect-WVUFoundationOffice365MSOL"
Export-ModuleMember -Function "Connect-HSCExchangeOnline"
Export-ModuleMember -Function "Connect-HSCExchangeOnlineV1" -Alias "Connect-ExchangeOnlineV1"
Export-ModuleMember -Function "Connect-MainCampusExchangeOnline"
Export-ModuleMember -Function "Connect-WVUFoundationExchangeOnline"

#Disable Functions
Export-ModuleMember -Function "Disable-*"

#Get Functions
Export-ModuleMember -Function "Get-HSCConnectionAccount" -Alias "Get-ConnectionAccount"
Export-ModuleMember -Function "Get-HSCO365MailboxStatus"
Export-ModuleMember -Function "Get-HSCGlobalAdminMember" -Alias "Get-HSCGlobalAdminMember"
Export-ModuleMember -Function "Get-HSCRoleMember"
Export-ModuleMember -Function "Get-HSCTenantName" -Alias "Get-TenantName"
Export-ModuleMember -Function "Get-HSCTenantNameMSOL" -Alias "Get-TenantNameMSOL"
Export-ModuleMember -Function "Get-HSCUserLicense"
Export-ModuleMember -Function "Get-HSCUserLicenseMSOL"
Export-ModuleMember -Function "Get-HSCDirectoryRoleName"
Export-ModuleMember -Function "Get-HSCLitigationHoldV1"
Export-ModuleMember -Function "Get-HSCLitigationHold"

#Set Functions
Export-ModuleMember -Function "Set-HSCUserLicense"
Export-ModuleMember -Function "Set-HSCBlockCredential"

#Test Functions
Export-ModuleMember -Function "Test-*"
#>