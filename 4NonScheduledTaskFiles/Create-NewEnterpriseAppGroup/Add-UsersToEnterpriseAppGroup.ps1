#--------------------------------------------------------------------------------------------------
#
#  File:  Add-UsersToNewEnterpriseAppGroups.ps1
#
#  Author:  Kim Rodney
#
#  Last Update: August 4, 2020
#
#  Version:  1
#
#  Description: Used to add existing users with permissions to an Entperise app to the new cloud security groups for granting consent to Enterprise Applications in Azure.
#
#--------------------------------------------------------------------------------------------------
#Install-Module -name importexcel
#Connect-AzureAD
#Install-module AzureAD -Force
#Import-Module AzureAD -Force
#Update-Module AzureAD -force

#get worksheets from Excel workbook
$Lists = Import-Excel -path C:\github\HSC-PowerShell-Repository\Create-NewEnterpriseAppGroup\EnterpriseApps.xlsx -WorksheetName List
$Apps = Import-Excel -path C:\github\HSC-PowerShell-Repository\Create-NewEnterpriseAppGroup\EnterpriseApps.xlsx -WorksheetName App2Group

foreach ($App in $Apps )
{
    
    foreach ($List in $Lists)
        {
        If ($List.DisplayName -eq $App.App)
            { 
        
            #clean the user's display name
            $User = $List.Assignment.Trim()
            #$User
        
            #Get user's ObjectID
            $UObject = Get-AzureADUser -Filter "DisplayName eq '$User'" | where {$_.UserPrincipalName -like '*@hsc.wvu.edu'}
            $UObjectID = $UObject.ObjectId
            #$UObjectID

            #Get Group ObjectID
            $GroupID = $app.ObjectID
            #$Group = get-azureadgroup -SearchString $App.Group
            #$GroupID = $Group.ObjectId
            #$GroupID
        
        
            #testing values to add user to cloud group
            $List.DisplayName + " equals " + $App.App
            "---------------------------------------------------------------------------------------- "
            "Add user " + $User + " to group " + $App.Group + " for Enterprise Application " + $App.App
            "Using ObjectID " + $UObjectID + " and GroupID " + $GroupID
            "---------------------------------------------------------------------------------------- "
            " "
            try{Add-AzureAdGroupMember -objectID $GroupID -RefObjectId $UObjectID}
            #catch { "An error occurred adding " + $UObject.DisplayName + " with User ObjectID " + $UObjectID + " to " + $Group.DisplayName + " with Group ObjectID " + $GroupID }
            catch { }
            }
        else
            {
            #shouldn't see this but JUST in case
            #"No match. NEXT!"
            }
        }
    
}



#Get-AzureADUser -Filter "EndsWith(UserPrincipalName,"hsc.wvu.edu")"

#Get-AzureADUser -Filter "startswith(Title,'Sales')"