Import-Module ActiveDirectory

$SearchBase = "OU=Students,OU=SOM,OU=hsc,DC=hs,DC=wvu-ad,DC=wvu,DC=edu"
$users = Get-ADUser -Properties extensionAttribute10 -Filter * -SearchBase $SearchBase
$ValidEA10 = ("Resource","StandardUser","EPA","Clinic","Ruby")
$Count = 0

$UsersToCheck =  $((Get-Date -Format yyyy-MM-dd-HH-mm) + "-SOMStudents.csv")
New-Item -type File $UsersToCheck -Force

foreach ($user in $users)
{
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
		$user | select SamAccountName,extensionAttribute10,DistinguishedName | Export-Csv $UsersToCheck -Append
			
		#$user | Set-ADUser -Add @{extensionAttribute10="StandardUser"}
		#Set-ADUser -Instance $user
		
	
	}
	
	$Count++
	Write-Output "User count: $Count"
	Write-Output "*******************"
}