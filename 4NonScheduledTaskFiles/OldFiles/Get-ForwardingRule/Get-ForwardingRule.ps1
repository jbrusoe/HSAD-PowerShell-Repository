$mailboxes = Import-csv ForwardingRule.csv

foreach ($mailbox in $mailboxes)
{
	Write-Output $("Primary SMTP Address: " + $mailbox.primarySMTPAddress)
	
	$Rules = Get-InboxRule -Mailbox $mailbox.primarySMTPAddress
	
	Write-Output $("Rule Count: " + $Rules.Count)
	
	if ($Rules.Count -gt 0)
	{
		foreach ($rule in $rules)
		{
			Write-Output $("Rule Name: " + $rule.Name)
			Write-Output $("Rule Description: " + $rule.Description)
				
			if (![string]::IsNullOrEmpty($rule.ForwardTo))
			{
				Write-Output $("ForwardTo: " + $rule.ForwardTo)	
				Add-Content -Path ForwardingRules.txt -Value $($mailbox.PrimarySMTPAddress + "," + $rule.Name + "," + $rule.ForwardTo)
				
				if ($rule.ForwardTo.indexOf("@"))
				{
					$rule | Remove-InboxRule
				}
			}
			else
			{
				Write-Output "Rule is not a forwarding rule"
			}
			
		}
	}
	
	Write-Output "**********************************"
}