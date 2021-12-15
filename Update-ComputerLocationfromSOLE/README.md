## Update-ComputerLocationfromSOLE.ps1

**Originally Written by:** Matt Logue<br>
**Maintained by:** Jeff Brusoe<br>
**Last Updated:** March 22, 2021<br>
**Server:** sysscript4<br>
**Scheduled Task:** Once per day<br>
**Tested with Built-in VSCode Script Analyzer:** September 29,2020<br>

**Purpose:** This file searches pulls from a SQL view from Sole BannerData database for a form submitted when a computer moves departments.  Then it updates the AD Location attribute

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1

**Module Dependencies**
* SqlServer Module
* SCCM Powershell Module (or SCCM Admin Console software installed)

#### Version History
* **September 28, 2020** - File created and SQL connection setup
* **September 29, 2020** - Error handling setup, comments added, scheduled task created and placed into production
* **February 11, 2021** - Cleaned up file and changed code to conform to HSC PS coding style
* **March 22, 2021** - Corrected error querying DB
