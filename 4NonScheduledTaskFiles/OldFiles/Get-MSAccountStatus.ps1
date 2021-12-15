$DisabledCount = 0

while ($true)
{
	Get-Date
	Get-ADUser microsoft -Properties LockedOut | select Enabled,LockedOut
	
	
	Start-Sleep -s 5
	
	Write-Output "********************"
}