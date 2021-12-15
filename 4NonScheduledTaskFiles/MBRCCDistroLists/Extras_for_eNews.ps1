Add-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"








###############Adding Users from AD Group "MBRCC eNews Extras"############

$mbrccEnewsExtrasgroup = get-QADGroup -GroupType Security -SizeLimit 0 | where {($_.'Name' -like 'MBRCC eNews Extras')} | sort name

foreach ($pass in $mbrccEnewsExtrasgroup){

$allmbrccgroups += @($pass)
}




foreach ($listing in $allmbrccgroups){

$GroupName = $listing.name

#echo $listing.name





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

