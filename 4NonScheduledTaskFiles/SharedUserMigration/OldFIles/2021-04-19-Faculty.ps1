$Residents = Import-Csv 2021-04-19-Faculty.csv
[string]$PreviousHSCEmail = $null

Start-Transcript "2021-04-19-Faculty.txt"

foreach ($Resident in $Residents)
{
    Write-Output $("HSC Email: " + $Resident.HSCEmail)
	
	if ($Resident.HSCEmail -eq $PreviousHSCEmail) {
		Write-Output "Same email - Previous AD user will be used"
	}
	else {
		Write-Output "Searching for HSC AD User"

		try {
			$ADUser = Get-ADUser -Filter * -Properties mail -ErrorAction Stop |
				where {$_.mail -eq $Resident.HSCEmail}
		}
		catch {
			Write-Warning "Unable to find user"
			return
		}
	}

    if (($ADUser | Measure).Count -eq 1)
    {
		try {
			
			Write-Output "Unhiding user from address book"
		
			$ADUser |
				Set-ADUser -Replace @{msExchHideFromAddressLists=$false} -ErrorAction Stop
		}
		catch {
			Write-Warning "Unable to unhide address"
			return
		}

        $AddressToApply = $Resident.AddressToApply

        if ($AddressToApply -like "*smtp:*" -OR
			$AddressToApply -like "*sip*" -OR
			$AddressToApply -like "*x500*") 
		{
			if ($AddressToApply -like "*smtp:*") {
				$AddressToApply = $AddressToApply.ToLower()
			}
			
            Write-Output "SMTP/X500 Address to Apply: $AddressToApply"

			try {
				$ADUser |
					Set-ADUser -Add @{proxyAddresses = $AddressToApply}  -ErrorAction Stop #-WhatIf
			}
			catch {
				Write-Warning "Unable to add: $AddressToApply"
			}
            
        }
        else {
            $AddressToApply = "x500:" + $AddressToApply
			
            Write-Output "Address to Apply: $AddressToApply"

			try {
				$ADUser |
					Set-ADUser -Add @{proxyAddresses = $AddressToApply} -ErrorAction Stop #-WhatIf
			}
            catch {
				Write-Warning "Unable to add $AddressToApply"
			}
        }
    }
	else {
		Write-Warning "Unable to find a unique HSC AD user"
	}

	$PreviousHSCEmail = $Resident.HSCEmail

    Write-Output "************************"
}

Stop-Transcript