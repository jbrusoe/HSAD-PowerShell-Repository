$ADGroup = Get-ADGroup "Office 365 Base Licensing Group"
$NewGroup = Get-ADGroup "M365 A3 for Faculty Licensing Group"

$UsersToRemove = Get-ADGroupMember -Identity $ADGroup.DistinguishedName #|
					#Select -First 250

$UserCount = 1

foreach ($UserToRemove in $UsersToRemove) {
		$SamAccountName = $UserToRemove.SamAccountName
		Write-Output "Current User: $UserToRemove"
		Write-Output "User Count: $UserCount"
		$UserCount++
		
		Write-Output "Removing User from old group"
		$ADGroup | Remove-ADGroupMember -Members $SamAccountName -Confirm:$false
		
		Write-Output "Adding user to new group"
		Add-ADGroupMember -Identity $NewGroup.DistinguishedName -Members $SamAccountName
		
		Start-Sleep -s 1
		
		Write-Output "*******************************"
}