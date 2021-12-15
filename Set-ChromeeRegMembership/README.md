## Set-ChromeeRegMembership.ps1

**Written by:** Kevin Russell<br>
**Last Updated:** June 24, 2021<br>
**Server:** sysscript4<br>
**Scheduled Task:** Every 15 minutes<br>
**Tested with Script Analyzer:** 

**Purpose:** The purpose of this file is to run as a scheduled task which
            checks the CTRU OU for any user with a department name of SOM 
            Clinical Research Trials L4 or HSC Clinical and Translational 
            Science L3 and a job title of Sponsor Monitor or Senior CRA.

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1

#### Version History
* **June 10, 2021** - File completed and put into production

