[CmdletBinding()]
[CmdletBinding()]
param (
    [ValidateNotNull()]
    [string]$Path = "\\hs.wvu-ad.wvu.edu\public\bioc\"
)

Set-HSCEnvironment
Write-Output "Path: $Path"

$OutputFile = "$PSScriptRoot\Logs\" + (Get-Date -Format yyyy-MM-dd-HH-mm) + "-LargeFilesOutput.csv"

Write-Output "Getting file list"
$Files = Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue

Write-Output $("Files Count: " + $Files.Count)

Write-Output "Selecting files"
$LargeFiles = $Files |
    Sort-Object -Descending -Property Length |
    Select-Object -First 20 -Property FullName,LastWriteTime,@{N='SizeInGB';E={[math]::round($_.Length/1GB,2)}}

$LargeFiles | Format-Table -AutoSize
$LargeFiles | Export-Csv $OutputFile

Invoke-HSCExitCommand -ErrorCount $Error.Count