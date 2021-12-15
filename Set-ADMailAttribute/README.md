## Set-ADMailAttribute.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** March 9, 2021<br>
**Server:** sysscript4<br>
**Scheduled Task:** Daily at 10 am<br>
**Tested with Script Analyzer:** March 9, 2021

**Purpose:** The purpose of this file is to copy the primary SMTP address over to the mail attribute field in AD.

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1

#### Version History
* **May 12, 2020** - File completed and put into production
* **March 9, 2021**
  * Updated to use new HSC PS modules
  * Cleaned up code to conform with HSC PS Coding Standards
