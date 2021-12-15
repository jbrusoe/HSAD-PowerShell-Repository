## HSC-CommonCodeModule.psm1

#### Summary
This module contains functions that are commonly used in many HSC PowerShell files. The following functions are currently included in this module. Type `Get-Help <FunctionName>` in order to learn more about any specific function. The following functions are included in this module:

| | Function Name | Function Summary |
| :--- | :------------- | :--- |
| 1. | [Get-HSCDepartmentMapPath](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Get-HSCDepartmentMapPath.md) | This function returns the path to the department map file which is used in the account creation process |
| 2. | [Get-HSCEncryptedDirectoryPath](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Get-HSCEncryptedDirectoryPath.md) | The purpose of this function is to return the path to the encrypted file *directory* used to connect to the HSC Office 365 tenant. |
| 3. | [Get-HSCEncryptedFilePath](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Get-HSCEncryptedFilePath.md) | Returns the path to the encrypted *file* used to connect to the HSC Office 365 tenant.|
| 4. | Get-HSCGitHubLogPath | Returns the path the HSC GitHub log repo (This is being removed) |
| 5. | [Get-HSCGitHubRepoPath](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Get-HSCGitHubRepoPath.md) | Returns the directory path to the HSC PowerShell repository |
| 6. | [Get-HSCLastFile](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Get-HSCLastFile.md) | Returns the last x number of files from a directory |
| 7. | [Get-HSCLogFileName](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Get-HSCLogFileName.md) | Generates the names of the various log files |
| 8. | [Get-HSCNetworkLogFileName](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Get-HSCNetworkLogFileName.md) | This function generates the names of the various log files and their corresponding path on the network file share. |
| 9. | [Get-HSCNetworkLogPath](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Get-HSCNetworkLogPath.md) |  This function returns the path to the network log file. |
| 10. | [Get-HSCParameter](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Get-HSCParameter.md) | Returns a list of parameters that differ from the default values |
| 11. | [Get-HSCPasswordFromSecureStringFile](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Get-HSCPasswordFromSecureStringFile.md) | Decrypts a secure string file. It only works on the same machine with the same logged on user who created the file. |
| 12. | [Get-HSCPowerShellVersion](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Get-HSCPowerShellVersion.md) | This function returns the version of PowerShell running. It's used because some functions can't run on PowerShell Core (Version 7). |
| 13. | [Get-HSCRandomPassword](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Get-HSCRandomPassword.md) | Randomly generates a password to meet WVU and HSC password complexity rules |
| 14. | [Get-HSCServerName](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Get-HSCServerName.md) | Returns the computer name that calls this function |
| 15. | [Invoke-HSCExitCommand](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Invoke-HSCExitCommand.md) | This function handles cleanup tasks to exit HSC PowerShell files | 
| 16. | [New-HSCSecureStringFile](https://github.com/jbrusoe/HSC-PowerShell-Repository/tree/master/3PowerShell-Code-Review/2021-04-15/PSRunspaces) | Creates a new secure string file for cloud authentication purposes |
| 17. | [Remove-HSCOldLogFile](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Remove-HSCOldLogFile.md) | Cleans up old log files |
| 18. | [Send-HSCEmail](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Send-HSCEmail.md) | This is a wrapper function for Send-MailMessage with some HSC defaults preconfigured |
| 19. | [Set-HSCEnvironment](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Set-HSCEnvironment.md) | Configures a common HSC PowerShell environment for files to run in |
| 20. | [Set-HSCWindowTitle](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Set-HSCWindowTitle.md) | Changes the title of the currently running PowerShell host |
| 21. | [Start-HSCCountdown](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Start-HSCCountdown.md) | Displays a progress bar with a message |
| 22. | [Test-HSCLogFilePath](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Test-HSCVerbose.md) | Determines if a log file path is valid |
| 23. | [Test-HSCPowerShell7](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Test-HSCPowerShell7.md) | Ensures that the file calling this function is running PowerShell version 7 |
| 24. | [Test-HSCVerbose](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Test-HSCVerbose.md) | Returns a boolean value to indicate whether or not the -Verbose parameter was used |
| 25. | [Update-HSCPowerShellDocumentation](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Update-HSCPowerShellDocumentation.md) | Generates the documentation markdown files for the HSC PowerShell modules |
| 26. | [Write-HSCColorOutput](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Write-HSCColorOutput.md) | Changes the color of the display used with Write-Output |
| 27. | [Write-HSCLogFileSummaryInformation](https://github.com/jbrusoe/HSC-PowerShell-Repository/blob/master/1HSCCustomModules/HSC-CommonCodeModule/Documentation/Write-HSCLogFileSummaryInformation.md) | |

#### Function Version Testing
<table>
<thead>
  <tr>
    <th></th>
    <th colspan="5"><b>PowerShell Version</b></th>
    <th></th>
  </tr>
</thead>
<tbody>
  <tr>
    <td></td>
    <td><b>Function Name</b></td>
    <td><b>5.1</b></td>
    <td><b>7.0.2</b></td>
    <td><b>7.1.2</b></td>
    <td><b>7.1.3</b></td>
    <td><b>Pester</b></td>
  </tr>
  <tr>
    <td>1.</td>
    <td><b>Get-HSCDepartmentMapPath</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
  <tr>
    <td>2.</td>
    <td><b>Get-HSCEncryptedDirectoryPath</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
   <tr>
    <td>3.</td>
    <td><b>Get-HSCEncryptedFilePath</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
  <tr>
    <td>4.</td>
    <td><b>Get-HSCGitHubRepoPath</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
    <tr>
    <td>5.</td>
    <td><b>Get-HSCLastFile</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
  <tr>
    <td>6.</td>
    <td><b><i>Get-HSCLogFileName</i></b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center"></td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
  </tr>
   <tr>
    <td>7.</td> 
     <td><b><i>Get-HSCParameter</i></b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
  </tr>
  <tr>
    <td>8.</td>
    <td><b>Get-HSCPasswordFromSecureStringFile</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
  <tr>
    <td>9.</td>
    <td><b>Get-HSCPowerShellVersion</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
    <tr>
    <td>10.</td>
    <td><b>Get-HSCRandomPassword</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
  <tr>
    <td>11.</td>
    <td><b>Get-HSCServerName</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
   <tr>
    <td>12.</td>
    <td><b>Invoke-HSCExitCommand</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
  <tr>
    <td>13.</td>
    <td><b>New-HSCSecureStringFile</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
  <tr>
    <td>14.</td>
    <td><b>Remove-HSCOldLogFile</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
  <tr>
    <td>15.</td>
    <td><b>Send-HSCEmail</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
  <tr>
    <td>16.</td>
    <td><b>Set-HSCEnvironment</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
  <tr>
    <td>17.</td>
    <td><b>Set-HSCWindowTitle</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
  <tr>
    <td>18.</td>
    <td><b>Start-HSCCountdown</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
  <tr>
    <td>19.</td>
    <td><b>Test-HSCLogFilePath</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>
  <tr>
    <td>20.</td>
    <td><b>Test-Verbose</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
  <td style="text-align:center">X</td>
    <td s1yle="text-align:center">X</td>
  </tr>
  <tr>
    <td>21.</td>
    <td><b>Update-HSCPowerShellDocumentation</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">X</td>
  </tr>  <tr>
  <td>22.</td>
    <td><b>Write-HSColorOutput</b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
  </tr>
  <td>23.</td>
  <td><b><i>Write-HSCLogFileSummaryInformation</i></b></td>
    <td style="text-align:center">X</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
  </tr>
  
</tbody>
</table>
