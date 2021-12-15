$AzureADUsers = Get-AzureADUser -All $true #| where {$_.UserPrincipalName -like "*hsc.wvu.edu*"}

foreach ($AzureADUser in $AzureADusers)
{
    $UPN = $AzureADUser.UserPrincipalName
    
    $Licenses = Get-HSCUserLicense $UPN

    if ($Licenses.SkuPartNumber -contains "ENTERPRISEPACKPLUS_FACULTY") {
        $LicenseInfoObject = [PSCustomObject]@{
            UPN = $UPN
            Licenses = $Licenses.SkuPartNumber -join ";"
        }

        $LicenseInfoObject | Export-Csv LicenseInfo4.csv -Append
        $LicenseInfoObject
    }
	else {
		$LicenseInfoObject = [PSCustomObject]@{
            UPN = $UPN
            Licenses = $null
        }
		
		$LicenseInfoObject
	}
}