
Add-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"

$me = $env:USERNAME
$MyName = get-qaduser -SamAccountName $me

$OutputLists = @()
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
Echo "Comparing timestamps of CC Membership.xlsm (active) and CC Membership Converted.csv (temp)."
echo " "
$TempFilefullPath = "\\hs.wvu-ad.wvu.edu\public\mbrcc\csc\Publications\Do Not Use\CC Membership Converted.csv"
$ActiveFilefullPath = "\\hs.wvu-ad.wvu.edu\public\MBRCC\data\CC_Membership\CC Membership.xlsm"
$TempFileLastWrite = (get-item $TempFilefullPath).LastWriteTime
$ActiveFileLastWrite = (get-item $ActiveFilefullPath).LastWriteTime
$timespan = new-timespan -days 0 -hours 0 -minutes 1

$starline = "**************************************************************"
$activeoutput = "CC Membership.xlsm last updated " + $ActiveFileLastWrite
$tempoutput = "CC Membership Converted.csv last updated " + $TempFileLastWrite
echo $starline
echo $activeoutput
echo $tempoutput
echo $starline
echo " "


if (($ActiveFileLastWrite - $TempFileLastWrite) -gt $timespan) {
echo "Update needed. Updating the Membership.csv (temp) file"
    $xlCSV = 6
	$Excel = New-Object -Com Excel.Application 
	$Excel.visible = $True 
	$Excel.displayalerts=$False 
	#$WorkBook = $Excel.Workbooks.Open(1)("\\hs.wvu-ad.wvu.edu\public\MBRCC\data\CC_Membership\CC Membership.xlsx") 
	$WorkBook = $Excel.Workbooks.Open("\\hs.wvu-ad.wvu.edu\public\MBRCC\data\CC_Membership\CC Membership.xlsm")
	$Worksheet = $WorkBook.Worksheets.Item(1)
	#$Workbook.SaveAs("\\hs.wvu-ad.wvu.edu\public\MBRCC\CSC\test\CC Membership Converted.csv",$xlCSV) 
	$Worksheet.SaveAs("\\hs.wvu-ad.wvu.edu\public\MBRCC\CSC\Publications\Do Not Use\CC Membership Converted.csv",$xlCSV) 
	$Excel.quit()
echo "Update Complete"	
} 
else {
    echo "No update needed.  Membership.csv (temp) file is up to date."
}

echo " "
echo " "
echo "Please be patient as Member Info is compiled ..."
echo "This could take up to 30 seconds."
################for ($z=40; $z -gt 1; $z--) {
################  Write-Progress -Activity "Member Info is being compiled ..." -SecondsRemaining $z -CurrentOperation "$z% complete" -Status "Please wait."
################  Start-Sleep 1
################}
echo " "
$foofoo = Import-Csv -Path '\\hs.wvu-ad.wvu.edu\public\MBRCC\csc\Publications\Do Not Use\CC Membership Converted.csv' | where {(($_.MembershipBeginDate -ne "") -and ($_.MembershipEndDate -eq ""))} | select * | sort CCProgram

echo " "

$reloop = $false
###echo $reloop
$continueLoop = $True
while ($continueLoop -eq $True){
############################################if ($continueLoop -eq $True){


############################################
#Begin Menu Selection Area
############################################
$starline = "**************************************************************"

echo $starline
echo "Program Lists"
echo " "
echo "1. EMT & Metastasis"
echo "2. Breast"
echo "3. Osborn Hem Malignancy"
echo "4. T2R2"
echo "5. Allen Lung"
echo "6. Obesity"
echo "7. Health Services"
echo "8. Non-Aligned"
echo " "
echo "9. All Members"
echo $starline
echo " "
#echo " "
$selection = Read-Host "Please choose program number from list above"
if (($selection -ne "1") -and ($selection -ne "2") -and ($selection -ne "3") -and ($selection -ne "4") -and ($selection -ne "5") -and ($selection -ne "6") -and ($selection -ne "7") -and ($selection -ne "8") -and ($selection -ne "9")){
#echo "Please choose a number from 1-9"
$selection = Read-Host "Incorrect selection.  Please choose program number from list above"
}
else {
if ($selection -eq "1"){$choice = "EMT"}
if ($selection -eq "2"){$choice = "Breast"}
if ($selection -eq "3"){$choice = "Osborn"}
if ($selection -eq "4"){$choice = "T2R2"}
if ($selection -eq "5"){$choice = "Allen"}
if ($selection -eq "6"){$choice = "Obesity"}
if ($selection -eq "7"){$choice = "Health Services"}
if ($selection -eq "8"){$choice = "Non-Aligned"}
if ($selection -eq "9"){$choice = "All Members"}
}

echo " "
echo " "

if ($choice -eq 'EMT'){
$ProgramChoice = "You selected the " + $choice + " Program"
#$EMT_Members = @()
echo $ProgramChoice
}

if ($choice -eq 'Breast'){
$ProgramChoice = "You selected the " + $choice + " Program"
#$Breast_Members = @()
echo $ProgramChoice
}

if ($choice -eq 'Osborn'){
$ProgramChoice = "You selected the " + $choice + " Program"
#$Osborn_Members = @()
echo $ProgramChoice
}

if ($choice -eq "T2R2"){
$ProgramChoice = "You selected the " + $choice + " Program"
#$T2R2_Members = @()
echo $ProgramChoice
}

if ($choice -eq 'Allen'){
$ProgramChoice = "You selected the " + $choice + " Program"
#$Allen_Members = @()
echo $ProgramChoice
}

if ($choice -eq 'Obesity'){
$ProgramChoice = "You selected the " + $choice + " Program"
#$Obesity_Members = @()
echo $ProgramChoice
}

if ($choice -eq 'Health Services'){
$ProgramChoice = "You selected the " + $choice + " Program"
#$HealthServices_Members = @()
echo $ProgramChoice
}

if ($choice -eq 'Non-Aligned'){
$ProgramChoice = "You selected the " + $choice + " Program"
#$NonAligned_Members = @()
echo $ProgramChoice
}

if ($choice -eq 'All Members'){
$ProgramChoice = "You selected " + $choice
#$All_Members = @()
echo $ProgramChoice
}

############################################
#End Menu Selection Area
############################################






#***************************************
#Begin Compilation Process
#***************************************
###echo "Beginning Compilation Section"
###echo $reloop
if ($reloop -eq $False){
###echo "reloop equals "
###echo $reloop
echo " "
######################echo "Please wait as Member Info is compiled..."
######################################for ($z=40; $z -gt 1; $z--) {
######################################  Write-Progress -Activity "Member Info is being compiled ..." -SecondsRemaining $z -CurrentOperation "$z% complete" -Status "Please wait."
######################################  Start-Sleep 1
######################################}
######################echo " "
######################$foofoo = Import-Csv -Path '\\hs.wvu-ad.wvu.edu\public\MBRCC\csc\Publications\Do Not Use\CC Membership Converted.csv' | where {(($_.MembershipBeginDate -ne "") -and ($_.MembershipEndDate -eq ""))} | select * | sort CCProgram

$i=0
foreach ($member in $foofoo) {

if ($member.CCProgram -like "*EMT*"){$EMT_Members += @($member)}
if ($member.CCProgram -like "*Breast*"){$Breast_Members += @($member)}
if ($member.CCProgram -like "*Osborn*"){$Osborn_Members += @($member)}
if ($member.CCProgram -like "*T2R2*"){$T2R2_Members += @($member)}
if ($member.CCProgram -like "*Allen*"){$Allen_Members += @($member)}
if ($member.CCProgram -like "*Obesity*"){$Obesity_Members += @($member)}
if ($member.CCProgram -like "*Health Services*"){$HealthServices_Members += @($member)}
if ($member.CCProgram -like "*Non-Aligned*"){$NonAligned_Members += @($member)}

$All_Members += @($member)

}
}
if ($choice -eq 'EMT'){
$MemberOutput = $EMT_Members | sort 'Publishing Name'
}

if ($choice -eq 'Breast'){
$MemberOutput = $Breast_Members | sort 'Publishing Name'
}

if ($choice -eq 'Osborn'){
$MemberOutput = $Osborn_Members | sort 'Publishing Name'
}

if ($choice -eq "T2R2"){
$MemberOutput = $T2R2_Members | sort 'Publishing Name'
}

if ($choice -eq 'Allen'){
$MemberOutput = $Allen_Members | sort 'Publishing Name'
}

if ($choice -eq 'Obesity'){
$MemberOutput = $Obesity_Members | sort 'Publishing Name'
}

if ($choice -eq 'Health Services'){
$MemberOutput = $HealthServices_Members | sort 'Publishing Name'
}

if ($choice -eq 'Non-Aligned'){
$MemberOutput = $NonAligned_Members | sort 'Publishing Name'
}

if ($choice -eq 'All Members'){
$MemberOutput = $All_Members  | sort 'Publishing Name'
}

echo " "
$output= "There are " + $MemberOutput.count + " members in your selected program"
echo $output



############################################
#Prompt user for action
############################################
echo " "
echo $starline
echo "What do you want to do with the generated Member list?"
echo " "
echo "1. Generate list for Reference Manager Search"
echo "2. Bold Members in Program Publication Output"
echo "3. Display Program Members List"
echo $starline
echo " "
$decision = Read-Host "Please choose 1, 2, or 3"
echo " "

############################################
#Begin Refman Search Area
############################################
if ($decision -eq "1"){
echo "Highlight list below and paste into Reference Manager Search Box"
echo " "
$a = 0
foreach ($r in $MemberOutput){
$a++
if ($a -lt $MemberOutput.count){
$r.'Publishing Name' = "{" + $r.'Publishing Name' + "} OR "
}
else{
$r.'Publishing Name' = "{" + $r.'Publishing Name' + "}"
}
echo $r.'Publishing Name'

}
echo " "
}

############################################
#End Refman Search Area
############################################

if ($decision -eq "2"){
############################################
#Begin Output Script Cleaning Area
############################################
$startingPath = "\\hs.wvu-ad.wvu.edu\public\mbrcc\csc\publications\Programs\"
#$folderpath = Read-Host "Enter folder path of file"
$moveTo = $startingPath + $choice + "\"
$place = $startingPath
$file = $choice + ".txt"
$boldedFile = $choice + " Bolded on " + $date + ".txt"
$HtmlFile =  $choice + " " + $date + ".html"
#echo $file
$BackupFile = $choice +".txt"
Copy-Item ($place+$file) ($MoveTo+$BackupFile)
(Get-Content ($place+$file)) | ForEach-Object {$_ -replace "Publications", '<style type="text/css"> #Article a {text-decoration: none !important;} </style>'} | Set-Content ($place+$file)
(Get-Content ($place+$file)) | ForEach-Object {$_ -replace "PM :" , "PM:"} | Set-Content ($place+$file)
(Get-Content ($place+$file)) | ForEach-Object {$_ -replace "PMCID :" , "PMCID:"} | Set-Content ($place+$file)
(Get-Content ($place+$file)) | ForEach-Object {$_ -replace "ISI :" , "ISI:"} | Set-Content ($place+$file)
(Get-Content ($place+$file)) | ForEach-Object {$_ -replace "PMC :" , "PMC:"} | Set-Content ($place+$file)
(Get-Content ($place+$file)) | ForEach-Object {$_ -replace "PM:" , "http://www.ncbi.nlm.nih.gov/pubmed/"} | Set-Content ($place+$file)
(Get-Content ($place+$file)) | ForEach-Object {$_ -replace "PMCID:" , ""} | Set-Content ($place+$file)
(Get-Content ($place+$file)) | ForEach-Object {$_ -replace "ISI:" , 'http://gateway.isiknowledge.com/gateway/Gateway.cgi?GWVersion=2&amp;SrcAuth=Alerting&amp;SrcApp=Alerting&amp;DestApp=WOS&amp;DestLinkType=FullRecord;UT=" /'} | Set-Content ($place+$file)
(Get-Content ($place+$file)) | ForEach-Object {$_ -replace "<br><br>" , "<br><br>

"} | Set-Content ($place+$file)

############################################
#End Output Script Cleaning Area
############################################


############################################
#Begin Bolding Area
############################################
foreach ($p in $MemberOutput){
$p.'Publishing Name' = $p.'Publishing Name'.replace(","," ")
$p.'Publishing Name' = $p.'Publishing Name'.replace(".","")
$boldme = $MemberOutput.'Publishing Name'}
#echo $boldme

#$place = "y:\test\"
#$startingPath = [Environment]::GetFolderPath("Desktop")
#$startingPath = "\\hs.wvu-ad.wvu.edu\public\mbrcc\csc\publications\Programs\"
##$folderpath = Read-Host "Enter folder path of file"
#$moveTo = $startingPath + $choice + "\"
#$place = $startingPath
#$file = $choice + ".txt"
#$boldedFile = $choice + " Bolded on " + $date + ".txt"
#$HtmlFile =  $choice + " " + $date + ".html"
##echo $file
#$BackupFile = $choice +".txt"
#$name = (Get-Content 'y:\test\test Member List.txt')

foreach ($person in $boldme){
$replacename = "<b>"+$person+"</b>"
$processing = "Bolding " + $person
echo $processing
(Get-Content ($place+$file)) | ForEach-Object {$_-replace $person, $replacename} | Set-Content ($place+$file)
}
#Copy-Item ($place+$file) ($MoveTo+$BackupFile)
Copy-Item ($place+$file) ($MoveTo+$HtmlFile)
Copy-Item ($place+$file) ($MoveTo+$BoldedFile)
Remove-Item ($place+$file)
}
############################################
#End Bolding Area
############################################

############################################
#Begin Display Members Area
############################################
if ($decision -eq "3"){
if ($choice -eq "All Members"){$choice = "All"}
echo " "
$headerline = $Choice + " Program Members"
echo $headerline
echo " "
foreach ($l in $MemberOutput){
echo $l.'Last,First'
}
echo " "
}

############################################
#End Display Members Area
############################################


###########################################
#End continueLoop for loop
###########################################

echo $starline
echo " "
$loopChoice = Read-Host "Do you want to make another selection? Y or N"
if (($loopChoice -ne "Y") -and ($loopChoice -ne "N")){
#echo "Please choose a number from 1-9"
$selection = Read-Host "Incorrect selection.  Please choose either Y or N"
}
else{

if ($loopChoice -eq "Y"){
$reloop = $True
cls
}
else {
$continueLoop = $False
}

echo " "
echo " "
echo " "
}

############################################}
}



Write-Host "Press any key when finished to close the window"

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


