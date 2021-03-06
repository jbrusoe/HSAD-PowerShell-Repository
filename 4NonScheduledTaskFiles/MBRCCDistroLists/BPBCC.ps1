Add-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"
#Connect-QADService -Service 'wvuh.wvuhs.com'
#cls
#echo "Establishing Connections........"
######$mbrccgroups = get-QADGroup -GroupType 'Security' | where {$_.groupname -like "*breastcare*"} | sort displayname
$today=(Get-Date -UFormat "%m%d")
$date = $(Get-Date -Format 'ddMMMyyyy')
$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
#$Location = Get-Location
$LogFilePath = [string]$myDir
#echo $GroupName


if (!$LogFilePath.EndsWith("\"))
{
	$LogFilePath = $LogFilePath + "\"
}
if ((Test-Path $LogFilePath) -eq $false)
{
md $LogFilePath
}
#####echo " "
#####echo " "
#####echo " "
######Beginning the import processes
#####echo "********************************************************"
#####echo "Beginning Import Process"
#####echo "********************************************************"





######################################################################################################################################
#Retrieve and load XML feed of "BETTY PUSKAR BREAST CARE CENTER (MBRCC)" from HSC Directory
$url = New-Object XML
$url.load("https://sole.hsc.wvu.edu/Apps/Directory/XMLView.aspx?DepartmentID=2073")
$users = @()
$users = @($url.wvuhscdirectory.person)
$users = $users | sort lastname



$output = "Loading " + $users.count + " users imported from the BETTY PUSKAR BREAST CARE CENTER (MBRCC) directory webpage"
#####echo " "
#echo $output
foreach ($i in $users){
$usersFullname += @($i.lastname + ", " + $i.firstname)}
###echo $usersFullname


foreach ($a in $users){$a.mail1 = $a.mail1.ToLower()}
foreach ($b in $users){$b.mail1 = $b.mail1.TrimEnd()}
foreach ($n in $users){$n.mail1 = $n.mail1 + ";"}
foreach ($user in $users){
$email += @($user.mail1)
}
$emailSorted2 = @($email | sort)
#####echo " "
#####echo " "
#echo $emailSorted
##########$output = "There were " + $emailSorted.count + " users imported from the BETTY PUSKAR BREAST CARE CENTER (MBRCC) directory webpage"
##########echo " "
##########echo $output
#####echo " "
#####echo " "
$usersFullname = @()

foreach ($j in $emailSorted2){

if (($j -notlike "mooremis@wvu*") -and ($j -notlike "smithce@wvu*") -and ($j -notlike "plumc@wvu*") -and ($j -notlike "saskoc@wvu*") ){

$emailSorted += @($j) 
}
}

$Global:bpbccOutput = $emailSorted
#echo $emailSorted
