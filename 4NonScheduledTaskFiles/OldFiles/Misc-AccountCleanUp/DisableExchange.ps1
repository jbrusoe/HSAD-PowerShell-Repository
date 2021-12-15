$users = get-mailbox -ResultSize Unlimited

foreach ($user in $users)
{
	$user.primarysmtpaddress
	$user.alias
	$MBStat = Get-MailboxStatistics $user.primarysmtpaddress
	$MBStat.LastLogonTime
	
	"********************************"
}