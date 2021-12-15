#PowerShell Runspace Testing
#Written by: Jeff Brusoe
#Last Updated: APril 14, 2021
#
#Based on: https://www.youtube.com/watch?v=kvSbb6g0tMA

Set-StrictMode -Version Latest
Clear-Host

$StopWatch = New-Object System.Diagnostics.Stopwatch

Write-Output "Generating Delay Array..."
$MillisecondArray = Get-Random -Count 50 -Minimum 100 -Maximum 500

Write-Output "`n`nBeginning to Process Delays Sequentially"

$StopWatch.Start()
$Process = 1
foreach ($Millisecond in $MillisecondArray)
{   
    Write-Output "Process $Process Milliseconds: $Millisecond"
    $Process++

    #Start-Sleep -Milliseconds $Millisecond

    $ElapsedTime = $StopWatch.Elapsed
    Write-Output "Elapsed Time: $ElapsedTime"

    Write-Output "***************************"
}

$SequentialElapsedTime = $StopWatch.Elapsed

Write-Output "`n`nNow Trying with Runspaces"
$MinRunspaces = 1
$MaxRunspaces = 5
$RunspacePool = [RunspaceFactory]::CreateRunspacePool($MinRunspaces,$MaxRunspaces)
$RunspacePool.ApartmentState = "MTA"
$RunspacePool.Open()

$CodeContainer = {
    param (
        [int]$Milliseconds
    )

    Start-Sleep -Milliseconds $Milliseconds
    return $Milliseconds
}

$Threads = @()
$StopWatch.Restart()
foreach ($Millisecond in $MillisecondArray)
{
    $RunspaceObject = [PSCustomObject]@{
        Runspace = [PowerShell]::Create()
        Invoker = $null
    }

    $RunspaceObject.Runspace.RunspacePool = $RunspacePool
    $RunspaceObject.Runspace.Addscript($CodeContainer) | Out-Null
    $RunspaceObject.Runspace.AddParameter("Milliseconds",$Millisecond) | Out-Null
    $RunspaceObject.Invoker = $RunspaceObject.Runspace.BeginInvoke()

    $Threads += $RunspaceObject
    
    $ElapsedTime = $StopWatch.Elapsed
    Write-Output "Elapsed Time: $ElapsedTime"
    Write-Output "***************************" 
}

$ElapsedTime = $StopWatch.Elapsed
Write-Output "Time to Create All Runspaces: $ElapsedTime"

while ($Threads.Invoker.IsCompleted -contains $false) {
    Write-Verbose "Waiting for all threads to complete"
}

$RunspaceElapsedTime = $StopWatch.Elapsed
#$Threads.Invoker
$Threads.Runspace.Streams

