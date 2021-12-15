## HSC-ActiveDirectoryModule.psm1

**Written by:** Jeff Brusoe<br>
**Last Updated:** March 10, 2021<br>
**Tested with Script Analyzer:** February 19, 2021

**Purpose:** This is a module containing commonly used HSC AD functions. Functions in the module include:
1. Add-HSCADOrgUnitToGroup
2. Add-HSCADUserProxyAddress
3. Get-HSCADUserCount
4. Get-HSCADUserFromString
5. Get-HSCADUserParentContainer
6. Get-HSCDirectoryMapping
7. Get-HSCLoggedOnUser
8. Get-HSCPrimarySMTPAddress
9. Send-HSCNewAccountEmail
10. Set-HSCADUserAddressBookVisibility
11. Set-HSCGroupMembership
12. Set-HSCPasswordRequired
13. Test-HSCADModuleLoaded
14. Test-HSCADOrgUnit

**Other HSC Module Dependencies**<br>
* HSC-CommonCodeModule.psm1

#### Version History
* **October 15, 2020** - File completed and put into production
* **February 19, 2021**
  * Tested with Script Analyzer
  * Began writing Pester tests
  * Minor code cleanup
* **March 10, 2021**
  * Wrote Set-HSCADUserAddressBookVisibility
