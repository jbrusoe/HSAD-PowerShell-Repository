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

Function Get-AccountStatus
{
    [CmdletBinding()]
    param(
        [string]$username
    )

    $StartTime = get-date
    $WVUHDomains = "wvuhs.com","wvuh.wvuhs.com"
    $DomainUser = 0


    foreach ($domain in $WVUHDomains)
    {
        try 
        {
            $WVUHUser = Get-ADUser -Identity $username -Server $domain -Properties PasswordLastSet
            #$DomainUser++
        }
        catch 
        {
            
        }        
    }

    try 
    {    
        $HSUser = Get-ADUser $username -Properties DistinguishedName, whenCreated, PasswordLastSet, extensionAttribute1, extensionAttribute7       

        ##
        #Check HS password last set and whenCreated
        if($HSUser.PasswordLastSet -AND $HSUser.whenCreated)
            {                
                $TimeFromCreation = ($HSUser.whenCreated - $HSUser.PasswordLastSet).TotalMinutes 
                
                if ($TimeFromCreation -le "2" -AND $TimeFromCreation -ge "-2")
                {
                    $HSClaimed = $false
                    Write-Host "PasswordLastSet and whenCreated are within 3 minutes.  User needs to change password before account will process.  Make sure they have changed their password."
                }
                else
                {
                    $HSClaimed = $true    
                }
            }
        #End check
        ##


        #Checking for for various OU's
        if ($HsUser.DistinguishedName.Split(',')[1] -like 'OU=FromNewUsers')
        {
            Write-Host ""
            Write-Host "Account is in FromNewUsers OU" 
            Write-Host ""                    
        }
        if ($HSUser.DistinguishedName.Split(',')[1] -like 'OU=DeletedAccounts')
        {
            Write-Host ""
            Write-Host "Account is in DeletedAccounts OU" 
            Write-Host ""
        }
        if ($HSUser.DistinguishedName.Split(',')[1] -like 'OU=NewUsers*')
        {
            Write-Host ""
            Write-Host "Account is in NewUsers OU; still needs to be processed" 
            Write-Host ""
            
            if($HSClaimed)
            {
                Write-Host "Check in TDX to see if CSC form was submitted.  Under Ticket Reports choose Search Specific Word/Phrase"
                Write-Host "In description put users last name and search.  See if there is a Add New Account ticket that has user in it"
                Write-Host "If ticket does not exist CSC need to submit form."
                Write-Host ""           
            }
            #test if WVU had same passwdlastset and whencreated, set true false
            #if wvu and hs claimed are both true write-host user needs to claim account
        }
        if ($HSUser.DistinguishedName.Split(',')[2] -like 'OU=Inactive Accounts')
        {
            Write-Host ""
            Write-Host "Account is in inactive accounts OU" 
            Write-Host ""
        }
        #End in New Users check



        #pwd expire days            
        if ($HSUser.PasswordLastSet -le [datetime]"2019-06-30")
        {
            Write-Host "Password was last set prior to 6/30/2019; they need to claim account in new IDM system"

            $90DayPwdExpire = New-TimeSpan -Start $StartTime -End $HSUser.PasswordLastSet.AddDays(90)
            
            Write-Host ""
            Write-Host "Password expires in $($90DayPwdExpire.days) days"
            Write-Host ""
        }
        else
        {
            $365DayPwdExpire = New-TimeSpan -Start $StartTime -End $HSUser.PasswordLastSet.AddDays(365)
                
            Write-Host ""
            Write-Host "Password expires in $($365DayPwdExpire.Days) days"
            Write-Host ""
        }
        #end pwd expire days


        

        #pwd's sync'd
        
            $domain = New-Object System.DirectoryServices.DirectoryEntry("LDAP://DC=WVU-AD,DC=WVU,DC=EDU")
            $Searcher = New-Object System.DirectoryServices.DirectorySearcher
            $Searcher.SearchRoot = $domain
            $Searcher.PageSize = 10000
            $Searcher.Filter = "(&(objectCategory=person)(sAMAccountName=$username))"
            $Searcher.SearchScope = "Subtree"
                        
                    
            $PropertyList = "pwdLastSet"

            $index = $Searcher.PropertiesToLoad.Add($PropertyList)

                    
            $SearchResults = $Searcher.FindAll()
                            
            
           # $result = $SearchResult.GetDirectoryEntry()
            
          #  Write-Host "Password Last Set:         " + [datetime]::fromfiletime($result.ConvertLargeIntegerToInt64($result.pwdLastSet[0]))
            

        
        #check for HS/WVUH password sync
        if($HSUser.PasswordLastSet -AND $WVUHUser.PasswordLastSet)
        {    
            $HSWVUHPwdLastSetTimeSpan = New-TimeSpan -Start $HSUser.PasswordLastSet -End $WVUHUser.PasswordLastSet
            #$HSWVUHPwdLastSetTimeSpan = New-TimeSpan -Start $WVUHUser.PasswordLastSet -End $HSUser.PasswordLastSet
                
            if ($HSWVUHPwdLastSetTimeSpan.Seconds -gt "120" -OR $HSWVUHPwdLastSetTimeSpan.Days -gt "0")
            #if ($HSWVUHPwdLastSetTimeSpan.Seconds -gt "120" -OR $HSWVUHPwdLastSetTimeSpan.Days -lt "0")
            {
                Write-Host "HSC and WVUH passwords do not match"
                Write-Host ""
            }
            else
            {
                Write-Host "HS and WVUH passwords are in sync"
                Write-Host "" 
            }
        }
        #end HS/WVUH passwd sync check


        if($DomainUser -eq 2)
        {
            Write-Host "User is in both WVUH and WVUHS domain.  Did not check for HS/WVUH password sync"
        }
        #end pwd's sync'd 
        
        
        if (($HSUser.extensionAttribute7 -eq "No365") -OR ($HSUser.extensionAttribute7 -eq "$null"))
        {
            Write-Host ""
            Write-Host "Account does not have a 365 license; needs a license applied for email"
            Write-Host ""
        }


        if ($StartTime -ge $HSUser.extensionAttribute1)
        {
            Write-Host ""     
            Write-Host "The end date has passed $($HSUser.extensionAttribute1); if the account needs turned back on they need to contact the EBO to get it changed"
            Write-Host ""
        }    
    }
    catch 
    {
        
    }
}