## Set-RDPGroupsAndSettings.ps1

**Written by:** Kevin Russell<br>
**Last Updated:** March 29, 2021<br>
**Server:** SysScript4 under KevinAdmin<br>
**Scheduled Task:** Every 10 minutes<br>

**Purpose:** This file searches for new emails in the Remote Access request folder that have been sent from the Sharepoint Remote Request form.  It will see if the user and pc are in the correct AD groups and via Invoke-Command add the user to Remote Desktop Users group of that machine if they are not in it. It runs on SysScript4 under hte kevinadmin account.  It reads from krussell@hsc.wvu.edu

**Common Code Module Dependencies**<br>


#### Version History
* **April 28, 2020** - Fix the issue of remote machine having error due to not being able to execute the Get-ADGroupMember command
