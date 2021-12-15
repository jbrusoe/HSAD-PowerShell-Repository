$Mailboxes = Get-Mailbox -ResultSize Unlimited # | sort -#| select -last 4000

$Count = 0

foreach ($Mailbox in $Mailboxes)
{
	$Count++
	"Count: $Count"
	
	"Mailbox: " + $Mailbox.PrimarySMTPAddress
	
	Search-Mailbox -identity $Mailbox.PrimarySMTPAddress -SearchQuery "'From:no-reply@server.profichi.com.ua' AND 'subject:Action needed'" -DeleteContent -Force
	
	"`n***********************************`n"
	#Start-Sleep -s 2
}