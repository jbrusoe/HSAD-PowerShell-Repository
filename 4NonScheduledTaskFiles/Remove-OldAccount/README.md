## Remove-OldAccount.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** February 10, 2020<br>
**Server:** Any<br>
**Scheduled Task:** Not run as a scheduled task<br>

**Purpose:** This file begins by looking for any AD user flagged as being a StandardUser (in extensionAttribute10) who also has their password last set date set to over a year ago. For these users, it will disable the account and move it to the DisabledUsersOU.<br>

**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1

#### Version History
* **February 10, 2020** - Corrected error with extensionAttribute10 output.

#### Sample Output (prior to the extensionAttribute10 fix). These users were all disabled.
![Sample Output](https://raw.githubusercontent.com/jbrusoe/HSC-PowerShell-Repository/master/3PowerShell-Code-Review/2020-02-13/ADUsers2.JPG?token=AJVS736VQRWTDLXGX3VXWAS6JL3M6)
