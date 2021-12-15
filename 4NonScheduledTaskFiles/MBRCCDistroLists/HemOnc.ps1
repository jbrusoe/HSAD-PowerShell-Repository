Add-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"

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



######################################################################################################################################
#Retrieve and load XML feed of "SECTION OF HEMATOLOGY / ONCOLOGY (MBRCC)" from HSC Directory
$url = New-Object XML
#$url.load("https://sole.hsc.wvu.edu/Apps/Directory/XMLView.aspx?DepartmentID=2079")
$users = @()
$users = @($url.wvuhscdirectory.person)
$users = $users | sort lastname



$output = "Loading " + $users.count + " users from the SECTION OF HEMATOLOGY / ONCOLOGY (MBRCC) directory webpage"
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
#####echo " "
#####echo " "
#####echo " "



################  Adding the MBRCC Hemonc AD Group  ################ 
$GroupMembers = @(Get-QADGroupMember -Indirect 'Hemonc' | where {($_.'name' -like '* *') -and ($_.'name' -notlike '*lab*') -and ($_.'name' -notlike '*cisoffice*') -and ($_.'name' -notlike '*formfill*') -and ($_.'accountisdisabled' -eq $false)} | select email)
#echo $GroupMembers.groupname
foreach ($a in $GroupMembers){$a.email = $a.email.ToLower()}
foreach ($b in $GroupMembers){$b.email = $b.email.TrimEnd()}
Foreach ($c in $GroupMembers){$c.email = $c.email + ";"}
foreach ($turn in $GroupMembers){


$MBRCCHemoncUsers += @($turn.email)}
$MBRCCHemoncUsers = $MBRCCHemoncUsers | sort 


$output4 = "Loading " + $MBRCCHemoncUsers.count + " users from MBRCC Hemonc Group in AD"
#echo $output4
#####echo " "
#####echo " "
#echo $MBRCCHemoncUsers
#####echo  " "

$hemOncUsers = @()
$hemOncUsers += $emailSorted
$hemOncUsers += $MBRCCHemoncUsers
$hemOncUsers = $hemOncUsers | select -Unique
#echo $hemOncUsers
$Global:hemOncOutput = $hemOncUsers