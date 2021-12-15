## Disable-EndAccessDate.ps1

**Written by:** Jeff Brusoe<br>
**Last Updated:** January 26, 2021<br>
**Server:** sysscript3<br>
**Scheduled Task:** Once per day at 4 am<br>
**Current Status:** This file is currently in production.<br>
**Tested with Script Analyzer:** February 2, 2021

**Purpose:** This file searches for accounts that are past their end access dates. They are then disabled based on the following schedule:<br>
1. **End Access Date = Current Date**<br>
	a. AD account is disabled<br>
	b. MAPI/OWA/ActiveSync are all disabled for mailbox<br>
	c. Set out of office reply - "The HSC account for this person is no longer active."<br>
2. **Account Disable Date + 7 days**<br>
	a. Account is hidden in the address book<br>
	b. AD account is removed from AD groups<br>
	c. Add AD groups to DB<br>
	d. Send limit to 10 kb<br>
	e. Remove user from One Drive Members groups<br>
	f. Set block credential to true (Enabled = $false with AzureAD cmdlets)<br>
3. **Account Disable Date + 30 Days**<br>
	a. extensionAttribute7 is set to "No365"<br>
	b. AD account is moved to "Deleted Accounts"<br>
	c. Move home folder to MS OneDrive<br>
4. **Account Disable Date + 60 Days**<br>
	a. Account is deleted.<br>
	
**Common Code Module Dependencies**<br>
* HSC-CommonCodeModule.psm1<br>
* HSC-ActiveDirectoryModule.psm1<br>
* HSC-Office365Module.psm1<br>
* HSC-SPOModule.psm1<br>
* HSC-SQLModule.psm1<br>

**This file requires a connection to the SQL Server instance in Office 365 (hscpowershell.database.windows.net).**
