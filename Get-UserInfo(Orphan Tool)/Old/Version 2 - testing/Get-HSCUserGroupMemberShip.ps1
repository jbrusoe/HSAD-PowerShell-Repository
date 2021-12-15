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

Function Get-HSCUserGroupMemberShip{

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName
    )

    try{
        $MemberOf = Get-ADPrincipalGroupMembership -Identity $UserName | Select-Object name
    }
    catch{
        Write-Warning "There was an error finding group memebership"
        Write-Warning $error[0].Exception.Message
    }

    ForEach-Object ($Member in $MemberOf){
        
    }

    write-output ""
    write-output ""
    $MemberOf.name | Sort-Object
    write-output ""
    write-output ""

}