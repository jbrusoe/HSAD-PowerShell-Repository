Set-HSCEnvironment

#$Mailboxes = Get-Mailbox -ResultSize Unlimited | where {$_.PrimarySMTPAddress -like "*hsc.wvu.edu*"  -AND $_.PrimarySMTPAddress -notlike "*rni.*" -AND $_.PrimarySMTPAddress -notlike "*wvurni*"}
$Mailboxes = Import-Csv 2020-10-20-AllMailboxes2.csv

$Count = 0

foreach ($Mailbox in $Mailboxes)
{
	$Count++
	Write-Output "Count: $Count"

	Write-Output $("Mailbox: " + $Mailbox.Alias)
	
	Search-Mailbox -identity $Mailbox.Alias -SearchQuery 'Subject:"Re: Important Medical and Dependent Care Flexible Spending Accounts (FSA) Information" AND received:10/19/2020' -DeleteContent -Force
	
	Write-Output "`n***********************************`n"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count