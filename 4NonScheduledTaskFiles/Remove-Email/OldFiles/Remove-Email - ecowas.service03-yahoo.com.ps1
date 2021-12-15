$Mailboxes = Get-Mailbox -ResultSize Unlimited # | sort -#| select -last 4000

$Count = 0

foreach ($Mailbox in $Mailboxes)
{
	$Count++
	"Count: $Count"
	
	"Mailbox: " + $Mailbox.PrimarySMTPAddress
	
	Search-Mailbox -identity $Mailbox.PrimarySMTPAddress -SearchQuery 'Subject:"YOUR ATTENTION IS NEEDED @ Wednesday, 07 March 2018"' -DeleteContent -Force
	
	"`n***********************************`n"
	#Start-Sleep -s 2
}