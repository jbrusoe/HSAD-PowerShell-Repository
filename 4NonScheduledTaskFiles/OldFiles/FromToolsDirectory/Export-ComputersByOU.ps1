
$OUs = Get-ADOrganizationalUnit -SearchBase "OU=HS Computers,DC=HS,DC=wvu-ad,DC=wvu,DC=edu" -Filter *

foreach ($OU in $OUs)
{
	$DN = $OU.DistinguishedName
	$name = $OU.Name
	$file = $Name + ".csv"
	$DN
	Get-QADComputer -SearchRoot "$OU" -SizeLimit 0 | select Name,DistinguishedName | export-csv c:\ad-development\exports\$file
	#Get-QADComputer -SearchRoot $DN
 
}