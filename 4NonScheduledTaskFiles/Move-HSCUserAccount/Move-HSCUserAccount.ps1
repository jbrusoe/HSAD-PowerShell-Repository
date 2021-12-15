$UsersToMove = Import-Csv H23.csv

$DestinationOU = "OU=2023,OU=DH,OU=SOD Students,OU=SOD,OU=HSC,DC=hs,DC=wvu-ad,DC=wvu,DC=edu"
Get-ADOrganizationalUnit -Identity $DestinationOU

Start-Sleep -s 5

foreach ($UserToMove in $UsersToMove)
{
    Write-Output $("SamAccountName: " + $UserToMove.SamAccountName)

    $ADUser = Get-ADUser $UserToMove.SamAccountName
    Write-Output $("Source DN: " + $ADUser.DistinguishedName)

    Move-ADObject -Identity $ADUser.DistinguishedName -TargetPath $DestinationOU

    Write-Output "*******************************"
}