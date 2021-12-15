## Disable-NewUsers.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** September1, 2021<br>
**Server:** sysscript3<br>
**Scheduled Task:** Every 15 minutes<br>
**Script Analyzer:** December 21, 2020

**Purpose:** The purpose of this file is to disable all users in the NewUsers OU and move any accounts that have been there for more than 60 days out of NewUsers to the FromNewUsers OU.

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1
