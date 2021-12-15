## Import-HSCMailboxForWVUF.ps1
**Written by:** Jeff Brusoe<br>
**Last Updated:** May 20, 2021<br>
**Server:** sysscript2<br>
**Scheduled Task:** Once per day at 6:00 pm<br>
**Tested with Script Analyzer:** May 21, 2021

**Purpose: This file imports the HSC address book into the WVUF Office 365 tenant**

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-Office365Module.psm1

#### Version History
* **October 28, 2019** - File completed and put into production
* **May 21, 2021**
  * Update to conform to HSC PowerShell coding standards
  * Corrected several cosmetic errors
