$users = get-qaduser -sizelimit 0 -includedproperties useraccountcontrol -searchroot "hs.wvu-ad.wvu.edu/hsc/SOM"

New-Item -name "UAC3.csv" -type file -force
$count = 0

foreach ($user in $users)
{
	$Error.Clear()
	
	"Username: " + $user.samaccountname
	$InitialUAC = $user.useraccountcontrol
	
	
	
	if (($InitialUAC -eq 66080) -OR ($InitialUAC -eq 66082) -OR ($InitialUAC -eq 544) -OR ($InitialUAC -eq 546))
	{
		"Setting UAC"
		"Initial UAC: " + $InitialUAC
		
		if ($count -lt 5)
		{
			$count
			Read-Host "Proceed"
			$count++
		}
	
		Set-ADAccountControl $user.samaccountname -PasswordNotRequired $false
		start-sleep -s 1
		
		"Done setting UAC"
		$newuser = get-qaduser -samaccountname $user.samaccountname -includedproperties useraccountcontrol
		$newuac = $newuser.useraccountcontrol
		
		while (($newuac -eq $InitialUAC) -AND ($Error.Count -eq 0))
		{
			"In while loop"
			$newuser = get-qaduser -samaccountname $user.samaccountname -includedproperties useraccountcontrol
			
			start-sleep -s 2
			
			$newuac = $newuser.Useraccountcontrol
		}
	}
	else
	{
		"No change needed"
	}
	
	$FinalUser = get-qaduser $user.samaccountname -sizelimit 0 -includedproperties useraccountcontrol
	$FinalUAC = $FinalUser.useraccountcontrol
	
	$Output = $user.samaccountname +"," +  $InitialUAC + "," + $FinalUAC
	
	if ($Error.Count -gt 0)
	{
		$Output += "Error setting UAC"
	}
	else
	{
		if ($InitialUAC -eq $FinalUAC)
		{
			$Output += ",No UAC change"
		}
		else
		{
			$Output += ",UAC Changed"
		}

		$Output

		Add-Content UAC3.csv -value $Output
	}
	
	"*************************"
}