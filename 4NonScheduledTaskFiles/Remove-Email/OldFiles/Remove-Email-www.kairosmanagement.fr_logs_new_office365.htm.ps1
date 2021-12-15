$Mailboxes = Get-Mailbox -ResultSize Unlimited # | sort -#| select -last 4000

$Count = 0

foreach ($Mailbox in $Mailboxes)
{
	$Count++
	"Count: $Count"
	
	"Mailbox: " + $Mailbox.PrimarySMTPAddress
	
	Search-Mailbox -identity $Mailbox.PrimarySMTPAddress -SearchQuery 'http://www.kairosmanagement.fr/logs/new/office365.htm' -DeleteContent -Force
	
	"`n***********************************`n"
	#Start-Sleep -s 2
}