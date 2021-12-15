[CmdletBinding()}
param (
	#Common HSC PowerShell Parameters
	[switch]$NoSessionTranscript,
    [string]$LogFilePath = "c:\AD-Development\Disable-POPIMAP\Logs",
	[switch]$StopOnError, #$true is used for testing purposes
	[int]$DaysToKeepLogFiles = 7, #this value used to clean old log files
	
	#File specific parameters
	[parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$UPN
)

Write-Output "Current User: $UPN" | Out-Host

if ($UPN.indexOf("@") -gt 0)
{
	#In
}
$LicenseDetails = (Get-MsolUser -UserPrincipalName $MsolUser.UserPrincipalName).Licenses
	
	if ($LicenseDetails -ne $null)
	{
		$i = 0
		
		foreach ($LicenseDetail in $LicenseDetails)
		{
			Add-Content -Path "O365LicenseInformation.txt" -Value $("`nLicense Name: " + $LicenseDetails.AccountSkuId.Split(" ")[$i])
			Add-Content -Path "O365LicenseInformation.txt" -Value "Service Status"

			$i++
			
			foreach ($Service in $LicenseDetail.ServiceStatus)
			{
				Add-Content -Path "O365LicenseInformation.txt" -Value $($Service.ServicePlan.ServiceName + ": " + $Service.ProvisioningStatus)
				$Service.ServiceName
				$Service.Provisioningtatus
			}

			
			
		}
	}
	else
	{
		Add-Content -Path "O365LicenseInformation.txt" -Value "Unlicensed user"
	}
	
	Add-Content -Path "O365LicenseInformation.txt" -Value "******************************"
	"******************************"
}