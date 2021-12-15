
Connect-QADService -Service 'wvuh.wvuhs.com' 

$mbrccgroups = get-QADGroup -GroupType 'Distribution' -SizeLimit '0' |
	where {($_.groupname -like "*mbrcc*") -or ($_.groupname -like "*9 west*") -or
			($_.groupname -like "*bmtu*") -or ($_.groupname -like "*WVUM surgical Oncology Expansion (9E)*")} |
	sort displayname


#Note (May 14, 2021): $allmbrccgroups and $mbrccgroups are the same


foreach ($listing in $allmbrccgroups){

	$GroupName = $listing.displayname

	$GroupMembers = @(Get-QADGroupMember $listing.groupname | select Name,email,department,title,groupname,displayname | sort name)

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
		$Complete += @($turn)
	}

	foreach ($a in $GroupMembers){$a.email = $a.email.ToLower()}
	foreach ($b in $GroupMembers){$b.email = $b.email.TrimEnd()}
	foreach ($n in $GroupMembers){$n.email = $n.email + ";"}

	foreach ($member in $GroupMembers){
		$email += @($member.email | where {$member.email -Like '*wvumedicine*'})

		$emailSorted = @($email | sort)
		$AllMembers += @($member.name | where {$member.email -Like '*wvumedicine*'})
	}
}

$AllMembersUnique = @($AllMembers | select -Unique)
$AllMembersUnique = @($AllMembersUnique | sort )

$OutputNames += @($AllMembersUnique)
$output = "Loading " + $AllMembersUnique.count + " users from the WVUH AD Groups"

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

$output5 = "There are " + $EmailListUnique2.count + " users after combining the lists"
#echo $output5
$Global:clinicOutput = $EmailListUnique2
