## Get-HSCMailboxForWVUF.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** August 14, 2020<br>
**Server:** sysscript2<br>
**Scheduled Task:** Daily at 5:05 am<br>

**Purpose:** The purpose of this file is to export the HSC address book so that it can be imported into the tenant of the WVU Foundation. The file is emailed to them after it is generated.

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-Office65Module.psm1

#### Version History
* **May 21, 2020** - Moved to common code modules and finished testing with them
* **August 14, 2020** - Moved to newer versions of common code modules, cleaned up code, and moved to V2 of the Exchange cmdlets
