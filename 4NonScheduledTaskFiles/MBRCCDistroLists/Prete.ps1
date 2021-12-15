Add-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"

#cls
#echo "Establishing Connections........"

$today=(Get-Date -UFormat "%m%d")
$date = $(Get-Date -Format 'ddMMMyyyy')
$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$LogFilePath = [string]$myDir


if (!$LogFilePath.EndsWith("\"))
{
	$LogFilePath = $LogFilePath + "\"
}
if ((Test-Path $LogFilePath) -eq $false)
{
md $LogFilePath
}
######echo " "
######echo " "
######echo " "
#######Beginning the import processes
######echo "********************************************************"
######echo "Beginning Import Process"
######echo "********************************************************"






################  Adding the MBRCC Prete Users AD Group  ################ 
$GroupMembers = @(Get-QADGroupMember -Indirect 'MBRCC Prete Users' | where {($_.'name' -like '* *') -and ($_.'name' -notlike '*lab*') -and ($_.'name' -notlike '*cisoffice*') -and ($_.'name' -notlike '*formfill*') -and ($_.'accountisdisabled' -eq $false)} | select email)
#echo $GroupMembers.groupname
foreach ($j in $Groupmembers) {if ($j.email -like "skennedy@hsc.wvu.edu") {$j.email = "skkennedy@hsc.wvu.edu"}}
foreach ($a in $GroupMembers){$a.email = $a.email.ToLower()}
foreach ($b in $GroupMembers){$b.email = $b.email.TrimEnd()}
Foreach ($c in $GroupMembers){$c.email = $c.email + ";"}

foreach ($turn in $GroupMembers){


$MBRCCPreteUsers += @($turn.email)}
$MBRCCPreteUsers = $MBRCCPreteUsers | sort 


$output4 = "Loading " + $MBRCCPreteUsers.count + " users from MBRCC Prete Users in AD"





$Global:preteOutput = $mbrccPreteUsers
#echo $mbrccPreteUsers