$users = get-mailbox -resultsize unlimited

foreach ($user in $users)
{
	get-mailboxstatistics $user.primarysmtpaddress
	
	$Output = $user.primarysmtpaddress + "," + (get-mailboxstatistics $user.primarysmtpaddress).LastLogonTime
	
	Add-Content "ExchangeUser.csv" -value $Output
}