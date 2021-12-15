#$Mailboxes = Get-Mailbox -ResultSize Unlimited | where {$_.PrimarySMTPAddress -notlike "*rni.*" -AND $_.PrimarySMTPAddress -notlike "*wvurni*" -AND $_.PrimarySMTPAddress -like "*hsc.wvu.edu*"}
#$Mailboxes | Select PrimarySMTPAddress | export-csv PrimarySMTPAddress.csv

$Count = 0
$Mailboxes = Import-Csv "wvumedicine.csv"

foreach ($Mailbox in $Mailboxes)
{
	$Count++
	"Count: $Count"
	
	Write-Output $("Mailbox: " + $Mailbox.mail)
	
	Search-Mailbox -identity $Mailbox.mail -SearchQuery 'Subject:"WVU COVID-19 Vaccine Questionnaire"' -TargetMailbox "microsoft@hsc.wvu.edu" -TargetFolder "Inbox"
	
	Write-Output "`n***********************************`n"
	Start-Sleep -s 1
}