$FileName = "FileName"

$Services = Get-Service

$Services | Foreach-Object -Parallel {
    $NewFileName = $using:FileName + "-" +
                    $_.Name + ".txt"

    Write-Output $NewFileName
} -ThrottleLimit 20