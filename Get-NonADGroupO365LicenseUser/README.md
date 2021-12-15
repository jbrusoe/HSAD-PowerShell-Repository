## Get-NonADGroupO365LicenseUser.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** July 6, 2021<br>
**Server:** sysscript5<br>
**Scheduled Task:** Daily at 2pm<br>
**Tested with Script Analyzer:** July 6, 2021

**Purpose:** This file searches for AD users who have Yes365 set and generates a list of those that aren't in the Office 365 Base Licensing Group.

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1

#### Version History
* **July 6, 2021** - File completed and put into production
