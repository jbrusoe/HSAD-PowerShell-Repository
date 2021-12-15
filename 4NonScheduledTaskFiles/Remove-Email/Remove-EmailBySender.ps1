
Write-Output "Generating list of mailboxes"
$Mailboxes = Get-Mailbox -ResultSize Unlimited # | sort -#| select -last 4000

$Count = 0

Write-Output "Beginning to search"
foreach ($Mailbox in $Mailboxes)
{
	$Count++
	Write-Output "Count: $Count"
	
	Write-Output $("Mailbox: " + $Mailbox.PrimarySMTPAddress)
	
	Search-Mailbox -identity $Mailbox.PrimarySMTPAddress -SearchQuery 'From:" zsanchez@guaranteedreturns.com"' -DeleteContent -Force
	
	Write-Output "`n***********************************`n"
	#Start-Sleep -s 2
}
