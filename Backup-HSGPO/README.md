## Backup-HSGPO.ps1<br>

**Location:** sysscript2<br>
**Scheduled Task:** 1am on the first of every month<br>
**File Status:** Working & used in production.<br>
**Last Updated:** July 29, 2021<br>
**Checked with PowerShell Script Analyzer** July 29, 2021

**Purpose:** This file backups up the GPOs in the HS domain. The backup is written to the \\hs.wvu-ad.wvu.edu\public\ITS\Network and Voice Services\public\Backups\GPO Backups\ directory as well as to the BackupGPO GitHub repo.

**Required Modules:**
* HSC-CommonCodeModule.psm1
* Group Policy cmdlets -  https://docs.microsoft.com/en-us/powershell/module/grouppolicy/?view=windowsserver2019-ps.
