$SharedUsers = Import-Csv Residents.csv

foreach ($SharedUser in $SharedUsers)
{
	$ADUser = Get-ADUser $SharedUser.SamAccountName
	Write-Output $("Current User: " + $ADUser.SamAccountName)
	$ADUser.DistinguishedName

	Write-Output "Setting LegacyExchangeDN"
	$x500 = "x500:" + $SharedUser.LegacyExchangeDN
	$ADUser | Set-ADUser -Add @{ProxyAddresses=$x500} -WhatIf
	
	Write-Output "Setting X500"
	$x500 = "x500:" + $SharedUser.x500
	$ADUser | Set-ADUser -Add @{proxyAddresses=$x500} -WhatIf
	
	Write-Output "Displaying user in address book"
	$ADUser | Set-ADUser -Replace @{msExchHideFromAddressLists=$false} -WhatIf
	
	Write-Output "Setting WVUM Email Proxy"
	$WVUMProxy = "smtp:" + $SharedUser.WVUMEmail.Trim()
	$ADUser | Set-ADUser -Add @{proxyAddresses=$WVUMProxy} -WhatIf
	
	Start-Sleep -s 2
	
	Write-Output "*******************"
}
