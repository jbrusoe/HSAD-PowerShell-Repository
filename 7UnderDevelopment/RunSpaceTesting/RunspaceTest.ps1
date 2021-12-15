# https://www.youtube.com/watch?v=kvSbb6g0tMA

[CmdletBinding()]
param()

$StopWatch = New-Object System.Diagnostics.Stopwatch

$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, 4)
$RunspacePool.ApartmentState = "MTA"
$RunspacePool.Open()

$CodeContainer = {
    Param(
        [int]$MSDelay
    )

    Write-Verbose "$MSDelay Milliseconds"

    Start-Sleep -Milliseconds $MSDelay
    Write-Output "Completed Delay: $MSDelay milliseconds"
}

$Threads = @()
$StopWatch = [System.Diagnostics.Stopwatch]::StartNew()

$MSDelays = Get-Random -Minimum 50 -Maximum 250 -Count 15

Foreach ($MSDelay in $MSDelays)
{
    $RunspaceObject = [PSCustomObject]@{
        Runspace = [PowerShell]::Create()
        Invoker = $null
    }
    $RunspaceObject.Runspace.RunSpacePool = $runspacePool
    $RunspaceObject.Runspace.AddScript($CodeContainer) | Out-Null
    $RunspaceObject.Runspace.AddArgument($MSDelay) | Out-Null
    $RunspaceObject.Invoker = $runspaceObject.Runspace.BeginInvoke()
    $Threads += $RunspaceObject
    $Elapsed = $StopWatch.Elapsed
    Write-Output "Finished creating runspace for $MSDelay. Elapsed time: $Elapsed"
}

$Elapsed = $StopWatch.Elapsed
Write-Output "Finished creating all runspaces. Elapsed time: $Elapsed"

while ($threads.Invoker.IsCompleted -contains $false) {}

$Elapsed = $StopWatch.Elapsed
Write-Output "All runspaces completed. Elapsed time: $Elapsed"

$ThreadResults = @()
Foreach ($Thread in $Threads)
{
    $ThreadResults += $Thread.Runspace.EndInvoke($Thread.Invoker)
    $Thread.Runspace.Dispose()
}

$RunspacePool.Close()
$RunspacePool.Dispose()