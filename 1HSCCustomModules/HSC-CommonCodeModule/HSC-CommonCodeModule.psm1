<#
	.SYNOPSIS
		This module contains some common functions that are used by many HSC PowerShell files.

	.DESCRIPTION
		This module contains the common functions that are used by many HSC PowerShell files. These functions are:

		1. Get-HSCDepartmentMapPath
		2. Get-HSCEncryptedDirectoryPath
		3. Get-HSCEncryptedFilePath
		4. Get-HSCGitHubRepoPath
        5. Get-HSCLastFile
		6. Get-HSCLogFileName
		7. Get-HSCNetworkLogFileName
		8. Get-HSCNetworkLogPath
		9. Get-HSCParameter
		10. Get-HSCPasswordFromSecureStringFile
		11. Get-HSCPowerShellVersion
		12. Get-HSCRandomPassword
		13. Get-HSCServerName
		14. Invoke-HSCExitCommand
		15. New-HSCSecureStringFile
		16. Remove-HSCOldLogFile
		17. Send-HSCEmail
		18. Set-HSCEnvironment
		19. Set-HSCWindowTitle
		20. Start-HSCCountdown
		21. Test-HSCLogFilePath
		22. Test-HSCPowerShell7
		23. Test-HSCVerbose
		24. Update-HSCPowerShellDocumentation
		25. Write-HSCColorOutput
		26. Write-HSCLogFileSummaryInformation

	.NOTES
		HSC-CommonCodeModule.psm1
		Last Modified by: Jeff Brusoe
		Last Modified: November 17, 2021

		Version: 2.0
#>

[CmdletBinding()]
param ()

$SyscriptServers = @(
	"sysscript2",
	"sysscript3",
	"sysscript4",
	"sysscript5",
	"DESKTOP-1MQ9DJO",
	"DESKTOP-DBGBDVF",
	"HSVDIWIN10JB"
	)

function Get-HSCDepartmentMapPath
{
	<#
		.SYNOPSIS
			Returns the path to the department mapping file used during
			the account creation process

		.DESCRIPTION
			This file returns the path to a department mapping file. It contains
			information such as the OU, home directory path, etc. for users
			based on the department that they are in.

		.PARAMETER DirectoryOnly
			Returns the directory that the department map file is in rather
			than the actual file.

		.OUTPUTS
			System.String

		.EXAMPLE
			Get-HSCDepartmentMapPath
			<RootPath>\HSC-PowerShell-Repository\2CommonFiles\MappingFiles\DepartmentMap.csv

		.EXAMPLE
			Get-HSCDepartmentMapPath -DirectoryOnly
			<RootPath>\GitHub\HSC-PowerShell-Repository\2CommonFiles\MappingFiles\

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: March 19, 2021

			PS Version 5.1 Tested:
			- June 26, 2020
			- February 16, 2021
			PS Version 7.0.2 Tested: June 26, 2020
			PS Version 7.1.2 Tested: February 16, 2021
			PS Version 7.1.3 Tested: March 19, 2021
	#>

	[CmdletBinding()]
	[OutputType([string])]
	param (
		[switch]$DirectoryOnly
	)

	try
	{
		$DepartmentMapPath = (Get-HSCGitHubRepoPath) +
								"2CommonFiles\MappingFiles\"
		Write-Verbose "Directory Path: $DepartmentMapPath"

		if (!$DirectoryOnly) {
			$DepartmentMapPath += "DepartmentMap.csv"
		}

		Write-Verbose "Department Map Path: $DepartmentMapPath"

		if (Test-Path -Path $DepartmentMapPath) {
			Write-Verbose "Department map path exists"
			return $DepartmentMapPath
		}
		else {
			Write-Warning "Department map path doesn't exist"
			return $null
		}
	}
	catch {
		Write-Warning "Unable to get department map path"
		return $null
	}
}

function Get-HSCEncryptedDirectoryPath
{
	<#
		.SYNOPSIS
			Returns the file path to the 2CommonFiles\EncryptedFiles directory in
			the HSC GitHub repository.

		.DESCRIPTION
			The encrypted directory folder holds the encrypted files needed to automate
			notifications to Office 365 or SQL Servers.

		.OUTPUTS
			System.String

		.EXAMPLE
			PS C:\Users\jbrus> Get-HSCEncryptedDirectoryPath
			C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\

		.EXAMPLE
			PS C:\Users\jbrus> Get-HSCEncryptedDirectoryPath -Verbose
			VERBOSE: Current Module Path: C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\HSC-CommonCodeModule\HSC-CommonCodeModule.psd1
			VERBOSE: Directory: C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\
			VERBOSE: Directory exists
			C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: March 23, 2021

			PS Version 5.1 Tested:
			- June 26, 2020
			- February 16, 2021
			PS Version 7.0.2 Tested: June 26, 2020
			PS Version 7.1.2 Tested: February 16, 2021
	#>

	[CmdletBinding()]
	[OutputType([string])]
	param ()

	try
	{
		$EncryptedDirectoryPath = (Get-HSCGitHubRepoPath) +
									"2CommonFiles\EncryptedFiles\"
		Write-Verbose "Encrypted Directory Path: $EncryptedDirectoryPath"

		if (Test-Path -Path $EncryptedDirectoryPath) {
			Write-Verbose "Directory exists"
			return $EncryptedDirectoryPath
		}
		else {
			Write-Verbose "Directory doesn't exist"
			return $null
		}
	}
	catch {
		Write-Warning "Unable to get encrypted directory path"
		return $null
	}
}

function Get-HSCEncryptedFilePath
{
	<#
		.SYNOPSIS
			Returns the path to the encrypted files used to establish O365 tenant connection

		.DESCRIPTION
			This function assumes that the \GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\
			directory exists on the computer. If it does, it will return the full path to it.

		.PARAMETER UseSysscriptDefault
			Forces the function to only process values contained in the SysscriptServers array

		.PARAMETER ServerName
			The name of the server to get the encrypted file path

		.PARAMETER UserName
			Name of the user who will be decrypting the file. This must be
			the same user who encrypted the file.

		.PARAMETER EncryptedDirectoryPath
			Path to where the encrypted files should be stored on the local machine

		.EXAMPLE
			PS C:\Users\jbrus> Get-HSCLoggedOnUser

			UserName Domain
			-------- ------
			jbrus    DESKTOP-1MQ9DJO

			PS C:\Users\jbrus> Get-HSCEncryptedDirectoryPath
			C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\
			PS C:\Users\jbrus> Get-HSCEncryptedFilePath
			C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\jbrus-DESKTOP-1MQ9DJO.txt

		.OUTPUTS
			System.String

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: February 17, 2021

			PS Version 5.1 Tested:
			- June 26, 2020
			- February 17, 2021
			PS Version 7.0.2 Tested: June 26, 2020
			PS Version 7.1.2 Tested: February 17, 2021
	#>

	[CmdletBinding()]
	[Alias("Get-EncryptedFilePath")]
	[OutputType([String])]
	param (
		[switch]$UseSysscriptDefault,

		[ValidateNotNullOrEmpty()]
		[string]$ServerName = (Get-HSCServerName),

		[ValidateNotNullOrEmpty()]
		[string]$UserName = ((Get-HSCLoggedOnUser).UserName),

		[ValidateNotNullOrEmpty()]
		[string]$EncryptedDirectoryPath = (Get-HSCEncryptedDirectoryPath)
	)

	try {
		Write-Verbose "Testing input parameters"
		Write-Verbose "Server Name: $ServerName"
		Write-Verbose "UserName: $UserName"
		Write-Verbose "Encrypted Directory Path: $EncryptedDirectoryPath"

		if ($UseSysscriptDefault -AND ($SyscriptServers -contains $ServerName)) {
			Write-Verbose "Getting encrypted file path on: $ServerName"
		}
		elseif ($UseSysscriptDefault -AND ($SyscriptServers -notcontains $ServerName)) {
			Write-Warning "Using -UserSysscriptDefault parameter, but server name is not sysscript"
			throw "Server name is not sysscript with -UseSysscriptDefault switch"
		}

		if ([string]::IsNullOrEmpty($EncryptedDirectoryPath)) {
			Write-Warning "Encrypted Directory Path is null"
			throw "Encrypted Directory Path is Null"
		}

	}
	catch {
		Write-Warning "Invalid Input Parameters"
		return $null
	}

	Write-Verbose "Beginning to generate path..."

	try
	{
		if ($UseSysscriptDefault)
		{
			#This part is here to maintain backwards compatability
			Write-Verbose "`n`nServer Name: $ServerName"

			$ServerNumber = $ServerName.substring($ServerName.Length - 1)
			Write-Verbose "ServerNumber: $ServerNumber"

			$EncryptedFilePath = $EncryptedDirectoryPath + "normal" + $ServerNumber + ".txt"
			Write-Verbose "Encrypted File Path: $EncryptedFilePath"
		}
		else {
			$EncryptedFilePath = $EncryptedDirectoryPath +
									$UserName +
									"-"	+ $ServerName +
									".txt"

			Write-Verbose "Encrypted File Path: $EncryptedFilePath"
		}
	}
	catch {
		Write-Warning "There was an error generating the encrypted file path."
		$EncryptedFilePath = $null
	}

	return $EncryptedFilePath
}

function Get-HSCGitHubLogPath
{
	[CmdletBinding()]
	[OutputType([String])]
	param()

	$LoggedOnUser = Get-HSCLoggedOnUser
	Write-Verbose $("Logged on User: " + $LoggedOnUser.UserName)

	$GitHubLogPath = "c:\users\" + $LoggedOnUser.UserName +
						"\Documents\GitHub\HSC-Logs\"

	$GitHubLogPath
}

function Get-HSCGitHubRepoPath
{
	<#
		.SYNOPSIS
			This function returns the root path of the HSC GitHub repository

		.DESCRIPTION
			The purpose of this function is to return the path to the root of the
			GitHub repository. This is done by looking for the .git directory
			associated with the repository name (HSC-PowerShell-Repository).

		.OUTPUTS
			System.String

		.PARAMETER TopLevelPath
			The path to search if the paths from the $FirstSearchLocations array
			aren't found

		.PARAMETER FirstSearchLocations
			This array provides the function with "hints" of where to start searching
			for the GitHub repo path. This is a way to help speed up the function.

		.PARAMETER HSCRepositoryName
			The name of the HSC (or really any repository) to be searched for.

		.EXAMPLE
			PS C:\users\jbrus\OneDrive\Documents\GitHub\HSC-PowerShell-Repository> Get-HSCGitHubRepoPath
			C:\users\jbrus\OneDrive\Documents\GitHub\HSC-PowerShell-Repository\

		.EXAMPLE
			PS C:\users\jbrus\OneDrive\Documents\GitHub\HSC-PowerShell-Repository> Get-HSCGitHubRepoPath -Verbose
			VERBOSE: Beginning search for HSC GitHub Repo Path:
			VERBOSE: GitHubDirectory: C:\users\jbrus\OneDrive\Documents\GitHub\HSC-PowerShell-Repository\.git
			C:\users\jbrus\OneDrive\Documents\GitHub\HSC-PowerShell-Repository\

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: March 16, 2021

			PS Version 5.1 Tested: March 16, 2021
			PS Version 7.1.3 Tested: March 16, 2021
	#>

	[CmdletBinding(DefaultParameterSetName = "SearchLocations")]
	[OutputType([String])]
	param (
		[Parameter(ParameterSetName = "SearchLocations",
					ValueFromPipeline = $true)]
		[ValidateNotNullOrEmpty()]
		[string[]]$FirstSearchLocations = @(
			"C:\users\Jeff\Documents\GitHub\HSC-PowerShell-Repository",
			"C:\users\jbrus\OneDrive\Documents\GitHub\HSC-PowerShell-Repository",
			"C:\users\microsoft\Documents\GitHub\HSC-PowerShell-Repository",
			"C:\Users\krussell\Documents\GitHub\HSC-PowerShell-Repository",
			"C:\Users\kevinadmin\Documents\Github\HSC-PowerShell-Repository"
		),

		[Parameter(ParameterSetName = "TopLevelPath")]
		[ValidateNotNullOrEmpty()]
		[string]$TopLevelPath = "c:\users\",

		[ValidateNotNullOrEmpty()]
		[string]$HSCRepositoryName = "HSC-PowerShell-Repository"
	)

	begin {
		Write-Verbose "Beginning search for HSC GitHub Repo Path"
		Write-Verbose "HSC GitHub Repo Name: $HSCRepositoryName"

		[string]$GitHubDirectory = $null
	}

	process
	{
		if ($PSCmdlet.ParameterSetName -eq "SearchLocations") {
			foreach ($FirstSearchLocation in $FirstSearchLocations) {
				if (Test-Path $FirstSearchLocation){
					$GitHubDirectory = (Get-ChildItem $FirstSearchLocation -Directory -Hidden -Recurse |
						Where-Object {$_.FullName -like "*.git*"}).FullName

					Write-Verbose "GitHubDirectory: $GitHubDirectory"
					break
				}
				else {
					Write-Verbose "First Search Location $FirstSearchLocation Not Found"
				}
			}
		}
		else {
			if (Test-Path $TopLevelPath)
			{
				Write-Verbose "Top Level Path Exists... Begining Repo Search..."

				$GitHubDirectory = (Get-ChildItem $TopLevelPath -Directory -Hidden -Recurse |
					Where-Object {($_.Name -eq ".git") -AND
						($_.FullName -like "*$HSCRepositoryName*")}).FullName
			}
			else {
				Write-Warning "Top Level Path Doesn't Exist"
			}
		}
	}

	end {
		try {
			return $((Split-Path $GitHubDirectory -Parent -ErrorAction Stop) + "\")
		}
		catch {
			Write-Verbose "Returning null value"
			return $null
		}
	}
}

function Get-HSCLastFile
{
	<#
		.SYNOPSIS
			Returns the last x number of files from a directory

		.DESCRIPTION
			This function searches a directory and returns the last
			$NumberOfFiles based on the last write time

		.OUTPUTS
			System.String[]

		.EXAMPLE
			dir -file | sort lastwritetime

    		Directory: C:\users\jbrus\OneDrive\Documents\GitHub\HSC-PowerShell-Repository


			Mode                 LastWriteTime         Length Name
			----                 -------------         ------ ----
			-a---l          2/3/2021  11:19 AM            227 .gitignore
			-a---l          2/3/2021  11:19 AM           3313 DisableAccountProcess.md
			-a---l          2/3/2021  11:19 AM            367 HSCExclusionList.md
			-a---l          2/3/2021  11:19 AM           1759 README.md
			-a---l          2/4/2021   1:58 PM           2408 WVUHSCPowerShellCodingStandards.md
			-a---l          2/5/2021   3:09 PM           1180 ADExtensionAttributes.md
			-a---l         2/17/2021   4:12 PM           4487 PowerShellDevelopmentGoals.md
			-a---l         3/10/2021   3:35 PM            792 PSSavedLinks.md
			-a---l         3/15/2021   4:16 PM          17887 HSCPowerShellSummaryFile.md
			-a---l         3/15/2021   4:16 PM           8681 ScheduledTaskSummary.md

			Get-HSCLastFile -DirectoryPath .
			C:\users\jbrus\OneDrive\Documents\GitHub\HSC-PowerShell-Repository\ScheduledTaskSummary.md

		.PARAMETER DirectoryPath
			The path to the directory to be searched

		.PARAMETER NumberOfFiles
			Specifies the number of files to return

		.NOTES
			Written by: Jeff Brusoe
			Last Update: March 29, 2021
	#>

	[CmdletBinding()]
	[OutputType([string[]])]
	param (
		[Parameter(Mandatory = $true,
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true)]
		[string]$DirectoryPath,

		[ValidateRange(1,5)]
		[int]$NumberOfFiles = 1
	)

	begin {
		Write-Verbose "Directory Path: $DirectoryPath"
		Write-Verbose "Number of Files: $NumberOfFiles"
	}

	process
	{
		if (Test-Path $DirectoryPath)
		{
			Write-Verbose "$DirectoryPath exists"

			try {
				$GetChildItemParams = @{
					Path = $DirectoryPath
					File = $true
					ErrorAction = "Stop"
				}

				$LastFileNames = Get-ChildItem @GetChildItemParams |
					Sort-Object -Property LastWriteTime -Descending |
					Select-Object FullName -first $NumberOfFiles |
						ForEach-Object {$_.FullName}
			}
			catch {
				Write-Warning "Unable to get list of files in"
				$LastFileNames = $null
			}
		}
		else {
			Write-Verbose "$DirectoryPath doesn't exist"
			$LastFileNames = $null
		}
	}

	end {
		return $LastFileNames
	}
}

function Get-HSCLogFileName
{
	<#
	.SYNOPSIS
		This function generates the names of the various log files.

	.DESCRIPTION
		The purpose of this function is to generate the names of log
		files used by the calling file/function. The date format used is
		Year-Month-Day(2 digit)-Hour(24 hour time)-Minute(2 digit).

	.PARAMETER ProgramName
		ProgramName is the user provided name of the program. It is used to help
		build the session transcript log name. If it is null, then its use is omitted.

	.PARAMETER LogFileType
		Specifies the type of log file to generate. Valid types are: SessionTranscript,
		Error, Output, and Other.

	.PARAMETER FileExtension
		Specifies the file extension to be used for the log file.
		The default value is .txt

	.NOTES
		Written by: Jeff Brusoe
		Last Updated by: Jeff Brusoe
		Last Updated: March 29, 2021
	#>

	[Cmdletbinding()]
	[OutputType([string])]
	Param(
		[string]$ProgramName=$null,

		[ValidateSet("SessionTranscript","Error","Output","Other")]
		[string]$LogFileType="SessionTranscript",

		[ValidateSet("txt","csv","log")]
		[string]$FileExtension="txt"
	)

	Write-Output "Generating $LogFileType log file name..." | Out-Null

	[string]$LogFile=$null

	if ([string]::IsNullOrEmpty($ProgramName)) {
		$LogFile = $LogFilePath + "\" + (Get-Date -format yyyy-MM-dd-HH-mm) + "-$LogFileType.$FileExtension"
	}
	else {
		$LogFile = $LogFilePath + "\" + (Get-Date -format yyyy-MM-dd-HH-mm) + "-$ProgramName-$LogFileType.$FileExtension"
	}

	Write-Verbose "Log File: $LogFile"

	return $LogFile
}

function Get-HSCNetworkLogFileName
{
	<#
		.SYNOPSIS
			This function generates the names of the various log files and their
			corresponding path on the network file share.

		.DESCRIPTION
			The purpose of this function is to generate the names of log
			files used by the calling file/function, and the path that is
			generated is on the network file share instead of the GitHub repo.
			The date format used is Year-Month-Day(2 digit)-Hour(24 hour time)-Minute(2 digit).
		
		.OUTPUTS
			PSObject

		.PARAMETER ProgramName
			ProgramName is the user provided name of the program and is used to specifiy the log name.

		.PARAMETER LogFileType
			Specifies the type of log file to generate. Valid types are: SessionTranscript,
			Error, Output, and Other.

		.PARAMETER FileExtension
			Specifies the file extension to be used for the log file.
			The default value is .txt.

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: November 17, 2021
	#>

	[Cmdletbinding()]
	[OutputType([PSObject[]])]
	Param(
		[Parameter(Mandatory=$true,
					ValueFromPipeline=$true,
					ValueFromPipelineByPropertyName=$true,
					Position=0)]
		[string[]]$ProgramName,

		[ValidateSet("SessionTranscript","Error","Output","Other")]
		[string]$LogFileType="SessionTranscript",

		[ValidateSet("txt","csv","log")]
		[string]$FileExtension="txt"
	)

	begin {
		Write-Verbose "Log File Type: $LogFileType"
		Write-Verbose "File Extension: $FileExtension"
	}
	
	process
	{
		foreach ($Name in $ProgramName) {
			$LogFilePath = (Get-HSCNetworkLogPath) + "\" + $ProgramName +
						"\Logs\" + (Get-Date -format yyyy-MM-dd-HH-mm) +
						"-$ProgramName-$LogFileType.$FileExtension"

			Write-Verbose "Log File Path: $LogFilePath"

			[PSCustomObject]@{
				ProgramName = $Name
				LogFilePath = $LogFilePath
			}
		}
	}
}

function Get-HSCNetworkLogPath
{
	<#
		.SYNOPSIS
			This function returns the path to the network log file.

		.OUTPUTS
			System.String

		.EXAMPLE
			Get-HSCNetworkLogPath
			\\hs.wvu-ad.wvu.edu\public\ITS\Network and Voice Services\microsoft\HSC-Logs\

		.EXAMPLE
			Get-HSCNetworkLogPath -Verbose
			VERBOSE: Network Log Path: \\hs.wvu-ad.wvu.edu\public\ITS\Network ...
			\\hs.wvu-ad.wvu.edu\public\ITS\Network and Voice Services\microsoft\HSC-Logs\

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: November 17, 2021
	#>

	[CmdletBinding()]
	param(
		[string]$NetworkLogPathRoot = "\\hs.wvu-ad.wvu.edu\public\ITS\Network and " +
										"Voice Services\microsoft\HSC-Logs\"
	)

	Write-Verbose "Network Log Path Root: $NetworkLogPathRoot"

	$NetworkLogPathRoot
}

function Get-HSCParameter
{
	<#
		.SYNOPSIS
			The purpose of this function is to display any nondefault parameters that were passed to the originating function.

		.PARAMETER ParameterList
			This parameter comes from the built-in $PSBoundParameters variable.
			See: https://blogs.msdn.microsoft.com/timid/2014/08/12/psboundparameters-and-commonparameters-whatif-debug-etc/

		.OUTPUTS
			Displays to the screen any parameters that are not set to default values. This must be called from
			inside a function or ps1 file.

		.EXAMPLE
			PS C:\Users\jbrus> Get-HSCParameter -ParameterList $PSBoundParameters
			All input parameters are set to default values.

		.NOTES
			Written by: Jeff Brusoe
			Last  Updated by: Jeff Brusoe
			Last Updated: June 3, 2020

			PS Version 5.1 Tested: June 26, 2020
			PS Version 7.0.2 Tested: June 26, 2020
	#>

	[CmdletBinding()]
	[Alias("Get-Parameter")]
	param (
		[Parameter(Mandatory=$true)]
		[hashtable]$ParameterList
	)

	process
	{
		try
		{
			if (($ParameterList.keys | Measure-Object).Count -eq 0)
			{
				Write-Output "All input parameters are set to default values." | Out-Host
			}
			else
			{
				Write-Output "The following parameters have nondefault values:" | Out-Host

				foreach ($key in $ParameterList.keys)
				{
					$param = Get-Variable -Name key -ErrorAction SilentlyContinue

					if($null -ne $param)
					{
						Write-Output "$($param.name): $($param.value)" | Out-Host
					}
				}
			}
		}
		catch
		{
			Write-Warning "There was an error generating the parameter list." | Out-Host
		}

		Write-Output "`n" | Out-Host
	}
}

function Get-HSCPasswordFromSecureStringFile
{
	<#
		.SYNOPSIS
			The purpose of this function is to decrypt a secure string file to
			handle user authentication to Office 365 or other HSC protected environments.

		.DESCRIPTION
			This function decrypts a secure string file in order to use that
			for authentication. In order to decrypt it, the file must have
			been encrypted on the same machine with the same logged in user
			used as the one being used for decryption. There are also options
			to change the secure string file as well as prompt the user for credentials.

		.PARAMETER PWFile
			The path to the password file that is to be decrypted

		.OUTPUTS
			System.String

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: June 23, 2020

			PS Version 5.1 Tested: June 30, 2020
			PS Version 7.0.2 Tested: June 30, 2020
	#>

	[CmdletBinding()]
	[Alias("Get-PasswordFromSecureStringFile")]
	param (
		[ValidateNotNullOrEmpty()]
		[string]$PWFile = (Get-HSCEncryptedFilePath)
	)

	[string]$Password=$null
	$PWFile = $EncryptedFileDirectory + $PWFile

	Write-Verbose "Password File Path: $PWFile"

	if (Test-Path $PWFile)
	{
		Write-Verbose "Decrypting Password..."

		try
		{
			$securestring = convertto-securestring -string (get-content $PWFile)
			$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securestring)
			$Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

			Write-Verbose "Password decrypted successfully."
		}
		catch {
			Write-Warning "There was an error decrypting the password. Exiting file."
			$Password = $null
		}
	}

	return $Password
}

function Get-HSCPowerShellVersion
{
	<#
		.SYNOPSIS
			Returns the version of PowerShell

		.DESCRIPTION
			The purpose of this function is to return the version of PowerShell
			that the current host is running. This is needed since modules such
			as the Active Directory and Office 365 one only semi-work on PowerShell 7.

		.EXAMPLE
			PS C:\Users\jbrus> Get-HSCPowerShellVersion
			5.1

		.EXAMPLE
			PS C:\Users\jbrus> Get-HSCPowerShellVersion -Verbose
			VERBOSE: PowerShell Version: 5.1
			5.1

		.EXAMPLE
			PS C:\Users\jbrus> Get-HSCPowerShellVersion -Verbose
			VERBOSE: PowerShell Version: 7.0
			7

		.OUTPUTS
			System.String

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: March 29, 2021

			PS Version 5.1 Tested:
			- June 26, 2020
			- February 17, 2021
			PS Version 7.0.2 Tested: June 26, 2020
			PS Version 7.1.2 Tested: February 17, 2021
			PS Version 7.1.3 Tested: March 29, 2021
	#>

	[CmdletBinding()]
	[OutputType([string])]
	param ()

	try
	{
		$PowerShellVersion = [string]$PSVersionTable.PSVersion.Major + "." +
			[string]$PSVersionTable.PSVersion.Minor

		Write-Verbose "PowerShell Version: $PowerShellVersion"
		return $PowerShellVersion
	}
	catch {
		Write-Warning "Unable to get PowerShell version"
		return $null
	}
}

function Get-HSCRandomPassword
{
	<#
		.SYNOPSIS
			The purpose of this function is to generate a random password.

		.DESCRIPTION
			The password generated meets WVU password complexity requirements:
			1. Must be between 8 and 20 characters in length.
			2. Must contain characters from at least three
			   of the following four categories:
				a. Uppercase letters: A-Z
				b. Lowercase letters: a-z
				c. Numbers: 0-9
			d. Only these special characters: ! ^ ? : . ~ - _

		.OUTPUTS
			System.String

		.PARAMETER PasswordLength
			The length of the randomly generated password

		.EXAMPLE
			PS C:\Users\jbrus> Get-HSCRandomPassword
			Fk]D%fE?pul\O4b1Y_)v

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: April 5, 2021
	#>

	[CmdletBinding()]
	[OutputType([string])]
	param (
		[ValidateRange(7,20)]
		[int]$PasswordLength = 20
	)

	Write-Verbose "Generating random password..."
	Write-Verbose "Password Length: $PasswordLength"

	try {
		$PasswordLength--

		#https://blogs.technet.microsoft.com/undocumentedfeatures/2016/09/20/powershell-random-password-generator/
		[string]$Password = ([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 |
			Sort-Object {Get-Random})[0..$PasswordLength] -join ''

		Write-Verbose "Password: $Password"
	}
	catch {
		Write-Warning "Error generating random password"
		[string]$Password = $null
	}
	finally {
		Write-Verbose "Done generating random password"
	}

	return $Password
}

function Get-HSCServerName
{
	<#
		.SYNOPSIS
			This function returns the name of the server currently running the ps1 file.

		.PARAMETER MandatoryServerNames
			This paramter tells the function to only return the server name
			if the name is included in the $AllowedServerNames array.
			Currently, this array contains the four sysscript servers
			(sysscript2, sysscript3, sysscript4, sysscript5) as well
			as my personal workstation and Surface for testing purposes.

		.OUTPUTS
			System.String

		.EXAMPLE
			Get-HSCServerName
			<return server name>

		.EXAMPLE
			Get-HSCServeName -MandatoryServerNames
			- sysscript2 (if on sysscript2)
			- $null if not on sysscript2, 3, or 4

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: April 5, 2021
	#>

	[CmdletBinding()]
	[Alias("Get-ServerName")]
	[OutputType([string])]
	param(
		[switch]$MandatoryServerNames
	)

	$AllowedServerNames = @(
					"sysscript2",
					"sysscript3",
					"sysscript4",
					"sysscript5",
					"HSVDIWIN10JB",
					"DESKTOP-1MQ9DJO"
				)

	try
	{
		[string]$ServerName = (Get-ChildItem env:computername).Value
		Write-Verbose "Server Name: $ServerName"

		if ($MandatoryServerNames -AND $AllowedServerNames -contains $ServerName) {
			return $ServerName
		}
		elseif ($MandatoryServerNames -AND $AllowedServerNames -notcontains $ServerName) {
			Write-Warning "Server name is not in server name array"
			return $null
		}
		elseif ([string]::IsNullOrEmpty($ServerName)) {
			Write-Warning "Error retrieving server name"
			return $null
		}
		else {
			return $ServerName
		}
	}
	catch {
		Write-Warning "Error retrieving server name" | Out-Host
		return $null
	}
}

function Invoke-HSCExitCommand
{
	<#
		.SYNOPSIS
			This function handles cleanup tasks to exit HSC PowerShell files.

		.DESCRIPTION
			This function is called to handle error conditions where a PS file
			should exit or to exit a file that has completed its work.
			It does the following:
			* Displays the count of the $Error variable
			* Stops the transcript
			* Exits the file
			* To be developed: Display more information about how the file exited (normal or with )

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: March 12, 2021
	#>

	[CmdletBinding(SupportsShouldProcess = $true)]
	[Alias("Exit-Commands")]
	[Alias("Exit-Command")]
	param (
		[int]$ErrorCount = -1
	)

	if ($ErrorCount -ge 0) {
		Write-Output "Final Error Count: $ErrorCount"
	}
    else {
        Write-Verbose "Error Count Not Provided"
    }

	try {
		Write-Verbose "Stopping Transcript"
		Stop-Transcript -ErrorAction Stop
	}
	catch {
		Write-Verbose "Unable to stop transcript"
	}
	finally {
		Write-Verbose "Exiting file"

        if ($PSCmdlet.ShouldProcess("Exiting Program")) {
            exit
        }

	}
}

function New-HSCSecureStringFile
{
	<#
		.SYNOPSIS
			This function generates a new secure string file.

		.DESCRIPTION
			This function generates a new secure string file. By default, it is stores in the
			1HSCCustomModules\EncryptedFiles directory with a name of <Username>-<ServerName>.txt

		.OUTPUTS
			There are two outputs generated from this function:
			1.  A boolean value indicating whether the function was successful in creating
				the secure string file.
			2. 	The actual secure string file located in 1HSCCustomModules/EncryptedFiles

		.EXAMPLE
			PS C:\Users\jbrus> New-HSCSecureStringFile
			Creating new secure string file
			Username: jbrus
			Computer Name: DESKTOP-1MQ9DJO
			Enter Current Password: ***********
			True

		.EXAMPLE
			PS C:\Users\jbrus> New-HSCSecureStringFile -WhatIf
			Creating new secure string file
			Username: jbrus
			Computer Name: DESKTOP-1MQ9DJO
			Output File: C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\\jbrus-DESKTOP-1MQ9DJO.txt

			What if: Performing the operation "Overwriting file" on target "C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\\jbrus-DESKTOP-1MQ9DJO.txt".
			Enter Current Password: ************
			What if: Performing the operation "Output to File" on target "C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\\jbrus-DESKTOP-1MQ9DJO.txt".
			True

		.EXAMPLE
			PS C:\Users\jbrus> New-HSCSecureStringFile -Confirm
			Creating new secure string file
			Username: jbrus
			Computer Name: DESKTOP-1MQ9DJO
			Output File: C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\\jbrus-DESKTOP-1MQ9DJO.txt


			Confirm
			Are you sure you want to perform this action?
			Performing the operation "Overwriting file" on target
			"C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\\jbrus-DESKTOP-1MQ9DJO.txt".
			[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y
			Enter Current Password: ************

			Confirm
			Are you sure you want to perform this action?
			Performing the operation "Output to File" on target
			"C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\\jbrus-DESKTOP-1MQ9DJO.txt".
			[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y
			True

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: June 30, 2020

			PS Version 5.1 Tested: June 29, 2020
			PS Version 7.0.2 Tested: June 29, 2020
	#>

	[CmdletBinding(SupportsShouldProcess, ConfirmImpact="Medium")]
	[OutputType([bool])]
	param(
        [ValidateNotNullOrEmpty()]
		[string]$OutputDirectoryPath = (Get-HSCEncryptedDirectoryPath),

        [ValidateNotNullOrEmpty()]
		[string]$UserName = $((Get-HSCLoggedOnUser).UserName),

        [ValidateNotNullOrEmpty()]
		[Alias("ComputerName")]
		[string]$ServerName = $(Get-HSCServerName)
	)

	begin
	{
		Write-Verbose "Creating new secure string file"
		Write-Verbose "Username: $UserName"
		Write-Verbose "Computer Name: $ServerName"
	}

	process
	{
		if (Test-Path $OutputDirectoryPath)
		{
			$OutputFile = "$OutputDirectoryPath\$UserName-$ServerName.txt"
			Write-Verbose "Output File: $OutputFile`n"

			try
			{
				if ((Test-Path -Path $OutputFile) -AND
				($PSCmdlet.ShouldProcess($OutputFile,"Overwriting file"))) {
					Write-Verbose "Encrypted file already exists"
					Read-Host "Enter Current Password" -AsSecureString |
						ConvertFrom-SecureString -ErrorAction Stop |
						Out-File $OutputFile -ErrorAction Stop
				}
				else {
					Write-Verbose "Output file doesn't exist and will be created"
					$CurrentPassword = Read-Host "Enter Current Password" -AsSecureString

					Write-Verbose "Current Password: $CurrentPassword"
					$CurrentPassword |
						ConvertFrom-SecureString |
						Out-File $OutputFile
				}

				Write-Verbose "Successfully created secure string file."
				return $true
			}
			catch {
				Write-Warning "There was an error generating the secure string file."
                return $false
			}
		}
		else {
			Write-Warning "File output path doesn't exist"
			return $false
		}
	}
}

Function Remove-HSCOldLogFile
{
	<#
        .SYNOPSIS
            Removes old log files to avoid cluttering up directory

        .DESCRIPTION
            This function searches for log files older than three days
            (or a value specified by the user) and removes (or copies)
            the files from a specified directory.

            The function returns a -1 if any errors occur when trying to
            clean up the old log files. If no errors occur, then it wil return
            the total number of log files removed.

        .OUTPUTS
            System.Int32

        .PARAMETER Path
            The path to the directory that will be looked in to remove any old log files

        .PARAMETER Days
            The number of days from the current date to keep any log files

        .PARAMETER CSV
            Switch parameter to indicate searching directory for .csv files

        .PARAMETER TXT
            Switch parameter to indicate searching directory for .txt files

        .PARAMETER LOG
            Switch parameter to indicate searching directory for .log files

        .PARAMETER LBB
            Switch parameter to indicate searching directory for .lbb files
            (From backing up the SAN encryption keys)

        .NOTES
            Written by: Kevin Russell
            Last updated by: Jeff Brusoe
            Last Updated: April 14, 2021

            PS 5.1 Tested - June 30, 2020
            PS 7.0.2 Tested - June 30, 2020
	#>

	[Cmdletbinding(SupportsShouldProcess=$true)]
	[Alias("Remove-OldLogFiles")]
	[Alias("Remove-OldLogFile")]
	[OutputType([int])]

	Param(
        [ValidateNotNullOrEmpty()]
		[string]$Path = $($MyInvocation.PSScriptRoot + "\Logs\"),

        [ValidateNotNullOrEmpty()]
		[int]$Days = 3,

		[switch]$CSV,
		[switch]$TXT,
		[switch]$LOG,
		[switch]$LBB, #Generated from SAN encryption key backup
		[switch]$Delete
	)

	Write-Verbose "Days to keep log files: $Days"
    $DeletedFiles = 0

	if ($Days -gt 0)  {
		$Days = -1*$Days
	}

    $RemoveBeforeDate = (Get-Date).AddDays($Days)

	if ($Delete) {
		Write-Verbose "Files will be deleted."
	}
	else {
		Write-Verbose "Files will not be deleted."
	}

	Write-Verbose "Removing old log files"

    if (Test-Path $Path) {
        Write-Verbose "Path exists"
    }
    else {
        Write-Warning "Path does not exist"
        return -1
    }

	$RemoveString = @() #Array of file extensions to remove

	if ($CSV) {
		Write-Verbose "Adding csv files to remove string."
		$RemoveString += "*.csv"
	}

	if ($TXT) {
		Write-Verbose "Adding txt files to remove string" | Out-Host
		$RemoveString += "*.txt"
	}

	if ($LOG) {
		$RemoveString += "*.log"
	}

    if ($LBB) {
		$RemoveString += "*.lbb"
	}

	if (($RemoveString | Measure-Object).Count -eq 0) {
		Write-Warning "No file extensions specified to be removed"
		return -1
	}

	Write-Verbose "RemoveString:"
    for ($i = 0; $i -lt $RemoveString.Length; $i++) {
        Write-Verbose $RemoveString[$i]
    }

    Write-Verbose "Path: $Path"
    $files = Get-ChildItem -Path $Path\* -Include $RemoveString

    Write-Verbose $("File Count: " + ($files | Measure-Object).Count)

    foreach ($file in $files)
    {
        if($file.LastWriteTime -lt $RemoveBeforeDate)
        {
            if (!$Delete) {
                Write-Output $("Potential Delete: " + $file.FullName)
            }
            else {
                Write-Verbose $("Removing: " + $file.FullName)

                if ($PSCmdlet.ShouldProcess("Removing files")) {
                    Remove-Item -Path $file.fullname -Force
                }
            }
            $DeletedFiles++
        }
    }

    return $DeletedFiles
}

Function Send-HSCEmail
{
	<#
		.SYNOPSIS
			This function is used to send email from HSC PowerShell files

		.DESCRIPTION
			The purpose of this function is to serve as a wrapper for the
			Send-MailMessage cmdlet. It was originally written to make it easier
			to decrypt the password to send email. However, this isn't necessary anymore,
			so this function is here for legacy purposes now.

		.OUTPUTS
			System.bool

		.PARAMETER To
			Specifies the email recipient

		.PARAMETER From
			Specifies the email sender

		.PARAMETER SMTPServer
			The IP address of the SMTP relay server. The default is hssmtp.hsc.wvu.edu

		.PARAMETER Subject
			Specifies the email subject

		.PARAMETER MessageBody
			A string which is the email message body

		.PARAMETER Attachments
			The path (or array of paths) to the attachments which will be sent

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: April 21, 2021
	#>

	[CmdletBinding(SupportsShouldProcess=$true,
					ConfirmImpact="Low")]
	[Alias("Send-Email")]
	[OutputType([bool])]
	Param (
		[Parameter(Mandatory=$true)]
		[string[]]$To,

		[ValidateNotNullOrEmpty()]
		[string]$From = "microsoft@hsc.wvu.edu",

		[Parameter(Mandatory=$true)]
		[string]$Subject,

		[Parameter(Mandatory=$true)]
		[string]$MessageBody,

		[string[]]$Attachments,

		[ValidateNotNullOrEmpty()]
		[string]$SMTPServer = "Hssmtp.hsc.wvu.edu"
	)

	Write-Verbose "Preparing to send email..."
	Write-Verbose "Subject: $Subject"
	Write-Verbose "SMTPServer: $SMTPServer"

	$SendMailMessageParams = @{
		To = $To
		From = $From
		SMTPServer = $SMTPServer
		Subject = $Subject
		UseSSL = $true
		Port = 587
		Body = $MessageBody
		ErrorAction = "Stop"
	}

	foreach ($Recipient in $To) {
		Write-Verbose "Recipient: $Recipient"

		if ($Recipient.indexOf("@") -eq -1) {
			Write-Warning "Invalid to field"
			return $false
		}
		else {
			Write-Verbose "Valid Recipient"
			Write-Verbose "******************"
		}
	}

	try
	{
		if ($null -eq $Attachments) {
			if ($PSCmdlet.ShouldProcess("Sending email...")) {
				Send-MailMessage @SendMailMessageParams
			}
		}
		else {
			if ($PSCmdlet.ShouldPRocess("Sending email with attachment...")) {
				$SendMailMessageParams["Attachments"] = $Attachments
				Send-MailMessage @SendMailMessageParams
			}
		}

		Write-Verbose "Successfully sent email"
		return $true
	}
	catch {
		Write-Warning "Unable to send email message"
		return $false
	}
}

function Set-HSCEnvironment
{
	<#
        .SYNOPSIS
            This function configures the HSC PowerShell environment.

        .DESCRIPTION
            This function configures the environment for files that use this module. It performs the follwing tasks.
            0. Stop transcript if it is currently running
            1. Sets strictmode to the latest version
            2. Clear $Error variable
            3. Clear PS window
            4. Sets the PowerShell window title
            5. Set location to root of ps1 directory
            6. Generates transcript log file path
            7. Start transcript log file
            8. Removes old .txt log files
            9. Set $ErrorActionPreference
            10. Display parameter information

        .PARAMETER NoSessionTranscript
            By default, a session transcript is created. This parameter prevents creating that file.

        .PARAMETER LogFilePath
            THe path to write any logs files and the session transcript. It defaults to $PSScriptRoot\Logs

        .PARAMETER StopOnError
            Stops program execution if an error is detected

        .PARAMETER DaysToKeepLogFiles
            Determines how long old log files should be kept for

        .NOTES
            Written by: Jeff Brusoe
            Last Updated by: Jeff Brusoe
            Last Updated: May 10, 2021
	#>

	[CmdletBinding(SupportsShouldProcess=$true,
					ConfirmImpact = "Low")]
	[Alias("Set-Environment")]
	[OutputType([String])]
	param (
		[bool]$NoSessionTranscript=$false,
		[string]$LogFilePath = $($MyInvocation.PSScriptRoot + "\Logs\"),
		[bool]$StopOnError=$false,
		[int]$DaysToKeepLogFiles = 5
	)

	if ([string]::IsNullOrEmpty($MyInvocation.PSCommandPath)) {
		Write-Warning "Function is being called outside a ps1 file"
		return $null
	}

	#0. Stop transcript in case it is still running
	try {
		Write-Verbose "Stopping transcript"
		Stop-Transcript -ErrorAction Stop
	}
	catch {
		Write-Verbose "No transcript is currently running"
	}

	#1. Set strict mode
	Set-StrictMode -Version Latest #Configures for current scope (Probably not needed)
	Set-PSDebug -Strict #Configures struct mode for global scope

	#2. Clear Error Variable
	$global:Error.Clear()

	#3. Clear PS Window
	Clear-Host

	#4. Set Window Title
	if ($PSCmdlet.ShouldProcess("Setting Window Title")) {
		Set-HSCWindowTitle -WindowTitle $MyInvocation.PSCommandPath
	}

	#5. Set location to $PSScriptRoot
	Set-Location $MyInvocation.PSScriptRoot

	#6. Generate transcript log file path
	#Parse file location to determine program name
	try {
		Write-Output $("PSCommandPath: " + $MyInvocation.PSCommandPath) | Out-Host
		$ProgramName = $MyInvocation.PSCommandPath
		$ProgramName = $ProgramName.substring(0,$ProgramName.indexOf("."))
		$ProgramName = $ProgramName.substring($ProgramName.lastindexOf("\")+1)
		Write-Output "Program Name: $ProgramName" | Out-Host

		##$TranscriptLogFile = Get-HSCLogFileName -ProgramName $ProgramName
		$TranscriptLogFile = (Get-HSCNetworkLogFileName -ProgramName $ProgramName).LogFilePath
		Write-Output "Transcript File Path: $TranscriptLogFile" | Out-Host

		#New-Item -Path $TranscriptLogFile -Type File -Force

		#Start-Sleep -Seconds 3
	}
	catch {
		Write-Warning "Unable to generate transcript log file path"
		$TranscriptLogFile = $null
	}

	#7 & 8. Start transcript and remove old log files
	#if (Test-HSCLogFilePath -LogFilePath $LogFilePath)
	if ($true)
	{
		if (!$NoSessionTranscript) {
			Write-Verbose "Starting transcript log file"

			if ($PSCmdlet.ShouldProcess("Starting Transcript")) {
				
				Start-Transcript $TranscriptLogFile | Out-Host
			}
		}
		else {
			Write-Verbose "Transcript log file will not be created..."
		}

		Write-Output "Removing old log files" | Out-Host
		Remove-HSCOldLogFile -CSV -TXT -Path $LogFilePath -Days $DaysToKeepLogFiles -Verbose -Delete
	}
	else {
		Write-Warning "Log file path doesn't exist..."
	}

	#9. Set $ErrorActionPreference
	if ($StopOnError) {
		Write-Verbose 'Setting $ErrorActionPreference to Stop'
		$global:ErrorActionPreference = "Stop"
	}
	else {
		Write-Verbose 'Setting $ErrorActionPreference to Continue'
		$global:ErrorActionPreference = "Continue"
	}

	#10. Display Parameter Information
	Write-Verbose "Summarizing Parameter Information"
	Get-HSCParameter -ParameterList $PSBoundParameters

	return $TranscriptLogFile
}

function Set-HSCWindowTitle
{
	<#
        .SYNOPSIS
            Sets the PowerShell window title

        .DESCRIPTION
            The purpose of this function is to change the title in the PowerShell window.
            It can do this by either passing in a value or by parsing up the file path to
            the ps1 file that called this function.

        .EXAMPLE
            Set-HSCWindowTitle
            <Changes window title to name of ps1 file that called this function>

        .EXAMPLE
            Set-HSCWindowTitle -WindowTitle "Jeff's PowerShell Window"
            <Window title set to "Jeff's PowerShell Window"

        .PARAMETER WindowTitle
            This is a string parameter that specifies the PowerShell window title. If it
            isn't provided, it will be determined by the $PSCommandPath variable.

        .NOTES
            Written by: Jeff Brusoe
            Last Updated by: Jeff Brusoe
            Last Updated: June 2, 2020

            PS Version 5.1 Tested: June 29, 2020
            PS Version 7.0.2 Tested: June 29, 2020
	#>

	[CmdletBinding(SupportsShouldProcess = $true,
					ConfirmImpact="Low")]
	[Alias("Set-WindowTitle")]
	param (
		[string]$WindowTitle=$MyInvocation.PSCommandPath
	)

	if ($PSCmdlet.ShouldProcess("Setting Window Title"))
	{
		if (![string]::IsNullOrEmpty($WindowTitle)) {
			$WindowTitle = $WindowTitle.substring($WindowTitle.lastindexOf("\")+1)
		}
		else {
			$WindowTitle = "HSC PowerShell"
		}

		try {
			Write-Verbose "Setting Window Title: $WindowTitle"
			$Host.UI.RawUI.WindowTitle = $WindowTitle
		}
		catch {
			Write-Warning "Unable to set window title"
		}
	}
}

Function Start-HSCCountdown
{
	<#
		.SYNOPSIS
			This function displays a progress bar and message stating the reason for the delay.
			It is basically a more user friendly version of Start-Sleep which may look like the window
			has locked up if it is used.

		.EXAMPLE
			Start-HSCCountdown -Message "Test Message" -Seconds 60
			<Output is a progress bar>

		.PARAMETER Seconds
			This is the integer value that tells how long the pause should occur for.

		.PARAMETER Messsage
			The actdual message to display in the countdown box

		.OUTPUTS
			System.bool

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Originally Written: October 21, 2016
			Last Updated; May 12, 2021

			PS Version 5.1 Tested: June 29, 2020
			PS Version 7.0.2 Tested: June 29, 2020
			PS Version 7.1.3 Tested: May 12, 2021
	#>

	[CmdletBinding(SupportsShouldProcess = $true,
					ConfirmImpact = "Low")]

	[Diagnostics.CodeAnalysis.SuppressMessageAttribute `
	("PSUseShouldProcessForStateChangingFunctions","", `
	Justification = "Start-Sleep Doesn't Change System State.")]

	[Alias("Start-Countdown")]
	[OutputType([bool])]
	Param(
		[Parameter(Position = 0)]
		[ValidateNotNullOrEmpty()]
		[Int32]$Seconds = 10,

		[Parameter(Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]$Message = "Pausing for $Seconds seconds..."
	)

	try {
		$WriteProgressParams = @{
			Id = 1
			Activity = $Message
			Completed = $false
			ErrorAction = "Stop"
		}

		for ($Count=1; $Count -le $Seconds; $Count++) {
			$WriteProgressParams["PercentComplete"] = (($Count / $Seconds) * 100)
			$WriteProgressParams["Status"] = "Waiting for $Seconds seconds, $($Seconds - $Count) left"

			if ($PSCmdlet.ShouldProcess("Attempting to display progress bar...")) {
				Write-Progress @WriteProgressParams
				Start-Sleep -Seconds 1
			}

		}

		$WriteProgressParams["PercentComplete"] = 100
		$WriteProgressParams["Status"] = "Completed"
		$WriteProgressParams["Completed"] = $true
		Write-Progress @WriteProgressParams

		return $true
	}
	catch {
		Write-Warning "Unable to display progress bar"

		return $false
	}

}

function Test-HSCLogFilePath
{
	<#
		.SYNOPSIS
			Verifies that the log file path exists.

		.DESCRIPTION
			This function verifies that the log file path exists.
			An option exists to create the path if it doesn't exist.

		.OUTPUTS
			System.bool

		.PARAMETER LogFilePath
			This is a mandatory parameter that is the log file path
			that needs to be tested.

		.PARAMETER CreatePath
			This is a switch parameter to indicate that the path should be
			created if the log file path doesn't exist.

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Originally Written: April 10, 2018
			Last Updated: May 12, 2021
	#>

	[Cmdletbinding()]
	[Alias("Test-LogFilePath")]
	[OutputType([bool])]
	Param(
		[Parameter(Mandatory = $true)]
		[string]$LogFilePath,

		[switch]$CreatePath
	)

	if (!(Test-Path -Path $LogFilePath))
	{
		if ($CreatePath)
		{
			Write-Verbose "Log file path doesn't exist and is being created..."

			try {
				New-Item -Path $LogFilePath -ItemType "Directory" -ErrorAction "Stop"
				Write-Verbose "Successfully created log file path"

				return $true
			}
			catch {
				Write-Warning "Unable to create log file path directory"
				return $false
			}
		}
	}
	else {
		Write-Verbose "Log file path exists"
		return $true
	}
}

function Test-HSCPowerShell7
{
	<#
		.SYNOPSIS
			This function tests to see if a version of PowerShell
			greater than 7 is being used.
		
		.EXAMPLE
			$null is returned in this example since running on PS7
			returns a null value

			$null -eq (Test-HSCPowerShell7)
			True

		.EXAMPLE
			Test-HSCPowerShell7 -Verbose
			VERBOSE: PowerShell Version: 7.1
			VERBOSE: Running PowerShell 7
		
		.EXAMPLE
			PS C:\Users\Jeff> Test-HSCPowerShell7 -Verbose
			VERBOSE: PowerShell Version: 5.1
			VERBOSE: Incorrect PowerShell Version
			Test-HSCPowerShell7 : Incorrect PowerShell Version

		.OUTPUTS
			- Exception if PS7 is not being used
			- $null if PS7 is being used

		.NOTES
			Last Updated by: Jeff Brusoe
			Last Updated: November 16, 2021
	#>

	[CmdletBinding()]
	param()

	if ((Get-HSCPowerShellVersion) -ge 7) {
        Write-Verbose "Running PowerShell 7"
    }
    else {
        Write-Verbose "Incorrect PowerShell Version"
        throw "Incorrect PowerShell Version"
    }
}

function Test-HSCVerbose
{
	<#
		.SYNOPSIS
			This function determines if the verbose common parameter has been used.

		.DESCRIPTION
			The purpose of this function is to return true/false depending on whether
			the verbose parameter has been passed to the calling PowerShell file.

		.OUTPUTS
			Retuns a boolean value depending on if the -Verbose parameter has been used.

		.EXAMPLE
			PS C:\Users\jbrus> Test-HSCVerbose
			False

		.EXAMPLE
			PS C:\Users\jbrus> Test-HSCVerbose -Verbose
			VERBOSE: Testing for verbose parameter
			VERBOSE: Verbose parameter is present
			True

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: February 17, 2021

			PS Version 5.1 Tested:
			- June 29, 2020
			- February 17, 2021
			PS Version 7.0.2 Tested: June 29, 2020
			PS Version 7.1.2 Tested: February 17, 2021
	#>

	[CmdletBinding()]
	[OutputType([bool])]
	param ()

	Write-Verbose "Testing for verbose parameter"

		try {
			if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
				Write-Verbose "Verbose parameter is present"
				return $true
			}
			else {
				Write-Verbose "Verbose parameter is not present"
				return $false
			}
		}
		catch {
			Write-Warning "Unable to determine if verbose parameter is present"
			throw "Unable To Determine Verbose"
		}
}

function Update-HSCPowerShellDocumentation
{
	<#
		.SYNOPSIS
			This function updates the documentation files for the functions
			contained in the HSC PowerShell modules.

		.DESCRIPTION
			The purpose of this function is to automatically update the markdown
			files for the HSC PowerShell modules. It does this using the
			platyPS module - https://github.com/PowerShell/platyPS

		.OUTPUTS
			System.bool

		.PARAMETER ModuleNames
			This parameter are the module names to generate the markdown files for.

		.PARAMETER RootOutputDirectory
			The root directory to place the markdown files. It assumes that there is
			a subdirectory contained here called Documentation.

		.NOTES
			Written by: Jeff Brusoe
			Last Updated by: Jeff Brusoe
			Last Updated: May 12, 2021
	#>

	[CmdletBinding()]
	[OutputType([bool])]
	param(
		[ValidateNotNullOrEmpty()]
		[string[]]$ModuleNames = @(
			"HSC-CommonCodeModule",
			"HSC-ActiveDirectoryModule"
		),

		[ValidateNotNullOrEmpty()]
		[string]$RootOutputDirectory = (Get-HSCGitHubRepoPath)
	)

	$PSHelpCreated = $true

	try {
		Write-Verbose "Attempting to import platyPS module"
		Import-Module platyPS -ErrorAction Stop
	}
	catch {
		Write-Warning "Unable to import platyPS module"
		$PSHelpCreated = $false
	}

	Write-Verbose "Root Output Directory: $RootOutputDirectory"

	try
	{
		foreach ($ModuleName in $ModuleNames)
		{
			Write-Verbose "Current Module Name: $ModuleName"

			$OutputDirectory = $RootOutputDirectory +
								"1HSCCustomModules\$ModuleName\Documentation\"
			Write-Verbose "Output Directory: $OutputDirectory"

			if (Test-Path $OutputDirectory) {
				Write-Verbose "Output directory exists"
			}

			$NewMarkdownHelpParams = @{
				Module = $ModuleName
				OutputFolder = $OutputDirectory
				NoMetadata = $true
				Force = $true
				ErrorAction = "Stop"
			}

			New-MarkdownHelp @NewMarkDownHelpParams
		}
	}
	catch {
		Write-Warning "Unable to generate PS help files"
		$PSHelpCreated = $false
	}

	return $PSHelpCreated
}

Function Write-HSCColorOutput
{
	<#
		.SYNOPSIS
			This function changes the output color and uses Write-Output to log stuff to the session transcript.

		.DESCRIPTION
			This function allows color output in combination with Write-Output.
			It's needed since Write-Output doesn't support this feature found in Write-Host.
			Write-Output is used due to some issues writing log files. Write-Output is also considered
			a better option to display output than Write-Host. (https://github.com/PowerShell/PSScriptAnalyzer/blob/master/RuleDocumentation/AvoidUsingWriteHost.md)

			In this code, ForegroundColor refers to the color of the text.

		.OUTPUTS
			The output of this function is the same as Write-Output but with the specified color displayed.

		.EXAMPLE
			PS C:\Users\jbrus> Write-ColorOutput -Message "Test Message"
			Test Message (Shown in the green which is the default)

		.EXAMPLE
			PS C:\Users\jbrus> Write-HSCColorOutput -Message "Test Message" -ForegroundColor "Blue"
			Test Message (Shown in blue)

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: June 5, 2020

			PS Version 5.1 Tested: June 29, 2020
			PS Version 7.0.2 Tested: June 29, 2020
	#>

	[CmdletBinding(PositionalBinding=$true)]
	[Alias("Write-ColorOutput")]
	param (
		[Parameter(Mandatory=$true,
					ValueFromPipeline=$true,
					ValueFromPipelineByPropertyName = $true,
					Position = 0)]
		[string[]]$Message,

		[string]$ForegroundColor = "Green"
	)

	begin
	{
		if ([Enum]::GetValues([System.ConsoleColor]) -NotContains $ForegroundColor)
		{
			Write-Verbose "An invalid system color was passed into the function. The default value of green is being used." | Out-Host
			$ForegroundColor = "Green"
		}

		$CurrentColor = [Console]::ForegroundColor
		$BackgroundColor = [Console]::BackgroundColor

		if ($CurrentColor -eq $ForegroundColor)
		{
			Write-Verbose "Current color matches input foreground color." | Out-Host
		}

		if ($BackgroundColor -eq "ForegroundColor") {
			Write-Verbose "Foreground color matches background color and will not be changed."
		}
	}

	process
	{
		[Console]::ForegroundColor = $ForegroundColor

		foreach ($m in $Message) {
			Write-Output $m
		}
	}

	end {
		[Console]::ForegroundColor = $CurrentColor
	}
}

Function Write-HSCLogFileSummaryInformation
{
	<#
	.SYNOPSIS
		This function writes common information to log files used for Active Directory
		and Exchange PowerShell files.

	.NOTES
		Written By: Matt Logue
		Last Updated:November 13, 2016
	#>

	[cmdletbinding()]
	[Alias("Write-LogFileSummaryInformation")]
	Param(
		[string]$FilePath = $null, #A null path will just put this information on the screen
		[switch]$ComputerName, #$true = include computer name in log file
		[switch]$ExcludedUsers, #$true = display list of users excluded from processing
		[string]$Summary = $null #if not null output summary
	)

    	$dateTime = Get-Date -Format G

	if (([string]::IsNullOrEmpty($FilePath)) -or ((Test-Path -Path $FilePath) -eq $false))
	{
        	Write-Verbose $("*-------------- "+$dateTime+"--------------*") | Out-Host
        	Write-ColorOutput -Message "File Path is Empty" -ForegroundColor "Green" -Verbose | Out-Host

        	if ($ComputerName -eq $true)
        	{
				Write-Verbose $("Computer Name: "+ $env:computername) | Out-Host
       		}

		if ($ExcludedUsers -eq $true)
		{
			Write-Verbose $("Excluded Users: ") | Out-Host
		}

		if (![string]::IsNullOrEmpty($Summary))
		{
			Write-Verbose $("Summary: "+ $Summary) | Out-Host
		}

    }
	else
	{

		Write-Verbose ("*-------------- $dateTime --------------*`n`r") | Out-Host
		Add-Content -Value ("*-------------- $dateTime --------------*`n`r") -Path $FilePath

		Write-Verbose $("File: "+ $FilePath) | Out-Host
		Add-Content -Value "File: $FilePath`n`r" -Path $FilePath

		if ($ComputerName -eq $true)
		{
			Write-Verbose $("Computer Name: "+ $env:computername) | Out-Host
			Add-Content -Value "`r`nComputerName: $env:computername`n`r" -Path $FilePath
		}

		if ($ExcludedUsers -eq $true)
		{
			Write-Verbose $("Excluded Users: ") | Out-Host
			Add-Content -Value "`r`nExcluded Users: `r`n" -Path $FilePath
		}

		if (![string]::IsNullOrEmpty($Summary))
		{
			Write-Verbose $("Summary: "+ $Summary) | Out-Host
			Add-Content -Value "Summary:`r`n$Summary" -Path $FilePath
		}
	}
}