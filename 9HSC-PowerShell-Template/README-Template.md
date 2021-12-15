## FileName.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** October 28, 2019<br>
**Server:** sysscript4<br>
**Scheduled Task:** Once per hour<br>
**Tested with Script Analyzer:**

**Purpose:** This file searches AD for accounts that do not have "Resource" or "EAP" in extensionAttribute10. These accounts all have their "PasswordNeverExpires" flag set to false.

**Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1

#### Version History
* **October 28, 2019** - File completed and put into production
