## WVU HSC Account Disable Process

The process to disable AD user accounts at the HSC involves four separate processes. These include the following files:
1. Disable-EndAccessDate.ps1
2. Disable-NewUsers.ps1
3. Remove-OldAccount.ps1
4. Remove-UserHomeDirectory.ps1

The first two are automated, but the 3rd and 4th both are manually run.

### [Disable-EndAccessDate.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Disable-EndAccessDate)
The purpose of this file is to look through the end access dates(extensionAttribute1) of all AD users to see if the end access date has passed. It runs once per day at 4am. If it finds an account that needs to be disabled, then the following process is performed:
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
	f. Set block credential to true<br>
3. **Account Disable Date + 30 Days**<br>
	a. extensionAttribute7 is set to "No365"<br>
	b. AD account is moved to "Deleted Accounts"<br>
	c. Move home folder to MS OneDrive<br>
4. **Account Disable Date + 60 Days**<br>
	a. Account is deleted.<br>

### [Disable-NewUsers.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Disable-NewUsers)
This file does the following to accounts that are (or were) in the NewUsers org unit:
1. Disables all accounts in the NewUsers and FromNewUsers org units.
2. Moves any users in NewUsers that have been there for more than 60 days to FromNewUsers.
3. Disable users in *OU=DisabledDueToInactivity2,OU=Inactive Accounts,DC=HS,DC=wvu-ad,DC=wvu,DC=edu*
   - This is the destination for Remove-OldAccount.ps1
4. Delete users created over 90 days ago.

This file runs every 10 minutes on sysscript3.

### [Remove-OldAccount.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Remove-OldAccount)
This is a file which is run manually to search for users that haven't changed their password in over a year. Get-ADUser is piped into the following where clause:

![Remove-OldAccount0](https://raw.githubusercontent.com/jbrusoe/HSC-PowerShell-Repository/master/3PowerShell-Code-Review/OldFiiles/2020-02-13/Remove-OldAccount-0.JPG?token=AJVS736P6FM2UHRV6I6VQX265STVY)
![Remove-OldAccount1](https://raw.githubusercontent.com/jbrusoe/HSC-PowerShell-Repository/master/3PowerShell-Code-Review/OldFiiles/2020-02-13/Remove-OldAccount-1a.JPG?token=AJVS7336J3BIFOR6AGHKAYK65STYG)
![Remove-OldAccount2](https://raw.githubusercontent.com/jbrusoe/HSC-PowerShell-Repository/master/3PowerShell-Code-Review/OldFiiles/2020-02-13/Remove-OldAccount-2.JPG?token=AJVS73524R5CKSAPTRMOH2C65STZS)

Once these users are identified, they are moved to this OU: *OU=DisabledDueToInactivity2,OU=Inactive Accounts,DC=HS,DC=wvu-ad,DC=wvu,DC=edu*

### [Remove-UserHomeDirectory.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Remove-OldHomeDirectory)
This file is currently being developed
