## Backup-ADGroupMembershipByUser.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** September 10, 2021<br>
**Server:** sysscript3<br>
**Scheduled Task:** Daily at 5:15 pm<br>
**Tested with Script Analyzer:** September 10, 2021

**Purpose:** This file backs up the AD group memberships and writes that information to a DB table in the O365 SQL instance. These are keyed off a user's SamAccountName.

**Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1

#### Version History
* **September 10, 2021** - File completed and put into production
