## Update-MailboxClutterStatusDB.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** July 26, 2021<br>
**Server:** sysscript3<br>
**Scheduled Task:** Daily at 12:15 pm<br>
**Tested with Script Analyzer:** July 26, 2021

**Purpose:** This file updates the database that records the clutter status of all Office 365 mailboxes.

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-Office365Module.psm1
* HSC-SQLModule.psm1

#### Version History
* **July 23, 2021** - File completed and put into production
* **July 26, 2021**
   * Configured file to query DB for records not updated in the past week (Issue 405)
   * Corrected an issue with the log file path (Issue 402)
