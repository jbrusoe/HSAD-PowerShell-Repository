$TranscriptPath = (Get-Date -Format yyyy-MM-dd-HH-mm) +
                    "RemoveSODFiles-SessionTranscript.txt"
Start-Transcript $TranscriptPath

$FileLocations = @(
            "c:\windows\DBUtil_2_3.sys",
            "c:\windows\temp\DBUTIL_2_3.sys",
            $((Get-ChildItem env:temp).Value + "\location\DBUtil_2_3.sys")
        )

$SearchBase = "OU=SOD,OU=HSC,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU"

$ImportFile = "SODComputers.csv"
$SODComputers = Import-Csv $ImportFile

foreach ($SODComputer in $SODComputers)
{
    Write-Output $("Current Computer: " + $SODComputer.SODComputers)

    $LDAPFilter = " (&(objectCategory=Computer)(name=" + $SODComputer.SODComputers + "*))"
    Write-Output "LDAPFilter: $LDAPFilter"

    $ADComputerObjects = Get-ADComputer -LDAPFilter $LDAPFilter #-SearchBase $SearchBase

    foreach ($ADComputer in $ADComputerObjects)
    {
        Write-Output $("Computer Name: " + $ADComputer.Name)

        $ComputerName = $ADComputer.Name

        if (Test-Connection $ComputerName) {
            Write-Output "Computer is up"
            Invoke-Command -ComputerName $ComputerName -FilePath ".\RemoteRemove.ps1"
        }
        else {
            Write-Warning "Computer is down"
        }
    }

    Write-Output "************************"
}


<#
foreach ($FileLocation in $FileLocations) {
    try {
        Write-Output "Current File Location: $FileLocation"

        if (Test-Path $FileLocation) {
            #Remove-Item -Path $FileLocation -Force -ErrorAction Stop
        }
        else {
            Write-Output "File doesn't exist"
        }
    }
    catch {
        Write-Warning "Unable to remove file"
    }

    Write-Output "******************"
}
#>

Stop-Transcript