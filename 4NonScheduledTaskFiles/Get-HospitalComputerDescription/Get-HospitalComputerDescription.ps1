[CmdletBinding()]
param ()

$Computers = Import-Csv HospitalComputers.csv
$Properties = @(
	"Name",
	"Description",
	"LastBadPasswordAttempt",
	"LastLogonDate",
	"OperatingSystem",
	"OperatingSystemVersion"
)

foreach ($Computer in $Computers)
{
    #Write-Output $Computer.ComputerName

    $ComputerName = $Computer.ComputerName
    $ComputerName = $ComputerName.substring($ComputerName.indexOf("\")+1)
	$ComputerName = $ComputerName.Trim()

    #Write-Output "Trimmed Computer Name: $ComputerName"
    Write-Verbose $ComputerName
	try {
		$ADComputer = Get-ADComputer -Identity $ComputerName -Server wvuhs.com -Properties $Properties -ErrorAction Stop
	}
	catch {
		try {
			$ADComputer = Get-ADComputer -Identity $ComputerName -Server wvuh.wvuhs.com -Properties $Properties -ErrorAction Stop
		}
		catch {
			$ADComputer = $null
		}
	}
	
    if ($null -eq $ADComputer) {
		[PSCustomObject]@{
			ComputerNameFromFile = $Computer.ComputerName
			Name = $null
			Description = $null
			LastBadPasswordAttempt = $null
			LastLogonDate = $null
			OperatingSystem = $null
			OperatingSystemVersion = $null 
		}
	}
	else {
		[PSCustomObject]@{
			ComputerNameFromFile = $Computer.ComputerName
			Name = $ADComputer.name
			Description = $ADComputer.description
			LastBadPasswordAttempt = $ADComputer.lastBadPasswordAttempt
			LastLogonDate = $ADComputer.lastLogonDate
			OperatingSystem = $ADComputer.operatingSystem
			OperatingSystemVersion = $ADComputer.operatingSystemVersion
		}
	}

    Write-Verbose "***********************"
}