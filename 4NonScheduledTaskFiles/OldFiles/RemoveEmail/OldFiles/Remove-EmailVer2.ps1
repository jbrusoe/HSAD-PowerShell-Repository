$Mailboxes = Get-Mailbox -ResultSize Unlimited | select -Skip 3000

$Count = 0

foreach ($Mailbox in $Mailboxes)
{
	$Count++
	$Count
	"Mailbox: " + $Mailbox.PrimarySMTPAddress
	
	Search-Mailbox -identity $Mailbox.PrimarySMTPAddress -SearchQuery 'Subject:"Memo From HR Department"' -DeleteContent -Force
	
	Start-Sleep -s 1
	
	"****************************"
}