Add-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"


#Retrieve and load XML feed of "Extra Newsletter People" from MBRCC Website
$url2 = New-Object XML
#$url2.load("https://sole.hsc.wvu.edu/Apps/Directory/XmlView.aspx?feed=b0154a3a-58c8-452a-ae83-23f2cf0ba9ec")
$users2 = @($url2.wvuhscdirectory.person)
if ($users2){
foreach ($u in $users2){if (($u.firstname -eq "James") -and ($u.lastname -eq "Brick")){$u.mail1 = "jbrick@hsc.wvu.edu"}}
foreach ($a in $users2){$a.mail1 = $a.mail1.ToLower()}
foreach ($b in $users2){$b.mail1 = $b.mail1.TrimEnd()}
foreach ($n in $users2){$n.mail1 = $n.mail1 + ";"}
foreach ($user2 in $users2){
$email2 += @($user2.mail1)
}
}





###############Adding Users from AD Group "MBRCC eNews Extras"############

$mbrccEnewsExtrasgroup = get-QADGroup -GroupType Security -SizeLimit 0 | where {($_.'Name' -like 'MBRCC eNews Extras')} | sort name

foreach ($pass in $mbrccEnewsExtrasgroup){

$allmbrccgroups += @($pass)
}




foreach ($listing in $allmbrccgroups){

$GroupName = $listing.name







# Find members in group
#$GroupMembers = @(Get-QADGroupMember $listing.groupname | where {$_.name -notlike "*@*"} | select Name,email,department,title,groupname | sort name)
#echo $Groupname
$GroupMembers = @(Get-QADGroupMember $listing.name | where {($_.'name' -like '* *') -and ($_.'name' -notlike '*lab*') -and ($_.'accountisdisabled' -eq $false)} | select email,Name,department,title,groupname,displayname,lastname,ntaccountname -Unique | sort email,lastname,ntaccountname)
#echo $GroupMembers.groupname

foreach ($a in $GroupMembers){$a.email = $a.email.ToLower()}
foreach ($b in $GroupMembers){$b.email = $b.email.TrimEnd()}
Foreach ($c in $GroupMembers){$c.email = $c.email + ";"}
foreach ($turn in $GroupMembers){

if ($turn.name -like "*@*"){
$turn.email = $turn.name
$turn.name = $turn.displayname}

if ($turn.email -eq "linda.carte@wvumedicine.org;"){
#echo "Found her"
$turn.email = "cartel@wvumedicine.org;"}

$labemails +=  @($turn.email)
$turn.groupname = $GroupName
$Complete += @($turn.email)}
$labemails = $labemails | select -Unique

$labemails = @()

}
$Complete = $Complete | sort | select -unique

#echo $Complete

##########################################################################

$emailSorted2 = @($email2 | sort )
$EmailSorted2 += @($Complete)

$emailSorted2 = @($emailSorted2 | sort | select -unique )
###echo " "
###echo " "
###echo $emailSorted2
###$output2 = "There were " + $emailSorted2.count + " users imported from the Extra Newsletter People listing"
###echo $output2
#echo $emailsorted2
$Global:eNewsExtraUsers = $emailSorted2
###echo $emailSorted2
###Write-Host "Press any key to close this window"
###$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


