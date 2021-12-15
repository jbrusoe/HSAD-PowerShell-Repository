$CSVUsers = Import-Csv "UsersToMove.csv"

foreach ($CSVUser in $CSVUsers)
{
	Write-Output $("UPN: " + $CSVUser.UserPrincipalName)

    $SamAccountName = $CSVUser.UserPrincipalName.Split('@')[0]
    Write-Output $("SamAccountName: $SamAccountName")

    $LDAPFilter = "(samAccountName=$SamAccountName)"
    $ADUser = Get-ADUser -LDAPFilter $LDAPFilter

    $TargetOU = $CSVUser.TargetOU
    Write-Output "TargetOU:"
    Write-Output $TargetOU

    $DistinguishedName = $ADUser.DistinguishedName
    Write-Output "Distinguished Name:"
    Write-Output $DistinguishedName

    Move-ADObject -Identity $DistinguishedName -TargetPath $TargetOU -Verbose

    Start-Sleep -s 10
    Write-Output "*************************"
}