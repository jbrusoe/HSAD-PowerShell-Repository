Add-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"
#Connect-QADService -Service 'wvuh.wvuhs.com'
#cls
#echo "Establishing Connections........"
##########$mbrccgroups = get-QADGroup -GroupType 'Distribution' | where {$_.groupname -like "*mbrcc*"} | sort displayname
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
#####


######################################################################################################################################
#Retrieve and load XML feed of "BONNIE WELLS WILSON MOBILE MAMMOGRAPHY PROGRAM (BONNIE’S BUS) (MBRCC)" from HSC Directory
$url = New-Object XML
$url.load("https://sole.hsc.wvu.edu/Apps/Directory/XMLView.aspx?DepartmentID=2074")
$users = @()
$users = @($url.wvuhscdirectory.person)
$users = $users | sort lastname



$output = "Loading " + $users.count + " users from the BONNIE WELLS WILSON MOBILE MAMMOGRAPHY PROGRAM (BONNIE’S BUS) (MBRCC) directory webpage"
#####echo " "
#echo $output
foreach ($i in $users){
$usersFullname += @($i.lastname + ", " + $i.firstname)}
##########echo $usersFullname


foreach ($a in $users){$a.mail1 = $a.mail1.ToLower()}
foreach ($b in $users){$b.mail1 = $b.mail1.TrimEnd()}
foreach ($n in $users){$n.mail1 = $n.mail1 + ";"}
foreach ($user in $users){
$email += @($user.mail1)
}
$emailSorted = @($email | sort)
#####echo " "
#####echo " "
#echo $emailSorted
$usersFullname = @()


$Global:BonniesBusOutput = $emailSorted