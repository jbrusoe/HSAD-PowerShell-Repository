$Residents = Import-Csv 2021-02-11-Residents.csv
[string]$PreviousHSCEmail = $null

Start-Transcript "2021-02-11-ResidentSessionTranscript.txt"

foreach ($Resident in $Residents)
{
    Write-Output $("HSC Email: " + $Resident.HSCEmail)
	
	if ($Resident.HSCEmail -eq $PreviousHSCEmail) {
		Write-Output "Same email - Previous AD user will be used"
	}
	else {
		Write-Output "Searching for HSC AD User"
		$ADUser = Get-ADUser -Filter * -Properties mail | where {$_.mail -eq $Resident.HSCEmail}
		
		Write-Output "Setting Account Visibility"
		$ADUser | Set-ADUser -Replace @{msExchHideFromAddressLists=$false} -ErrorAction Stop #-WhatIf
	}

    if (($ADUser | Measure).Count -eq 1)
    {
        $AddressToApply = $Resident.AddressToApply

        if ($AddressToApply -like "*smtp:*" -OR $AddressToApply -like "*x500*") {
			if ($AddressToApply -like "*smtp:*") {
				$AddressToApply = $AddressToApply.ToLower()
			}
			
            Write-Output "SMTP/X500 Address to Apply: $AddressToApply"

			try {
				#$ADUser |
					#Set-ADUser -Add @{proxyAddresses = $AddressToApply}  -ErrorAction Stop #-WhatIf
			}
			catch {
				Write-Warning "Unable ot add: $AddressToApply"
			}
            
        }
        else {
            $AddressToApply = "x500:" + $AddressToApply
			
            Write-Output "Address to Apply: $AddressToApply"

			try {
				#$ADUser |
				#Set-ADUser -Add @{proxyAddresses = $AddressToApply} -ErrorAction Stop #-WhatIf
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