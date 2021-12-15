$Mailboxes = Import-csv AllMailboxes12.csv # = Get-Mailbox -ResultSize Unlimited

foreach ($Mailbox in $Mailboxes)
{
	"Mailbox: " + $Mailbox.PrimarySMTPAddress
	
	Search-Mailbox -identity $Mailbox.PrimarySMTPAddress -SearchQuery 'Subject:"Memo From HR Department"' -DeleteContent -Force
}