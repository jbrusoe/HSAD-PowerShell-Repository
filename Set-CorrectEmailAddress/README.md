## Set-CorrectEmailAddress.ps1

Written by: Jeff Brusoe<br>
Last Updated: December 15, 2020<br>
Server: sysscript3<br>
Scheduled Task: Once per day at 8:00 am<br>
Script Analyzer: December 15, 2020<br>
Log Files: [https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-CorrectEmailAddress/Logs](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-CorrectEmailAddress/Logs)<br>
<br>

Purpose: This file cleans up the mail attribute for people who had no.email@wvu.edu set by SailPoint. It uses the following algorithm to accomplish this:
* Search AD proxy addresses for a primary SMTP address (start with SMTP:)
* If no primary SMTP address is found, looks in extensionAttribute6 (Employee/Hospital/HIPAA) to set the address based on this.
  * Employee: SamAccountName@hsc.wvu.edu
  * Hospital: SamAccountName@wvumedicine.org
  * Student: SamAccountName@mix.wvu.edu
* If the mail attribute can't be set by the previous steps, it will be populated with the AD UPN.
