## Remove-ExchangeForwardingRuleRandom.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** October 7, 2020<br>
**Server:** sysscript2<br>
**Scheduled Task:** Every 3 hours<br>
**Script Analyzer:** October 7, 2020<br>

**Purpose:** This file removed mail forwarding rules from mailboxes. Because of the number of mailboxes, it works in conjunction with Remove-ExchangeForwardingRule.ps1 and randomly selects mailboxes to look at.

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-Office365Module.psm1

#### Version History
* **October 7, 2020** - Modified Remove-ExchangeForwardingRule.ps1 to randomly select mailbox and put into production.
