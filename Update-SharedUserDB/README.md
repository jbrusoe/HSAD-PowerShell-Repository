## Update-SharedUserDB.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** October 5, 2020<br>
**Server:** sysscript4<br>
**Scheduled Task:** Daily at 10am<br>
**Tested with Script Analyzer:** October 8, 2020

**Purpose:** This file writes the shared user file which is sent from the hospital to a DB table in the HSC O365 SQL instance.

**Common Code Module Dependencies**<br>
* HSC-SQLModule.psm1
* HSC-CommonCodeModule.psm1

#### Version History
* **October 5, 2020** - File completed and put into production
* **October 8, 2020** - Added code to remove db entries before updating new ones.
