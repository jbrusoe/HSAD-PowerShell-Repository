<#
.SYNOPSIS
    This script will run on sysscript5 as a scheduled task.  Its purpose
    is to scan HS Computers OU for PC's with a lastLogedOn date
    of older than 6 months and disable the computer and move it to the
    Inactive Computers OU.

    Before removing it will export these attributes to a CSV:

    PCName
    DateOfMove
    Enabled
    LastLogonDate
    Location
    LAPs
    BitLocker
    OS
    Description
    dN

.PARAMETER
    $Today - String, this is todays date formatted MM-dd-yyyy

    $OU - String, this it the OU to scan for inactive computers

    $InactiveOU - String, this is the OU for inactive (stale) computer
                  objects.  Currently:
                  "OU=Inactive Computers,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU"

    $TodayDateInactiveOU - String, this is the OU that gets created to move
                           the new stale objects to.  It resides in the
                           Inactive Computers OU and sets the current date
                           as the OU name

    $PCRemovedLogPath - String, this is the log file path for removed PC's

    $PCFailedRemoveLogPath - String, this is the log file path for failed
                            to remove PC's

    $OlderThanDays - Int, this is the number of days to set your date range

    $PCProperties - Array, these are the attributes that will be used for
                    the Get-ADComputer call

    $PCObject - Array, these are the attributes used in the Select-Object
                of the Get-ADComputer call
.EXAMPLE

.NOTES
    Author: Kevin Russell
    Last Update: Kevin Russell
    Last Update On: 10/25/21

#>

[CmdletBinding()]
param(
    [string]$Today = (Get-Date -Format MM-dd-yyyy),

    [string]$OU = 'OU=HS Computers,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU',

    [string]$InactiveOU = "OU=Inactive Computers,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU",

    [string]$TodayInactiveOU = "OU=$Today,OU=Inactive Computers,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU",

    [string]$PCRemovedLogPath = "$PSScriptRoot\CSV\$Today-MovedPC.csv",

    [string]$PCFailedRemoveLogPath = "$PSScriptRoot\CSV\$Today-FailedMove.csv",

    [int]$OlderThanDays = "-625",

    [array]$PCProperties = @(
        "Name"
        "Enabled"
        "distinguishedName"
        "ms-Mcs-AdmPwd"
        "Location"
        "OperatingSystem"
        "Description"
        "lastLogonDate"
        "whenChanged"
    ),

    [array]$PCObject = @(
        "Name"
        "Enabled"
        "lastLogonDate"
        "distinguishedName"
        "ms-Mcs-AdmPwd"
        "Location"
        "OperatingSystem"
        "Description"
        "whenChanged"
    )
)

#initial setup
try {
	[string]$TranscriptLogFile = Set-HSCEnvironment

	if ($null -eq $TranscriptLogFile) {
		Write-Warning "There was an error configuring the environment. Program is exiting."
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}
    Write-Output $OlderThanDays
	Write-Verbose "Transcript Log file: $TranscriptLogFile"
	Write-Verbose "Start Date: $StartDate"
}
catch {
	Write-Warning "Error configuing environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}
#setup done

$ComputerParams = @{
    "Filter" = 'operatingsystem -like "*Windows*"'
    "Properties" = $PCProperties
    "SearchBase" = $OU
}

#Get list of PC's over 180 days since last logon date and are not a server
$OldPC = Get-ADComputer @ComputerParams |
    Where-Object {$_.lastLogonDate -lt (Get-Date).AddDays($OlderThanDays)} |
    Where-Object {$_.operatingsystem -NotLike "*Server*"} |
    Sort-Object -Property Name |
    Select-Object $PCObject

Write-Output "There where $($OldPC.Count) objects found"

$Count = 0

if($OldPC -eq "$NullOrEmpty") {
    Write-Output "No machines were found to be moved"
    Write-Output "Exiting..."
    Exit
}
else {
    #Create OU for daily move
    try {
        New-ADOrganizationalUnit -Name $Today -Path $InactiveOU
    }
    catch {
        Write-Warning $error[0].Exception.Message
    }
    #End create OU

    ForEach ($pc in $OldPC) {

        if ($pc.Name -like "*scope*") {
            Write-Output "$($pc.Name)"
        }
        if ($pc.Name -like "*apogee*") {
            Write-Output "$($pc.Name)"
        }
        else {
            #Get Bitlocker info
            [array]$BitLockerKeys = @()
            $BitLockerFilter = 'objectclass -eq "msFVE-RecoveryInformation"'
            $BitlockerProperties = @(
                "Name",
                'msFVE-RecoveryPassword'
            )

            $BitLockerParams = @{
                "Filter" = $BitLockerFilter
                "SearchBase" = "$($pc.distinguishedName)"
                "Properties" = $BitlockerProperties
            }

            $BitLockerObjects = Get-ADObject @BitLockerParams |
                    Select-Object $BitlockerProperties

            foreach ($Key in $BitLockerObjects) {
                $BitLockerKeys += $Key.'msFVE-RecoveryPassword'
            }
            #End get bitlocker info

            #Export DataCapture to CSV
            [PSCustomObject]@{
                PCName = $pc.Name
                DateOfMove = Get-Date
                Enabled = $pc.Enabled
                LastLogonDate = $pc.lastLogonDate
                Location = $pc.Location
                LAPs = $pc."ms-Mcs-AdmPwd"
                BitLocker = $BitLockerKeys -join ';'
                OS = $pc.OperatingSystem
                Description = $pc.Description
                dN = $pc.distinguishedName
            } | Export-Csv -Path $PCRemovedLogPath -NoTypeInformation -Append -Force

            #Disable and Move PC to Inactive OU with todays date
            Try{
                $error.clear()

                if($Count -le 150){

                    Get-ADComputer $pc.Name |
                        Disable-ADAccount -PassThru |
                        Move-ADObject -TargetPath $TodayInactiveOU

                    Write-Output "$($pc.Name) was successfully disabled"
                    Write-Output "$($pc.Name) was moved to:  $TodayInactiveOU"
                    $Count++
                }
                else{
                    Write-Output ""
                    Write-Output "Total count is $Count, stopping program"
                    Break
                }
            }
            Catch{
                Write-Output "There was an error trying to remove $($pc.Name)"
                Write-Warning $error[0].Exception.Message

                #Export failed list to CSV
                [PSCustomObject]@{
                    PCName = $pc.Name
                    DateOfAttempedMove = Get-Date
                    Error = $error[0].Exception.Message
                    Enabled = $pc.Enabled
                    LastLogonDate = $pc.lastLogonDate
                    Location = $pc.Location
                    LAPs = $pc."ms-Mcs-AdmPwd"
                    BitLocker = $BitLockerKeys -join ';'
                    OS = $pc.OperatingSystem
                    Description = $pc.Description
                    dN = $pc.distinguishedName
                } | Export-Csv -Path $PCFailedRemoveLogPath -NoTypeInformation -Append -Force
            }
        }
    }
}