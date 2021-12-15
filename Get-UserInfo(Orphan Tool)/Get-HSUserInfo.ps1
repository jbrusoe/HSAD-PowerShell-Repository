<#
    .SYNOPSIS
        This function gets information from the HS domain.  The properties are defined in the $HSProperties array in line 31.  Accepts a
        string of $username

    .OUTPUTS
        

    .EXAMPLE
        #Get-HSUserInfo -username krussell

    .EXAMPLE
        

    .NOTES
        Written by: Kevin Russell
        Last Updated: 

        PS Version 5.1 Tested:  
        PS Version 7.0.2 Tested: 
#>	

Function Get-HSUserInfo
{
    [CmdletBinding()]
    param(
        [string]$username
    )
    
        $TodaysDate = Get-Date

        $HSProperties = @("CN", "Department", "DistinguishedName", "EmailAddress", "Enabled", "extensionAttribute1", "extensionAttribute6", "extensionAttribute7", "extensionAttribute11",`
        "extensionAttribute12", "extensionAttribute14", "extensionAttribute10", "LockedOut", "PasswordLastSet", "lastLogon", "whenCreated", "LastBadPasswordAttempt")
    
        try
        {
            $HSUser = Get-ADUser -Identity $username -Properties $HSProperties
            Write-Host ""
            Write-Host "HSC-AD Information:" -ForegroundColor Yellow 
            Write-Host "===================" -ForegroundColor Blue
        }
        catch
        {
            #want to leave blank; easier to read for helpdesk 
        }
        
    
        
        if ($HSUser.CN)
        {
            Write-Host "Name:                     "$HSUser.CN
        }
        if ($HSUser.extensionAttribute11)
        {
            Write-Host "WVUID:                    "$HSUser.extensionAttribute11
        }    
        if ($HSUser.whenCreated)
        {
            Write-Host "Created On:               "$HSUser.whenCreated
        }
        if ($HSUser.extensionAttribute1)
        {
            if ($HSUser.extensionAttribute1 -ge $TodaysDate)
            {
                Write-Host -NoNewLine "End Date:                  "
                Write-Host $HSUser.extensionAttribute1 -ForegroundColor Red                
            }
            else 
            {
                Write-Host "End Date:                 "$HSUser.extensionAttribute1
            }            
        }
        if ($HSUser.extensionAttribute6)
        {
            Write-Host "Account Type:             "$HSUser.extensionAttribute6
        }
        if ($HSUser.extensionAttribute10)
        {
            Write-Host "Account Status:           "$HSUser.extensionAttribute10
        }
        if ($HSUser.extensionAttribute14)
        {
            Write-Host "HIPAA Status:             "$HSUser.extensionAttribute14
        }
        if ($HSUser.extensionAttribute7)
        {
            if (($HSUser.extensionAttribute7 -eq "No365") -OR ($HSUser.extensionAttribute7 -eq "$null"))
            {
                Write-Host -NoNewLine "Licensed:                  "
                Write-Host $HSUser.extensionAttribute7 -ForegroundColor Red                
            }
            else
            {
                Write-Host "Licensed:                 "$HSUser.extensionAttribute7
            }            
        }    
        if ($HSUser.Department)
        {
            Write-Host "Department:               "$HSUser.Department
        }    
        if ($HSUser.DistinguishedName)
        {
            Write-Host "LDAP:                     "$HSUser.DistinguishedName
        }    
        if ($HSUser.EmailAddress)
        {
            Write-Host "EmailAddress:             "$HSUser.EmailAddress
        }    
        if ($HSUser.Enabled)
        {
            if ($HSUser.Enabled)
            {
                Write-Host "Enabled:                  "$HSUser.Enabled
            }
            else 
            {
                Write-Host -NoNewLine "Enabled:                   "
                Write-Host  $HSUser.Enabled -ForegroundColor Red    
            }            
        }    
        if ($HSUser.LockedOut)
        {
            if ($HSUser.LockedOUt)
            {
                Write-Host -NoNewLine "Locked:                   "
                Write-Host  $HSUser.LockedOut -ForegroundColor Red
                try 
                {
                    Unlock-ADAccount -Identity $username -ErrorAction SilentlyContinue		
                    Write-Host "The password been done wore out, account has been unlocked." -ForegroundColor Cyan
                }
                catch 
                {
                    Write-Host "There was an error unlocking the account" -ForegroundColor Red
                }                
            }
            else 
            {
                Write-Host "Locked:                   "$HSUser.LockedOut
            }            
        }    
        if ($HSUser.PasswordLastSet)
        {
            Write-Host "Passwd Last Set:          "$HSUser.PasswordLastSet
        }    
        if ($HSUser.LastBadPasswordAttempt)
        {
            Write-Host "LastBadPasswordAttempt:   "$HSUser.LastBadPasswordAttempt
        }
        if ($HSUser.lastLogon)
        {
            Write-Host "Last Logon:               "$HSUser.lastLogon
        }                                
            
    
        Get-WVUUserInfo $username
    
        Get-WVUHUserInfo $username 
    
        Write-Host ""
        Write-Host ""
        Write-Host ""
        Write-Host ""
        Write-Host "notes and additional information" -ForegroundColor Yellow
        Write-Host "================================" -ForegroundColor Blue
        Get-AccountStatus $username
    
        try 
        {
            $proxy = Get-ADUser -Identity $username -Properties proxyAddresses
            Write-Host "`nProxy Addresses"
            Write-Host "---------------"        
            $proxy.proxyAddresses | Sort-Object -CaseSensitive
        }
        catch 
        {
            
        }
        
        try 
        {
            $MemberOf = Get-ADPrincipalGroupMembership -Identity $username | Select-Object name
            Write-Host "`nAD Group Membership"
            Write-Host "-------------------"        
            $MemberOf.name | Sort-Object
        }
        catch 
        {
            
        }    
}