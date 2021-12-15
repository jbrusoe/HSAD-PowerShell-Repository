Add-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"
Connect-QADService -Service 'wvuh.wvuhs.com' 
#####echo "Establishing Connections........"
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
$mbrccgroups = get-QADGroup -GroupType 'Distribution' -SizeLimit '0' | where {($_.groupname -like "*mbrcc*") -or ($_.groupname -like "*9 west*") -or ($_.groupname -like "*bmtu*") -or ($_.groupname -like "*WVUM surgical Oncology Expansion (9E)*")} | sort displayname
#$mbrccgroups = get-QADGroup -GroupType 'Distribution' | where {$_.groupname -like "*mbrcc*"} | sort displayname
#$mbrccgroups = get-QADGroup -GroupType 'Distribution' | where {$_.groupname -like "WVUH 9 West*"} | sort displayname
#$mbrccgroups3 = get-QADGroup -GroupType 'Distribution' | where {$_.groupname -like "WVUH BMTU*"} | sort displayname

##########echo " "
##########echo " "
##########echo "Listing of all WVUH MBRCC Distribution groups"
##########echo "***************************"
##########echo " "
foreach ($pass in $mbrccgroups){
#echo $pass.displayname

$allmbrccgroups += @($pass)
}


foreach ($listing in $allmbrccgroups){
###########echo " "
###########echo " "
############echo $listing.groupname
###########echo $listing.displayname
############echo "this is the listing.displayname"
###########echo "****************************"
$GroupName = $listing.displayname




#echo $Groupname



# Find members in group
#$GroupMembers = @(Get-QADGroupMember $listing.groupname | where {$_.name -notlike "*@*"} | select Name,email,department,title,groupname | sort name)
$GroupMembers = @(Get-QADGroupMember $listing.groupname | select Name,email,department,title,groupname,displayname | sort name)
#echo $GroupMembers.groupname
foreach ($turn in $GroupMembers){

if ($turn.name -eq "Snider-Ennis, Courie") {$turn.email = "courie.sniderennis1@wvumedicine.org"}
if ($turn.name -eq "Chilcote, Kaleena") {$turn.email = "kaleena.chilcote@hsc.wvu.edu"}
if ($turn.email -eq "tina.helms2@wvumedicine.org") {$turn.email = "tina.helms@wvumedicine.org"}
if ($turn.email -eq "sonikpreet.aulakh.m@wvumedicine.org") {$turn.email = "sonikpreet.aulakh@hsc.wvu.edu"}
if ($turn.name -eq "Aulakh, Sonikpreet") {$turn.email = "sonikpreet.aulakh@hsc.wvu.edu"}

if ($turn.name -like "*@*"){
$turn.email = $turn.name
$turn.name = $turn.displayname}
if ($turn.name -eq "Alan Thomay"){$turn.email = "aathomay@hsc.wvu.edu"}
$turn.groupname = $GroupName
$Complete += @($turn)}

#$Complete += @($GroupMembers)
#$test = @($GroupMembers)
#foreach ($pass in $test){
#$test2 += @($pass)
##$test2 += $GroupName
#}
##echo "2nd loop"



foreach ($a in $GroupMembers){$a.email = $a.email.ToLower()}
foreach ($b in $GroupMembers){$b.email = $b.email.TrimEnd()}
foreach ($n in $GroupMembers){$n.email = $n.email + ";"}
#echo $GroupMembers

foreach ($member in $GroupMembers){
#$member.groupname = $GroupName
#########echo $member.name
#########echo $member.email
#########echo $member.department
#########echo $member.title

$email += @($member.email | where {$member.email -Like '*wvumedicine*'})

$emailSorted = @($email | sort)
$AllMembers += @($member.name | where {$member.email -Like '*wvumedicine*'})
#echo $member.groupname
#$member.membership = $GroupName
#echo $member.membership
#echo "****************************"
##########echo " "
}
##########echo " "
##########echo " "
}
$AllMembersUnique = @($AllMembers | select -Unique)
$AllMembersUnique = @($AllMembersUnique | sort )
##########echo $AllMembersUnique
##########echo $AllMembersUnique.count

$OutputNames += @($AllMembersUnique)
$output = "Loading " + $AllMembersUnique.count + " users from the WVUH AD Groups"
#echo $output


#$clincOutputwvuhs = $clincOutputwvuhs
#echo "starting wvuhs script"
#& "$myDir\Clinic_wvuhs.ps1"
#$EmailListWVUHS = $clincOutputwvuhs
#echo $EmailListWVUHS
#echo "that was the WVUHS Users"

#$EmailList += @($EmailListWVUHS)
$EmailList += @($emailSorted) 
$EmailList += @($emailSorted1) 
$EmailList += @($emailSorted2) 
$EmailList += @($emailSorted3) 
$EmailList += @($emailSorted4) 


$EmailListUnique += @($EmailList | sort | select -Unique) 
$ClinicalGroups = get-content \\hs-mbrcc\mbrcc\DistroLists\addClinicalGroups.txt
$EmailListUnique += $ClinicalGroups

foreach ($r in $EmailListUnique){$r = $r.ToLower()}

$EmailListUnique = @($EmailListUnique | select -Unique)


foreach ($t in $EmailListUnique){
  if (($t -notlike "peckc@wvu*") -and ($t -notlike "hardenab@wvu*") -and ($t -notlike "sonikpreet.aulakh.m@*")){
$EmailListUnique2 += @($t)}
}

#echo $EmailListUnique2
$output5 = "There are " + $EmailListUnique2.count + " users after combining the lists"
#echo $output5
$Global:clinicOutput = $EmailListUnique2
#echo $EmailListUnique2
Disconnect-QADService -Service 'wvuh.wvuhs.com' 
#Disconnect-QADService -Service 'wvuhs.com'

#pause
#Write-Host "Press any key to close this window"
#$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
