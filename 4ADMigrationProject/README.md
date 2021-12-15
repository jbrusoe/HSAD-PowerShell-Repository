# AD Information for Migration Project

## User Information

| | Data to Collect | Location of Collected Data | PowerShell File | Output Verified |
| :--- | ------------- | -------- | ------- | ---- |
| 1. | Initial Count | HSC Azure SQL Instance | [Get-ADUserInfo.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserInfo)| Yes |
| 2. | adminCount Attribute Value | Network Log Directory | [Get-ADUserInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserInfoForMigration) | Yes |
| 3. | extensionAttributes | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Backup-ADExtensionAttribute.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Backup-ADExtensionAttribute) | Yes  |
| 4. | Ongoing count for growth projections | HSC Azure SQL Instance | [Get-ADUserInfo.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserInfo) | Yes |
| 5. | User Parent OU |  [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Backup-HSADUserOrgUnit.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Backup-HSADUserOrgUnit) | Yes |
| 6. | Disbled/Enabled Status | Network Log Directory | [Get-ADUserInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserInfoForMigration) | Yes |
| 7. | Password Information | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-ADUserInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserInfoForMigration) | Yes |
| 8. | Account Lock Status | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-ADUserInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserInfoForMigration) | Yes |
| 9. | Service Delegations | Not Collected | |
| 10. | Fine grained Password Policies Applied | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-ADUserInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserInfoForMigration) | Yes |
| 11. | Group Memberships | HSC Azure SQL Instance and [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Backup-ADGroupMembershipByGroupName.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Backup-ADGroupMembershipByGroupName), [Backup-ADGroupMembershipByUser.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Backup-ADGroupMembershipByUser), and  [Get-ADUserInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserInfoForMigration) | |
| 12. | SIDs & SID History | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-ADUserInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserInfoForMigration) | Yes |
| 13. | Service Principal Names | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-ADUserSPN.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserSPN) | Yes  |
| 14. | Token Size | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-ADUserTokenSize.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADUserTokenSize) | Yes |
| 15. | Service Accounts | | |
| 16. | All user object info backup | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-AllADUserObjectInfo.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-AllADUserObjectInfo) |  |

## Computer Information
| | Data to Collect | Location of Collected Data | PowerShell File | Output Verified |
| :--- | ------------- | -------- | ------- |  ---- |
| 1. | OS Information | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-ADComputerInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADComputerInfoForMigration) | Yes |
| 2. | Custom Attribute Values | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-ADComputerInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADComputerInfoForMigration) | Yes |
| 3. | Drive mappings not defined by GPO | Classfiles Share | [Get-StartUpInfoForADMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-StartUpInfoForADMigration) | Yes |
| 4. | Total Computer Objects | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-ADComputerInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADComputerInfoForMigration) | Yes |
| 5. | Disabled/Enabled Status | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-ADComputerInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADComputerInfoForMigration) | Yes |
| 6. | Last Authentication to domain | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-StartUpInfoForADMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-StartUpInfoForADMigration) | Yes |
| 7. | Last Reboot | Classfiles Share | [Get-StartUpInfoForADMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-StartUpInfoForADMigration) | Yes |
| 8 | Service Delegations | Not collected |
| 9. | Group memberships including cross forest/cross domain | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-ADComputerInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADComputerInfoForMigration) |  |
| 10. | Password Last Changed | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-ADComputerInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADComputerInfoForMigration) | Yes |
| 11. | SPN | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-ADComputerInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADComputerInfoForMigration) | Yes |
| 12. | All Computer Object Info | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-ADComputerInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADComputerInfoForMigration) | Yes |

## Groups
| | Data to Collect | Location of Collected Data | PowerShell File | Output Verfied |
| :--- | ------------- | -------- | ------- |  ---- |
| 1. | Used by/sourced from M365/AAD | Not Collected | |
| 2. | Empty | Network File Share | [Get-ADEmptyGroup.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADEmptyGroup) | Yes |
| 3. | Similar | Not Collected | |
| 4. | Source OU | Network File Share | [Get-ADGroupInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADGroupInfoForMigration) | Yes |
| 5. | Nested (including circular nested) | [HSC Log File Repo](https://github.com/jbrusoe/HSC-Logs) | [Get-ADGroupMembershipNoRecursion.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADGroupMembershipNoRecursion) |  |
| 6. | Global/Universal/Local Security Groups | Network File Share | [Get-ADGroupInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADGroupInfoForMigration) | Yes |
| 7. | SIDs & SID History | Network File Share | [Get-ADGroupInfoForMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-ADGroupInfoForMigration) | Yes |
| 8. | Distribution Groups (if any) | Not collected | |

## Fileshares
| | Data to Collect | Location of Collected Data | PowerShell File | Output Verified |
| :--- | ------------- | -------- | ------- | ---- |
| 1. | Share Permissions | | [Get-FileShareInfoForADMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-FileShareInfoForADMigration) | |
| 2. | Filesystem Permissions - Top Level | Network File Share | [Get-FileShareACL.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-FileShareACL) | Yes |
| 3. | Filesystem Permissions - Child directory/objects (not inherited) | Network File Share | [Get-FileShareACL.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-FileShareACL) | Yes |
| 4. | Ownership (Not Inherited) | | | |
| 5. | Directory List | Network File Share | [Get-FileShareDirectory.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-FileShareDirectory) | Yes |

## Shared Printers
| | Data to Collect | Location of Collected Data | PowerShell File | Output Verfied |
| :--- | ------------- | -------- | ------- | --- |
| 1. | Share/access permissions (if different from authenticated users) | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-SharedPrinterInfoForADMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-SharedPrinterInfoForADMigration) | Yes |
| 2. | Mappings not "pushed" | Classfiles Share | [Get-StartUpInfoForADMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-StartUpInfoForADMigration) | Yes |
| 3. | Client Default Printers (If not pushed) | Classfiles Share | [Get-StartUpInfoForADMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-StartUpInfoForADMigration) | Yes |
| 4. | If push printers utilized, user or computer targeting | Not Collected | | |
| 5. | Printer info from Print Servers | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-SharedPrinterInfoForADMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-SharedPrinterInfoForADMigration) | Yes |
| 6. | All printer Security Groups | [GitHub AD Migration Directory](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/4ADMigrationProject) | [Get-SharedPrinterInfoForADMigration.ps1](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/Get-SharedPrinterInfoForADMigration) | Yes |

## Group policies
| | Data to Collect | Location of Collected Data | PowerShell File | Output Verified |
| :--- | ------------- | -------- | ------- | --- |
| 1. | Linked, but not enabled | | | |
| 2. | Enabled but not linked | | | |
| 3. | Empty | | | |
| 4. | Targeting (object specific, group, wmi filter) | | | |
| 5. | OU linking | | | |
