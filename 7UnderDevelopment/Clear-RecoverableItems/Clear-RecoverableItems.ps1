#Clear-RecoverableItems.ps1
#Written by: Jeff Brusoe
#Last Updated: June 14, 2021

[CmdletBinding()]
param (
	[Parameter(Mandatory=$true,
				ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
				Position = 0)]
	[string]$UserName
)

try {
	Set-HSCEnvironment -ErrorAction Stop
	#Connect-HSCExchangeOnline -ErrorAction Stop
}
catch {
	Write-Warning "Unable to configure environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
	$Mailbox = Get-EXOMailbox $UserName -PropertySets Hold -Properties SingleItemRecoveryEnabled -ErrorAction Stop

	Write-Verbose "Successfully pulled mailbox information"
}
catch {
	try {
		$Mailbox = Get-Mailbox $UserName -ErrorAction Stop

		Write-Verbose "Successfully pulled mailbox information"
	}
	catch {
		Write-Warning "Unable to find user: $UserName"
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}
}

try {
	Write-Verbose "Pulling hold status"

	$LitigationHoldEnabled = $Mailbox.LitigationHoldEnabled
	$ComplianceTagHoldApplied = $Mailbox.ComplianceTagHoldApplied
	$SingleItemRecoveryEnabled = $Mailbox.SingleItemRecoveryEnabled

	Write-Verbose "Litigation Hold Enabled: $LitigationHoldEnabled"
	Write-Verbose "Compliance Tag Hold Applied: $ComplianceTagHoldApplied"
	Write-Verbose "SingleItemREcoveryEnabled: $SingleItemRecoveryEnabled"
}
catch {
	Write-Warning "Unable to pull account hold information"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}



Invoke-HSCExitCommand -ErrorCount $Error.Count






