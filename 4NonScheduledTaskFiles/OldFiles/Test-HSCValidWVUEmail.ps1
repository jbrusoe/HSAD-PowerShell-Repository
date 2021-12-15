function Test-HSCValidWVUEmail
{
	<#
	.SYNOPSIS
		This function tests whether an email is a valid WVU email address. It only checks if
		it's possible, but not that the account actually exists.

	.DESCRIPTION
		There are currently only two tests to determine if the email address is valid.
		1. Does the email address contain wvu.edu?
		2. Is there an @ symbol in the email address string

	.EXAMPLE
		PS C:\Users\jbrus> Test-HSCValidWVUEmail -EmailAddress "test@hsc.wvu.edu"
		True

	.EXAMPLE
		PS C:\Users\jbrus> Test-HSCValidWVUEmail -EmailAddress "test@gmail.com"
		False

	.PARAMETER EmailAddress
		This email address is what will be tested by the logic of hte code.

	.OUTPUTS
		Returns a boolean value to indicate whether the email address is valid

	.NOTES
		Written by: Jeff Brusoe
		Last Updated by: Jeff Brusoe
		Last Updated: June 23, 2020

		PS Version 5.1 Tested: June 29, 2020 
		PS Version 7.0.2 Tested: June 29, 2020
	#>
	
	[CmdletBinding()]
	[Alias("Test-ValidWVUEmail")]
	[OutputType([bool])]
	param (
		[Parameter(Mandatory=$True)][string]$EmailAddress
	)

	begin
	{
		$ValidEmail = $false
	}
	
	process
	{
		Write-Verbose "Attempting to verify: $EmailAddress" | Out-Host

		if (($EmailAddress.indexOf("wvu.edu") -gt 0) -AND ($EmailAddress.indexOf("@") -gt0))
		{
			Write-Verbose "The email is valid" | Out-Host
			$ValidEmail = $true
		}
		else
		{
			Write-Verbose "The email is invalid" | Out-Host
			$ValidEmail = $false
		}
	}

	end
	{
		return $ValidEmail
	}
}