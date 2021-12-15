## Get-ADUserTokenSize.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** September 21, 2021<br>
**Server:** sysscript5<br>
**Scheduled Task:** Daily at 9pm<br>
**Tested with Script Analyzer:** September 21, 2021

**Purpose:** This calculates the token size for an AD user based on the following formula from this site - https://docs.microsoft.com/en-US/troubleshoot/windows-server/windows-security/kerberos-authentication-problems-if-user-belongs-to-groups.

![image](https://user-images.githubusercontent.com/40579055/133675256-c45eadcb-dc5a-4a22-b802-80aa94b4962d.png)


**Module Dependencies**<br>
* HSC-CommonCodeModule.psm1
* HSC-ActiveDirectoryModule.psm1

#### Version History
* **September 21, 2021** - File completed and put into production
