[CmdletBinding()]
[CmdletBinding()]
param (
    [ValidateNotNull()]
    [string]$Path = "\\hs.wvu-ad.wvu.edu\Public\SOD\"
)

Set-HSCEnvironment
Write-Output "Path: $Path"
$OutputFile = "$PSScriptRoot\Logs\" + (Get-Date -Format yyyy-MM-dd-HH-mm) + "-LargeFilesOutput.csv"

Write-Output "Getting file list"
$Files = Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue

Write-Output $("Files Count: " + $Files.Count)

Write-Output "Selecting files"
$LargeFiles = $Files | sort -Descending -Property Length | Select -First 20 -Property FullName,LastWriteTime,@{N='SizeInGB';E={[math]::round($_.Length/1GB,2)}}

$LargeFiles | Format-Table -AutoSize
$LargeFiles | Export-Csv $OutputFile

Invoke-HSCExitCommand