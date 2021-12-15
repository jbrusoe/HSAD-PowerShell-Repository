<#
	.SYNOPSIS
		The purpose of this function is to quickly display basic account information for a HS user

	.DESCRIPTION
		Name, WVUID, CreatedOn, EndDate, AccountType, AccountStatus, HIPAA Status, LicnesedM365, Department,
        distinguishedName, Email, Enabled, PasswordLastSet, LastBadPasswordAttempt, LastLogon and Locked.

	.PARAMETER
		UserName - user the script uses to lookup

	.NOTES
		Originally Written by: Kevin Russell
		Updated & Maintained by: Kevin Russell
		Last Updated by: Kevin Russell
		Last Updated: March 15, 2021
#>

Function Get-HSCUserProxyAddress{

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName
    )

    try{
        $ProxyAddressList = Get-ADUser -Identity $UserName -Properties proxyAddresses
    }
    catch{
        Write-Warning "Please check your spelling"
        Write-Warning $error[0].Exception.Message
        Break
    }

    Write-Output ""
    Write-Output ""
    $ProxyAddressList.proxyAddresses | Sort-Object -CaseSensitive
    Write-Output ""
    Write-Output ""

}