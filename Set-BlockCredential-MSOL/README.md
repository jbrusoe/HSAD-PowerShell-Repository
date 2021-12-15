## Set-BlockCredential.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** May 19, 2020<br>
**Server:** sysscript4<br>
**Scheduled Task:** Every 5 minutes<br>

**Purpose:** This file uses the MSOL Office 365 cmdlets to ensure that the block credential is set to false for people who have just reset their password.

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1
* HSC-Office365Module.psm1

#### Version History
* **January 9, 2020** - Old file copied over to GitHub
* **May 20, 2020** - Modified to work with HSC common code modules
