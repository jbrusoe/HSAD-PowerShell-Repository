#Connected/Pulling Data from WVUHS.wvuh.com

while ($Loop -le '2'){
$mbrccgroupswvuhs = @()

if ($Loop -gt '1'){Connect-QADService -Service 'wvuhs.com'}

$mbrccgroupswvuhs += get-QADGroup -GroupType 'Distribution' -SizeLimit '0' | where {($_.groupname -like "*mbrcc*") -or ($_.groupname -like "*9 west*") -or ($_.groupname -like "*bmtu*") -or ($_.groupname -like "*WVUM surgical Oncology Expansion (9E)*")} | sort displayname


$allmbrccgroups = @()
foreach ($pass in $mbrccgroupswvuhs){
#echo $pass.displayname

$allmbrccgroups += @($pass)
}

foreach ($listing in $allmbrccgroups){

if ($listing.GroupName){

$GroupName = $listing.displayname




#echo $GroupName
#echo $listing.GroupName
#pause

#echo "Line 70"

# Find members in group
#$GroupMembers = @(Get-QADGroupMember $listing.groupname | where {$_.name -notlike "*@*"} | select Name,email,department,title,groupname | sort name)
$GroupMemberswvuhs = @(Get-QADGroupMember $listing.GroupName | select Name,email,department,title,groupname,displayname | sort name)
#echo $GroupMembers.groupname
foreach ($turn in $GroupMemberswvuhs){
#if ($turn.Name -like "*mdw*"){echo $turn}
if ($turn.name -eq "Snider-Ennis, Courie") {$turn.email = "courie.sniderennis1@wvumedicine.org"}
if ($turn.Name -eq "mdw0032@wvuhs.com") {$turn.Name = "matthew.west@wvumedicine.org"}
if ($turn.name -eq "Chilcote, Kaleena") {$turn.email = "kaleena.chilcote@hsc.wvu.edu"}
if ($turn.email -eq "tina.helms2@wvumedicine.org") {$turn.email = "tina.helms@wvumedicine.org"}
if ($turn.email -eq "sonikpreet.aulakh.m@wvumedicine.org") {$turn.email = "sonikpreet.aulakh@hsc.wvu.edu"}
if ($turn.name -eq "Aulakh, Sonikpreet") {$turn.email = "sonikpreet.aulakh@hsc.wvu.edu"}

#if ($turn -like "*mdw*"){echo $turn

#pause}
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



foreach ($a in $GroupMemberswvuhs){$a.email = $a.email.ToLower()}
foreach ($b in $GroupMemberswvuhs){$b.email = $b.email.TrimEnd()}
foreach ($n in $GroupMemberswvuhs){$n.email = $n.email + ";"}
#echo $GroupMembers



foreach ($member in $GroupMemberswvuhs){
#$member.groupname = $GroupName
#########echo $member.name
#########echo $member.email
#########echo $member.department
#########echo $member.title





#$email += @($member.email | where {$member.email -Like '*wvumedicine*'})
$email += @($member.email)
$emailSorted = @($email | sort)
$AllMembers += @($member.name)
#$AllMembers += @($member.name | where {$member.email -Like '*wvumedicine*'})



#echo $member.groupname
#$member.membership = $GroupName
#echo $member.membership
#echo "****************************"
##########echo " "
}
##########echo " "
##########echo " "
}
}
$AllMembersUnique = @($AllMembers | select -Unique)
$AllMembersUnique = @($AllMembersUnique | sort )
##########echo $AllMembersUnique
##########echo $AllMembersUnique.count

$OutputNames += @($AllMembersUnique)
$output = "Loading " + $AllMembersUnique.count + " users from the WVUHS AD Groups"
#echo $output




$EmailList += @($emailSorted) 
$EmailList += @($emailSorted1) 
$EmailList += @($emailSorted2) 
$EmailList += @($emailSorted3) 
$EmailList += @($emailSorted4) 

$EmailListLooped += @($EmailList)
Disconnect-QADService -Service 'wvuh.wvuhs.com'
$Loop++
}

$EmailListUnique += @($EmailListLooped | sort | select -Unique) 
#$ClinicalGroups = get-content \\hs-mbrcc\mbrcc\DistroLists\addClinicalGroups.txt
#$EmailListUnique += $ClinicalGroups

#foreach ($r in $EmailListUnique){$r = $r.ToLower()}

#$EmailListUnique = @($EmailListUnique | select -Unique)


foreach ($t in $EmailListUnique){
  if (($t -notlike "peckc@wvu*") -and ($t -notlike "hardenab@wvu*") -and ($t -notlike "sonikpreet.aulakh.m@*")){
$EmailListUnique2 += @($t)}
}

#echo $EmailListUnique2
$output5 = "There are " + $EmailListUnique2.count + " users after combining the lists"
#echo $output5
#echo $EmailListUnique2
$Global:clinicOutputwvuhs = $EmailListUnique2
#echo $EmailListUnique2
Disconnect-QADService -Service 'wvuhs.com' 
