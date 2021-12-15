$Mailboxes = Get-Mailbox -ResultSize Unlimited | Sort -Descending

$Count = 0

foreach ($Mailbox in $Mailboxes)
{
	$Count++
	"Count: $Count"
	
	"Mailbox: " + $Mailbox.PrimarySMTPAddress
	
	Search-Mailbox -identity $Mailbox.PrimarySMTPAddress -SearchQuery 'Subject:"Unsecured Sign-in Detected (Action Required)"' -DeleteContent -Force
	
	"`n***********************************`n"
	#Start-Sleep -s 2
}