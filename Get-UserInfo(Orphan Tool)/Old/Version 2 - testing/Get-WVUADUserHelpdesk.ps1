<#
	.SYNOPSIS
		The purpose of this function is to quickly display basic account information for a WVU user

	.DESCRIPTION
		Domain, Name, WVUID, EnterpriseID, CreatedOn, Department, distinguishedName,Email, Enabled,
        Locked, PasswordLastSet, PasswordExpired, LastBadPasswordAttempt

	.PARAMETER
		UserName - user the script uses to lookup

	.NOTES
		Originally Written by: Kevin Russell
		Updated & Maintained by: Kevin Russell
		Last Updated by: Kevin Russell
		Last Updated: March 15, 2021

		**User this version if you are not on a server for finding WVU-AD user information**
#>

Function Get-WVUADUserHelpdesk{

    [CmdletBinding()]
    param(
		[Parameter(Mandatory=$true)]
		[string]$UserName
    )

	Write-Output "`n`nWVU-AD Information:"
	Write-Output "==================="

	try{

		$domain = New-Object System.DirectoryServices.DirectoryEntry("LDAP://DC=WVU-AD,DC=WVU,DC=EDU")
		$Searcher = New-Object System.DirectoryServices.DirectorySearcher
		$Searcher.SearchRoot = $domain
		$Searcher.PageSize = 10000
		$Searcher.Filter = "(&(objectCategory=person)(sAMAccountName=$username))"
		$Searcher.SearchScope = "Subtree"
		$SearchResults = $Searcher.FindAll()

		foreach ($SearchResult in $SearchResults)
		{
			$result = $SearchResult.GetDirectoryEntry()

			$Item = $result.Properties

			"FullName:                  " + $Item.CN
			"UserName:                  " + $Item.sAMAccountName
			"EmailAddress:              " + $Item.mail
			"Created On:                " + $Item.whenCreated
			"Department:                " + $Item.Department
			"distinguishedName:         " + $Item.DistinguishedName
			"Password Last Set:         " + [datetime]::fromfiletime($result.ConvertLargeIntegerToInt64($result.pwdLastSet[0]))
			"Password Expires:          " + [datetime]::fromfiletime($result.ConvertLargeIntegerToInt64($result.accountExpires[0]))
			"LastBadPasswordAttempt:    " + [datetime]::fromfiletime($result.ConvertLargeIntegerToInt64($result.badPasswordTime[0]))
			"LastLogonTimestamp:        " + [datetime]::fromfiletime($result.ConvertLargeIntegerToInt64($result.lastLogonTimestamp[0]))


			[int]$uacValue = $Item.userAccountControl.toString()

			$AccountIsDisabled = $false
			$AccountLocked = $false
			$PasswordExpired = $false

			foreach ($value in $uacValue)
			{
				if ($value -eq 514)
				{
					$AccountIsDisabled = $true
				}

				if ($value -contains 16)
				{
					$AccountLocked = $true
				}

				if ($value -contains 8388608)
				{
					$PasswordExpired = $true
				}
			}
			"Account Is Disabled:       " + $AccountIsDisabled
			"Account Is Locked:         " + $AccountLocked
			"Password Expired:          " + $PasswordExpired
		}
	}
	catch{
		Write-Warning $error[0].Exception.Message
        Invoke-HSCExitCommand -ErrorCount $Error.Count
	}
}