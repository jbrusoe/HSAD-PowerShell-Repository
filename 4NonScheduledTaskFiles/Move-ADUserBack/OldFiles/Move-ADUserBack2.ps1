[CmdletBinding()]
param()

$ADUsers = Get-ADUser -Filter * -Properties extensionAttribute1,memberOf |
                Where-Object {$_.extensionAttribute1 -eq "07/29/2021"}
$UserCount = 0
foreach ($ADUser in $ADUsers)
{
    Write-Output $("Current AD User: " + $ADUser.SamAccountName)
    Write-Output $("Distinguished Name: ")
    Write-Output $ADUser.DistinguishedName
    Write-Output "User Count: $UserCount"
    $UserCount++

    $ADUser | Enable-ADAccount
    
    Write-Output "*****************************"
}