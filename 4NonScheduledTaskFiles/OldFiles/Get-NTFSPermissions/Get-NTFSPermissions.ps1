[CmdletBinding()]
param (
	[string]$FolderToBackupPermissions = "c:\AD-Development",
	[string]$LogPath = $PSScriptRoot,
	[switch]$IncludeFiles
	)

#Initialize environment
Clear-Host
Set-StrictMode -Version Latest

Write-Verbose $("Setting window title")
Write-Verbose $("PSCommandPath: " + $PSCommandPath)
$Host.UI.RawUI.WindowTitle = $PSCommandPath.substring($PSCommandPath.lastindexOf("\")+1)

$OutputFile = $LogPath + "\" + (Get-Date -format yyyy-MM-dd-hh-mm) + "-NTFSPermissionBackup.csv"
$SessionTranscript = $LogPath + "\" + (Get-Date -format yyyy-MM-dd-hh-mm) + "-NTFSPermissionBackup-SessionTranscript.txt"
#End of environment initialization block

Write-Output "Path to backup NTFS Permissions: $FolderToBackupPermissions"
Write-Output "Output file path: $LogPath"
Write-Output "Include Files: $IncludeFiles"

Write-Output "`nVerifying path to backup exists"
if (Test-Path $FolderToBackupPermissions)
{
	Write-Output "Path to backup permissions exists"
}
else
{
	Write-Warning "Path to backup doesn't exist. Program is exiting."
	Return
}

#Begin permission backup
Get-Childitem -path $FolderToBackupPermissions | Where-Object {$_.PSIsContainer} | Get-ACL | Select-Object Path -ExpandProperty Access | Export-CSV $OutputFile