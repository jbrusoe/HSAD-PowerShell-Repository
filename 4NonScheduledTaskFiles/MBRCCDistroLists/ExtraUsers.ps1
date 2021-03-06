Add-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"
########################Connect-QADService -Service 'wvuh.wvuhs.com'
#cls
########################echo "Establishing Connections........"
########################$mbrccgroups = get-QADGroup -GroupType 'Distribution' | where {$_.groupname -like "*mbrcc*"} | sort displayname
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
###################echo " "
###################echo " "
###################echo " "
####################Beginning the import processes
###################echo "********************************************************"
###################echo "Beginning Import Process"
###################echo "********************************************************"

#Retrieve and load XML feed of "All Directory" from MBRCC Website
$url = New-Object XML
$url.load("https://sole.hsc.wvu.edu/Apps/Directory/XmlView.aspx?feed=88478e85-c932-4cca-9da3-094848487c3f")
$users = @($url.wvuhscdirectory.person)
foreach ($a in $users){$a.mail1 = $a.mail1.ToLower()}
foreach ($b in $users){$b.mail1 = $b.mail1.TrimEnd()}
foreach ($n in $users){$n.mail1 = $n.mail1 + ";"}
foreach ($user in $users){
$email += @($user.mail1)
}
$emailSorted = @($email | sort )
#################echo " "
#################echo " "
##################echo $emailSorted
#################$output = "There were " + $emailSorted.count + " users imported from the All Directory listing"
#################echo " "
#################echo $output
#################echo " "
#################echo " "
#################
#################
#################
#################
#################
#################echo "Processing the WVUH Distribution Lists"
#################echo " "
#################echo " "

##################################Retrieve WVUH users from wvuhs.wvuh.com AD Distribution Lists
##################################$mbrccgroups = get-QADGroup -GroupType 'Distribution' | where {$_.groupname -like "*mbrcc*"} | sort displayname
#################################foreach ($listing in $mbrccgroups){
#################################$GroupMembers = @(Get-QADGroupMember $listing.groupname | select Name,email | sort name)
#################################
#################################	foreach ($turn in $GroupMembers){
#################################	# Converting the users with email address only to name and email
#################################		if ($turn.name -like "*@*"){
#################################		$turn.email = $turn.name
#################################		}
#################################	
#################################	}
#################################	foreach ($a in $GroupMembers){$a.email = $a.email.ToLower()}
#################################	foreach ($b in $GroupMembers){$b.email = $b.email.TrimEnd()}
#################################	foreach ($n in $GroupMembers){$n.email = $n.email + ";"}
#################################	$WVUHusers += @($GroupMembers.email)
#################################}
#################################$WVUHusersSorted = @($WVUHusers | sort )
##################################echo $WVUHusersSorted
#################################$output = "There were " + $WVUHusersSorted.count + " users imported from the WVUH Distribution Lists"
#################################echo " "
#################################echo " "
#################################echo $output
#################################echo " "
#################################echo " "
#################################echo " "
#################################echo " "

#Combining all the lists into one for final output
$AllGroups += @($emailSorted)
############$AllGroups += @($WVUHusersSorted)
$AllGroups = @($AllGroups | sort )


$output = "The combined lists have " + $AllGroups.count + " users"
#####echo $output
#####echo " "
#####echo " "
#####echo " "
#####echo " "
#Removing duplicates
$AllUsersUnique = @($AllGroups | select -Unique)
foreach ($j in $AllUsersUnique){

if (($j -notlike "*ybakri@hsc.wvu*") -and ($j -notlike "*crowell*") -and ($j -notlike ";") -and ($j -notlike "*ljaros@hsc.wvu*") -and ($j -notlike "*jrogers@hsc.wvu*") -and ($j -notlike "mooremis@wvu*") -and ($j -notlike "smithce@wvu*") -and ($j -notlike "plumc@wvu*") -and ($j -notlike "saskoc@wvu*")){
$AllUsersUniqueClean += @($j)
}
}
#####################echo $AllUsersUniqueClean
######################$output = "There are " + $AllUsersUniqueClean.count + " users after removing duplicates"
######################echo $output

$Global:allDirectoryUsers = $AllUsersUniqueClean
#echo $AllUsersUniqueClean
#pause

##echo $AllUsersUnique.count
##echo $AllUsersUniqueClean.count











