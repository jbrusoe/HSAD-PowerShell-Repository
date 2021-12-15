## Get-MainCampusMailbox.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** December 18, 2020<br>
**Server:** sysscript2<br>
**Scheduled Task:** Daily at 5am<br>
**Tested with Script Analyzer:** December 18, 2020

**Purpose:** This file gets a list of mailboxes from the WVU main campus Office 365 tenant. These are then imported as contacts into the HSC Office 365 tenant.

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1

#### Version History
* **February 4, 2020**
  - Moved to GitHub directory
  - Began working on file cleanup to use new common code
  
* **August 18, 2020**
   - Migrated to new HSC modules to use Connect-MainCampusExchangeOnline
   - Migrated to Exchange V2 cmdlets
   - Modified attributes to pull ones supplied by Get-EXORecipient
   
 * **December 18, 2020**
    - Made changes to code to comply with HSC PowerShell coding standards
