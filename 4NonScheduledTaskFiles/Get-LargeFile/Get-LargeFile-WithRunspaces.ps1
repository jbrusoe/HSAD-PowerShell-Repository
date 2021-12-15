[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]$Path = "\\hs.wvu-ad.wvu.edu\public\bioc\"
)

Set-HSCEnvironment
Write-Output "Path: $Path"
$OutputFile = "$PSScriptRoot\Logs\" + (Get-Date -Format yyyy-MM-dd-HH-mm) + "-LargeFilesOutput.csv"

$MinRunspaces = 1
$MaxRunspaces = 5
$RunspacePool = [RunspaceFactory]::CreateRunspacePool($MinRunspaces,$MaxRunspaces)
$RunspacePool.ApartmentState = "MTA"
$RunspacePool.Open()

$CodeContainer = {
    param (
        [string]$Path
    )

    $Files = Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue

    Write-Output $("Files Count: " + $Files.Count)

    Write-Output "Selecting files"
    $LargeFiles = $Files |
        Sort-Object -Descending -Property Length |
        Select-Object -First 20 -Property FullName,LastWriteTime,@{N='SizeInGB';E={[math]::round($_.Length/1GB,2)}}
}

$Directories = Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue

$Threads = @()
foreach ($Directory in $Directories) {
    $RunspaceObject = [PSCustomObject]@{
        Runspace = [PowerShell]::Create()
        Invoker = $null
    }

    $RunspaceObject.Runspace.RunspacePool = $RunspacePool
    $RunspaceObject.Runspace.Addscript($CodeContainer) | Out-Null
    $RunspaceObject.Runspace.AddParameter("Path",$Directory.Path) | Out-Null
    $RunspaceObject.Invoker = $RunspaceObject.Runspace.BeginInvoke()

    $Threads += $RunspaceObject
}

while ($Threads.Invoker.IsCompleted -contains $false) {
    Write-Verbose "Waiting for all threads to complete"
}

$Threads.Runspace.Streams
Invoke-HSCExitCommand