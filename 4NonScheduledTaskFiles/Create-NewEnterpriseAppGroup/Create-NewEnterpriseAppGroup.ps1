#--------------------------------------------------------------------------------------------------
#
#  File:  Create-NewEnterpriseAppGroups.ps1
#
#  Author:  Kim Rodney
#
#  Last Update: August 4, 2020
#
#  Version:  1
#
#  Description: Used to create cloud security groups for granting consent to Enterprise Applications in Azure.
#
#--------------------------------------------------------------------------------------------------


$Names = Import-Csv 'C:\github\HSC-PowerShell-Repository\Create-NewEnterpriseAppGroups\GroupNames.csv'
#$Names
foreach ($Name in $names){
#$Name.Name
"Creating Group: " + $Name.Name
$Nickname = $Name.Name.Replace(' ','')
#$Nickname
New-AzureADGroup -DisplayName $Name.Name -SecurityEnabled $true -MailEnabled $False -MailNickName $Nickname -Description "Enteprise App Group"
"Checking Group: " + $Name.Name
Get-AzureADGroup -SearchString $Name.Name
}


