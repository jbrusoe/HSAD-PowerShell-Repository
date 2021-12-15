## Disable-AccountSecurityCompliance.ps1

**Location:** sysscript4<br>
**Schedule Task:** Everyday at 7:20 am.<br>
**File Status:** Working & used in production.<br>
**Last Updated:** September 1, 2021<br>
**Checked with Script Analyzer:** September 1, 2021<br>
<br>
**Purpose:** This file reads a database table of people who should have their accounts disabled due to being out of security compliance or HIPAA training. Users in that database are then disabled (OWA/MAPI/ActiveSync Enabled set to false).

**HSC Module Requirements:**
- HSC-CommonCodeModule
- HSC-Office365Module
- HSC-SQLModule
