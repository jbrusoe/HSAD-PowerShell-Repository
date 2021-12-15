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

Function Get-HSCADUser{

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName
    )

    $HSProperties = @(
        "CN",
        "Department",
        "DistinguishedName",
        "EmailAddress",
        "Enabled",
        "extensionAttribute1",
        "extensionAttribute6",
        "extensionAttribute7",
        "extensionAttribute11",
        "extensionAttribute12",
        "extensionAttribute14",
        "extensionAttribute10",
        "LockedOut",
        "PasswordLastSet",
        "lastLogon",
        "whenCreated",
        "LastBadPasswordAttempt"
    )

    $HSUserProperties = @{
        Identity = $UserName
        Server = 'hs.wvu-ad.wvu.edu'
        Properties = $HSProperties
    }

    try{
        $HSUser = Get-ADUser @HSUserProperties
    }
    catch{
        Write-Warning $error[0].Exception.Message
        Break
    }

    $HSUserProperty = [PSCustomObject]@{
        Name                     = $HSUser.("CN")
        WVUID                    = $HSUser.("extensionAttribute11")
        CreatedOn                = $HSUser.("whenCreated")
        EndDate                  = $HSUser.("extensionAttribute1")
        AccountType              = $HSUser.("extensionAttribute6")
        AccountStatus            = $HSUser.("extensionAttribute10")
        HIPAAStatus              = $HSUser.("extensionAttribute14")
        Licensed                 = $HSUser.("extensionAttribute7")
        Department               = $HSUser.("Department")
        LDAP                     = $HSUser.("DistinguishedName")
        EmailAddress             = $HSUser.("EmailAddress")
        Enabled                  = $HSUser.("Enabled")
        PasswordLastSet          = $HSUser.("PasswordLastSet")
        LastBadPasswordAttempt   = $HSUser.("LastBadPasswordAttempt")
        LastLogon                = $HSUser.("lastLogon")
        Locked                   = $HSUser.("LockedOut")
    }
    
    Write-Output ""
    Write-Output ""
    Write-Output "Name:                     $($HSUserProperty.Name)"
    Write-Output "WVUID:                    $($HSUserProperty.WVUID)"
    Write-Output "Created On:               $($HSUserProperty.CreatedOn)"
    Write-Output "End Date:                 $($HSUserProperty.EndDate)"
    Write-Output "Account Type:             $($HSUserProperty.AccountType)"
    Write-Output "Account Status:           $($HSUserProperty.AccountStatus)"
    Write-Output "HIPAA Status:             $($HSUserProperty.HIPAAStatus)"
    Write-Output "Licensed:                 $($HSUserProperty.Licensed)"
    Write-Output "Department:               $($HSUserProperty.Department)"
    Write-Output "LDAP:                     $($HSUserProperty.LDAP)"
    Write-Output "EmailAddress:             $($HSUserProperty.EmailAddress)"
    Write-Output "Enabled:                  $($HSUserProperty.Enabled)"
    Write-Output "Passwd Last Set:          $($HSUserProperty.PasswordLastSet)"
    Write-Output "LastBadPasswordAttempt:   $($HSUserProperty.LastBadPasswordAttempt)"
    Write-Output "Last Logon:               $($HSUserProperty.lastLogon)"
    Write-Output "Locked:                   $($HSUserProperty.Locked)"
    Write-Output ""
    Write-Output ""
}