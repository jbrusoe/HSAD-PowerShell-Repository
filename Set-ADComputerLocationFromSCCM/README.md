## Set-ADComputerLocationFromSCCM.ps1

**Originally Written by:** Matt Logue<br>
**Maintained by:** Jeff Brusoe
**Last Updated:** February 8, 2021<br>
**Server:** sysscript4<br>
**Scheduled Task:** Daily at 6:58 am, 11:58 am, and 4:58 pm<br>
**Tested with Script Analyzer:**

**Purpose:** Reads a log file off of the SCCM Share and set the AD Location attribute on the PC after it is imaged

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1

#### Version History
* **February 8, 2021**
  - File and directory renamed to mach
  - File updated and put into production
