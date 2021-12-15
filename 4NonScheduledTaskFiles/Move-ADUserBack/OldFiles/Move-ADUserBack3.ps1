$ADUsers = Import-Csv "UsersToMove.csv"

foreach ($ADUserUPN in $ADUsers)
{
    $ADUser = Get-ADUser $ADUserUPN.SamAccountName -Properties extensionAttribute7

    if ($ADUser.DistinguishedName -like "*OU=DeletedAccounts*" -AND $ADUser.extensionAttribute7 -eq "Yes365")
    {
        $ADUser | select SamAccountName,DistinguishedName | Export-Csv "CleanedUsersToMove2.csv" -Append
    }
}