## PowerShell Code Review - January 30, 2020

* Focus over the past two weeks has been on account and file cleanup issues.<br>
* Testing migration of nursing DB to Azure
* Imported WVUF addresses in HSC address book
* Kevin's hardware file

#### Account cleanup issues
  * Disable-EndAccessDate.ps1 - Testing and now in production (including account deletions)
  * Disable-NewUsers.ps1
  * Remove-OldAccount.ps1
  * Get-ADUserInfo.ps1

  ![Examples of Problem Accounts](https://raw.githubusercontent.com/jbrusoe/HSC-PowerShell-Repository/master/3PowerShell-Code-Review/2020-01-30/OldAccounts.JPG?token=AJVS7335DSNQN5QARWD2KMC6HMGDK)
  ![Get-ADUserInfo.ps1 DB](https://raw.githubusercontent.com/jbrusoe/HSC-PowerShell-Repository/master/3PowerShell-Code-Review/2020-01-30/DB.JPG?token=AJVS7362RPIUNWIYUX7DWXS6HQFQG)


#### File Cleanup Issues
  * Updated AD common code module
    * Get-PrimarySMTPAddress
    * Get-ADUserCount
