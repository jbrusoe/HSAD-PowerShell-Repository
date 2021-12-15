## Create-NewAccount.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** August 18, 2021<br>
**Server:** sysscript4<br>
**Scheduled Task:** Every 15 minutes<br>
**Tested with Script Analyzer:** August 18, 2021

**Purpose:** This file is used to create HS domain and Office 365 accounts for users without needing a CSC request form filled out. Access to the [department mapping file](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/2CommonFiles/MappingFiles) is **required** in order for this file to run.

**Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1

#### Version History
* **January 12, 2021** - File completed and put into production
* **June 4, 2021** - Corrected various errors wtih file and put into production
* **August 18, 2021** - Corrected minor errors in program output
