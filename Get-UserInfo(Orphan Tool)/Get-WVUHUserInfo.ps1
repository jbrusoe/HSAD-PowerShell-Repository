<#
    .SYNOPSIS
        

    .OUTPUTS
        

    .EXAMPLE
        

    .EXAMPLE
        

    .NOTES
        Written by: Kevin Russell
        Last Updated: 

        PS Version 5.1 Tested:  
        PS Version 7.0.2 Tested: 
#>	

Function Get-WVUHUserInfo
{
    [CmdletBinding()]
    param(
        [string]$username
    )   
        
    $WVUHDomains = "wvuhs.com","wvuh.wvuhs.com"
    $WVUHProperties = @("CN", "Department", "Enabled", "DistinguishedName", "Mail", "LastBadPasswordAttempt", "LockedOut", "PasswordExpired", "PasswordLastSet", "extensionAttribute13", "whenCreated", "extensionAttribute11")
    
    foreach ($domain in $WVUHDomains)
    {
        try 
        {
            $WVUHUser = Get-ADUser -Identity $username -Server $domain -Properties $WVUHProperties            
            Write-Host ""
            Write-Host ""
            Write-Host "WVUH Information:" -ForegroundColor Yellow	
            Write-Host "=================" -ForegroundColor Blue
            Write-Host "Domain:                   "$domain.Split('.')[0]            
                        
                                             
            if ($WVUHUser.CN)
            {
                Write-Host "Name:                     "$WVUHUser.CN
            }
            if ($WVUHUser.extensionAttribute11)
            {
                Write-Host "WVU ID:                   "$WVUHUser.extensionAttribute11
            }
            if ($WVUHUser.extensionAttribute13)
            {
                Write-Host "Enterprise ID:            "$WVUHUser.extensionAttribute13
            }
            if ($WVUHUser.whenCreated)
            {
                Write-Host "Created On:               "$WVUHUser.whenCreated
            }
            if ($WVUHUser.Department)
            {
                Write-Host "Department:               "$WVUHUser.Department
            }
            if ($WVUHUser.DistinguishedName)
            {
                Write-Host "LDAP:                     "$WVUHUser.DistinguishedName
            }
            if ($WVUHUser.Mail)
            {
                Write-Host "Email:                    "$WVUHUser.Mail
            }
            if ($WVUHUser.Enabled)
            {
                Write-Host "Enabled:                  "$WVUHUser.Enabled
            }
            if ($WVUHUser.LockedOut)
            {
                Write-Host "Locked:                   "$WVUHUser.LockedOut
            }                    
            if ($WVUHUser.PasswordLastSet)
            {
                Write-Host "Passwd Last Set:          "$WVUHUser.PasswordLastSet
            }
            if ($WVUHUser.PasswordExpired)
            {
                Write-Host "Passwd Expired:           "$WVUHUser.PasswordExpired
            }
            if ($WVUHUser.LastBadPasswordAttempt)
            {
                Write-Host "LastBadPasswordAttempt:   "$WVUHUser.LastBadPasswordAttempt
            }                
                             
            Write-Host ""
            Write-Host ""
        }
        catch 
        {
            #Left blank intentionally
        } 
    }
}