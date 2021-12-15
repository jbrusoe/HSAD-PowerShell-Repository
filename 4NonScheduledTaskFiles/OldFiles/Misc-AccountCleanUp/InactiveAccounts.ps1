$users = Import-csv InactiveAccounts2.csv

$Count = 0
foreach ($user in $users)
{
	$Count
	$user.SamAccountName
	$Count++
	
	$usr = Get-QADUser $user.SamAccountName
	
	if ($usr.Count -gt 1)
	{
		Return
	}
	else
	{
		$usr | remove-qadobject -Force
	}
	"********************"
	
	Start-Sleep -s 3
}