
Add-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"

$me = $env:USERNAME
$MyName = get-qaduser -SamAccountName $me
$DoNotShow = "No"
#echo "MembersCalled"
#echo $MembersCalled2
#echo "DoNotShow"
#echo $DoNotShow
if($MembersCalled2 -eq "Yes"){$DoNotShow = "Yes"}
#echo "MembersCalled"
#echo $MembersCalled2
#echo "DoNotShow"
#echo $DoNotShow
$OutputLists = @()
$MembersAllEmail = @()
$MembersAllEmail2 = @()
$comboList = 0
$today=(Get-Date -UFormat "%m%d")
$date = $(Get-Date -Format 'ddMMMyyyy')
$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFilePath = [Environment]::GetFolderPath("Desktop")

if (!$LogFilePath.EndsWith("\"))
{
	$LogFilePath = $LogFilePath + "\"
}
if ((Test-Path $LogFilePath) -eq $false)
{
md $LogFilePath
}
if ($DoNotShow -eq "Yes"){
echo " "
Echo "Comparing timestamps of CC Membership.xlsm (active) and CC Membership Converted.csv (temp)."
echo " "
}
$TempFilefullPath = "\\hs.wvu-ad.wvu.edu\public\MBRCC\DistroLists\CC Membership Converted.csv"
$ActiveFilefullPath = "\\hs.wvu-ad.wvu.edu\public\MBRCC\data\CC_Membership\CC Membership.xlsm"
$TempFileLastWrite = (get-item $TempFilefullPath).LastWriteTime
$ActiveFileLastWrite = (get-item $ActiveFilefullPath).LastWriteTime
$timespan = new-timespan -days 0 -hours 0 -minutes 1

$starline = "**************************************************************"
$activeoutput = "CC Membership.xlsm last updated " + $ActiveFileLastWrite
$tempoutput = "CC Membership Converted.csv last updated " + $TempFileLastWrite
if ($DoNotShow -eq "Yes"){
echo $starline
echo $activeoutput
echo $tempoutput
echo $starline
echo " "
}

if (($ActiveFileLastWrite - $TempFileLastWrite) -gt $timespan) {
if ($DoNotShow -eq "Yes"){
echo "Update needed. Updating the Membership.csv (temp) file"
echo "This may take a short period of time to complete.  Please watch for any prompts."
}
    $xlCSV = 6
	$Excel = New-Object -Com Excel.Application 
	$Excel.visible = $True 
	$Excel.displayalerts=$False 
	
	$WorkBook = $Excel.Workbooks.Open("\\hs.wvu-ad.wvu.edu\public\MBRCC\data\CC_Membership\CC Membership.xlsm")
	$Worksheet = $WorkBook.Worksheets.Item(1)
	
	$Worksheet.SaveAs("\\hs.wvu-ad.wvu.edu\public\MBRCC\DistroLists\CC Membership Converted.csv",$xlCSV) 
	$Excel.quit()
if ($DoNotShow -eq "Yes"){
echo "Update Complete"	
}
} 
else {
if ($DoNotShow -eq "Yes"){ 
 echo "No update needed.  Membership.csv (temp) file is up to date."
 }
}

if ($DoNotShow -eq "Yes"){echo " "}
$foofoo = Import-Csv -Path '\\hs.wvu-ad.wvu.edu\public\MBRCC\DistroLists\CC Membership Converted.csv' | where {(($_.MembershipBeginDate -ne "") -and ($_.MembershipEndDate -eq ""))} | select * | sort 'Last,First'
#echo $foofoo
if ($DoNotShow -eq "Yes"){echo " "}


foreach ($member in $foofoo) {



$All_Members += @($member)

}



$MemberOutput = $All_Members  | sort 'Publishing Name'

#echo $MemberOutput.email










foreach ($l in $MemberOutput){
#echo $l.'Last,First'    #Use to display name
#echo $l.email    #Use to display email address 
#echo " "
$l.'Last,First' = $l.'Last,First' +";"
$MembersPotentialNames += $l.'Last,First' 


############if ($l.email -ne ""){
############$l.email = $l.email + ";"
############$MembersPotentialEmail += $l.email
############}
}
#echo " "
#echo $MembersPotentialEmail
echo $MembersPotentialNames
####################################################$Courtney_DeVries = "courtney.devries@hsc.wvu.edu" +";"
####################################################$MembersPotentialEmail += $Courtney_DeVries

$MembersPotentialEmail2 += @($MembersPotentialEmail | sort | select -Unique)

#echo $MembersPotentialEmail2

#echo " "
#$output= "There are " + $MemberOutput.count + " members in your selected program"
#echo $output



#echo $MembersPotentialEmail2
#echo $MembersPotentialNames
$Global:MembersPotentialOutput = $MembersPotentialEmail2






#Write-Host "Press any key when finished to close the window"

#$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

pause