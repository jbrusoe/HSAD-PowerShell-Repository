$O365Mailboxes = Get-ExoMailbox -ResultSize 100 |
    Where-Object { $_.PrimarySMTPAddress -notlike "*rni.*" -AND
                    $_.PrimarySMTPAddress -notlike "*wvurni" -AND
                    $_.UserPrincipalName -like "*hsc.wvu.edu*" }

$PSSession = Get-PSSession

$minimumAmountOfThreads = 1;
$maximumAmountOfThreads= 15;


$sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault();
$RunspacePool = [RunspaceFactory]::CreateRunspacePool($minimumAmountOfThreads, $maximumAmountOfThreads, $sessionState, $Host);
$RunspacePool.Open();

$threads = @();

foreach ($O365Mailbox in $O365Mailboxes) {
    $ScriptBlock = {
        param( $ImportSession, $MBX )
        Import-PSSession $PSSession
        Write-Output $O365Mailbox.PrimarySMTPAddress
    }

    $RunspaceObject = [PSCustomObject] @{
        Runspace = [PowerShell]::Create()
        Invoker = $null
    }

    $RunspaceObject.Runspace.RunSpacePool = $runspacePool;
    $RunspaceObject.Runspace.AddScript($scriptBlock) | Out-Null;
    $RunspaceObject.Runspace.AddArgument($importSession) | Out-Null;
    $RunspaceObject.Runspace.AddArgument($server) | Out-Null;
    $RunspaceObject.Invoker = $RunspaceObject.Runspace.BeginInvoke();
    $threads += $RunspaceObject;
}

$threads

#Get-RSJob | Receive-RSJob
#Select-Object @{Name="PrimarySMTPAddress";Expression={$_.PrimarySMTPAddress}},IsEnabled