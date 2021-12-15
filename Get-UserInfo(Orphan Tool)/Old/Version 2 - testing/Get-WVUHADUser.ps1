<#
	.SYNOPSIS
		The purpose of this function is to quickly display basic account information for a WVUH user

	.DESCRIPTION
		This function accepts a UserName for input and returns info before for wvuhs.com and wvuh.wvuhs.com:

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

Function Get-WVUHADUser{

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName,

        [ValidateNotNullOrempty()]
        [string[]]$WVUHDomains = @(
            "wvuhs.com",
            "wvuh.wvuhs.com"
        ),

        [ValidateNotNullOrEmpty()]
        [string[]]$WVUHProperties = @(
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
    )

    foreach ($Domain in $WVUHDomains){

        $error.Clear()

        $WVUHUserProperties = @{
            Identity = $UserName
            Server = $domain
            Properties = $WVUHProperties
        }

        try{
            $WVUHUser = Get-ADUser @WVUHUserProperties
        }
        catch{
            Break
        }

        $WVUHUserProperty = [PSCustomObject]@{
            Domain                   = $domain
            Name                     = $WVUHUser.("CN")
            WVUID                    = $WVUHUser.("extensionAttribute11")
            EnterpriseID             = $WVUHUser.("extensionAttribute13")
            CreatedOn                = $WVUHUser.("whenCreated")
            Department               = $WVUHUser.("Department")
            LDAP                     = $WVUHUser.("DistinguishedName")
            Email                    = $WVUHUser.("Mail")
            Enabled                  = $WVUHUser.("Enabled")
            Locked                   = $WVUHUser.("LockedOut")
            PasswordLastSet          = $WVUHUser.("PasswordLastSet")
            PasswordExpired          = $WVUHUser.("PasswordExpired")
            LastBadPasswordAttempt   = $WVUHUser.("LastBadPasswordAttempt")
        }

        Write-Output "`n`n"
        Write-Output "Domain:                   $($WVUHUserProperty.Domain)"
        Write-Output "Name:                     $($WVUHUserProperty.Name)"
        Write-Output "WVU ID:                   $($WVUHUserProperty.WVUID)"
        Write-Output "Enterprise ID:            $($WVUHUserProperty.EnterpriseID)"
        Write-Output "Created On:               $($WVUHUserProperty.CreatedOn)"
        Write-Output "Department:               $($WVUHUserProperty.Department)"
        Write-Output "LDAP:                     $($WVUHUserProperty.LDAP)"
        Write-Output "Email:                    $($WVUHUserProperty.Email)"
        Write-Output "Enabled:                  $($WVUHUserProperty.Enabled)"
        Write-Output "Locked:                   $($WVUHUserProperty.Locked)"
        Write-Output "Passwd Last Set:          $($WVUHUserProperty.PasswordLastSet)"
        Write-Output "Passwd Expired:           $($WVUHUserProperty.PasswordExpired)"
        Write-Output "LastBadPasswordAttempt:   $($WVUHUserProperty.LastBadPasswordAttempt)"
        Write-Output "`n`n"
    }
}