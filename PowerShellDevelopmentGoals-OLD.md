# PowerShell Development Goals

### Short Term Goals (Completed by February 1, 2021)
1. Migrate all PowerShell files to new [HSC modules](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/1HSCCustomModules).
2. Migrate all Exchange Powershell files to [version 2](https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps) of the cmdlets.
3. Migrate all Office 365 modules from [MSOnline](https://docs.microsoft.com/en-us/powershell/module/msonline/?view=azureadps-1.0) to [AzureAD](https://docs.microsoft.com/en-us/powershell/module/azuread/?view=azureadps-2.0).
3. Develop a standard checklist for all current ps1, psm1, and psd1 files. This will also include MS best practices for PowerShell.
   * https://devblogs.microsoft.com/scripting/weekend-scripter-best-practices-for-powershell-scripting-in-shared-environment/
   * https://devblogs.microsoft.com/scripting/the-top-ten-powershell-best-practices-for-it-pros/
   * https://github.com/PoshCode/PowerShellPracticeAndStyle
4. Run all current PowerShell files through the [PS Script Analyzer](https://www.powershellgallery.com/packages/PSScriptAnalyzer/1.19.1)
5. Implement a code testing procedure with PowerShell [Pester](https://github.com/pester/Pester).

### Medium Term Goals (Completed by July 1, 2021)
1. Use PowerShell [runspaces](https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.runspaces.runspace?view=powershellsdk-7.0.0) to speed up **Disable-ExchangeForwardingRule.ps1**. Pulling rules for a mailbox is a slow process which means this file is running slower(especially as hospital accounts are moved to the cloud), and runspaces should speed this file up. If this works, runspaces could be used to speed up several other files.
   * https://adamtheautomator.com/powershell-multithreading/
2. Look at department populated by SailPoint for new accounts. Have **Create-NewAccount.ps1** move user automatically after account is claimed if a mapping can be established between the department field and a specific OU. This would eliminate the need for a CSC form for these departments.
3. Migrate SON student services DB to Azure instance.
   * In progress
   * https://azure.microsoft.com/en-us/resources/videos/how-to-migrate-sql-server-2008-or-r2-to-azure-sqldbmi/
4. Migrate to using modern auth with PowerShell files.
   * https://o365reports.com/2020/07/04/modern-auth-and-unattended-scripts-in-exchange-online-powershell-v2/
   * https://www.365admin.com.au/2017/07/how-to-connect-to-office-365-via.html
5. Look at PnP PowerShell for SharePoint. A major use for this would be to access the [HSC Exclusion List](https://wvuhsc.sharepoint.com/PowerShellDevelopment/Lists/DoNotDisableList/AllItems.aspx?viewpath=%2FPowerShellDevelopment%2FLists%2FDoNotDisableList%2FAllItems.aspx). 
    * ***Done - September 1, 2020*** - Get-HSCSPOExclusionList has been written with this module, and is located in the HSC-SharePointOnline.psm1 module.
6. Write file to remove and backup old home directories.
   
### Long Term Goals (Completed by December 31, 2021)
1. Learn about object oriented programming in PowerShell and create an HSC user [class](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_classes?view=powershell-7). This could be used with functions (that also need to be written) such as Get-HSCADUser or Set-HSCADUser. If this works as I expect, classses such as HSCMailbox and HSCO365User could also be written.
2. Create a file that runs periodically to document global O365 settings. This could then be used to see if anything was changed (either manually or by default from Microsoft) or if any settings were added/removed.
3. Move logging (such as for users created, etc.) to a database instead of a text log file. Develop a file that will look through these db tables to see if any errors are present.
   * In progress
4. Move any ps1 files that can be over to PowerShell version 7 (or whatever the latest version of PS Core is). Currently, AD and O365 modules will only run on PS 5.1.
5. Look at machine learning options with PowerShell.
   * https://docs.microsoft.com/en-us/azure/machine-learning/studio/powershell-module
   * https://powertoe.wordpress.com/2017/10/23/h2o-machine-learning-with-powershell/
   * https://www.analyticsvidhya.com/blog/2019/05/using-power-deep-learning-cyber-security-2/
   * https://www.youtube.com/watch?v=M0OYzJT6uLk
6. Look at PowerShell forms
