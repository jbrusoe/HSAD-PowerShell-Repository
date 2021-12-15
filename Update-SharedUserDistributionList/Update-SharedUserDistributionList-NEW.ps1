<#
	.SYNOPSIS
        The purpose of this file is to update the shared user distribution
        list based on information from the daily shared user file.

    .PARAMETER WVUMSharedUserGroup
        The name of the shared user group to update

    .PARAMETER DataSource
        IP address of the SQL DB instance

    .PARAMETER Database
        Name of the database to write information to

    .PARAMETER SQLUserName
        SQL username to use when connecting to DB.

    .NOTES
        Written by: Kevin Russell
		Last Modified by: Jeff Brusoe
		Last Modified: January 7, 2021
#>

[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]$WVUMSharedUserGroup = "TestWVUMSharedUsers", #"WVUMSharedUsersGroup", #

    [ValidateNotNullOrEmpty()]
    [string]$DataSource = "hscpowershell.database.windows.net",

    [ValidateNotNullOrEmpty()]
    [string]$Database = "HSCPowerShell",

    [ValidateNotNullOrEmpty()]
    [string]$SQLUsername = "HSCPowerShell"
)

#Configure environment
try {
    Set-HSCEnvironment -ErrorAction Stop
    Connect-HSCOffice365MSOL -ErrorAction Stop

    $TodaysDate = Get-Date -format MM/dd/yyyy

    $MM = $TodaysDate.Split("/,/")[0]
    $dd = $TodaysDate.Split("/,/")[1]
    $Date = $MM + $dd

    $Added = @()
    $UserInfo = @()
    $UsersNotFound = @()
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    $GroupObjectID = Get-MSOLGroup -SearchString $WVUMSharedUserGroup -ErrorAction Stop

    $GetMSOLGroupMemberParams = @{
        GroupObjectId = $GroupObjectID.ObjectId
        All = $true
        ErrorAction = "Stop"
    }

    $WVUMUsersInSharedGroup = Get-MSOLGroupMember @GetMSOLGroupMemberParams
}
catch {
    Write-Warning "Error searching for group/group members"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    $SQLPassword = Get-HSCSQLPassword -Verbose -ErrorAction Stop

    $GetHSCConnectionStringParams = @{
        DataSource = $DataSource
        Database = $Database
        Username = $SQLUserName
        SQLPassword = $SQLPassword
        ErrorAction = "Stop"
    }
    $SQLConnectionString = Get-HSCConnectionString @GetHSCConnectionStringParams

    $SQLQuery = 'select * from SharedUserTable'

    $InvokeSqlCmdParams = @{
        Query = $SQLQuery
        ConnectionString = $SQLConnectionString
        ErrorAction = "Stop"
    }
    $SharedUsers = Invoke-SqlCmd @InvokeSqlCmdParams
}
catch {
    Write-Warning "SQL Error"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($SharedUser in $SharedUsers)
{
    if ($SharedUser.HSCEmail -eq $false)
    {
        try
        {
            $HSUserInfo = Get-ADUser $SharedUser.uid -Properties * -ErrorAction Stop

            if ($HSUserInfo.extensionAttribute7 -eq "Yes365") {
                Write-Output "$HSUserInfo.name has exAtt7 set to Yes365"
            }
            else
            {
                $UIDUserObjectId = Get-MsolUser -SearchString $SharedUser.uid

                Write-Output $("Checking $WVUMSharedUserGroup group " +
                    "share access for $($HSUserInfo.name)...")

                if ($UIDUserObjectId.ObjectId -in $WVUMUsersInSharedGroup.ObjectId) {
			        Write-Output "$($HSUserInfo.name) already in WVUM Shared Users group"
		        }
		        else
		        {
                    if (($null -ne $UIDUserObjectId.ObjectId) -AND
                        (($UIDUserObjectId.ObjectId).count -eq 1))
				    {
                        Write-Output "Adding $($HSUserInfo.name) to the WVUM Shared Users group..."

                        $AddMsolGroupMemberParams = @{
                            GroupObjectiD = $GroupObjectID.ObjectId
                            GroupMemberType = "User"
                            GroupMemberObjectId = $UIDUserObjectId.ObjectId
                            ErrorAction = "Stop"
                        }

                        try {
                            Add-MsolGroupMember @AddMsolGroupMemberParams
                        }
                        catch {
                            Write-Warning "Unable to add user to WVUM Shared Users Group"
                        }

                        Write-Output "$($HSUserInfo.name) has been added to the security group"

                        $Added += $HSUserInfo
                    }
                    elseif (($null -ne $UIDUserObjectId.ObjectId) -AND
                    (($UIDUserObjectId.ObjectId).count -gt 1))
				    {
                        Write-Output "Multiple GUID's found.  Attempting to find " +
                            "correct GUID for $($user.firstname) $($user.lastname)"

                        $GetMSOLUserParams = @{
                            SearchString = ("$($user.firstname) $($user.lastname)")
                            ErrorAction = "Stop"
                        }

                        try {
                            $NewObjectID = Get-MsolUser @GetMSOLUserParams
                        }
                        catch {
                            Write-warning "Error trying to find MSOL user"
                        }

                        if ($NewObjectId.ObjectId -in $WVUMUsersInSharedGroup.ObjectId) {
                            Write-Output "$($HSUserInfo.name) already in WVUM Shared Users group"
                        }
                        else
                        {
                            Write-Output "Adding $($HSUserInfo.name) to the WVUM Shared Users group..."

                            try {
                                Add-MsolGroupMember @AddMsolGroupMemberParams
                                Write-Output "$($HSUserInfo.name) has been added to the security group"

                                $Added += $HSUserInfo
                            }
                            catch {
                                Write-Warning "Unable to add user to group"
                            }
                        }
                    }
                    elseif (($HSUserInfo.DistinguishedName -like '*OU=FromNewUsers,OU=DeletedAccounts,DC=HS,DC=wvu-ad,DC=wvu,DC=edu') -OR
                            ($HSUserInfo.DistinguishedName -like '*OU=NewUsers,DC=HS,DC=wvu-ad,DC=wvu,DC=edu'))
                    {

                    }
                }
            }
        }
        catch
        {
            try
            {
                $GetADUserParams = @{
                    Identity = $SharedUser.uid
                    Server = "wvu-ad.wvu.edu"
                    Properties = "*"
                    ErrorAction = "Stop"
                }

                $WVUADSamAccountName = Get-ADUser @GetADUserParams

                if (($WVUADSamAccountName.department -like 'SOM Anesthesiology L4') -OR
                    ($WVUADSamAccountName.department -like 'SOM Eastern Division L4') -OR
                    ($WVUADSamAccountName.Department -like 'SOM Family Medicine L4') -OR
                    ($WVUADSamAccountName.Department -like 'SOM Ophthalmology L4'))
                {
                    if ($WVUADSamAccountName.ObjectId -in $WVUMUsersInSharedGroup.ObjectId)
		            {
			            Write-Output "$($WVUADSamAccountName.name) already in WVUM Shared Users group"
		            }
		            else {
                        $Added += $HSUserInfo
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
    Write-Output "*******************************"
}

$Added |
    Export-Excel "$PSScriptRoot\TestLogs\$(get-date -format yyyy-MM-dd)-UsersAdded.xlsx" -Append

$UsersNotFound |
    Export-Excel "$PSScriptRoot\TestLogs\$(get-date -format yyyy-MM-dd)-UsersNotFound.xlsx" -Append

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