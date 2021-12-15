[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]$WVUMSharedUserGroup = "WVUMSharedUsersGroup"
)

#Configure environment
Set-HSCEnvironment

$TodaysDate = Get-Date -format MM/dd/yyyy

$MM = $TodaysDate.Split("/,/")[0]
$dd = $TodaysDate.Split("/,/")[1]
$Date = $MM + $dd

$Added = @()
$users = @()
$UserInfo = @()
$UsersNotFound = @()

Connect-HSCOffice365MSOL

if ($Error.Count -gt 0)
{
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}
<#
$UserInfo = @(
			[PSCustomObject]@{
				status = $user.status
				wvu_id = $user.wvuid
				uid = $user.uid
				FirstName = $user.firstname
				LastName = $user.lastname
				email = $user.email
				HSCEmail = $user.hscemail
	}
)
#>

try {
    $GroupObjectID = Get-MSOLGroup -SearchString $WVUMSharedUserGroup -ErrorAction Stop
    $WVUMUsersInSharedGroup = Get-MSOLGroupMember -GroupObjectId $GroupObjectID.ObjectId -All -ErrorAction Stop
}
catch {
    Write-Warning "Error searching for group/group members"
    Invoke-HSCExitCommand -ErrorAction Stop
}

try {
    $SQLPassword = Get-HSCSQLPassword -Verbose -ErrorAction Stop
    $SQLConnectionString = Get-HSCConnectionString -DataSource hscpowershell.database.windows.net -Database HSCPowerShell -Username HSCPowerShell -SQLPassword $SQLPassword
    Write-Output $SQLConnectionString

    $SQLQuery = 'select * from SharedUserTable'

    $users = Invoke-SqlCmd -Query $SQLQuery -ConnectionString $SQLConnectionString -ErrorAction Stop
}
catch {
    Write-Warning "SQL Error"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}


foreach ($user in $users)
{	
    if ($user.HSCEmail -eq $false)
    {
        Try
        {
            $HSUserInfo = Get-ADUser $user.uid -Properties *                      

            if ($($HSUserInfo.extensionAttribute7) -eq "Yes365")
            {
                Write-Output "$($HSUserInfo.name) has exAtt7 set to Yes365"              
            }
            else
            {
                $UIDUserObjectId = Get-MsolUser -searchstring $user.uid 
                
                Write-Output "Checking $WVUMSharedUserGroup group share access for $($HSUserInfo.name)..."                

                
                if ($UIDUserObjectId.ObjectId -in $WVUMUsersInSharedGroup.ObjectId)
		        {
			        Write-Output "$($HSUserInfo.name) already in WVUM Shared Users group"                    			        
		        }
		        else
		        {                   
                    
                    if (($null -ne $UIDUserObjectId.ObjectId) -AND ($($UIDUserObjectId.ObjectId).count -eq 1))
				    {
                        Write-Output "Adding $($HSUserInfo.name)	to the WVUM Shared Users group..."			
					
                        Add-MsolGroupMember -GroupObjectId $($GroupObjectID.ObjectId) -GroupMemberType User -GroupMemberObjectId $($UIDUserObjectId.ObjectId)
					    
                        Write-Output "$($HSUserInfo.name) has been added to the security group"				    

                        $Added += $UserInfo
                    }
                    
                    elseif (($null -ne $UIDUserObjectId.ObjectId) -AND ($($UIDUserObjectId.ObjectId).count -gt 1))
				    {
                        Write-Output "Multiple GUID's found.  Attempting to find correct GUID for $($user.firstname) $($user.lastname)" 
                        
                        $NewObjectID = Get-MsolUser -SearchString "$($user.firstname) $($user.lastname)"
                        
                        if ($NewObjectId.ObjectId -in $WVUMUsersInSharedGroup.ObjectId)
                        {
                            Write-Output "$($HSUserInfo.name) already in WVUM Shared Users group"
                        }
                        else
                        {
                            Write-Output "Adding $($HSUserInfo.name)	to the WVUM Shared Users group..."
                            
                            Add-MsolGroupMember -GroupObjectId $($GroupObjectID.ObjectId) -GroupMemberType User -GroupMemberObjectId $($NewObjectID.ObjectId)

                            Write-Output "$($HSUserInfo.name) has been added to the security group"					        

                            $Added += $UserInfo
                        }
                    }			    
				    
                    elseif (($HSUserInfo.DistinguishedName -like '*OU=FromNewUsers,OU=DeletedAccounts,DC=HS,DC=wvu-ad,DC=wvu,DC=edu') -OR
                            ($HSUserInfo.DistinguishedName -like '*OU=NewUsers,DC=HS,DC=wvu-ad,DC=wvu,DC=edu'))
                    {                            
        
                    }                                       
                }
            }
        }
        Catch
        {                      
            Try
            {
                $WVUADSamAccountName = Get-ADUser $user.uid -Server wvu-ad.wvu.edu -properties *                 
                
                if (($WVUADSamAccountName.department -like 'SOM Anesthesiology L4') -OR ($WVUADSamAccountName.department -like 'SOM Eastern Division L4') -OR ($WVUADSamAccountName.Department -like 'SOM Family Medicine L4') -OR ($WVUADSamAccountName.Department -like 'SOM Ophthalmology L4'))
                {                    
                    if ($WVUADSamAccountName.ObjectId -in $WVUMUsersInSharedGroup.ObjectId)
		            {
			            Write-Output "$($WVUADSamAccountName.name) already in WVUM Shared Users group"                  			        
		            }
		            else
		            {                                                
                        
                        $ObjectID = Get-MsolUser -SearchString "$($WVUADSamAccountName.GivenName) $($WVUADSamAccountName.sn)"
                        
                        #Add-MsolGroupMember -GroupObjectId $($GroupObjectID.ObjectId) -GroupMemberType User -GroupMemberObjectId $($ObjectId.ObjectId)

                        $Added += $UserInfo
                    }                                           
                }                
            }
            Catch
            {
                Write-Output "$($user.uid) not found"
                $UsersNotFound += $UserInfo
            }
        }
    }
}

$Added | Export-Excel "C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\Update-SharedUserDistributionList\Logs\$(get-date -format yyyy-MM-dd)-UsersAdded.xlsx" -Append
$UsersNotFound | Export-Excel "C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\Update-SharedUserDistributionList\Logs\$(get-date -format yyyy-MM-dd)-UsersNotFound.xlsx" -Append



##########################
#Removing users from list
##########################
Write-Output ""
Write-Output ""
Write-Output ""
Write-Output "Removing Users"
Write-Output "=============="

$Removed = @()
$UsersToRemovePath = "\\hs\public\tools\SharedUsersRpt\RemovedSharedUsers\RemovedSharedUsers$Date.xlsx"

if (Test-Path $UsersToRemovePath)
{
    $UsersToRemove = Import-Excel -Path $UsersToRemovePath
    
    foreach ($user in $UsersToRemove)
    {        
        $RemoveUser = Get-MsolUser -SearchString $user.uid        
        
        if ($RemoveUser.ObjectId -in $WVUMUsersInSharedGroup.ObjectId)
        {

            Remove-MsolGroupMember -GroupObjectId $($GroupObjectID.ObjectId) -GroupMemberType User -GroupMemberObjectId $($RemoveUser.ObjectId)
        
            Write-Output "$($User.uid) was successfully removed"

            $Removed += $UserInfo
        }
        else
        {
            Write-Output "$($User.uid) is not in $WVUMSharedUserGroup"
        }
    }    
}
else
{
    Write-Output "File to remove users does not exist. No users to remove today"
}

if ($Removed -ne "$null")
{
    $Removed | Export-Excel "C:\Users\microsoft\Documents\GitHub\HSC-PowerShell-Repository\Update-SharedUserDistributionList\$(get-date -format yyyy-MM-dd)-UsersRemoved.xlsx" -Append
}
##################
#end remove users
##################


Invoke-HSCExitCommand -ErrorCount $Error.Cout