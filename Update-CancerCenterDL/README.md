## Update-CancerCenterDL.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** August 18, 2021<br>
**Server:** sysscript3<br>
**Scheduled Task:** Daily at 10:00 am<br>
**Tested with Script Analyzer:** August 18, 2021

**Purpose:** This file is designed to generate distribution lists for the Cancer Center. It does this by querying SharePoint where users for these groups are updated (https://wvuhsc.sharepoint.com/sites/mbrcc/DL).

**Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-SharePointOnlineModule.psm1
* HSC-Office365Module.psm1

#### Version History
* **August 18, 2021** - File completed and put into production
