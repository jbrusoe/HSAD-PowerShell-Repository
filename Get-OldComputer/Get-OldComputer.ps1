<#
	.SYNOPSIS
        The purpose of this file is to search for AD computer objects
        that haven't changed their password in over 6 months.

	.PARAMETER Months
        This parameter is used to specify how many months back to go
        with the search. The default is 6.

	.PARAMETER PossibleDeleteFile
		The file where computers older than $Months are logged.

	.NOTES
		Written by: Jeff Brusoe
		Last Updated: December 10, 2020
#>

[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [int]$Months = 6,

    [ValidateNotNullOrEmpty()]
    [string]$PossibleDeleteFile = "$PSScriptRoot\Logs\" +
        (Get-Date -Format yyyy-MM-dd-HH-mm) + "-PossibleADComputerDelete.csv"
)

try {
    Set-HSCEnvironment -ErrorAction Stop
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorAction $Error.Count
}

$Properties = @(
    "Name",
    "Enabled",
    "lastLogonTimeStamp",
    "pwdLastSet"
    "Location",
    "OperatingSystem",
    "distinguishedName"
    )

try {
    Write-Output "Getting computer objects"
    $ADComputers = Get-ADComputer -Filter * -Properties $Properties -ErrorAction Stop |
        Sort-Object -Property pwdLastSet

    Write-Output $("Total Number of Computer Objects: " + ($ADComputers | Measure-Object).Count)
}
catch {
    Write-Warning "Error generating list of computer objects"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

foreach ($ADComputer in $ADComputers)
{
    $PasswordLastSet = [datetime]::FromFileTime($ADComputer.pwdLastSet)

    Write-Output $("Computer Name: " + $ADComputer.Name)
    Write-Output $("Password Last Set: $PasswordLastSet")

    if ($PasswordLastSet -lt (Get-Date).AddMonths(-1*$Months))
    {
        if (![string]::IsNullOrEmpty($ADComputer.OperatingSystem) -AND
            $ADComputer.OperatingSystem -ne "Max OS X")
            {
                $ADComputer |
                Select-Object @("Name",
                                "Enabled",
                                @{Name="PasswordLastSet";Expression={$PasswordLastSet}},
                                "OperatingSystem",
                                "distinguishedName") |
                Export-Csv $PossibleDeleteFile -Append -NoTypeInformation
            }
    }
    else {
        Write-Output "Computer password has been changed in the last 6 months"
    }

    Write-Output "**********************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count