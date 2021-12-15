## Export-ToSOLE.ps1

**Modified by:** Jeff Brusoe<br>
**Last Updated:** September 20, 2019<br>
**Server:** Sysscript3<br>
**Scheduled Task:** 15 minutes after the hour & 15 minutes before the hour<br>

**Purpose:** The purpose of this file is to export HS domain and Office 365 tenant information to a database table for SOLE account updates.

#### HSC Module Requirements:
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1
* HSC-SharePointModule.psm1
* HSC-SQLModule.psm1 (To do: Move to Ver2)
* HSC-Office365Module.psm1
