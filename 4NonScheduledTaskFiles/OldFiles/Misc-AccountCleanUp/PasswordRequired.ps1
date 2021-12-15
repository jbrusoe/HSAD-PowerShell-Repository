$users = get-qaduser -sizelimit 0

$ErrorSetting = @()

foreach ($user in $users)
{
	$user.samaccountname
	
	Set-Adaccountcontrol -PasswordNotRequired $false -identity $user.samaccountname
	
	if ($Error.Count -gt 0)
	{
		$ErrorSetting += "$user.samaccountname"
		$Error.Clear()
	}
}

Write-Output "`n`nError setting"
$ErrorSetting