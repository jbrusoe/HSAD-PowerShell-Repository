$ADUsers = Get-ADUser -filter * | where {$_.DistinguishedName -like "*OU=HSC*"}

$OUArray = @()

foreach ($ADUser in $ADUsers)
{
	$ADUser | select samaccountname,distinguishedName | export-csv -Append ADUsers.csv
	
	$OU = $ADUser.DistinguishedName.substring($ADUser.DistinguishedName.indexOf("OU"))
	$OU
	
	$OUArray += $OU.toString()
}

Write-Output "********"

$OUArray

$OUArray | Select -Unique | Out-File UniqueOU.csv