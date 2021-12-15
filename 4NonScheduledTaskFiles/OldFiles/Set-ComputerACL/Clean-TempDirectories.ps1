cls

$pcs = Get-ADComputer -SearchBase "OU=ClinicPCs,OU=SOD,OU=HS Computers,DC=HS,DC=wvu-ad,DC=wvu,DC=edu" -Filter *

foreach ($pc in $pcs)
{
	if (($pc.Name -ne "SOD-1095-04"))# -AND ($pc.Name -ne "SOD-LC-1040-GP1") -AND ($pc.Name -ne "SOD-DG-1025") )
	{
	$Error.Clear()

	"Current Computer: " + $pc.Name
	
    $path = "\\" + $pc.Name + "\c$\windows\temp\*"
    "Current Path: $path"
    
	Remove-Item $path -force -recurse -verbose -ea "SilentlyContinue"
	
	"*****************************************"
	}
}