## Set-ManagerField.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** May 1, 2020<br>
**Server:** sysscript2<br>
**Scheduled Task:** Daily at 10 am<br>

**Purpose:** This file compares the value of extensionAttribute4 (the employee number of the user's manager) with the EmployeeNumber field in AD. If a match is found, then it will populate the user's manager field.

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1

#### Version History
* **May 1, 2020** - File completed and put into production
