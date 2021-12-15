## Get-FileShareDirectory.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** October 29, 2021<br>
**Server:** sysscript5<br>
**Scheduled Task:** Daily at 5:00 am<br>
**Tested with Script Analyzer:** November 11, 2021

**Purpose:** This file logs the directories in all the file shares contained in the FileShares.csv file and was created for the AD migration project. ***This file uses PowerShell 7.***

**Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1
* PowerShell 7

#### Version History
* **October 29, 2021** - File completed and put into production
* **November 11, 2021** - CLeaned up file and got nested threading to work.
