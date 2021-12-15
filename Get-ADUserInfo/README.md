## Get-ADUserInfo.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** February 18, 2021<br>
**Server:** sysscript3<br>
**Scheduled Task:** Once per day at 8:30 am<br>
**Tested with Script Analyzer:** February 18, 2021<br><br>

**Purpose:** This file gets AD user accounts for things such as the total number of users, number in NewUsers, number disabled, etc. That information is written to an instance of a SQL Server in Azure.

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1
* HSC-SQLModule.psm1

**Version History**
* **March 16, 2020**
  * File Completed and put into production 
* **February 18, 2021**
  * Moved to new versions of HSC AD Modules
  * Cleaned up code
  * Fixed scheduled task
