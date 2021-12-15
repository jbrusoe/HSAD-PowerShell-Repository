# Get-FileShareSummaryInfo.ps1
# Written by Jeff Brusoe
# Last Updated: October 14, 2021
#
# The purpose of this file is to generate a summary of all the file shares
# as well as the file share permissions.

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$OutputFilePath = (Get-HSCGitHubRepoPath) +
								"4ADMigrationProject\"
)

try {
    Set-HSCEnvironment -ErrorAction Stop

    $GetSMBShareLog = $OutputFilePath + "FileShareSummary\" +
                                (Get-Date -Format yyyy-MM-dd) +
                                "-GetSMBShareLog.csv"

    New-Item -ItemType File -Path $GetSMBShareLog -Force

    $GetFileShareLog = $OutputFilePath + "FileShareSummary\" +
                                (Get-Date -Format yyyy-MM-dd) +
                                "-GetFileShareLog.csv"

    New-Item -ItemType File -Path $GetFileShareLog -Force

    $FileShareSummaryLog = $OutputFilePath + "FileShareSummary\" +
                            (Get-Date -Format yyyy-MM-dd) +
                            "-FileShareSummary.csv"

    New-Item -ItemType File -Path $FileShareSummaryLog -Force

    $GetSMBShareAccessLog = $OutputFilePath + "FileSharePermissions\" +
                                (Get-Date -Format yyyy-MM-dd) +
                                "-GetSMBShareAccessLog.csv"

    New-Item -ItemType File -Path $GetSMBShareAccessLog -Force
}
catch {
    Write-Warning "Unable to configure PS environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Getting list of AD Servers"

    $GetADComputerParams = @{
        Filter = "*"
        Properties = @(
            "OperatingSystem"
        )
        ErrorAction = "Stop"
    }
    $ADServers = Get-ADComputer @GetADComputerParams |
                    Where-Object {$_.OperatingSystem -like "*Windows Server*"}
}
catch {
    Write-Warning "Unable to generate list of AD servers"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($ADServer in $ADServers) {
    Write-Output $("Current File Server: " + $ADServer.Name)
    Write-Output "Distinguished Name:"
    Write-Output $ADServer.DistinguishedName

    $InfoSummaryObject = [PSCustomObject]@{
        ServerName = $ADServer.Name
        Enabled = $ADServer.Enabled
        CIMSession = $false
        GetSmbShare = $false
        GetFileShare = $false
        GetSmbShareAccess = $false
        DistinguishedName = $ADServer.DistinguishedName
    }

    if ($ADServer.Enabled) {
        Write-Output "Collecting File Share Information"

        $ExportCsvParams = @{
            Path = $GetSMBShareLog
            NoTypeInformation = $true
            Append = $true
            ErrorAction = "Stop"
        }

        try {
            Write-Output "Creating New CIM Session"
            $CIMSession = New-CimSession -ComputerName $ADServer.Name -ErrorAction Stop

            $InfoSummaryObject.CIMSession = $true
        }
        catch {
            Write-Warning "Unable to create new CIM session"
        }

        try {
            Write-Output "Getting Info from Get-SMBShare"

            $GetSMBShareInfo = Get-SmbShare -CimSession $CIMSession -ErrorAction Stop
            $GetSMBShareInfo

            $GetSMBShareInfo | Export-Csv @ExportCsvParams

            Write-Output "Successfully ran Get-SmbShare"
            Write-Output "--------------------------------"

            $InfoSummaryObject.GetSmbShare = $true
        }
        catch {
            Write-Warning "Error running Get-SmbShare"
            Write-Output "--------------------------------"
        }

        try {
            Write-Output "Getting Info from Get-FileShare"

            $GetFileShareInfo = Get-FileShare -CimSession $CIMSession -ErrorAction Stop
            $GetFileShareInfo

            $ExportCsvParams["Path"] = $GetFileShareLog
            $GetFileShareInfo | Export-Csv @ExportCsvParams

            Write-Output "Successfully ran Get-FileShare"
            Write-Output "--------------------------------"

            $InfoSummaryObject.GetFileShare = $true
        }
        catch {
            Write-Warning "Error running Get-FileShare"
            Write-Output "--------------------------------"
        }

        try {
            Write-Output "Getting info with Get-SmbShareAccess"

            $GetSMBShareAccess = $GetSMBShareInfo |
                Get-SmbShareAccess -CimSession $CIMSession -ErrorAction Stop
            $GetSMBShareAccess

            $ExportCsvParams["Path"] = $GetSMBShareAccessLog
            $GetSMBShareAccess | Export-Csv @ExportCsvParams

            Write-Output "Successfully ran Get-SmbShareAccess"
            Write-Output "--------------------------------"

            $InfoSummaryObject.GetSmbShareAccess = $true
        }
        catch {
            Write-Warning "Error running Get-SmbShareAccess"
            Write-Output "--------------------------------"
        }
    }
    else {
        Write-Warning "Server is disabled"
    }

    $InfoSummaryObject | Export-Csv $FileShareSummaryLog -NoTypeInformation -Append
    Write-Output "************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count