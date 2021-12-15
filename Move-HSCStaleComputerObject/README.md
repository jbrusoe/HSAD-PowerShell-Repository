## Move-HSCOldComputerObject.ps1

**Written by:** Kevin Russell<br>
**Last Updated:** October 25, 2021<br>
**Server:** SysScript5<br>
**Scheduled Task:** Runs Weekdays at 10:25PM<br>
**Tested with Script Analyzer: 10/27/2021**

**Purpose:**  The purpose of this script is to move stale PC objects to the
              Inactive Computers OU in AD.  It searches HSComputers OU for
              machines that have not had their password changed within the
              last year and are Windows OS.  They will then be disabled and
              moved to a OU named the current date under Inactive Computers 

**Enhancement:**  Find a way to validate non-Windows machines and servers for move.<br>
**Reported Issue:**  None

#### Version History
