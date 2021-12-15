$Mailboxes = Get-Mailbox -ResultSize Unlimited | where {$_.PrimarySMTPAddress -notlike "*rni.*" -AND $_.PrimarySMTPAddress -notlike "*wvurni*" -AND $_.PrimarySMTPAddress -like "*hsc.wvu.edu*"}

$Count = 0

$Mailboxes | Select PrimarySMTPAddress | export-csv PrimarySMTPAddress.csv

return

foreach ($Mailbox in $Mailboxes)
{
	$Count++
	"Count: $Count"
	
	Write-Output $("Mailbox: " + $Mailbox.PrimarySMTPAddress)
	
	Search-Mailbox -identity $Mailbox.PrimarySMTPAddress -SearchQuery 'Subject:"WVU COVID-19 Vaccine Questionnaire"' -TargetMailbox "microsoft@hsc.wvu.edu" -TargetFolder "Inbox"
	
	"`n***********************************`n"
	Start-Sleep -s 1
}