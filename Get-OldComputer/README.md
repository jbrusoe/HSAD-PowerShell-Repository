## Get-OldComputer.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** December 4, 2020<br>
**Server:** sysscript5<br>
**Scheduled Task:** Once per day at 10:45 pm<br>
**Tested with Script Analyzer:**

**Purpose:** This file searches AD for computer objects that haven't changed their password (pwdLastSet) in over 6 months.

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1

#### Version History
* **December 4, 2020** - File completed and put into production
