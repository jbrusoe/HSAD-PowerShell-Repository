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
######echo " "
######echo " "
######echo " "
#######Beginning the import processes
######echo "********************************************************"
######echo "Beginning Import Process"
######echo "********************************************************"
######



######################################################################################################################################
#Retrieve and load XML feed of "All_Members_AF" from HSC Directory
$url = New-Object XML
$url.load("https://sole.hsc.wvu.edu/Apps/Directory/XMLView.aspx?feed=b0afecd5-a6c9-4893-b4c7-a3f7732b1bdd")
$users = @()
$users = @($url.wvuhscdirectory.person)
$users = $users | sort lastname



$output = "Loading " + $users.count + " users from the All_Members_AF XML webpage"
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
$emailSortedAF = @($email | sort)
#####echo " "
#####echo " "
#echo $emailSortedAF
$usersFullname = @()
$email = @()



######################################################################################################################################
#Retrieve and load XML feed of "All_Members_GL" from HSC Directory
$url = New-Object XML
$url.load("https://sole.hsc.wvu.edu/Apps/Directory/XMLView.aspx?feed=a011222f-b9b8-48b7-8a41-12df1cd2b39f")
$users = @()
$users = @($url.wvuhscdirectory.person)
$users = $users | sort lastname



$output = "Loading " + $users.count + " users from the All_Members_GL XML webpage"
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
$emailSortedGL = @($email | sort)
#####echo " "
#####echo " "
#echo $emailSortedGL
$usersFullname = @()
$email = @()




######################################################################################################################################
#Retrieve and load XML feed of "All_Members_MR" from HSC Directory
$url = New-Object XML
$url.load("https://sole.hsc.wvu.edu/Apps/Directory/XMLView.aspx?feed=803b7fd7-d7cc-4890-a8a2-98f536b25aac")
$users = @()
$users = @($url.wvuhscdirectory.person)
$users = $users | sort lastname



$output = "Loading " + $users.count + " users from the All_Members_MR XML webpage"
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
$emailSortedMR = @($email | sort)
#####echo " "
#####echo " "
#echo $emailSortedMR
$usersFullname = @()
$email = @()




######################################################################################################################################
#Retrieve and load XML feed of "All_Members_SZ" from HSC Directory
$url = New-Object XML
$url.load("https://sole.hsc.wvu.edu/Apps/Directory/XMLView.aspx?feed=bba3af69-5036-4b70-841f-92969ed11e51")
$users = @()
$users = @($url.wvuhscdirectory.person)
$users = $users | sort lastname



$output = "Loading " + $users.count + " users from the All_Members_SZ XML webpage"
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
$emailSortedSZ = @($email | sort)
#####echo " "
#####echo " "
######echo $emailSortedSZ
#####echo " "
#####echo " "
$usersFullname = @()
$email = @()



####echo  " "
####echo "Combining Lists...."
####echo " "
####echo " "

$EmailList += @($emailSortedAF) 
$EmailList += @($emailSortedGL) 
$EmailList += @($emailSortedMR) 
$EmailList += @($emailSortedSZ) 
 


$EmailListUnique += @($EmailList | sort | select -Unique) 
#echo $emaillistunique
#####echo " "
#####echo " "
$output5 = "There are " + $EmailListUnique.count + " users after combining the lists"
#echo $output5

$Global:membersAllOutput = $EmailListUnique