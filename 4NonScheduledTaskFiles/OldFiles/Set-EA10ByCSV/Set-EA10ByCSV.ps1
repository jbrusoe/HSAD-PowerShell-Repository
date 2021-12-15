Import-Module ActiveDirectory

$ADUsers = Import-Csv "C:\Users\jbrusoeadmin\Documents\GitHub\HSC-PowerShell-Repository\Set-EA10ByCSV\EA10-6.csv"
$ValidEA10 = ("Resource","StandardUser","EPA","Clinic","Ruby","Terminated")
$Count = 0

$OutputFile = $((Get-Date -Format yyyy-MM-dd-HH-mm) + "-SetEA10.csv")

foreach ($ADUser in $ADUsers)
{
	$user = Get-ADUser $ADUser.SamAccountName.Trim() -Properties extensionAttribute10
	
	Write-Output $("Current SamAccountName: " + $user.SamAccountName)
	Write-Output $("Current DN: " + $user.DistinguishedName)
	Write-Output $("extensionAttribute10: " + $user.extensionAttribute10)
	
	if ($ValidEA10 -contains $user.extensionAttribute10)
	{
		Write-Output "Valid extensionAttribute10"
	}
	elseif ($user.extensionAttribute10 -eq "Unsure")
	{
		Write-Output "Removing unsure attribute"
		$user | Set-ADUser -Remove @{extensionAttribute10="Unsure"}
	}
	else
	{
		Write-Output "Invalid extensionAttribute10"
		$user | select SamAccountName,extensionAttribute10,DistinguishedName | Export-Csv $OutputFile -Append
		
		Write-Output "Setting extensionAttribute10"
		$user | Set-ADUser -Add @{extensionAttribute10=$ADUser.extensionAttribute10.Trim()}
		Set-ADUser -Instance $user
	}
	
	$Count++
	Write-Output "User count: $Count"
	Write-Output "*******************"
	
	Start-Sleep -s 2
}