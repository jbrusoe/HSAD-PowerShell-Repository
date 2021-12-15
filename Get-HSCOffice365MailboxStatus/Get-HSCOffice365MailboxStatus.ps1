#Get-HSCOffice365MailboxStatus.ps1
#Written by: Jeff Brusoe
#Last Updated: May 28, 2021

[CmdletBinding()]
param(
    [string]$ExportFile = $((Get-HSCGitHubRepoPath) +
								"2CommonFiles\MailboxFiles\" +
								(Get-Date -Format yyyy-MM-dd-HH-mm) +
								"-O365MailboxStatus.csv")
)

try {
    Set-HSCEnvironment -ErrorAction Stop
    Connect-HSCExchangeOnline

    if (Test-Path $ExportFile) {
        Write-Verbose "Remvoing Old Export File"
        Remove-Item -Path $ExportFile -Force
    }
}
catch {
    Write-Warning "Unable to configure HSC environment"
    Invoke-HSCExitCommand -ErrorAction Stop
}

Write-Output "Beginning to check mailbox status"

try {
    Write-Output "Beginning to generate list of enabled mailboxes"

    Get-HSCEnabledMailbox -ErrorAction Stop -Verbose |
        Export-Csv $ExportFile -ErrorAction Stop -Append -NoTypeInformation

}
catch {
    Write-Warning "Error generating list of mailboxes with their status"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count