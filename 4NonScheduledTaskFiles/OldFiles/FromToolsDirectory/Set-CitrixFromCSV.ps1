#$ErrorActionPreference = "SilentlyContinue"

$users = import-csv c:\ad-development\HSXP.csv

foreach ($user in $users)
{
	#echo $username

	try {
		echo "Setting home drive"
		get-qaduser -samaccountname $user.username -service hs.wvu-ad.wvu.edu | set-qaduser -TsHomeDrive Z:
	}
		
	catch {
		echo "Error setting home drive path."
	}

	try {
		echo "Setting profile path"
		#echo $user.username
		$profile = "\\hsdata.hs.wvu-ad.wvu.edu\tsprofiles\" + $user.username
		echo $profile
		get-qaduser -samaccountname $user.username -service hs.wvu-ad.wvu.edu | Set-qaduser -TsProfilePath $profile
		}
	catch {
		echo "Error setting profile path."
	}

	try {
		echo "Setting home directory"
		#echo $user.username
		$homepath = "\\hsdata.hs.wvu-ad.wvu.edu\tshome\" + $user.username
		echo $homepath
		get-qaduser -samaccountname $user.username -service hs.wvu-ad.wvu.edu | Set-qaduser -TsHomeDirectory $homepath
	}
	catch {
		echo "Error setting home directory path."
	}

}