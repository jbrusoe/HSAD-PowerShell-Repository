Add-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"
#Connect-QADService -Service 'OU=MBRCC,OU=HSC,DC=HS,DC=wvu-ad,DC=wvu,DC=edu' 
#cls
#echo "Establishing Connections........"
##$WVUHmbrccgroups = get-QADGroup -GroupType 'Distribution' | where {$_.groupname -like "*mbrcc*"} | sort displayname
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

#####$Members = Get-QADGroupMember $Groupname | select name,lastname | sort lastname
#$mbrccgroups = get-QADGroup -GroupType 'Distribution' | sort displayname
#$mbrccgroups2 = @(Get-Member $mbrccgroups)
$mbrccgroups = get-QADGroup -GroupType Security -SizeLimit 0 | where {($_.'Name' -like '*lab') -or ($_.'Name' -like '*MIF Admin') -and ($_.'Name' -notlike '$*') -and ($_.'Name' -like '* *') -and ($_.'DN' -like '*MBRCC*')} | sort name
#$mbrccgroups2 = Get-QADGroup $mbrccgroup | where {$_.'Name' -like 'Lab'}
#echo $mbrccgroups
#####echo " "
#####echo " "
###echo "Listing of MBRCC Lab Groups"
###
###echo "***************************"
############Add-Content $FilePath2 "*****************************"
############Add-Content $FilePath2 " "
#####echo " "
foreach ($pass in $mbrccgroups){
#echo $pass.name
###########Add-Content $FilePath2 $pass.name
$allmbrccgroups += @($pass)
}


foreach ($listing in $allmbrccgroups){
#####echo " "
#####echo " "
##########Add-Content $FilePath2 " "
#echo $listing.groupname
#echo $listing.name
#echo "this is the listing.displayname"
#echo "****************************"
$GroupName = $listing.name
############Add-Content $FilePath2 $listing.name
############Add-Content $FilePath2 "***********************"
############Add-Content $FilePath2 " "



$Complete = @()

#if (($listing.name -notlike '*Weed*')){


# Find members in group
#$GroupMembers = @(Get-QADGroupMember $listing.groupname | where {$_.name -notlike "*@*"} | select Name,email,department,title,groupname | sort name)
#echo $Groupname
$GroupMembers = @(Get-QADGroupMember $listing.name | where {($_.'name' -like '* *') -and ($_.'name' -notlike '*lab*') -and ($_.'accountisdisabled' -eq $false) } | select email,Name,department,title,groupname,displayname,lastname,ntaccountname -Unique | sort email,lastname,ntaccountname)
#echo $GroupMembers.groupname

foreach ($a in $GroupMembers){$a.email = $a.email.ToLower()}
foreach ($b in $GroupMembers){$b.email = $b.email.TrimEnd()}
Foreach ($c in $GroupMembers){$c.email = $c.email + ";"}

#echo $GroupMembers.email
foreach ($turn in $GroupMembers){

#####echo $turn.displayname


if ($turn.name -like "*@*"){
$turn.email = $turn.name
$turn.name = $turn.displayname}

$labemails +=  @($turn.email)
#echo $labemails
$turn.groupname = $GroupName
#$Complete += @($turn.email)
#$labemails = $labemails | select -Unique

$Complete += $labemails}
#$labemails = @()
#$Complete += @($GroupMembers)
#$test = @($GroupMembers)
#foreach ($pass in $test){
#$test2 += @($pass)
##$test2 += $GroupName
#}
##echo "2nd loop"
################$emailtest = "blank@blank.blank"
################foreach ($member in $GroupMembers){
#################$member.groupname = $GroupName
################if ($emailtest -ne $member.email){
################$emailtest = $member.email
################echo $member.name
################echo $member.email
################if ($member.department -ne "none") {echo $member.department}
################if ($member.title -ne "none") {echo $member.title}
################Add-Content $FilePath2 $member.name
################Add-Content $FilePath2 $member.email
################if ($member.department -ne "none") {Add-Content $FilePath2 $member.department}
################if ($member.title -ne "none") {Add-Content $FilePath2 $member.title}
################Add-Content $FilePath2 " "
################}
#################echo $member.groupname
#################$member.membership = $GroupName
#################echo $member.membership
#################echo "****************************"
################echo " "
################}
#####echo " "
################echo " "









#}















$Complete = $Complete | sort | select -unique
}
#pause
foreach ($j in $complete){

if (($j -notlike "no.email*") -and ($j -notlike "*qq.com*") -and ($j -notlike "mfarrugia@hsc*") -and ($j -notlike "ihare@hsc*") -and ($j -notlike ";") -and ($j -notlike "seiranmanesh@hsc*") -and ($j -notlike "bjones@hsc*") -and ($j -notlike "smarkwell@hsc*") -and ($j -notlike "bmoses2@hsc*") -and ($j -notlike "sbsharma@hsc*") -and ($j -notlike "wslone@hsc*") -and ($j -notlike "dvanderbilt@hsc*") -and ($j -notlike "ewalk@hsc*") -and ($j -notlike "eaustin@*") -and ($j -notlike "rwatts@*") -and ($j -notlike "akanate-hsc@*") -and ($j -notlike "jaddison@*") -and ($j -notlike "jzheng@*") -and ($j -notlike "sweed@*") -and ($j -notlike "skennedy@*") -and ($j -notlike "tworkman@*") -and ($j -notlike "wsmith@*") -and ($j -notlike "jfarris2@*") -and ($j -notlike "ppifer@*")){
$completeClean += @($j)
}
}

#####echo " "
#####echo " "
$output = "Loading " + $Completeclean.count + " users from MBRCC Lab Groups in AD"
#####echo $output
#####echo $completeClean
#####echo " "
#####echo " "
######echo $complete
#####echo " "

$Global:mbrccLabsOutput = $completeclean