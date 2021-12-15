$MsolUsers = Get-MsolUser -All # -userprincipalname jpaugh@hsc.wvu.edu

New-Item "O365LicenseInformation.txt" -type file -force

foreach ($MsolUser in $MsolUsers)
{
	"Current User: " + $MsolUser.UserPrincipalName
	
	Add-Content -Path "O365LicenseInformation.txt" -Value $("Current User: " + $MsolUser.UserPrincipalName)
	
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