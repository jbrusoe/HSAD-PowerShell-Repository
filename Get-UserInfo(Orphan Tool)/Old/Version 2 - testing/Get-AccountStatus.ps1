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
#>

Function Get-AccountStatus
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]    
        [string]$UserName
    )

    $HSUserProperties = @(
        "distinguishedName",
        "whenCreated",
        "PasswordLastSet",
        "extensionAttribute1",
        "extensionAttribute7"
    )

    try{
        $HSUser = Get-ADUser $UserName -Properties $HSUserProperties
    }
    catch{
        Write-Warning $error[0].Exception.Message           
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }

    
    #Check password last set and whenCreated
    if($HSUser.PasswordLastSet -AND $HSUser.whenCreated){

        $TimeFromCreation = ($HSUser.whenCreated - $HSUser.PasswordLastSet).TotalMinutes 
        
        if ($TimeFromCreation -le "2" -AND $TimeFromCreation -ge "-2"){
            $HSClaimed = $false
            Write-Output "PasswordLastSet and whenCreated are within 3 minutes."
            Write-Warning "User needs to change password before account will process."
        }
        else{
            $HSClaimed = $true    
        }
    }
    #End check
    

    #Checking for for various OU's
    if($HsUser.DistinguishedName.Split(',')[1] -like 'OU=FromNewUsers'){
        Write-Output ""
        Write-Warning "Account is in FromNewUsers OU" 
        Write-Output ""                    
    }
    if($HSUser.DistinguishedName.Split(',')[1] -like 'OU=DeletedAccounts'){
        Write-Output ""
        Write-Warning "Account is in DeletedAccounts OU" 
        Write-Output ""
    }
    if($HSUser.DistinguishedName.Split(',')[1] -like 'OU=NewUsers*'){
        Write-Output ""
        Write-Warning "Account is in NewUsers OU; still needs to be processed" 
        Write-Output ""
        
        if($HSClaimed){
            Write-Output "Check in TDX to see if CSC form was submitted.  Under Ticket Reports choose Search Specific Word/Phrase"
            Write-Output "In description put users last name and search.  See if there is a Add New Account ticket that has user in it"
            Write-Output "If ticket does not exist CSC need to submit form."
            Write-Output ""           
        }        
    }
    if($HSUser.DistinguishedName.Split(',')[2] -like 'OU=Inactive Accounts'){
        Write-Output ""
        Write-Warning "Account is in inactive accounts OU" 
        Write-Output ""
    }
    #End in New Users check
    
    
    
    #pwd expire days            
    if($HSUser.PasswordLastSet -le [datetime]"2019-06-30"){
        Write-Host "Password was last set prior to 6/30/2019; they need to claim account in new IDM system"

        $90DayPwdExpire = New-TimeSpan -Start $StartTime -End $HSUser.PasswordLastSet.AddDays(90)
        
        Write-Host ""
        Write-Host "Password expires in $($90DayPwdExpire.days) days"
        Write-Host ""
    }
    else{
        $365DayPwdExpire = New-TimeSpan -Start $StartTime -End $HSUser.PasswordLastSet.AddDays(365)
            
        Write-Host ""
        Write-Host "Password expires in $($365DayPwdExpire.Days) days"
        Write-Host ""
    }
    #end pwd expire days

    
    if(($HSUser.extensionAttribute7 -eq "No365") -OR ($HSUser.extensionAttribute7 -eq "$null")){
            Write-Host ""
            Write-Host "Account does not have a 365 license; needs a license applied for email"
            Write-Host ""
        }

    if($StartTime -ge $HSUser.extensionAttribute1){
        Write-Host ""     
        Write-Host "The end date has passed $($HSUser.extensionAttribute1); if the account needs turned back on they need to contact the EBO to get it changed"
        Write-Host ""
    }
    
    
    
    
    
    
    
    
    
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
}