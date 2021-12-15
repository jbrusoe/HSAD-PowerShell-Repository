$users = get-qaduser -sizelimit 0

foreach ($user in $users)
{
	$ProxyAddresses = $user.ProxyAddresses
	
	if ($ProxyAddresses -contains "accounts@hsc.wvu.edu")
	{
		Write-Output $("SamAccountName: " + $user.samaccountname)
		return
	}
}