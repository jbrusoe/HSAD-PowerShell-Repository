<#
.SYNOPSIS
    This script will run on sysscript5 as a scheduled task.  Its purpose
    is to scan the Inactive Computers OU for PC's with a whenChanged date
    of older than 6 months and remove the computer objects from AD.  To change
    the date range edit [int]$OlderThanDays = to however many days you want
    in the param section.

    Before removing it will export these attributes to a CSV:

    PCName
    DateOfRemoval
    Enabled
    LastLogonDate
    Location
    LAPs
    BitLocker
    Groups
    OS
    Description
    dN

.PARAMETER
	$Today - String, this is todays date formatted MM-dd-yyyy

    $OU - String, this it the OU to scan for inactive computers

    $PCRemovedLogPath - String, this is the log file path for removed PC's

    $PCFailedRemoveLogPath - String, this is the log file path for failed
                            to remove PC's

    $ServerForRemovalList - String,  this is a list of machines with server
                            OS for review before removal

    $PCProperties - Array, these are the attributes that will be used for
                    the Get-ADComputer call

    $PCObject - Array, these are the attributes used in the Select-Object
                of the Get-ADComputer call

    $OlderThanDays - Int, this is the number of days to set your date range

.EXAMPLE
    .\Remove-HSCStaleComputerObject.ps1

.NOTES
    Author: Kevin Russell

#>

[CmdletBinding()]
param(
    [string]$Today = (Get-Date -Format MM-dd-yyyy),

    [string]$OU = 'OU=Inactive Computers,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU',

    [string]$PCRemovedLogPath = "$PSScriptRoot\CSV\$Today-RemovedPC.csv",

    [string]$PCFailedRemoveLogPath = "$PSScriptRoot\CSV\$Today-FailedRemove.csv",

    [string]$ServerForRemovalList = "$PSScriptRoot\CSV\$Today-Server.csv",

    [array]$PCProperties = @(
        "Name"
        "Enabled"
        "distinguishedName"
        "ms-Mcs-AdmPwd"
        "Location"
        "OperatingSystem"
        "Description"
        "lastLogonDate"        
        "PasswordLastSet"
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
        "PasswordLastSet"
    ),

    [int]$OlderThanDays = "-180"
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

#Get list of PC's over 90 days since last logon date
$OldPC = Get-ADComputer -Filter * -Properties $PCProperties -SearchBase $OU |
    Where-Object {($_.lastLogonDate -lt (Get-Date).AddDays($OlderThanDays))} |
    Where-Object { $_.OperatingSystem -like "*Windows*"} |
    Where-Object { $_.Enabled -eq $False } |
    Select-Object $PCObject |
    Sort-Object -Property Name

Write-Output "There where $($OldPC.Count) objects found"

$Count = 0

ForEach ($pc in $OldPC) {
    #Get Bitlocker info
    [array]$BitLockerKeys = @()
    $BitLockerFilter = 'objectclass -eq "msFVE-RecoveryInformation"'
    $BitlockerProperties = @(
        "Name",
        'msFVE-RecoveryPassword'
    )
	$BitLockerObjects = Get-ADObject -Filter $BitLockerFilter -SearchBase $pc.distinguishedName -Properties $BitlockerProperties |
            Select-Object $BitlockerProperties

    foreach ($Key in $BitLockerObjects) {
        $BitLockerKeys += $Key.'msFVE-RecoveryPassword'
    }
    #End get bitlocker info

    #Get group membership
    $HSPCGroup = (Get-ADComputer $pc.Name | Get-ADPrincipalGroupMembership).Name

    if ($pc.OperatingSystem -like "*server*") {
        Write-Output "Adding $($pc.Name) to Server list for verification"

        #Export to server list
        [PSCustomObject]@{
            PCName = $pc.Name
            Enabled = $pc.Enabled
            LastLogonDate = $pc.lastLogonDate
            Location = $pc.Location
            LAPs = $pc."ms-Mcs-AdmPwd"
            BitLocker = $BitLockerKeys -join ';'
            Groups = $HSPCGroup -join ';'
            OS = $pc.OperatingSystem
            Description = $pc.Description
            dN = $pc.distinguishedName
        } | Export-Csv -Path $ServerForRemovalList -NoTypeInformation -Append -Force
    }
    else {
        #Export list to CSV
        [PSCustomObject]@{
            PCName = $pc.Name
            DateOfRemoval = Get-Date
            Enabled = $pc.Enabled
            LastLogonDate = $pc.lastLogonDate
            Location = $pc.Location
            LAPs = $pc."ms-Mcs-AdmPwd"
            BitLocker = $BitLockerKeys -join ';'
            Groups = $HSPCGroup -join ';'
            OS = $pc.OperatingSystem
            Description = $pc.Description
            dN = $pc.distinguishedName
        } | Export-Csv -Path $PCRemovedLogPath -NoTypeInformation -Append -Force

        Try{
        	$error.clear()

        	if($Count -le 25
            ){
                #Need to use ADObject instead of ADComputer because ADComputer
                #returns a leaf error
        		Get-ADComputer $pc.Name | Remove-ADObject -Confirm:$false -Recursive
                Write-Output "$($pc.Name) was successfully removed"
        		$Count++
        	}
        	else{
        		Write-Output ""
        		Write-Output "Total count is $Count, stopping program"
                Exit
        	}
        }
        Catch{
        	Write-Output "There was an error trying to remove $($pc.Name)"
            Write-Warning $error[0].Exception.Message

            #Export failed list to CSV
            [PSCustomObject]@{
                PCName = $pc.Name
                DateOfAttempedRemoval = Get-Date
                Error = $error[0].Exception.Message
                Enabled = $pc.Enabled
                LastLogonDate = $pc.lastLogonDate
                Location = $pc.Location
                LAPs = $pc."ms-Mcs-AdmPwd"
                BitLocker = $BitLockerKeys -join ';'
                Groups = $HSPCGroup -join ';'
                OS = $pc.OperatingSystem
                Description = $pc.Description
                dN = $pc.distinguishedName
            } | Export-Csv -Path $PCFailedRemoveLogPath -NoTypeInformation -Append -Force
        }
    }
}