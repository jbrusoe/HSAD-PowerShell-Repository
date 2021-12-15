## Remove-HSCOldComputerObject.ps1

**Written by:** Kevin Russell<br>
**Last Updated:** October 25, 2021<br>
**Server:** sysscript5<br>
**Scheduled Task:** Runs weekdays at 10:45PM<br>
**Tested with Script Analyzer: 10/27/21**

**Purpose:**  The purpose of this script is to remove stale PC object from AD.
              It searches InactiveComputers OU for machines that have not had
              their password changed or whenChanged date within the last 6 
              months and are disabled.

**Enhancement:**  Find a way to validate non-Windows machines for removal<br>
**Reported Issue:**  None

#### Version History
October 27, 2021 - File completed and put into production