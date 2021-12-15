#--------------------------------------------------------------------------------------------------
#
#  File:  Add-UsersToCloudGroups.ps1
#
#  Author:  Kim Rodney
#
#  Last Update: September, 2020
#
#  Version:  1
#
#  Description: Used to add users cloud security group.
#
#--------------------------------------------------------------------------------------------------
#Install-Module -name importexcel
#Connect-AzureAD

#get worksheets from Excel workbook
$Users = Import-Excel -path C:\temp\2020-09-11_activity_log.xlsx -WorksheetName Sheet1
$Group = Get-AzureADGroup -objectid "94a70f9e-d9f8-4b00-82e2-665d2dde991f"
##$group.DisplayName
$i = 0
    
foreach ($User in $Users)
        {
            #$user.Name
            ##$user.UPN
            ##$user = 'bjimmie@hsc.wvu.edu'
            ##$user
            $Sam = $user.UPN.Split('@')[0]
            ##$Sam
            $UObject = Get-AzureADUser -SearchString $sam | where {$_.UserPrincipalName -like "*@hsc.wvu.edu"}
            $UObjectID = $UObject.ObjectId
            ##$UObject
            ##$UObjectID
            
            
            #testing values to add user to cloud group
            ##$Sam + " equals " + $Group.DisplayName
            "---------------------------------------------------------------------------------------- "
            "Add user " + $Sam + " to group " + $Group.DisplayName
            "Using ObjectID " + $UObjectID + " and GroupID " + $Group.ObjectId
            "---------------------------------------------------------------------------------------- "
            " "
            try{Add-AzureAdGroupMember -objectID $Group.ObjectId -RefObjectId $UObjectID}
            catch { "An error occurred adding " + $UObject.DisplayName + " " + $_.ErrorDetails}
            ##catch { "An error occurred adding " + $UObject.DisplayName + " with User ObjectID " + $UObjectID + " to " + $Group.DisplayName + " with Group ObjectID " + $GroupID }
            $i
            $i++
   
}