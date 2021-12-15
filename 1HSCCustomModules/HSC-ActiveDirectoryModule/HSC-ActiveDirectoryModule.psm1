<#
	.SYNOPSIS
		This module contains some common Active Directory functions that are used by many HSC PowerShell files.

	.DESCRIPTION
		Active Directory functions included in this module:

		1. Add-HSCADUserOffice365BaseLicensingGroup
		2. Add-HSCADUserProxyAddress
		3. Convert-HSCDNToFQDN
		4. Get-HSCADUserCount
        5. Get-HSCADUserExt7
		6. Get-HSCADUserFromString
        7. Get-HSCADUserMailNickname
		8. Get-HSCADUserParentContainer
		9. Get-HSCDirectoryMapping
		10. Get-HSCLoggedOnUser
		11. Get-HSCPrimarySMTPAddress
		12. Get-HSCUserOrGroup
		13. Send-HSCNewAccountEmail
		14. Set-HSCADUserAddressBookVisibility
        15. Set-HSCADUserMailNickname
		16. Set-HSCGroupMembership
		17. Set-HSCPasswordRequired
		18. Test-HSCADModuleLoaded
		19. Test-HSCADOrgUnit

	.NOTES
		HSC-ActiveDirectoryModule.psm1
		Last Modified by: Jeff Brusoe
		Last Modified: June 28, 2021

		Version: 1.1
#>

[CmdletBinding()]
param ()

function Add-HSCADUserO365BaseLicensingGroup
{
	<#
		.SYNOPSIS
			This function adds a user(s) to the Office 365 Base Licensing Group.

		.DESCRIPTION
			This function adds a user(s) to the Office 365 Base Licensing Group
			in Active Directory. This group is the one that is used to license
			users for Office 365.

		.OUTPUTS
			PSObject

		.PARAMETER SamAccountName
			An array of Sam Account Names that contain users to be added to the
			Office 365 Base Licensing Group

		.PARAMETER BaseLicensingGroup
			The name of the base licensing group. This probably won't need to be changed.

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: July 26, 2021
	#>

	[CmdletBinding()]
	[OutputType([PSObject])]
	param (
		[Parameter(Mandatory = $true,
					ValueFromPipeline = $true,
					ValueFromPipelineByPropertyName = $true,
					Position = 0)]
		[string[]]$SamAccountName,

		[ValidateNotNullOrEmpty()]
		[string]$BaseLicensingGroup = "M365 A3 for Faculty Licensing Group"
	)

	begin {
		Write-Verbose "In Add-HSCADUserToOffice365BaseLicensingGroup function"

		try {
			Write-Verbose "Attempting to find base licensing group"
			$ADGroup = Get-ADGroup $BaseLicensingGroup -ErrorAction Stop
		}
		catch {
			Write-Warning "Unable to find base licensing group"
		}
		 
	}

	process
	{
		foreach ($SAM in $SamAccountName)
		{
			Write-Verbose "Current User: $SAM"

			try {
				$LDAPFilter = "(samAccountName=$SAM)"

				$GetADUserParams = @{
					LDAPFilter = $LDAPFilter
					Properties = "memberOf"
					ErrorAction = "Stop"
				}

				$ADUser = Get-ADUser @GetADUserParams
				Write-Verbose $("Found AD User: " + $ADUser.SamAccountName)
				Write-Verbose $("Found AD User: " + $ADUser.DistinguishedName)

				$CurrentADGroups = $ADUser.memberOf
				$InBaseLicensingGroup = $false
				$AddedToBaseLicensingGroup = $false

				foreach ($CurrentADGroup in $CurrentADGroups) {
					Write-Verbose $CurrentADGroup

					if ($CurrentADGroup -like "*M365 A3 for Faculty Licensing Group*") {
						Write-Verbose "User is already in base licensing group"

						$InBaseLicensingGroup = $true
						continue
					}
				}

				if (!$InBaseLicensingGroup) {
					Write-Verbose "Adding user to base licensing group"

					$ADGroup | Add-ADGroupMember -Members $ADUser.DistinguishedName
					$AddedToBaseLicensingGroup = $true
				}

				$ADUserInfo = [PSCustomObject]@{
					SamAccountName = $ADUser.SamAccountName
					InBaseLicensingGroup = $InBaseLicensingGroup
					AddedToBaseLicensingGroup = $AddedToBaseLicensingGroup
				}

				$ADUserInfo
			}
			catch {
				Write-Warning "Unable to add user to Office 365 Base Licensing Group"
			}
		}
	}
}

function Add-HSCADUserProxyAddress
{
	<#
		.SYNOPSIS
			This function adds a single (or multiple) proxy addresses to an AD Account.

		.DESCRIPTION
			The purpose of this function is to add a new proxy address to a specified user which 
			can be passed into the function as either an ADUser object or a string representing the SAMAccountName. The
			function returns either true or false based on if this operation is successful.

		.PARAMETER ADUser
			Specifies an ADUser object to add proxy address(es) to.

		.PARAMETER SamAccountName
			This parameter is a string representing an AD user's SAM account name
			that will be searched for to add the proxy address.

		.PARAMETER NewProxyAddress
			The new proxy addresses to be added

		.PARAMETER Primary
			A switch parameter to indicate that this is a primary SMTP address

		.EXAMPLE
			PS C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository> Get-ADUser jefftest -Properties * | select proxyAddresses -ExpandProperty proxyAddresses

			PS C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository> Add-HSCProxyAddress jefftest -NewProxyAddress "jefftest@hsc.wvu.edu" -Primary
			Attempting to find user: jefftest
			User found
			Adding: SMTP:jefftest@hsc.wvu.edu
			Successfully added new proxy address
			True

			PS C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository> Get-ADUser jefftest -Properties * | select proxyAddresses -ExpandProperty proxyAddresses
			SMTP:jefftest@hsc.wvu.edu

		.EXAMPLE
			PS C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository> Get-ADUser jefftest -Properties * | select proxyAddresses -ExpandProperty proxyAddresses
			SMTP:jefftest@hsc.wvu.edu

			PS C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository> Add-HSCProxyAddress jefftest -NewProxyAddress "jefftest2@hsc.wvu.edu"
			Attempting to find user: jefftest
			User found
			Current Proxy Address from ADUser: SMTP:jefftest@hsc.wvu.edu
			Adding: smtp:jefftest2@hsc.wvu.edu
			Successfully added new proxy address
			True

			PS C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository> Get-ADUser jefftest -Properties * | select proxyAddresses -ExpandProperty proxyAddresses
			smtp:jefftest2@hsc.wvu.edu
			SMTP:jefftest@hsc.wvu.edu

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: October 14, 2020
	#>

	[CmdletBinding(SupportsShouldProcess=$true,
					 ConfirmImpact = "Medium")]
	[OutputType([bool])]

	param (
		[Parameter(ValueFromPipeline=$false,
			ParameterSetName="ADUser",
			Mandatory=$true,
			Position=0)]
		[ValidateNotNullOrEmpty()]
		[Microsoft.ActiveDirectory.Management.ADAccount]$ADUser,

		[Parameter(ValueFromPipeline=$false,
			ParameterSetName="SamAccountName",
			Mandatory=$true,
			Position=0)]
		[ValidateNotNullOrEmpty()]
		[string]$SAMAccountName,
	
		[Parameter(ValueFromPipeline=$true,
			Mandatory=$true,
			Position=1)]
		[Alias("NewProxyAddresses")]
		[ValidateNotNullOrEmpty()]
		[string[]]$NewProxyAddress,

		[switch]$Primary
	)

	begin
	{
		Write-Verbose $("Parameter Set Name: " + $PSCmdlet.ParameterSetName)
		
		if ($PSCmdlet.ParameterSetName -eq "ADUser") {
			Write-Verbose $("ADUser SamAccountName: " + $ADUser.SamAccountName)
		}
		else {
			Write-Verbose "SamAccountName: $SamAccountName"
		}

		$ProxyAdded = $false
	}

	process
	{
		Write-Verbose $("In process block - Parameter Set Name: " + $PSCmdlet.ParameterSetName)
		
		if ($PSCmdlet.ParameterSetName -eq "SamAccountName")
		{
			try {
				Write-Verbose "Attempting to find user: $SamAccountName"

				$LDAPFilter = "(&(objectCategory=person)(objectClass=user)(sAMAccountName=$SamAccountName))"
				Write-Verbose "LDAP Filter: $LDAPFilter"

				$ADUser = Get-ADUser -LDAPFilter $LDAPFilter -Properties proxyAddresses -ErrorAction Stop

				if ($null -eq $ADUser) {
					Write-Warning "Unable to find AD User"
					$ProxyAdded = $false
				}
				else {
					Write-Output "User found" | Out-Host
					Write-Verbose "Distinguished Name:"
					Write-Verbose $ADUser.DistinguishedName

					$ProxyAdded = $true
				}
			}
			catch {
				Write-Warning "Unable to find AD user based on SamAccountName"
			}
		}
		
		if ($ProxyAdded)
		{
			#Verify one unique user was found
			try {
				$ADUserCount = ($ADUser | Measure-Object).Count
				Write-Verbose "AD User Count: $ADUserCount"

				if ($ADUserCount -eq 1)
				{
					Write-Verbose "One unique AD User was found"
				}
				else {
					Write-Warning "AD user count doesn't equal 1"
					$ProxyAdded = $false
				}
			}
			catch {
				Write-Warning "Unable to determine AD User Count"
				$ProxyAdded = $false
			}
		}

		if ($ProxyAdded)
		{
			#At this point, one unique AD user object should be found.
			#Now get proxy addresses to verify that the proxy address isn't already present
			#or that it's not the primary SMTP address
			$ProxyAddresses = $ADUser.proxyAddresses

			foreach ($ProxyAddress in $ProxyAddresses)
			{
				Write-Output "Current Proxy Address from ADUser: $ProxyAddress" | Out-Host

				if (($ProxyAddress.indexOf($NewProxyAddress) -ge 0) -AND ($ProxyAddress -clike "*SMTP*"))
				{
					Write-Output "New Proxy address is the primary SMTP address."
					$ProxyAdded = $false
				}
				elseif ($ProxyAddress.indexOf($NewProxyAddress) -ge 0)
				{
					Write-Output "New proxy address is already a proxy address" | Out-Host
					$ProxyAdded = $false
				}
			}
		}

		if ($ProxyAdded)
		{
			#Now proxy address will be added to AD account
			$NewProxyAddress = $NewProxyAddress.Trim()

			if ($Primary)
			{
				$NewProxyAddress = "SMTP:" + $NewProxyAddress
			}
			else {
				$NewProxyAddress = "smtp:" + $NewProxyAddress
			}

			Write-Output "Adding: $NewProxyAddress"

			try {
				if ($PSCmdlet.ShouldProcess("Adding new proxy address"))
				{
					Write-Verbose "About to set proxy address"
					$ADUser | Set-ADUser -Add @{proxyAddresses=$NewProxyAddress} -ErrorAction Stop
				}
				
				Write-Output "Successfully added new proxy address" | Out-Host
			}
			catch {
				Write-Warning "Unable to add new proxy address"	
				$ProxyAdded = $false
			}
		}
	}

	end {
		return $ProxyAdded
	}
}

function Convert-HSCDNToFQDN
{
	<#
		.SYNOPSIS
			This function converts a domain name to a fully qualified domain name.

		.PARAMETER $DN
			A string array of distinguished names to convert

		.OUTPUTS
			PSObject

		.EXAMPLE
			$DNArray = @("CN=TestUser,OU=ITS,OU=ADMIN,OU=HSC,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU",
						"OU=ITS,OU=ADMIN,OU=HSC,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU")
			$DNArray | Convert-HSCDNToFQDN

			OriginalDN                                                       FQDN
			----------                                                       ----
			CN=TestUser,OU=ITS,OU=ADMIN,OU=HSC,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU TestUser.ITS.ADMIN.HSC.HS.WVU-AD.WVU.EDU
			OU=ITS,OU=ADMIN,OU=HSC,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU             ITS.ADMIN.HSC.HS.WVU-AD.WVU.EDU

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: September 22, 2021
	#>

	[CmdletBinding()]
	[OutputType([PSObject[]])]
	param(
		[Parameter(Mandatory=$true,
					ValueFromPipeline=$true,
					ValueFromPipelineByPropertyName=$true,
					Position=0)]
		[Alias("DistinguishedName")]
		[string[]]$DN
	)

	process
	{
		foreach ($CurrentDN in $DN)
		{
			Write-Verbose "Current DN: $CurrentDN"

			$FQDN = $CurrentDN
			$FQDN = $FQDN -replace "DC=", "."
			$FQDN = $FQDN -replace "OU=", "."
			$FQDN = $FQDN -replace "CN=", "."
			$FQDN = $FQDN -replace ",", ""



			if ($FQDN.indexOf(".") -eq 0) {
				$FQDN = $FQDN.substring(1)
			}

			$FQDNObject = [PSCustomObject]@{
				OriginalDN = $CurrentDN
				FQDN = $FQDN
			}

			$FQDNObject
		}
	}
}

function Get-HSCADUserAdminCount
{
	<#
		.SYNOPSIS
			This function returns the adminCount attribute of an AD user(s)

		.OUTPUTS
			PSObject

		.PARAMETER SamAccountName
			This parameter is a string array of AD users to
			return the adminCount attribute for.

		.EXAMPLE
			"jbrusoe","krussell" | Get-HSCADUserAdminCount

			SamAccountName AdminCount UserDN
			-------------- ---------- ------
			jbrusoe                 1 CN=Jeff Brusoe,OU=Network Systems,OU=Network...
			krussell                1 CN=Kevin Russell,OU=Network Systems,OU=Netwo...

		.EXAMPLE
			Get-HSCADUserAdminCount jbrusoe,krussell

			SamAccountName AdminCount UserDN
			-------------- ---------- ------
			jbrusoe                 1 CN=Jeff Brusoe,OU=Network Systems,OU=Netw...
			krussell                1 CN=Kevin Russell,OU=Network Systems,OU=Ne...


		.EXAMPLE
			Get-ADUser jbrusoe | Get-HSCADUserAdminCount

			SamAccountName AdminCount UserDN
			-------------- ---------- ------
			jbrusoe                 1 CN=Jeff Brusoe,OU=Network Systems,OU=Network and Voice...

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: September 24, 2021
	#>
	[CmdletBinding()]
	[OutputType([PSObject[]])]
	param (
		[Parameter(ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true,
			Mandatory=$true,
			Position=0)]
		[string[]]$SamAccountName
	)

	process
	{
		foreach ($ADUserName in $SamAccountName)
		{
			[PSObject]$ADUserObject = $null
			try {
				$ADUser = Get-ADUser $ADUserName -Properties adminCount -ErrorAction Stop
				Write-Verbose "Found User: $ADUserName"
			}
			catch{
				Write-Warning "Unable to find user name"

				$ADUserObject = [PSCustomObject]@{
					SamAccountName = $ADUserName
					AdminCount = "UserNotFound"
					UserDN = "UserNotFound"
				}

				$ADUser = $null
			}

			if ($null -ne $ADUser)
			{
				$ADUserObject = [PSCustomObject]@{
					SamAccountName = $ADUser.SamAccountName
					AdminCount = $ADUser.AdminCount
					UserDN = $ADUser.DistinguishedName
				}
			}
			else {
				Write-Warning "ADUser object is null"
				$ADUserObject = [PSCustomObject]@{
					SamAccountName = $ADUserName
					AdminCount = "UserNotFound"
					UserDN = "UserNotFound"
				}
			}

			$ADUserObject
		}
	}
}
Function Get-HSCADUserCount
{
	#Written By: Jeff Brusoe
	#Last Updated: January 22, 2020
	#
	#Purpose: This function is designed to return the total number of AD users.

	[CmdletBinding()]
	param (
		[string]$OrgUnit = $null,
		[switch]$UserEnabled
	)

	$ADUserCount = 0

	try
	{
		if ($OrgUnit -eq "HSC")
		{
			#Correction for HSC org unit due to duplicate names
			$OrgUnitObject = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq 'OU=HSC,DC=HS,DC=wvu-ad,DC=wvu,DC=edu' " -ErrorAction Stop
		}
		elseif ($OrgUnit -eq "NewUsers")
		{
			$OrgUnitObject = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq 'OU=NewUsers,DC=HS,DC=wvu-ad,DC=wvu,DC=edu' " -ErrorAction Stop
		}
		elseif (![string]::IsNullOrEmpty($OrgUnit))
		{
			$OrgUnitObject = Get-ADOrganizationalUnit -Filter "Name -eq '$OrgUnit' " -ErrorAction Stop
		}
	}
	catch {
		Write-Warning "Unable to find org unit: $OrgUnit" | Out-Host
		$ADUserCount = -1
	}

	if (($null -ne $OrgUnitObject) -AND (($OrgUnitObject | Measure-Object).Count -eq 1))
	{
		#Org unit successfully found			
		try
		{
			if ($UserEnabled)
			{
				$ADUserCount = (Get-ADUser -Filter * -SearchBase $OrgUnitObject.DistinguishedName -ErrorAction Stop |
					Where-Object {$_.Enabled -eq $true} | Measure-Object).Count
			}
			else
			{
				$ADUserCount = (Get-ADUser -Filter * -SearchBase $OrgUnitObject.DistinguishedName -ErrorAction Stop | Measure-Object).Count
			}
			
			Write-Output "User Count: $ADUserCount" | Out-Host
		}
		catch
		{
			Write-Warning "Error getting user count" | Out-Host
			$ADUserCount = -1
		}
	}
	else
	{
		try
		{
			if ($UserEnabled)
			{
				$ADUserCount = (Get-ADUser -Filter * -ErrorAction Stop | Where {$_.Enabled -eq $true} | Measure).Count
			}
			else
			{
				$ADUserCount = (Get-ADUser -Filter * -ErrorAction Stop | Measure).Count
			}
			
			Write-Verbose "User Count: $ADUserCount"
		}
		catch
		{
			Write-Warning "Error getting user count"
			$ADUserCount = -1
		}
	}
	
	return $ADUserCount
}

Function Get-HSCADUserParentContainer
{
	<#
		.SYNOPSIS
			The purpose of this file is to get the AD Users's parent container.

		.DESCRIPTION

		.PARAMETER SamAcountName

		.PARAMETER ShortName
	
		.NOTES
			Written by: Jeff Brusoe
			Last Updated: December 14, 2021
	#>

	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true,
					ValueFromPipeline = $true,
					ValueFromPipelineByPropertyName = $true,
					Position = 0)]
		[Alias("User")]
		[string[]]$SamAccountName,

		[switch]$ShortName
	)

	begin {
		Write-Verbose "Searching for: $SamAccountName"
	}
	
	process
	{
		try {	
			$ADUser = Get-ADUser $SamAccountName -ErrorAction Stop
			Write-Verbose "Successfully found user"
		}
		catch {
			Write-Warning "User not found."
			return
		}
	
		$UserDN = $ADUser.DistinguishedName
		Write-Verbose "User DN: $UserDN"
	
		$ParentContainer = $UserDN.substring($UserDN.indexOf("OU="))
		
		if ($ShortName) {
			$ParentContainer = $ParentContainer.substring(0,$ParentContainer.indexOf(","))
		}
		
		Write-Verbose "Parent Container: $ParentContainer"
	}

	end {
		return $ParentContainer
	}
}

Function Get-HSCDirectoryMapping
{
	<#
		.SYNOPSIS
			This function takes a user's distinguished name for input and returns
			the path to the user's home directory.

		.DESCRIPTION
			During the HSC new account creation process, a homedirectory is created for
			all new users. This function determines the correct path to the users homedirectory
			based on a mapping file.

		.OUTPUTS
			This function currently returns a PS Object that contains the path to the
			users's homedirectory and whether it's a complete path. The complete path is being
			deprecated. When that happens, this function will just return a string for the path.

		.EXAMPLE
			PS C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository> $ADUser = Get-ADUser jbrusoe
			PS C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository> Get-HSCDirectoryMapping -UserDN $ADUser.DistinguishedName

			DirectoryPath                                              FullPath
			-------------                                              --------
			\\hs.wvu-ad.wvu.edu\public\ITS\Network and Voice Services\     True


			PS C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository> $ADUser = Get-ADUser krussell
			PS C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository> Get-HSCDirectoryMapping -UserDN $ADUser.DistinguishedName

			DirectoryPath                                                    FullPath
			-------------                                                    --------
			\\hs.wvu-ad.wvu.edu\public\ITS\support services\desktop support\     True

		.PARAMETER UserDN
			This is the distinguished name of the user to determine the home directory
			mapping of.

		.PARAMETER DetermineFullPath
			This parameter is being deprecated and shouldn't be used.

		.NOTES
			Last Modified by: Jeff Brusoe
			Last Modified: August 4, 2020
	#>
	
	[CmdletBinding()]
	[OutputType([PSObject])]
	param (
		[Parameter(ValueFromPipeline = $true,
			Mandatory=$true)]
		[string]$UserDN,
		[switch]$DetermineFullPath
	)
	
	begin
	{
		#Create object to hold directory information
		$HomeDirectoryInfo = New-Object PSObject
		
		$HomeDirectoryInfo | Add-Member -type NoteProperty -Name DirectoryPath -value $null 
		$HomeDirectoryInfo | Add-Member -type NoteProperty -Name FullPath -Value $false
		#In cases where the DN still needs to be parsed up later recursively, the FullPath value is set to false.
		#If the DirectoryPath value is the correct (& final) home directory path, the FullPath value is set to true.
	
		if ($UserDN.indexOf("CN=") -ge 0)
		{
			#Need to remove this from the DN
			$UserDN = $UserDN.substring($UserDN.indexOf(",")+1).Trim()
			Write-Verbose "Cleaned UserDN: $UserDN"
		}
	}
	
	process
	{
		#First check DirectoryMapping file for match
		[string]$HomeDirectoryPath = $null

		#Step 1: Check against home directory mapping file.
		#$HomeDirectoryMappings = Import-Csv $($MyInvocation.PSScriptRoot + "\HomeDirectoryMapping.csv")
		$HomeDirectoryMappings = Import-Csv "C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\Create-NewAccount\HomeDirectoryMapping.csv"
		#$HomeDirectoryMappings = Import-Csv "C:\HSCGitHub\HSC-PowerShell-Repository\Create-NewAccount\HomeDirectoryMapping.csv"

		[string]$HomeDirectoryPath = ($HomeDirectoryMappings |
			Where-Object {$UserDN -eq $_.UserDN}).DirectoryPath

		if ([string]::IsNullOrEmpty($HomeDirectoryPath))
		{
			[string]$HomeDirectoryPath = ($HomeDirectoryMappings |
				Where-Object {$UserDN -match $_.UserDN}).DirectoryPath
		}

		if ([string]::IsNullOrEmpty($HomeDirectoryPath))
		{
			Write-verbose "No match from directory mapping file"
		}
		else {
			$HomeDirectoryInfo.DirectoryPath = $HomeDirectoryPath
			$HomeDirectoryInfo.FullPath = $true
		}

		#Step 2: Check against predefined mappings
		[string]$ParentPath = $null

		if ([string]::IsNullOrEmpty($HomeDirectoryPath))
		{
			switch -wildcard ($UserDN)
			{
				"*OU=ADMIN*" 
				{
					$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\Admin\"
					$HomeDirectoryInfo.FullPath = $false
					$ParentPath = "ADMIN"
					break
				}
				"*OU=BASSCI*" 
				{
					$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\bassci\"
					$HomeDirectoryInfo.FullPath = $false
					break
				}
				"*OU=MBRCC*" 
				{
					$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\mbrcc\"
					$HomeDirectoryInfo.FullPath = $false
					break
				}			
				"*OU=SOM*" 
				{
					$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\som\"
					$HomeDirectoryInfo.FullPath = $false
					break
				}
				"*OU=SON*" 
				{
					$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\son\"
					$HomeDirectoryInfo.FullPath = $false
					break
				}
				"*OU=SOP*" 
				{
					$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\sop\"
					$HomeDirectoryInfo.FullPath = $false
					break
				}
				"*OU=SPH*" 
				{
					$HomeDirectoryInfo.DirectoryPath = "\\hs.wvu-ad.wvu.edu\public\sph\"
					$HomeDirectoryInfo.FullPath = $false
					break
				}
				default 
				{
					$HomeDirectoryInfo.DirectoryPath = "NoHomeDirectory"
					$HomeDirectoryInfo.FullPath = $true
				}
			}
		}

		#Step 3: Determine full path if switch not used
		if ($DetermineFullPath -AND
			!$HomeDirectoryInfo.FullPath -AND 
			($HomeDirectoryInfo -ne "NoHomeDirectory"))
		{
			$ParsedDN = $UserDN -split ","
			$ParsedDNCount = $ParsedDN.Length
			$AddToPath = $false

			for ($i=$ParsedDNCount-1; $i -ge 0; $i--)
			{
				$ParsedDN[$i] = $ParsedDN[$i] -replace "OU=",""

				if ($ParsedDN[$i] -eq $ParentPath)
				{
					$AddToPath = $true
				}
				elseif ($AddToPath)
				{	
					$HomeDirectoryInfo.DirectoryPath = $HomeDirectoryInfo.DirectoryPath + "\" + $ParsedDN[$i]+ "\"
				}
			}
			$HomeDirectoryInfo.FullPath = $true
		}
	}

	end
	{
		return $HomeDirectoryInfo
	}	
}

function Get-HSCLoggedOnUser
{
	<#
	.SYNOPSIS
		This function returns the currently logged on user.
		
	.OUTPUTS
		Returns a PSCustomObject that has two properties: Logged on username and domain.

	.NOTES
		Tested with the following version of PowerShell:
		1. 5.1.18362.752
		2. 7.0.2
		
		Written by: Jeff Brusoe
		Last Updated by: Jeff Brusoe
		Last Updated: June 24, 2020
	#>

	[CmdletBinding()]
	[OutputType([PSCustomObject])]
	param()

	try 
	{
		$LoggedOnUser = [PSCustomObject]@{
			UserName = $((Get-ChildItem Env:\USERNAME).Value)
			Domain = $((Get-ChildItem Env:\USERDOMAIN).Value)
		}

		return $LoggedOnUser
	}
	catch 
	{
		Write-Warning "Error getting logged on user" | Out-Null

		return $null
	}
}

function Get-HSCPrimarySMTPAddress
{
	<#
	.SYNOPSIS
		This function retrieves the primary SMTP address for AD users.
		
	.INPUTS
		This function can take a string(array) or ADUser object(array) and will
		get the primary SMTP address for those users.
		
	.PARAMETER UserNames
		This parameter takes a string array of users names as input. It will attempt to get
		the primary SMTP address after finding the users.
	
	.PARAMETER ADUsers
		Similar to UserNames, but this paramter takes an array of ADUsers (Microsoft.ActiveDirectory.Management.ADAccount)
		and attempts to get their primary SMTP address.
	
		
	.EXAMPLE
		PS C:\Windows\system32> "jbrusoe","krussell" | Get-HSCPrimarySMTPAddress

		SamAccountName PrimarySMTPAddress
		-------------- ------------------
		jbrusoe        jbrusoe@hsc.wvu.edu
		krussell       krussell@hsc.wvu.edu
		
	.EXAMPLE
		PS C:\Windows\system32> $Jeff = Get-ADUser jbrusoe -Properties proxyAddresses
		PS C:\Windows\system32> $Kevin = Get-ADUser krussell -Properties proxyAddresses
		PS C:\Windows\system32> $Jeff,$Kevin | Get-HSCPrimarySMTPAddress

		SamAccountName PrimarySMTPAddress
		-------------- ------------------
		jbrusoe        jbrusoe@hsc.wvu.edu
		krussell       krussell@hsc.wvu.edu
		
	.NOTES
		Written by: Jeff Brusoe
		Last Updated by: Jeff Brusoe
		Last Updated: July 16, 2020
	#>

	[CmdletBinding()]
	[OutputType([PSObject])]
		
	param (
		[Parameter(ValueFromPipeline=$true,
			ParameterSetName="ADUserArray",
			Mandatory=$true,
			Position=0)]
		[PSObject[]]$ADUsers,
		
		[Parameter(ValueFromPipeline=$true,
			ParameterSetName="UserNameArray",
			Mandatory=$true,
			Position=0)]
		[string[]]$UserNames,
		
		[switch]$NoOutput
	)
	
	begin {
		[PSObject[]]$PrimarySMTPAddresses = @()
	}

	process
	{
		Write-Verbose $("In process block - Parameter Set Name: " + $PSCmdlet.ParameterSetName)

		#Get array of ADUsers if a string array is passed in
		if ($PSCmdlet.ParameterSetName -eq "UserNameArray")
		{	
			$ADusers = $null
			foreach ($UserName in $UserNames)
			{
				try
				{
					$ADUsers += Get-ADUser $UserName -Properties proxyAddresses -ErrorAction Stop
					Write-Verbose "Found User: $UserName"
				}
				catch
				{
					Write-Warning "Unable to find user name"

					$ADUserObject = New-Object -TypeName PSObject
					$ADUserObject | Add-Member -MemberType NoteProperty -Name "SamAccountName" -Value $UserName
					$ADUserObject | Add-Member -MemberType NoteProperty -Name "PrimarySMTPAddress" -Value "UserNotFound"
				
					$PrimarySMTPAddresses += $ADUserObject
				}
			}
		}
		
		if ($null -ne $ADUsers)
		{
			foreach ($ADUser in $ADUsers)
			{
				$ADUserObject = New-Object -TypeName PSObject
				$ADUserObject |
					Add-Member -MemberType NoteProperty -Name "SamAccountName" -Value $ADUser.SamAccountName


				[string[]]$ProxyAddresses = $ADUser.proxyAddresses

				[string]$PrimarySMTPAddress = $ProxyAddresses -cmatch "SMTP:"
	
				if ([string]::IsNullOrEmpty($PrimarySMTPAddress))
				{
					Write-Verbose "Primary SMTP Address isn't defined"
					$ADUserObject |
						Add-Member -MemberType NoteProperty -Name "PrimarySMTPAddress" -Value $null
				}
				else {
					Write-Verbose $("Current User" + $ADUser.SamAccountName)
					Write-Verbose "Primary SMTP Address: $PrimarySMTPAddress"

					$PrimarySMTPAddress = ($PrimarySMTPAddress -replace "SMTP:","").Trim()
				
					$ADUserObject |
						Add-Member -MemberType NoteProperty -Name "PrimarySMTPAddress" -Value $PrimarySMTPAddress
				}
				
				$PrimarySMTPAddresses += $ADUserObject
			}
		}
		else {
			Write-Warning "ADUser object is null"
		}
	}

	end {
		return $PrimarySMTPAddresses
	}
}

function Get-HSCADUserFromString
{
	<#
		.SYNOPSIS
			This function returns an AD User array from a passed in string array

		.OUTPUTS
			[Microsoft.ActiveDirectory.Management.ADAccount[]]

		.PARAMETER UserNames
			This is the string array of usernames to get the corresponding AD user objects for.
			
		.EXAMPLE
			PS C:\Windows\system32> "jbrusoe","krussell" | Get-HSCADUserFromString

			DistinguishedName : CN=Jeff Brusoe,OU=Network Systems,OU=Network and Voice
								Services,OU=ITS,OU=ADMIN,OU=HSC,DC=HS,DC=wvu-ad,DC=wvu,DC=edu
			Enabled           : True
			GivenName         : Jeff
			Name              : Jeff Brusoe
			ObjectClass       : user
			ObjectGUID        : 04d2e77c-b50e-40ce-9e94-c819e2ed85e0
			SamAccountName    : jbrusoe
			SID               : S-1-5-21-865322659-4255640127-3857865232-2111
			Surname           : Brusoe
			UserPrincipalName : jbrusoe@hsc.wvu.edu

			DistinguishedName : CN=Kevin Russell,OU=Desktop Support,OU=Support
								Services,OU=ITS,OU=ADMIN,OU=HSC,DC=HS,DC=wvu-ad,DC=wvu,DC=edu
			Enabled           : True
			GivenName         : Kevin
			Name              : Kevin Russell
			ObjectClass       : user
			ObjectGUID        : f1db51f3-2a85-49d5-9ec6-19951d2257ae
			SamAccountName    : krussell
			SID               : S-1-5-21-865322659-4255640127-3857865232-2123
			Surname           : Russell
			UserPrincipalName : krussell@hsc.wvu.edu
			
		.NOTES
			Last updated by: Jeff Brusoe
			Last Updated: July 27, 2020
	#>

	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true,
			ValueFromPipeline = $true)]
		[string[]]$UserNames
	)

	begin
	{
		Write-Verbose "Beginning to Search for AD User Objects"

		[Microsoft.ActiveDirectory.Management.ADAccount[]]$ADUsers = $null
	}

	process
	{
		foreach ($UserName in $UserNames)
		{
			try {
				Write-Verbose "Attempting to find user: $UserName"
				$ADUser = Get-ADUser $UserName -ErrorAction Stop

				if ($null -ne $ADUser)
				{
					$ADUsers += $ADUser
				}
			}
			catch {
				Write-Warning "Unable to find user"
			}
		}
	}

	end
	{
		return $ADUsers
	}
}

function Get-HSCADUserMailNickname
{
	<#
		.SYNOPSIS
			This function returns the mailNickname field for AD users

		.DESCRIPTION
			The purpose of this function is to return the mailNickname
			attribute for HSC AD users. A PSCustomObject is returned that
			contains the SamAccountName and the user's mailNickname field.
			This attribute is $null if the field isn't populated in AD.

        .PARAMETER SamAccountName

		.EXAMPLE
			Get-HSCADUserMailNickname jbrusoe

			SamAccountName MailNickname
			-------------- ------------
			jbrusoe        jbrusoe
			
		.EXAMPLE
			"jbrusoe","krussell" | Get-HSCADUserMailNickname

			SamAccountName MailNickname
			-------------- ------------
			jbrusoe        jbrusoe
			krussell       krussell
			
		.EXAMPLE
			"jbrusoe","krussell","asdf" | Get-HSCADUserMailNickname

			WARNING: Unable to find AD User
			SamAccountName MailNickname
			-------------- ------------
			jbrusoe        jbrusoe
			krussell       krussell
			asdf

		.EXAMPLE
			Get-ADUser jbrusoe | Get-HSCADUserMailNickname

			SamAccountName MailNickname
			-------------- ------------
			jbrusoe        jbrusoe

		.EXAMPLE
			 Get-HSCADUserMailNickname @("jbrusoe","krussell")

			SamAccountName MailNickname
			-------------- ------------
			jbrusoe        jbrusoe
			krussell       krussell
		
		.OUTPUTS
			PSCustomObject

		.NOTES
			Writen by: Jeff Brusoe
			Last Updated: April 7, 2021
	#>
	[CmdletBinding()]
	[OutputType([PSCustomObject])]
	param(
		[ValidateNotNullOrEmpty()]
		[Parameter(ValueFromPipeline = $true,
					ValueFromPipelineByPropertyName = $true,
					Position = 0)]
		[string[]]$SamAccountName
	)

	begin {
		Write-Verbose "In Get-HSCADUserMailNickname Function"
	}
	
	process
	{
        if ($null -eq $SamAccountName) {
            throw
        }

		foreach ($HSCSAM in $SamAccountName)
		{
			Write-Verbose "Current SamAccountName: $HSCSAM"

			try {
				$HSCADUser = Get-ADUser $HSCSAM -ErrorAction Stop -Property mailNickname

				$MailNickname = [PSCustomObject]@{
					SamAccountName = $HSCADuser.SamAccountName
					MailNickname = $HSCADUser.mailNickname
				}
			}
			catch {
				Write-Warning "Unable to find AD User"
				
				$MailNickname = [PSCustomObject]@{
					SamAccountName = $HSCSAM
					MailNickname = $null
				}
			}

            $MailNickname
		}
	}
}

Function Get-HSCUserOrGroup {
	<#
    	.SYNOPSIS
			The purpose of this function is to determine if the username is a user or group

		.EXAMPLE
			Get-HSCUserOrGroup -Username krussell
			User

		.EXAMPLE
			Get-HSCUserOrGroup jbrusoe
			User

		.EXAMPLE
			Get-HSCUserOrGroup "Domain Admins"
			Group

		.EXAMPLE
			Get-HSCUserOrGroup abcd
			WARNING: Unable to find AD Object: abcd

		.OUTPUTS
			System.String

		.NOTES
			Written By:  Kevin Russell
			Last Updated By:  Kevin Russell
			Last Updated:  6/3/21

			To Do: Allow Pipeline Input
	#>

	[CmdletBinding()]
	[OutputType([String])]
	param(
		[Parameter(Mandatory=$true,
					Position = 0)]
		[string]$UserName
	)

	[string]$GroupOrUser = $null

	try {
		Get-ADUser $UserName -ErrorAction Stop | Out-Null
		$GroupOrUser = "User"

		Write-Verbose "$UserName is a user"
	}
	catch {
		try {
			Get-ADGroup $UserName -ErrorAction Stop | Out-Null
			$GroupOrUser = "Group"

			Write-Verbose "$UserName is a group"
		}
		catch {
			Write-Warning "Unable to find AD Object: $UserName"
		}
	}

	$GroupOrUser
}

function Send-HSCNewAccountEmail
{
	<#
		.SYNOPSIS
			This function sends the CSC a new account creation email.

		.DESCRIPTION
			This function sends a confirmation email to the department's CSC
			after successfully creating a new account. It is not intended to run
			in a stand-alone mode.

		.OUTPUTS
			The output of this function is an email such as the following:

			Subject: New Account Created: emily.battle@hsc.wvu.edu

			Message Body:
			The following account has been created in the HS domain and email system:
			Username: ehb10007
			Email Address: emily.battle@hsc.wvu.edu

		.PARAMETER CSCEmail
			The CSC email address who will be receiving the email.

		.PARAMETER SamAccountName
			This is the SamAccountName f the newly created account.

		.PARAMETER PrimarySMTPAddress
			This is the PrimarySMTPAddress of the newly created account.

		.PARAMETER SMTPServer
			The SMTP server to relay mail through.

		.PARAMETER From
			The email address sending the message

		.NOTES
			Writen by: Jeff Brusoe
			Last Updated: August 4, 2020
	#>

	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[string]$CSCEmail,

		[Parameter(Mandatory=$true)]
		[string]$SamAccountName,

		[Parameter(Mandatory=$true)]
		[string]$PrimarySMTPAddress,

		[ValidateNotNullOrEmpty()]
		[string]$NewUserOU,

		[ValidateNotNullOrEmpty()]
		[string]$SMTPServer = "Hssmtp.hsc.wvu.edu",

		[ValidateNotNullOrEmpty()]
		[string]$From = "microsoft@hsc.wvu.edu"
	)
	
	process
	{
		$MsgSubject = "New Account Created: $PrimarySMTPAddress"
		$MsgBody = "The following account has been created in the HS domain and email system:`nUsername: $SamAccountName`nEmail Address: $PrimarySMTPAddress" 
		
		if (![string]::IsNullOrEmpty($NewUserOU)) {
			$MsgBody += "`nNew User OU: $NewUserOU"
		}

		Write-Output "Message Subject: $MsgSubject" | Out-Host
		Write-Output "Message Body: $MsgBody" | Out-Host

		$Recipients = @($CSCEmail,"microsoft@hsc.wvu.edu","jbrusoe@hsc.wvu.edu","mkondrla@hsc.wvu.edu")

		try {
			Send-MailMessage -to $Recipients -From $From -SMTPServer $SMTPServer -Subject $MsgSubject -Body $MsgBody -ErrorAction Stop #UseSSL -port 587
		}
		catch {
			Write-Warning "Unable to email message confirming account createion"
		}
	}
}

function Set-HSCADUserAddressBookVisibility
{
	<#
		.SYNOPSIS
			The purpsoe of this function is to configure a HSC user's email
			address to either show or not show inthe address book.

		.DESCRIPTION
			This function configures an AD user to be visible(or not visible) in
			the global address list. It does this by changing the msExchHideFromAddressLists
			property in AD. This will then sync to the cloud to change the address book visibility
			which is why this function is in the AD module instead of the Office 365 module.

		.OUTPUTS
			A boolean value indicating if the visibility was successfully set/changed.

		.EXAMPLE
			Set-HSCADserAddressBookVisibility -SAMAccountName "jbrusoe"
			True

		.EXAMPLE
			Set-HSCADUserAddressBookVisibility abcdefg
			WARNING: Unable to find abcdefg
			False

		.EXAMPLE
			"jbrusoe","krussell" | Set-HSCADUserAddressBookVisibility
			True

		.EXAMPLE
			"jbrusoe","krussell" | Set-HSCADUserAddressBookVisibility -Verbose
			VERBOSE: Hide Email: False
			VERBOSE: Hide Email String: unhide email
			VERBOSE: Confirm Preference: High
			VERBOSE: Performing the operation "Set-HSCADUserAddressBookVisibility" on target "Attempting to unhide email".
			VERBOSE: Current Username: jbrusoe
			VERBOSE: Return Value: True
			VERBOSE: Performing the operation "Set-HSCADUserAddressBookVisibility" on target "Attempting to unhide email".
			VERBOSE: Current Username: krussell
			VERBOSE: Return Value: True
			True

		.PARAMETER SAMAccountName
			This parameter is the users's distinguished name or sam account name.

		.PARAMETER HideEmail
			Switch parameter to indicate that an account should be hidden instead of shown in
			the gloabl address list.

		.NOTES
			Last updated by: Jeff Brusoe
			Last Updated: March 10, 2021

			Tested with PowerShell 5.1 - March 10, 2021
			Does not work with PowerShell 7.1.1 - March 10, 2021
			Does not work with PowerShell 7.1.2 - March 10, 2021
	#>

	[CmdletBinding(SupportsShouldProcess=$true,
					ConfirmImpact="Medium")]
	[OutputType([bool])]
	param (
		[Parameter(Mandatory=$true,
					ValueFromPipeline=$true)]
		[string[]]$SAMAccountName,

		[switch]$HideEmail
	)

	begin {
		foreach ($SAM in $SamAccountName) {
			Write-Verbose "SAMAccountName: $SAM"
		}

		Write-Verbose "Hide Email: $HideEmail"

		if ($HideEmail) {
			$HideEmailString = "hide email"
		}
		else {
			$HideEmailString = "unhide email"
		}

		Write-Verbose "Hide Email String: $HideEmailString"
		Write-Verbose "Confirm Preference: $ConfirmPreference"
	}

	process
	{
		$ReturnValue = $true

		foreach ($SAM in $SamAccountName)
		{
			try {
				$ADUser = Get-ADUser -Identity $SAM -ErrorAction Stop
			}
			catch {
				Write-Warning "Unable to find $SAM"
				$ReturnValue = $false
			}

			if ($null -ne $ADUser -AND $ReturnValue) {
				if ($PSCmdlet.ShouldProcess("Attempting to $HideEmailString")) {
					try {
						$ADUser |
							Set-ADUser -Add @{msExchHideFromAddressLists=[bool]$HideEmail} -ErrorAction Stop
					}
					catch {
						try {
							Write-Verbose "Unable to add, trying to replace"

							$ADUser |
								Set-ADUser -Replace @{msExchHideFromAddressLists=[bool]$HideEmail} -ErrorAction Stop
						}
						catch {
							Write-Warning "Unable to configure user visibility"
							$ReturnValue = $false
						}
					}
				}
			}
			else {
				$ReturnValue = $false
			}

			Write-Verbose "Current Username: $SAM"
			Write-Verbose "Return Value: $ReturnValue"
		}
	}

	end {
		return $ReturnValue
	}
}

function Set-HSCADUserExt7
{
	<#
		.SYNOPSIS
			The purpsoe of this function is to configure an HSC user's
			extensionAttribute7 to be either Yes365 or No365.

		.DESCRIPTION
			This function configures an AD user to either sync to the cloud (Yes365) or not (No365).
			These values are sest in extensionAttribute7 which is why this function
			is in the AD module instead of the Office 365 module.

		.OUTPUTS
			PSObject

		.EXAMPLE
			Set-HSCADuserExt7 jbrusoe

			SamAccountName ADUserFound Ext7Set Ext7String
			-------------- ----------- ------- ----------
			jbrusoe               True    True Yes365

		.EXAMPLE
			Set-HSCADuserExt7 jbrusoe,krussell,asdf

			WARNING: Unable to find asdf
			WARNING: Unable to set extensionAttribute7
			SamAccountName ADUserFound Ext7Set Ext7String
			-------------- ----------- ------- ----------
			jbrusoe               True    True Yes365
			krussell              True    True Yes365
			asdf                 False   False Yes365

		.EXAMPLE
			Set-HSCADUserExt7 jbrusoeadmin -No365

			SamAccountName ADUserFound Ext7Set Ext7String
			-------------- ----------- ------- ----------
			jbrusoeadmin          True    True No365

		.EXAMPLE
			Set-HSCADuserExt7 jbrusoe -WhatIf -No365
			What if: Performing the operation "Set-HSCADUserExt7" on target "Attempting to extensionAttribute7 to No365".

			SamAccountName ADUserFound Ext7Set Ext7String
			-------------- ----------- ------- ----------
			jbrusoe               True   False No365

		.PARAMETER SAMAccountName
			This parameter is the users's distinguished name or sam account name.

		.PARAMETER No365
			The function assumes that Yes365 should be used here. This switch parameter
			is used when No365 should be set instead.

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: JUne 23, 2021
	#>

	[CmdletBinding(SupportsShouldProcess=$true,
					ConfirmImpact="Medium")]
	[OutputType([PSObject])]
	param (
		[Parameter(Mandatory=$true,
					ValueFromPipeline=$true,
					ValueFromPipelineByPropertyName = $true,
					Position = 0)]
		[string[]]$SAMAccountName,

		[switch]$No365
	)

	begin {
		foreach ($SAM in $SamAccountName) {
			Write-Verbose "SAMAccountName: $SAM"
		}

		if ($No365) {
			$Ext7String = "No365"
		}
		else {
			$Ext7String = "Yes365"
		}

		Write-Verbose "ExtensionAttribute7 String: $Ext7String"
		Write-Verbose "Confirm Action Preference: $ConfirmPreference"
	}

	process
	{
		foreach ($SAM in $SamAccountName)
		{
			Write-Verbose "Current SAM: $SAM"

			try {
				$ADUser = Get-ADUser -Identity $SAM -ErrorAction Stop
				$ADUserFound = $true
			}
			catch {
				Write-Warning "Unable to find $SAM"
				$ADUserFound = $false
			}

			if ($null -ne $ADUser -AND $ADUserFound) {
				$Ext7Set = $false #For -WhatIf case

				if ($PSCmdlet.ShouldProcess("Attempting to set extensionAttribute7 to $Ext7String")) {
					try {
						$ADUser |
							Set-ADUser -Add @{extensionAttribute7=$Ext7String} -ErrorAction Stop
						
						$Ext7Set = $true
					}
					catch {
						try {
							Write-Verbose "Unable to add ext7, attempting to replace"
							$ADUser |
								Set-ADUser -Replace @{extensionAttribute7=$Ext7String} -ErrorAction Stop
							
							$Ext7Set = $true
						}
						catch {
							Write-Warning "Unable to configure user visibility"
							$Ext7Set = $false
						}
					}
				}
			}
			else {
				Write-Warning "Unable to set extensionAttribute7"
				$Ext7Set = $false
			}

			$Ext7Info = [PSCustomObject]@{
				SamAccountName = $SAM
				ADUserFound = $ADUserFound
				Ext7Set = $Ext7Set
				Ext7String = $Ext7String
			}

			$Ext7Info
		}
	}
}

function Set-HSCGroupMembership
{
	<#
		.SYNOPSIS
			The purpsoe of this function is to add a new HSC AD user to the
			correct AD groups.

		.PARAMETER ADUser
			This parameter is the users's distinguished name or sam account name.

		.OUTPUTS
			A boolean value indicating if groups were succesfully added or not

		.DESCRIPTION
			Steps to search for groups
			1. Determine user OU parent DN.
			2. Add users to the DUO MFA and O365 license groups
			3. Add groups based on group mapping file

		.NOTES
			Last updated by: Jeff Brusoe
			Last Updated: March 3, 2021

			Tested with PS 5.1: March 3, 2021
			Doesn't work with 7.1.1 - March 3, 2021
	#>

	[CmdletBinding(SupportsShouldProcess=$true,
					ConfirmImpact="Medium")]
	[OutputType([bool])]
	param (
		[Parameter(ValueFromPipeline = $true,
					Mandatory=$true,
					Position=0)]
		[Alias("UserDN")]
		[string]$ADUser,

		[Parameter(ValueFromPipeline = $false)]
		[ValidateNotNullOrEmpty()]
		[string]$GroupMappingFile = (Get-HSCDepartmentMapPath)
	)

	begin
	{
		Write-Verbose "Beginning to set AD group membership"
		Write-Verbose "ADUser: $ADUser"

		[string]$UserOU = $null
		[string]$UserDN = $null
		$GroupsAdded = $true

		$DefaultGroupMemberships = @(
			"M365 A3 for Faculty Licensing Group",
			"HSC DUO MFA",
			"Block Legacy Authentication Group",
			"HSC Conditional Access Policy"
		)
	}

	process
	{
		Write-Verbose "In process block"

		#Step1: Get Parent OU
		try {
			$UserOU = Get-HSCADUserParentContainer -SamAccountName $ADUser -ErrorAction Stop

			Write-Verbose "User's Parent OU: $UserOU"
		}
		catch {
			Write-Warning "Unable to generate user's parent OU"
			$GroupsAdded = $false
			return
		}

		#Step2: Add user to default groups
		try {
			$UserDN = (Get-ADUser $ADUser -ErrorAction Stop).DistinguishedName

			Write-Verbose "UserDN: $UserDN"
		}
		catch {
			Write-Warning "Unable to find user"
			$GroupsAdded = $false
		}

		Write-Verbose "UserDN: $UserDN"

		foreach ($DefaultGroupMembership in $DefaultGroupMemberships)
		{
			Write-Verbose "Adding user to group: $DefaultGroupMembership"

			try {
				$GroupToAdd = Get-ADGroup $DefaultGroupMembership -ErrorAction Stop

				if ($PSCmdlet.ShouldProcess("Adding user to $DefaultGroupMembership"))
				{
					$GroupToAdd |
						Add-ADGroupMember -Members $UserDN -ErrorAction Stop
				}

				Write-Verbose "Sucessfully added user to group"
			}
			catch {
				Write-Warning "Unable to add group"
				$GroupsAdded = $false
			}
		}

		#Step 3: Check group mapping file
		try {
			Write-Verbose "Reading group maiing file"
			Write-Verbose "Group Mapping File: $Groupmapping File"

			$GroupMappings = Import-Csv $GroupMappingFile -ErrorAction Stop
		}
		catch {
			Write-Warning "Unable to read group mapping file"
			$GroupsAdded = $false
			return
		}

		Write-Verbose "UserOU: $UserOU"
		[string]$GroupsToAdd = ($GroupMappings |
									Where-Object {$_.OUPath -eq $UserOU} |
									Select-Object -First 1).Groups

		if ([string]::IsNullOrEmpty($GroupsToAdd)) {
			[string]$GroupsToAdd = ($GroupMappings |
										Where-Object {$_.OUPath -match $UserOU} |
										Select-Object -First 1).Groups
		}

		if ([string]::IsNullOrEmpty($GroupsToAdd)) {
			Write-Verbose "No match from group mapping file"
		}
		else {
			Write-Verbose "Groups to Add: $GroupsToAdd"
			
			[string[]]$Groups = $GroupsToAdd -split ";"

			foreach ($Group in $Groups)
			{
				$GroupDN = "CN=" + $Group + "," + $UserOU

				try {
					$GroupToAdd = Get-ADGroup -Identity $GroupDN -ErrorAction Stop
				}
				catch {
					Write-Warning "Unable to find Group: $GroupDN"
					$GroupToAdd = $null
				}

				if ($null -ne $GroupToAdd)
				{
					$User = Get-ADUser $UserDN #This may not be needed

					if ($PSCmdlet.ShouldProcess("Adding user to $Group group"))
					{
						try {
							$GroupToAdd |
								Add-ADGroupMember -Members $User.DistinguishedName -ErrorAction Stop

							Write-Verbose "Successfully added user to group"
						}
						catch {
							Write-Warning "Error adding user to group"
							$GroupsAdded = $false
						}
					}
				}
			}
		}
	}

	end {
		return $GroupsAdded
	}
}

function Set-HSCADUserMailNickname
{
    <#
	    .SYNOPSIS
            This function sets an AD users mailNickname field.

        .DESCRIPTION
            This function sets an AD users mailNickname field. It will then
            be synced to the user's mailbox in the cloud.

        .OUTPUT
            System.boolean
			
		.EXAMPLE
			Get-HSCADUserMailNickname jstover4
			SamAccountName MailNickname
			-------------- ------------
			jstover4
			
			Set-HSCADUserMailNickname jstover4 justin.stover -verbose
			VERBOSE: SamAccountName: jstover4
			VERBOSE: Mail Nickname: justin.stover
			VERBOSE: Performing the operation "Set-HSCADUserMailNickname" on target "Attempting to set mailNickname field".
			VERBOSE: AD User Found
			VERBOSE: Attempting to set mailNickname field
			VERBOSE: Successfully set mailNickname field
			True
			
			Get-HSCADUserMailNickname jstover4
			SamAccountName MailNickname
			-------------- ------------
			jstover4       justin.stover
			
		.EXAMPLE
			Set-HSCADUserMailNickname jstover4 justin.stover -verbose
			True

	    .NOTES
		    Written by: Jeff Brusoe
		    Last Updated: April 14, 2021
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
                    ConfirmImpact = "Medium")]
    [OutputType([bool])]
    param (
        [Parameter(Position = 0)]
        [string]$SamAccountName,

        [Parameter(Position = 1)]
        [string]$MailNickname
    )

    Write-Verbose "SamAccountName: $SamAccountName"
    Write-Verbose "Mail Nickname: $MailNickname"

    try {
        $ADUser = Get-ADUser $SamAccountName -ErrorAction Stop
    }
    catch {
        Write-Warning "Unable to find AD user"
        return $false
    }

    if ($PSCmdlet.ShouldProcess("Attempting to set mailNickname field"))
    {
        if ($null -ne $ADUser)
        {
            Write-Verbose "AD User Found"
            Write-Verbose "Attempting to set mailNickname field"
    
            try {
                $ADUser |
                    Set-ADUser -Add @{mailNickname = $MailNickname} -ErrorAction Stop
    
                Write-Verbose "Successfully set mailNickname field"
                return $true
            }
            catch {
                Write-Verbose "Unable to add mailNickname."
                Write-Verbose "Attempting to replace field"
    
                try {
                    $ADUser |
                        Set-ADUser -Replace @{mailNickname = $MailNickname} -ErrorAction Stop
    
                    Write-Verbose "Successfully set mailNickname field"
                    return $true
                }
                catch {
                    Write-Warning "Unable to replace mailNickname field"
                    return $false
                }
            }
        }
        else {
            Write-Verbose "Unable to find AD user"
            return $false
        }
    }
}

Function Set-HSCPasswordRequired
{
	<#
	.SYNOPSIS
		This function sets the password required for a user
		
	.INPUTS
		This function can take a string(array) or ADUser object(array) and will
		set the password required attribute for those users.
		
	.PARAMETER UserNames
		This parameter takes a string array of users names as input. It will attempt to
		set the password required attribute on all of these users.
	
	.PARAMETER ADUsers
		Similar to UserNames, but this paramter takes an array of ADUsers (Microsoft.ActiveDirectory.Management.ADAccount)
		and attempts to set the password required field on them.
	
	.PARAMETER NoOutput
		This is a switch parameter that prevents displaying function output.
		
	.EXAMPLE
		PS C:\Windows\system32> "jbrusoe","krussell" | Set-HSCPasswordRequired
		Current user: jbrusoe
		Password Not Required: False
		*****************************
		Current user: krussell
		Password Not Required: False
		*****************************

	.EXAMPLE
		PS C:\Windows\system32>  $Jeff = Get-ADUser jbrusoe -Properties PasswordNotRequired
		PS C:\Windows\system32> $Kevin = Get-ADUser krussell -Properties PasswordNotRequired
		PS C:\Windows\system32> @($Jeff,$Kevin) | Set-HSCPasswordRequired
		Current user: jbrusoe
		Password Not Required: False
		*****************************
		Current user: krussell
		Password Not Required: False
		*****************************

	.NOTES
		Written by: Jeff Brusoe
		Last Updated by: Jeff Brusoe
		Last Updated: July 13, 2020
	#>

	[CmdletBinding(SupportsShouldProcess=$true,
		ConfirmImpact="Medium")]

	param (
		[Parameter(ValueFromPipeline=$true,
			ParameterSetName="ADUserArray",
			Mandatory=$true,
			Position=0)]
		[Microsoft.ActiveDirectory.Management.ADAccount[]]$ADUsers,
		
		[Parameter(ValueFromPipeline=$true,
			ParameterSetName="UserNameArray",
			Mandatory=$true,
			Position=0)]
		[string[]]$UserNames,
		
		[switch]$NoOutput
	)

	begin {
		Write-Verbose "Beginning to set password required"
	}

	process
	{
		Write-Verbose $("In process block - Parameter Set Name: " + $PSCmdlet.ParameterSetName)
		
		#Get array of ADUsers if a string array is passed in
		if ($PSCmdlet.ParameterSetName -eq "UserNameArray")
		{
			$ADusers = $null

			Write-Debug "Process Block - If Statement"

			foreach ($UserName in $UserNames)
			{
				try {
					$ADUsers += Get-ADUser $UserName -Properties PasswordNotRequired -ErrorAction Stop
				}
				catch {
					Write-Warning "Unable to find user name"
				}
			}
		}
		
		foreach ($ADUser in $ADUsers)
		{
			if (!$NoOutput) {
				Write-Output $("Current user: " + $ADUser.SamAccountName) | Out-Host
				Write-Output $("Password Not Required: " + $ADUser.PasswordNotRequired) | Out-Host
			}
		
			try
			{
				if ($PSCmdlet.ShouldProcess("Setting password required for " + $ADUser.SamAccountName)) {
					$ADUser | Set-ADUser -PasswordNotRequired $false -ErrorAction Stop
				}
			}
			catch {
					Write-Warning "There was an error setting the password not required field"
			}
			
			if (!$NoOutput) {
				Write-Output "*****************************" | Out-Host
			}
		}
	}
	
	end
	{
		if ($Error.Count -gt 0) {
			$Error | Format-List
		}
		else {
			Write-Verbose "Password required has been set."
		}
	}
}

function Test-HSCADModuleLoaded
{
	[CmdletBinding()]
	[OutputType([bool])]
	param()

	if ($null -eq (Get-Module ActiveDirectory))
	{
		Write-Verbose "AD module is not loaded"
		return $false
	}
	else {
		Write-Verbose "AD module is loaded"
		return $true
	}
}

function Test-HSCADOrgUnit
{
	<#
		.SYNOPSIS
			This function determines if an AD OU exists
			
		.INPUTS
			This function can take a string(array) or AD Object (array) of OUs.

		.PARAMETER HSCADOUDN
			The OU to determine if it exists

		.EXAMPLE

		.EXAMPLE

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: February 19, 2021

			Tested with PS 5.1:
			Tested with PS 7.1.2:
	#>

	[CmdletBinding()]
	[OutputType([bool])]
	param(
		[ValidateNotNullOrEmpty()]
		[Parameter(ValueFromPipeline = $true)]
		[string]$HSADOUDN = "OU=hsc,dc=hs,dc=wvu-ad,dc=wvu,dc=edu"
	)

	Write-Verbose "Attempting to find this org unit:"
	Write-Verbose $HSADOUDN

	try {
		Get-ADOrganizationalUnit -Identity $HSADOUDN -ErrorAction Stop | Out-Null
		Write-Verbose "Found the DN"

		return $true
	}
	catch {
		Write-Warning "The org unit doesn't exist."
		return $false
	}
}

######################################
######################################
######################################

function Add-HSCADUserProxyAddress2
{

	[CmdletBinding(SupportsShouldProcess=$true,
					 ConfirmImpact = "Medium")]
	[OutputType([bool])]

	param (
		[Parameter(ValueFromPipeline=$false,
			ParameterSetName="ADUser",
			Mandatory=$true,
			Position=0)]
		[ValidateNotNullOrEmpty()]
		[PSObject]$ADUser,

		[Parameter(ValueFromPipeline=$false,
			ParameterSetName="SamAccountName",
			Mandatory=$true,
			Position=0)]
		[ValidateNotNullOrEmpty()]
		[string]$SAMAccountName,
	
		[Parameter(ValueFromPipeline=$true,
			Mandatory=$true,
			Position=1)]
		[Alias("NewProxyAddresses")]
		[ValidateNotNullOrEmpty()]
		[string[]]$NewProxyAddress,

		[switch]$Primary
	)

	begin
	{
		Write-Verbose $("Parameter Set Name: " + $PSCmdlet.ParameterSetName)
		
		if ($PSCmdlet.ParameterSetName -eq "ADUser") {
			Write-Verbose $("ADUser SamAccountName: " + $ADUser.SamAccountName)
		}
		else {
			Write-Verbose "SamAccountName: $SamAccountName"
		}

		$ProxyAdded = $false
	}

	process
	{
		if (!(Test-HSCADModuleLoaded))
		{
			Write-Verbose "Attempting to load AD Module"
			
			try {
				Import-Module ActiveDirectory -ErrorAction Stop
				$ProxyAdded = $true
			}
			catch {
				Write-Warning "Unable to load Active Directory module"
				$ProxyAdded = $false
			}
		}
		else {
			Write-Verbose "AD module is already loaded"
			$ProxyAdded = $true
		}

		Write-Verbose $("In process block - Parameter Set Name: " + $PSCmdlet.ParameterSetName)
		
		if ($PSCmdlet.ParameterSetName -eq "SamAccountName" -AND $ProxyAdded)
		{
			try {
				Write-Output "Attempting to find user: $SamAccountName" | Out-Host

				$LDAPFilter = "(&(objectCategory=person)(objectClass=user)(sAMAccountName=$SamAccountName))"
				Write-Verbose "LDAP Filter: $LDAPFilter"

				$ADUser = Get-ADUser -LDAPFilter $LDAPFilter -properties proxyAddresses -ErrorAction Stop

				if ($null -eq $ADUser) {
					Write-Warning "Unable to find AD User"
					$ProxyAdded = $false
				}
				else {
					Write-Output "User found" | Out-Host
					Write-Verbose "Distinguished Name:"
					Write-Verbose $ADUser.DistinguishedName

					$ProxyAdded = $true
				}
			}
			catch {
				Write-Warning "Unable to find AD user based on SamAccountName"
			}
		}
		
		if ($ProxyAdded)
		{
			#Verify one unique user was found
			try {
				$ADUserCount = ($ADUser | Measure-Object).Count
				Write-Verbose "AD User Count: $ADUserCount"

				if ($ADUserCount -eq 1)
				{
					Write-Verbose "One unique AD User was found"
				}
				else {
					Write-Warning "AD user count doesn't equal 1"
					$ProxyAdded = $false
				}
			}
			catch {
				Write-Warning "Unable to determine AD User Count"
				$ProxyAdded = $false
			}
		}

		if ($ProxyAdded)
		{
			#At this point, one unique AD user object should be found.
			#Now get proxy addresses to verify that the proxy address isn't already present
			#or that it's not the primary SMTP address
			$ProxyAddresses = $ADUser.proxyAddresses

			foreach ($ProxyAddress in $ProxyAddresses)
			{
				Write-Output "Current Proxy Address from ADUser: $ProxyAddress" | Out-Host

				if (($ProxyAddress.indexOf($NewProxyAddress) -ge 0) -AND ($ProxyAddress -clike "*SMTP*"))
				{
					Write-Output "New Proxy address is the primary SMTP address."
					$ProxyAdded = $false
				}
				elseif ($ProxyAddress.indexOf($NewProxyAddress) -ge 0)
				{
					Write-Output "New proxy address is already a proxy address" | Out-Host
					$ProxyAdded = $false
				}
			}
		}

		if ($ProxyAdded)
		{
			#Now proxy address will be added to AD account
			$NewProxyAddress = $NewProxyAddress.Trim()

			if ($Primary)
			{
				$NewProxyAddress = "SMTP:" + $NewProxyAddress
			}
			else {
				$NewProxyAddress = "smtp:" + $NewProxyAddress
			}

			Write-Output "Adding: $NewProxyAddress"

			try {
				if ($PSCmdlet.ShouldProcess("Adding new proxy address"))
				{
					Write-Verbose "About to set proxy address"
					$ADUser | Set-ADUser -Add @{proxyAddresses=$NewProxyAddress} -ErrorAction Stop
				}
				
				Write-Output "Successfully added new proxy address" | Out-Host
			}
			catch {
				Write-Warning "Unable to add new proxy address"	
				$ProxyAdded = $false
			}
		}
	}

	end {
		return $ProxyAdded
	}
}