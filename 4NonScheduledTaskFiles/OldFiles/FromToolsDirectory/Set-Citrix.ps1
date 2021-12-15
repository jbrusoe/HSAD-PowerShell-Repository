$username = $args[0]
$ErrorActionPreference = "SilentlyContinue"

if ($username -eq $null)
{
	$username = Read-Host "Enter Username: "
}

try {
	echo "Setting home drive"
	set-qaduser $username -TsHomeDrive Z:
}
catch {
	echo "Error setting home drive path."
}

try {
	echo "Setting profile path"
	Set-qaduser $username -TsProfilePath \\hsdata.hs.wvu-ad.wvu.edu\tsprofiles\$username
}
catch {
	echo "Error setting profile path."
}

try {
	echo "Setting home directory"
	Set-qaduser $username -TsHomeDirectory \\hsdata.hs.wvu-ad.wvu.edu\tshome\$username
}
catch {
	echo "Error setting home directory path."
}