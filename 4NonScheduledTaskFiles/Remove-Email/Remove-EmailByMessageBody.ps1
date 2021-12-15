#$Mailboxes = Get-Mailbox -ResultSize Unlimited # | sort -#| select -last 4000

$Count = 0

#foreach ($Mailbox in $Mailboxes)
#{
	$Count++
	"Count: $Count"
	
	"Mailbox: " + $Mailbox.PrimarySMTPAddress
	
	$MessageBody = "Helo, Just found my payflex  has an ending date to spend Sept 15 instead of Nov 30. Can someone help me? Thanks. Ray"

	#Search-Mailbox -identity $Mailbox.PrimarySMTPAddress -SearchQuery 'Body:"$MessageBody"' -DeleteContent -Force
	
	"`n***********************************`n"
	#Start-Sleep -s 2
#}