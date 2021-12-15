Function Get-WVUADUser{
    <#
	.SYNOPSIS
		The purpose of this function is to quickly display basic account information for a WVU user.
        

	.DESCRIPTION
		This function accepts a UserName for input and returns info before for domains provided:

        Domain, Name, WVUID, EnterpriseID, CreatedOn, Department, distinguishedName,Email, Enabled,
        Locked, PasswordLastSet, PasswordExpired, LastBadPasswordAttempt

	.PARAMETER
		UserName - user the script uses to lookup

	.NOTES
		Originally Written by: Kevin Russell
		Updated & Maintained by: Kevin Russell
		Last Updated by: Kevin Russell
		Last Updated: March 15, 2021
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName
    )

    $WVUProperties = @(
        "CN",
        "Department",
        "Enabled",
        "DistinguishedName",
        "Mail",
        "LastBadPasswordAttempt",
        "LockedOut",
        "PasswordExpired",
        "PasswordLastSet",
        "extensionAttribute13",
        "whenCreated",
        "extensionAttribute11"
    )

    $error.Clear()

    $WVUUserProperties = @{
        Identity = $UserName
        Server = 'wvu-ad.wvu.edu'
        Properties = $WVUProperties
    }

    try{
        $WVUUser = Get-ADUser @WVUUserProperties
    }
    catch{
        Break
    }

    $WVUUserProperty = [PSCustomObject]@{
        Name                   = $WVUUser.("CN")
        WVUID                  = $WVUUser.("extensionAttribute11")
        EnterpriseID           = $WVUUser.("extensionAttribute13")
        CreatedOn              = $WVUUser.("whenCreated")
        Department             = $WVUUser.("Department")
        LDAP                   = $WVUUser.("DistinguishedName")
        Email                  = $WVUUser.("Mail")
        Enabled                = $WVUUser.("Enabled")
        Locked                 = $WVUUser.("LockedOut")
        PasswordLastSet        = $WVUUser.("PasswordLastSet")
        PasswordExpired        = $WVUUser.("PasswordExpired")
        LastBadPasswordAttempt = $WVUUser.("LastBadPasswordAttempt")        
    }

    Write-Output ""
    Write-Output ""
    Write-Output "Domain:                   $($WVUUserProperty.Domain)"
    Write-Output "Name:                     $($WVUUserProperty.Name)"
    Write-Output "WVU ID:                   $($WVUUserProperty.WVUID)"
    Write-Output "Enterprise ID:            $($WVUUserProperty.EnterpriseID)"
    Write-Output "Created On:               $($WVUUserProperty.CreatedOn)"
    Write-Output "Department:               $($WVUUserProperty.Department)"
    Write-Output "LDAP:                     $($WVUUserProperty.LDAP)"
    Write-Output "Email:                    $($WVUUserProperty.Email)"
    Write-Output "Enabled:                  $($WVUUserProperty.Enabled)"
    Write-Output "Locked:                   $($WVUUserProperty.Locked)"
    Write-Output "Passwd Last Set:          $($WVUUserProperty.PasswordLastSet)"
    Write-Output "Passwd Expired:           $($WVUUserProperty.PasswordExpired)"
    Write-Output "LastBadPasswordAttempt:   $($WVUUserProperty.LastBadPasswordAttempt)"
    Write-Output ""
    Write-Output ""
}