$users = import-csv c:\ad-development\HSXP.csv

foreach ($user in $users)
{
	echo $user.username
	$name = $user.username
	Echo "Adding to HSC Citrix File Explorer"
	Add-qadgroupmember -Identity "HSC Citrix File Explorer" -Member $name
	Echo "Adding to HSC Citrix IE"
	Add-qadgroupmember -Identity "HSC Citrix IE" -Member $name
	Echo "Adding to HSC Citrix Office"
	Add-qadgroupmember -Identity "HSC Citrix Office" -Member $name

}