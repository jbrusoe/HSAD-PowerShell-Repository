$Mailboxes = Get-Mailbox -ResultSize Unlimited # | sort -#| select -last 4000

$Count = 0

foreach ($Mailbox in $Mailboxes)
{
	$Count++
	"Count: $Count"
	
	"Mailbox: " + $Mailbox.PrimarySMTPAddress
	
	Search-Mailbox -identity $Mailbox.PrimarySMTPAddress -SearchQuery "'From:admndocviadocument@dwpnow.com' AND 'subject:OneDrive: Review Document'" -DeleteContent -Force
	
	"`n***********************************`n"
	#Start-Sleep -s 2
}