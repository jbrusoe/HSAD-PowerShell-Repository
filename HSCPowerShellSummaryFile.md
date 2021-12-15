# HSC PowerShell Summary File

### PowerShell Modules
These modules contain functions which are used by the other PowerShell files listed below. See the function commments to determine who wrote and maintains that particular function. This file is also currently being updated.

| | **Module Name** | **Purpose** |
| :--- | --- | --- |
| 1. |[HSC-ActiveDirectoryModule.psm1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/1HSCCustomModules/HSC-ActiveDirectoryModule) | Provides functions to perform common AD tasks as well as ones used to connect to WVU-AD |
| 2. | [HSC-CommonCodeModule.psm1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/1HSCCustomModules/HSC-CommonCodeModule) | Has non-administrative functions that are used in most PowerShell files |
| 3. | [HSC-HelpDeskModule.psm1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/1HSCCustomModules/HSC-HelpdeskModule) | |
| 4. | [HSC-MiscFunctions.psm1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/1HSCCustomModules/HSC-MiscFunctions) | |
| 5. | [HSC-MSTeamsModule.psm1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/1HSCCustomModules/HSC-MSTeamsModule) | |
| 6. | [HSC-Office365Module.psm1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/1HSCCustomModules/HSC-Office365Module) | Has commonly used functions related to Office 365/Exchange Online.|
| 7. | [HSC-PSADHealth.psm1](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-PSADHealth/HSC-PSADHealth.psm1) | Functions used to monitor AD |
| 8. | [HSC-SharePointOnlineModule.psm1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/1HSCCustomModules/HSC-SharePointOnlineModule) | Functions used related to SharePoint online. |
| 9. | [HSC-SQLModule.psm1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/1HSCCustomModules/HSC-SQLModule) | Contains function calls so that PowerShell files can connect to and query SQL Server databases |
| 10. | [HSC-TestingModule.psm1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/1HSCCustomModules/HSC-TestingModule) | |
| 11. | [HSC_VMModule.psm1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/1HSCCustomModules/HSC-VMModule) | |
| 12. | [HSC-WindowsModule.psm1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/1HSCCustomModules/HSC-WindowsModule) | These are various functions that are designed to do tasks/get information on local workstations. |
### PowerShell Files
| | **File Name** | **Maintained By** | **Purpose** |
| :--- | --- | ---- | --- |
| 1. | [Backup-ADExtensionAttribute.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Backup-ADExtensionAttribute) | Jeff Brusoe | Writes a backup of the AD extension attributes for all users to a CSV file |
| 2. | [Backup-ADGroupMembershipByGroupName.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Backup-ADGroupMembershipByGroupName) | Jeff Brusoe | Writes AD group membership information to the O365 SQL instance based on group name |
| 3. | [Backup-ADGroupMembershipByUser.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Backup-ADGroupMembershipByUser) | Jeff Brusoe | Writes AD group membership information to the O365 SQL instance based on user name |
| 4. | [Backup-FileWVU.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Backup-FileWVU) | Jeff Brusoe | Backs up ps1 files in GitHub and AD-Development directories |
| 5. | [Backup-HSADProxyAddress.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Backup-HSADProxyAddress) | Jeff Brusoe | Backups up the HS AD proxy addresses for all users in domain |
| 6. | [Backup-HSADUserOrgUnit.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Backup-HSADUserOrgUnit) | Jeff Brusoe | Backs up the org units for all HS domain users |
| 7. | [Backup-HSGPO.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Backup-HSGPO) | Jeff Brusoe | Backs up HS AD GPO objects |
| 8. | ***[Backup-O365ProxyAddress.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Backup-O365ProxyAddress)*** | Jeff Brusoe | Backs up the proxy addresses from Office 365 |
| 9. | ***[Backup-WVUMProxyAddress.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Backup-WVUMProxyAddress)*** | Jeff Brusoe | Makes a backup of the proxyAddress field from the WVUM AD domains |
| 10. | [Compare-Ext15WithPrimarySMTPAddress.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Compare-Ext15WithPrimarySMTPAddress) | Jeff Brusoe | Compares extensionAttribute15 wtih the primary SMTP address and the AD mail attribute field |
| 11. | ***[Compare-SharedUserFile.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Compare-SharedUserFile)*** | Kevin Russell | Compares the daily shared user file with the previous days and if there is a change the removed users are emailed to Michele/Jackie/CindyB.
| 12. | Confirm-ValidCertificate.ps1 | Jeff Brusoe | Currently being developed |
| 13. | [Create-NewAccount.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Create-NewAccount) | Jeff Brusoe | Creates new accounts with SailPoint system |
| 14. | [Disable-AccountSecurityCompliance.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Disable-AccountSecurityCompliance) | Jeff Brusoe | This file looks at a SOLE database table for a list of users that are out of security compliance. They are disabled if found in that table. |
| 15. | [Disable-EndAccessDate.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Disable-EndAccessDate) | Jeff Brusoe | Looks at extensionAttribute1 where SailPoint writes the users end access date. If that has passed, the HSC account deprovisioning process will be started.|
| 16. | [Disable-NewUsers.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/Disable-NewUsers) | Jeff Brusoe | This file disables all accounts in NewUsers and moves any that have been there for more than 60 days to the FromNewusers OU. |
| 17. | ***[Disable-POPIMAP.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Disable-POPIMAP)*** | Jeff Brusoe | Sets the POPEnabled and IMAPEnabled flags to false for all mailboxes |
| 18. | [Enable-AccountAfterPasswordReset.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Enable-AccountAfterPasswordReset) | Jeff Brusoe | Ensures that accounts are enabled after a successful password reset |
| 19. | [Enable-AccountSecurityCompliance.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Enable-AccountSecurityCompliance) | Jeff Brusoe | Checks for any new users who have completed security awareness training and enables their account if any are found |
| 20. | [Export-ToSOLE.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Export-ToSole) | Jeff Brusoe | The purpose of this file is to export HS domain and Office 365 tenant information to a database table for SOLE account updates. |
| 21. | [Get-ADComputerInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADComputerInfoForMigration) | Jeff Brusoe | Used to collect AD computer info for migration project |
| 22. | [Get-ADEmptyGroup](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADEmptyGroup) | Jeff Brusoe | Logs groups that are empty for the AD migration project |
| 23. | [Get-ADGroupInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADGroupInfoForMigration) | Jeff Brusoe | Used to collect AD computer info for migration project |
| 24. | [Get-ADGroupMemberCount.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADGroupMemberCount) | Jeff Brusoe | Logs the number of users in AD groups |
| 25. | [Get-ADGDroupMembershipNoRecursion.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADGroupMembershipNoRecursion) | Jeff Brusoe | Gets AD group membership but lists groups instead of recursively searching for users |
| 26. | [Get-ADObjectCount.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADObjectCount) | Jeff Brusoe | Gets a daily count of all AD object types |
| 27. | [Get-ADUserInfo.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserInfo) | Jeff Brusoe | Records summary information about AD User totals into a SQL instance in Azure |
| 28. | [Get-ADUserInfoForMigration,ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserInfoForMigration) | Jeff Brusoe | Records data requested for the AD migration project |
| 29. | [Get-ADuserSPN](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserSPN) | Jeff Brusoe | Backs up the AD user SPN for the AD migration project |
| 30. | [Get-ADUserTokenSize](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserTokenSize) | Jeff Brusoe | Calculates the token size for AD users |
| 31. | [Get-AllADUserObjectInfo.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-AllADUserObjectInfo) | Jeff Brusoe | Backs up all attributes for all HS domain accounts |
| 32. | [Get-DFSInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-DFSInfoForMigration) | Jeff Brusoe | Gets DFS information needed to be logged for the AD migration project |
| 33. | [Get-DisabledUser.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-DisabledUser) | Jeff Brusoe | This file creates a log of all AD disabled users. It will be used to help clean up old AD accounts. |
| 34. | ***[Get-ExchangeForwardingRule.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ExchangeForwardingRule)*** | Jeff Brusoe | Logs all Office 365 Exchange forwarding rules | 
| 35. | ***[Get-ExchangeForwardingSMTPAddress.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ExchangeForwardingSMTPAddress)*** | Jeff Brusoe | Logs all Exchange forwarding SMTP addresses |
| 36. | [Get-FileShareACL.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-FileShareACL) | Jeff Brusoe | Gets the ACLs for file shares needed for the AD migration project |
| 37. | [Get-FileShareDirectory.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-FileShareDirectory) | Jeff Brusoe | Creates a list of all directories in the various file shares for the AD migration project |
| 38. | [Get-FileShareICACLS.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-FileShareICACLS) | Jeff Brusoe | Uses icacls.exe to generate the backup for the directory permissions needed for the AD migration project |
| 39. | [Get-FileShareSummaryInfo.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-FileShareSummaryInfo) | Jeff Brusoe | Gets a summary of all the file shares and their permissions for the AD migration project |
| 40. | ***[Get-HSCMailboxForWVUF.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-HSCMailboxForWVUF)*** | Jeff Brusoe | Creates a cleaned copy (hsc.wvu.edu email only, remove test accounts, etc.) to send to the WVU Foundation |
| 41. | [Get-HSCOffice365MailboxStatus.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-HSCOffice365MailboxStatus) | Jeff Brusoe | This file generates a list of mailboxes in Office 365 that are enabled. It is used to help speed up the Export-ToSOLE.ps1 file. |
| 42. | [Get-IDFScanAutomation.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-IDFScanAutomation)| Matt Logue | Reads IDF reports from the IDF mailbox, saves to security services share, creates pivot table xlsx report which is then uploaded to sharepoint with script on the sharepoint nodes |
| 43. | [Get-MainCampusMailbox.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-MainCampusMailbox) | Jeff Brusoe | This file accesses the main campus Office 365 tenant and creates a file that is imported to the HSC address book. |
| 44. | [Get-NonADGroupO365LicenseUser.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-HSCOffice365MailboxStatus) | Jeff Brusoe | searches for AD users who have Yes365 set and generates a list of those that aren't in the Office 365 Base Licensing Group |
| 45. | [Get-OldComputer.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-OldComputer) | Jeff Brusoe | Searches for any AD computer objects that haven't changed their password in over 6 months |
| 46. | [Get-RRQuarantineMessage.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-RRQuarantineMessage) | Jeff Brusoe | Sends an email to Ray Raylman with a list of the messages he has received which are in quarantine |
| 47. | [Get-SANEncryptionKey.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-SANEncryptionKey) | Jeff Brusoe | This file backs up the SAN encryption key. |
| 48. | [Get-SCCMEmailLogOSD.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-SCCMEmailLogOSD) | Matt Logue | This pulls log data from SCCM share and emails helpdesk the details of the imaged machine |
| 49. | Get-SharedPrinterInfoForADMigration.ps1 | Kevin Russell | This script gets shared printer info that will be used for the HS to HSAD migration.  It will be running as a scheduled task on Sysscript5.|
| 50. | Get-StartUpInfoForADMigration.ps1 | Kevin Russell | This will run as a startup script in a GPO.  It captures LastBootTime, All Printer, TCP/IP Printers, All Network Drives, Manually Mapped Drives|
| 51. | [Get-UpcomingDisabledAccount.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-UpcomingDisabledAccount) | Jeff Brusoe | This file sends out a daily email listing which accounts will be disabled over the next week |
| 52. | [Get-UserInfo.ps1(Orphan tool)](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-UserInfo(Orphan%20Tool))| Kevin Russell | Gets relevent WVU/HS/WVUH AD info as well as SCCM and Bitlocker. This is the Orphan Tool. |
| 53. | [Get-WVUFAddressBook.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-WVUFAddressBook) | Jeff Brusoe | File is designed to log into the WVUF Office 365 tenant and download their address book for import |
| 54. | ***[Get-WVUMExt13.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-WVUMExt13)*** | Jeff Brusoe | Logs values for WVUM's extensionAttribute13 |
| 55. | [Import-HSCMailboxForWVUF.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Import-HSCMailboxForWVUF) | Jeff Brusoe | This files connects to the WVU Foundation's tenant and import the HSC address book there |
| 56. | [Import-MainCampusMailbox.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Import-MainCampusMailbox)  | Jeff Brusoe | This file updates the HSC Office 365 tenant with contact information from the main campus. |
| 57. | [Import-WVUFAddressBook.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Import-WVUFAddressBook) | Jeff Brusoe | Imports the WVU Foundation's address book into the HSC address book |
| 58. | [Import-WVUMExt13.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Import-WVUMExt13) | Jeff Brusoe | Writes the value of WVUM's extensionAttribute13 to that attribute in the HS Domain |
| 59. | Move-DeptOfMedUser.ps1 | Jeff Brusoe | This file completes the configuration of Department of Medicine users since the granular department structure isn't sent over from SailPoint.  |
| 60. | Move-HSCStaleComputerObject.ps1 | Kevin Russell  | |
| 65. | [Remove-AzureADUserFromLocalAdminGroup.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Remove-AzureADUserFromLocalAdminGroup) | Jeff Brusoe | This file removes AzureAD users from a local admin group. |
| 66. | ***[Remove-ExchangeForwardingRuleRandom.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Remove-ExchangeForwardingRuleRandom)*** | Jeff Brusoe | Randomly selects mailboxes to search for unapproved forwarding rules |
| 67. | ***[Remove-ForwardingSMTPAddress.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Remove-ForwardingSMTPAddress)*** | Jeff Brusoe | This file removes non @hsc.wvu.edu forwarding email addresses. |
| 68. | ***[Remove-HospitalHIPAATraining.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Remove-HospitalHIPAATraining)*** | Jeff Brusoe | Removes the hospital's HIPAA training attribute (ext14) |
| 69. | Remove-HSCStaleComputerObject.ps1 | Kevin Russell | |
| 70. | [Send-IDFReportsToSharepoint.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-IDFScanAutomation) | Matt Logue | File uploads IDF/Spirion reports to Sharepoint online |
| 71. | ***[Send-SharedUserUpdateToWVUM](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Send-SharedUserUpdateToWVUM)*** | Jeff Brusoe | Sends email addresses for shared users back to the WVUM Office 365 administrators |
| 72. | [Set-ADComputerLocationFromSCCM.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-ADComputerLocationFromSCCM) | Jeff Brusoe | Reads a log file off of the SCCM Share and set the AD Location attribute on the PC after it is imaged |
| 73. | [Set-ADMailAttribute.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/Set-ADMailAttribute/Set-ADMailAttribute.ps1) | Jeff Brusoe | The purpose of this file is to copy the primary SMTP address over to the mail attribute field in AD |
| 74. | [Set-BlockCredential.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-BlockCredential) | Jeff Brusoe | Sets the MSOL BlockCredential field to false after a password reset |
| 75. | [Set-ChromeeRegMembership.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-ChromeeRegMemberhip) | Kevin Russell | This file adds users to the RDSH Chrome eReg group if the user is in the CTRU OU and have a department of SOM Clinical Research Trials L4 or HSC Clinical and Translational Science L3 and a job title of Sposor Monitor or Senior CRA |
| 76. | [Set-CorrectEmailAddress.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-CorrectEmailAddress) | Jeff Brusoe | This file cleans up the mail attribute for people who had no.email@wvu.edu set by SailPoint. |
| 77. | ***[Set-HospitallHIPAATraining.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-HospitalHIPAATraining)*** | Jeff Brusoe | Sets attribute to indicate user takes WVUM HIPAA training |
| 78. | [Set-MailContactCompanyField.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-MailContactCompanyField) | Jeff Brusoe | Ensures that the "CompanyName" field is populated in Office 365 for MSOL mail contacts |
| 79. | [Set-MainCampusSIPAddress.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-MainCampusSIPAddress) | Jeff Brusoe | This file sets the SIP address for the main campus contacts that are imported to the HSC address book. |
| 80. | [Set-ManagerField.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-ManagerField) | Jeff Brusoe | Sets the manager field in AD. This is done by comparing the EmployeeNumber field to extensionAttribute4 (the manager's employee number) |
| 81. | [Set-ManualRole.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-ManualRole) | Jeff Brusoe | This file ensures that manual role users are in the DUO MFA group |
| 82. | [Set-PasswordExpires.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-PasswordExpires) | Jeff Brusoe | Set non-resource AD accounts to ensure their passwords expire |
| 83. | [Set-PasswordRequired.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-PasswordRequired) | Jeff Brusoe | This file ensures that all user accounts are set to require a password. |
| 84. | [Set-RDPGroupAndSetting.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-RDPGroupsAndSettings) | Kevin Russell | This file searches for new emails in the Remote Access request folder that have been sent from the Sharepoint Remote Request form. It will see if the user and pc are in the correct AD groups and via Invoke-Command add the user to Remote Desktop Users group of that machine if they are not in it. |
| 85. | [Set-StandardUserAccount.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Set-StandardUserAccount) | Jeff Brusoe | This file sets extensionAttribute10 to be standard user for accounts in OUs such as NewUsers. See the SearchBaseArray to see a list of all OUs. |
| 86. | [Update-AddressList.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Update-AddressList) | Jeff Brusoe | Ensures that address lists between the HSC and hospital are updated properly. |
| 87. | [Update-CancerCenterDL.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Update-CancerCenterDL) | Jeff Brusoe | Updates distributions lists from the Cancer Center |
| 88. | [Update-ComputerLocationfromSOLE.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Update-ComputerLocationfromSOLE) | Jeff Brusoe | Reads a form submitted on SOLE for computer moves to update AD location attribute |
| 89. | Update-MailboxClutterStatusDB.ps1 | Jeff Brusoe | |
| 90. | ***[Update-SharedUserDB.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Update-SharedUserDB)*** | Jeff Brusoe | Writes the daily shared user CSV file to a database table |
| 91. | ***[Update-SharedUserDistributionList.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Update-SharedUserDistributionList)*** | Kevin Russell | Updates the All Users email list to include shared users |

Files in bold and italics are ones that have the potential to impact WVUM accounts in the tenant.
