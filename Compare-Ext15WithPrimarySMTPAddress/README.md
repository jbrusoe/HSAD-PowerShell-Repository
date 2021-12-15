## Compare-Ext15WithPrimarySMTPAddress.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** August 10, 2020<br>
**Server:** sysscript5<br>
**Scheduled Task:** Daily at 10:30 am<br>
**Tested with Script Analyzer:** August 10, 2020

**Purpose:** This file gets the value from extensionAttribute15 (which should be the primary SMTP address email prefix) and generates a report by comparing it to the AD mail attribute and the primary SMTP address obtained from the proxyAddresses field.

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1

#### Version History
* **August 10, 2020** - File completed and put into production
