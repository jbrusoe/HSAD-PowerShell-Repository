[CmdletBinding()]
param()

#$ADUsers = Get-ADUser -Filter * -Properties extensionAttribute1,memberOf |
#                Where-Object {$_.extensionAttribute1 -eq "07/29/2021"}

$CSVUsers = Import-Csv "CleanedUsersToMove2.csv"
$Departments = Import-Csv "C:\Users\Microsoft\Documents\GitHub\HSC-PowerShell-Repository\2CommonFiles\MappingFiles\DepartmentMap.csv"

foreach ($CSVUser in $CSVUsers)
{
    Write-Output $("Current ADUser: " + $CSVUSer.UserPrincipalName)

    $SAMAccountName = $CSVUser.UserPrincipalName.substring(0,$CSVUser.UserPrincipalName.indexOf("@"))
    Write-Output "SamAccountName: $SamAccountName"
    $ADUser = Get-ADUser $SAMAccountName -Properties memberOf
    $ADGroups = $ADUser.memberOf
    $ADGroups

    foreach ($ADGroup in $ADGroups) {
        #Write-Output $("Current Group: " + $ADGroup)

        $CleanedGroupName = $ADGroup -Replace "CN=",""
        $CleanedGroupName = $CleanedGroupName.substring(0,$CleanedGroupName.indexOf(","))

        #Write-Output "Cleaned Group Name: $CleanedGroupName"

        foreach ($CSVGroup in $Departments.Groups) {
            #Write-Output "Current CSV Group: $CSVGroup"

            $CSVGroups = $CSVGroup -split ";"

            if ($CSVGroups -contains $CleanedGroupName) {
                Write-Output "CleanedGroupName: $CleanedGroupName"
                Write-Output "Current CSV Group: $CSVGroup"
                
                $TargetOU = ($Departments | where {$_.Groups -eq $CSVGroup} | Select -First 1).OUPath
                Write-Output "Target OU: $TargetOU"
                Add-Content -Path "TargetOUs.txt" -Value $($SAMAccountName + "," + $TargetOU)
                break
            }
        }
    }

    Write-Output "*****************************"
}