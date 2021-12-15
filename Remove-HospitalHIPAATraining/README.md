## Remove-HospitalHIPAATraining.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** May 24, 2021<br>
**Server:** sysscript5<br>
**Scheduled Task:** Daily at 11:45 am<br>
**Tested with Script Analyzer:**

**Purpose:** This file searches AD for users that have HospitalHIPAA set in extensionAttribute14. If they are not currently in the file sent daily by the hospital, then that field is cleared to indicate that they no longer are covered by the hospital's HIPAA training. 

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1

#### Version History
* **March 17, 2021** - File completed and put into production
* **May 24, 2021** - Minor code cleanup & Pointed source file path to Common Files directory
