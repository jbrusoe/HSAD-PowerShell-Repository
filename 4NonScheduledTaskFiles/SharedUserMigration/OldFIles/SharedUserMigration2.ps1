$Residents = Import-Csv 2021-02-10-Residents.csv

foreach ($Resident in $Residents)
{
    Write-Output $("HSC Email: " + $Resident.HSCEmail)
    $ADUser = Get-ADUser -Filter * -Properties mail | where {$_.mail -eq $Resident.HSCEmail}
	
    if (($ADUser | Measure).Count -eq 1)
    {
        $AddressToApply = $Resident.AddressToApply

        if ($AddressToApply -like "*smtp:*" -OR $AddressToApply -like "*x500*") {
			if ($AddressToApply -like "*smtp:*") {
				$AddressToApply = $AddressToApply.ToLower()
			}
			
            Write-Output "SMTP/X500 Address to Apply: $AddressToApply"

            $ADUser | Set-ADUser -Add @{proxyAddresses = $AddressToApply}
        }
        else {
            $AddressToApply = "x500:" + $AddressToApply
			
            Write-Output "Address to Apply: $AddressToApply"

            $ADUser | Set-ADUser -Add @{proxyAddresses = $AddressToApply}
        }
		
		Write-Output "Setting Account Visibility"
		$ADUser | Set-ADUser -Replace @{msExchHideFromAddressLists=$false}
    }
	else {
		Write-Warning "Unable to find a unique HSC AD user"
	}

    Write-Output "************************"
}