### Updates since last code review

**HSC-CommonCodeModule.psm1**
  * Set-HSCEnvironment - Corrections to fix errors with $PSBoundParameters and Start-Transcript
  
**HSC-WindowsModule.psm1**
  * Get-HSCRunAsAdministrator
  * Get-HSCPSModulePath
   
**HSC-MSTeamModule.psm1**
  * Clear-HSCMSTeamsCache (Kevin)

**HSC-SQLModule.psm1**
  * Get-HSCConnectionString
  
**HSC-ActiveDirectoryModule**
  * Set-HSCPassswordRequired
  * Get-HSCPrimarySMTPAddress
  * Get-HSCDirectoryMapping
  * Get-HSCGroupMapping
  
**Files moved to new versions of modules**
  * Register-HSCPSRepoAndInstallModule.ps1 (Kevin)
  * Set-PasswordRequired.ps1
  * Create-NewAccount.ps1 (Major updates to this)
