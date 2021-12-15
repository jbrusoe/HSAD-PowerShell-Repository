## WVU Health Sciences Center PowerShell Best Practices & Style Guide

**1. Always start with [CmdletBinding()]**
* https://github.com/PoshCode/PowerShellPracticeAndStyle/blob/master/Style-Guide/Code-Layout-and-Formatting.md#always-start-with-cmdletbinding

**2. Limit lines of code to 115 characters**
* https://github.com/PoshCode/PowerShellPracticeAndStyle/blob/master/Style-Guide/Code-Layout-and-Formatting.md#always-start-with-cmdletbinding

**3. Always use a try/catch block (and -ErrorAction Stop) to exit code if issues arise with cmdlets such as:**
* Get-ADUser
* Set-ADUser
* Get-ADGroup
* Set-ADGroup
* Get-Mailbox
* Set-Mailbox
* Get-Recipient
* Get-EXOMailbox
* Get-AzureADUser
* Set-AzureADUser
* Import-Csv
* Export-Csv

**4. Never use $users or a variable name such as that. Be more descriptive - $ADUsers, $O365Mailboxes, $AzureADUsers, $MSOLUsers, etc.**

**5. Always use an approved PowerShell verb to begin a function, module, or file name.**
* [Approved Verbs for PowerShell Commands](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.1)

**6. Always use a singular noun in a PowerShell function, module, or file name.**

**7. Avoid hard coding any values or using magic numbers. Put them as named variables in the param() block instead.**
* [What are magic numbers in computer programming?](https://stackoverflow.com/questions/3518938/what-are-magic-numbers-in-computer-programming)

**8. Avoid long strings of parameters by using hash tables.**
* [Splatting with Hash Tables](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-7.1#splatting-with-hash-tables)

**9. Brace Style**

**10. Capitalization Conventions**
* https://docs.microsoft.com/en-us/dotnet/standard/design-guidelines/capitalization-conventions?redirectedfrom=MSDN
* https://github.com/PoshCode/PowerShellPracticeAndStyle/blob/master/Style-Guide/Code-Layout-and-Formatting.md#terminology

**Sources**<br>
* [PowerShell Best Practices and Style Guide](https://github.com/PoshCode/PowerShellPracticeAndStyle)
* https://devblogs.microsoft.com/scripting/the-top-ten-powershell-best-practices-for-it-pros/
* https://devblogs.microsoft.com/scripting/weekend-scripter-best-practices-for-powershell-scripting-in-shared-environment/
