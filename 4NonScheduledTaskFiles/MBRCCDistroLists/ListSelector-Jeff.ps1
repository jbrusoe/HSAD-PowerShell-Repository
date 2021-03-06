Add-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"

$me = $env:USERNAME
$MyName = get-qaduser -SamAccountName $me
#####echo $MyName.GivenName
#$me = "ageorg11"
#Connect-QADService -Service 'wvuh.wvuhs.com'
####cls
#echo "Establishing Connections........"
$OutputLists = @()
$comboList = 0
$today=(Get-Date -UFormat "%m%d")
$date = $(Get-Date -Format 'ddMMMyyyy')
$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFilePath = [Environment]::GetFolderPath("Desktop")
#$LogFilePath = [string]$myDir
$LogFilePath = "\\hs-mbrcc\mbrcc\DistroLists\Generated_Lists\" + $MyName.GivenName + "\"
#echo $GroupName
$MembersCalled = 0
if (!$LogFilePath.EndsWith("\"))
{
	$LogFilePath = $LogFilePath + "\"
}
#$LogFilePath = $LogFilePath + "Generated Lists\"
if ((Test-Path $LogFilePath) -eq $false)
{
md $LogFilePath
}
echo " "
echo " "
echo " "



$x = @()

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 



##$objListbox = New-Object System.Windows.Forms.Listbox 
##$objListbox.Location = New-Object System.Drawing.Size(10,40) 
##$objListbox.Size = New-Object System.Drawing.Size(260,20) 
##
##$objListbox.SelectionMode = "MultiExtended"
##
##[void] $objListbox.Items.Add("Members List")
##[void] $objListbox.Items.Add("Lab List")
##[void] $objListbox.Items.Add("MBRCC Admin")
##[void] $objListbox.Items.Add("WVUHealthcare List")
##[void] $objListbox.Items.Add("All Inclusive List")
##
##$objListbox.Height = 70
##$objForm.Controls.Add($objListbox) 
##$objForm.Topmost = $True
##
##$objForm.Add_Shown({$objForm.Activate()})
##[void] $objForm.ShowDialog()


$stuff = "" + $MyName.GivenName + "'s List Creator"

$objForm = New-Object System.Windows.Forms.Form 
#$objForm.Text = "Email List Generator"
$objForm.Text = $stuff
$objForm.Size = New-Object System.Drawing.Size(310,300) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True

$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {
        foreach ($objItem in $objListbox.SelectedItems)
            {$x += @($objItem)}
        $objForm.Close()
    }
    })

$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,238)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"

$OKButton.Add_Click(
   {
        foreach ($objItem in $objListbox.SelectedItems)
            {$x += @($objItem)}
        $objForm.Close()
  
   })

$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,238)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(300,20) 
$objLabel.Text = "Please make selections from list below:"
$objForm.Controls.Add($objLabel) 

$objListbox = New-Object System.Windows.Forms.Listbox 
$objListbox.Location = New-Object System.Drawing.Size(10,40) 
$objListbox.Size = New-Object System.Drawing.Size(300,20) 

$objListbox.SelectionMode = "MultiExtended"


#[void] $objListbox.Items.Add("Betty Puskar BCC")
#[void] $objListbox.Items.Add("Bonnie's Bus")
#[void] $objListbox.Items.Add("CCB")
[void] $objListbox.Items.Add("Cancer Prevention")
if (($me -eq "jsgeorge") -or ($me -eq "tlankford") -or ($me -eq "ddalton")){
#[void] $objListbox.Items.Add(" ")
[void] $objListbox.Items.Add("CCB Faculty")
[void] $objListbox.Items.Add("CCB Students")
}
[void] $objListbox.Items.Add("Clinic")
[void] $objListbox.Items.Add("Clinical Trials")

if (($me -eq "jsgeorge") -or ($me -eq "tlankford") -or ($me -eq "ddalton")){
#[void] $objListbox.Items.Add(" ")
[void] $objListbox.Items.Add("Disease Teams / Science Exchange")

}
[void] $objListbox.Items.Add("Hematology Oncology Section")
[void] $objListbox.Items.Add("MBRCC Administration")
[void] $objListbox.Items.Add("MBRCC Labs")
[void] $objListbox.Items.Add("MBRCC Members")
if (($me -eq "jsgeorge") -or ($me -eq "wnsmith")){
#[void] $objListbox.Items.Add(" ")
[void] $objListbox.Items.Add("MBRCC Members Potential")
}

#[void] $objListbox.Items.Add("Radiation Oncology")
[void] $objListbox.Items.Add(" ")
[void] $objListbox.Items.Add("Everyone")
#if (($me -eq "jsgeorge") -or ($me -eq "tlankford")){
#[void] $objListbox.Items.Add(" ")
#[void] $objListbox.Items.Add("Tina: List for Laura")
#}


if (($me -eq "jsgeorge") -or ($me -eq "lacciavatti") -or ($me -eq "ddalton")){
[void] $objListbox.Items.Add(" ")
[void] $objListbox.Items.Add("eNews List")
}

$objListbox.Height = 210
$objForm.Controls.Add($objListbox) 
$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()
#echo "before X"
#$x
#echo "after X"

$choices = @($objListbox.SelectedItems)
#echo $choices
 
#Beginning the import processes
echo "********************************************************"
echo "Beginning Import Process"
echo "********************************************************"
echo " "
echo " "
foreach ($choice in $choices){

if ($choice -eq 'Clinic'){echo "Adding Clinic Users" 
#& "$myDir\Clinic.ps1"
#$clinicOutput = $clinicOutput
& "$MyDir\Clinic_wvuhs.ps1"
$clinicOutputwvuhs = $clinicOutputwvuhs
#####echo " "
#####Echo "Clinic Users added to Output script"
#####echo " "
#$ClinicalGroups = get-content \\hs-mbrcc\mbrcc\DistroLists\addClinicalGroups.txt
#$OutputLists += $clinicOutput
$OutputLists += $clinicOutputwvuhs
#$OutputLists += $ClinicalGroups
$OutputFileName = "MBRCC Clinic Email List Created on  "
$comboList ++
Disconnect-QADService -Service 'wvuh.wvuhs.com' 
}

if ($choice -eq 'Betty Puskar BCC'){echo "Adding Betty Puskar BCC Users" 
& "$myDir\BPBCC.ps1"
$bpbccOutput = $bpbccOutput
#####echo " "
#####Echo "BPBCC Users added to Output script"
#####echo " "
$OutputLists += $bpbccOutput
$OutputFileName = "Betty Puskar BCC Email List Created on  "
$comboList ++
}

if ($choice -eq 'Radiation Oncology'){echo "Adding Radiation Oncology Users" 
& "$myDir\RadOnc.ps1"
$radOncOutput = $radOncOutput
#####echo " "
#####Echo "RadOnc Users added to Output script"
#####echo " "
$OutputLists += $radOncOutput
$OutputFileName = "Radiation Oncology Email List Created on  "
$comboList ++
}

if ($choice -eq "Bonnie's Bus"){echo "Adding Bonnie's Bus Users" 
& "$myDir\BonniesBus.ps1"
$BonniesBusOutput = $BonniesBusOutput
#####echo " "
#####Echo "BonniesBus Users added to Output script"
#####echo " "
$OutputLists += $BonniesBusOutput
$OutputFileName = "Bonnies Bus Email List Created on  "
$comboList ++
}

if ($choice -eq 'CCB Faculty'){echo "Adding CCB Faculty" 
#& "$myDir\CCB_Faculty.ps1"
$ccbFacultyOutput = get-content \\hs-mbrcc\mbrcc\DistroLists\ListsToEdit\CCB_Faculty.txt
$OutputLists += $ccbFacultyOutput
$OutputFileName = "CCB Faculty Email List Created on  "
$comboList ++
}

if ($choice -eq 'CCB Students'){echo "Adding CCB Students" 
#& "$myDir\CCB_Students.ps1"
$ccbStudentsOutput = get-content \\hs-mbrcc\mbrcc\DistroLists\ListsToEdit\CCB_Students.txt
$OutputLists += $ccbStudentsOutput
$OutputFileName = "CCB Students Email List Created on  "
$comboList ++
}

if ($choice -eq 'Disease Teams / Science Exchange'){echo "Adding Disease Teams / Science Exchange" 
echo " "
$MembersCalled = "No"
$Global:MembersCalled2 = $MembersCalled
echo "Adding MBRCC Members"
& "$myDir\MembersALL.ps1"
$AllInOneLauraList += $membersAllOutput



echo "Adding Extras for Laura List"
$ExtraLauraPeople = get-content \\hs-mbrcc\mbrcc\DistroLists\ListsToEdit\Extras_for_Laura_List.txt
$AllinOneLauraList += $ExtraLauraPeople



echo "Adding CTRU Users"
& "$myDir\CTRU.ps1"
$ctruOutput = $ctruOutput
$AllinOneLauraList += $ctruOutput






echo "Adding CPC Users" 
& "$myDir\Prete.ps1"
$preteOutput = $preteOutput
$AllinOneLauraList += $preteOutput


echo "Adding MBRCC Labs Users" 
& "$myDir\LabsMBRCC.ps1"
$mbrccLabsOutput = $mbrccLabsOutput
$AllinOneLauraList += $mbrccLabsOutput









foreach ($j in $AllinOneLauraList){

if (($j -notlike "lgibson@hsc*") -and ($j -notlike "*goldberg@hsc*") -and ($j -notlike "*wallis.marsh@hsc*") -and ($j -notlike "*seftor@hsc*") -and ($j -notlike "*nurkiewicz*") -and ($j -notlike "* *")){
$AllinOneLauraListClean += @($j) 
}
}
$AllInOneLauraListClean2 += @($AllInOneLauraListClean | sort | select -Unique)
$OutputLists += $AllInOneLauraListClean2
$OutputFileName = "Disease Teams Science Exchange Email List Created on  "
$comboList ++
}

if ($choice -eq 'Clinical Trials'){echo "Adding Clinical Research Users" 
& "$myDir\CTRU.ps1"
$ctruOutput = $ctruOutput
#####echo " "
#####Echo "CTRU Users added to Output script"
#####echo " "
$OutputLists += $ctruOutput
$OutputFileName = "CRU Email List Created on  "
$comboList ++
}

if ($choice -eq 'Hematology Oncology Section'){echo "Adding Hematology Oncology Section Users" 
& "$myDir\HemOnc.ps1"
$hemOncOutput = $hemOncOutput
#####echo " "
#####Echo "HemOnc Users added to Output script"
#####echo " "
$OutputLists += $hemOncOutput
$OutputFileName = "HemOnc Section Email List Created on  "
$comboList ++
}

if ($choice -eq 'CPC'){echo "Adding CPC Users" 
& "$myDir\Prete.ps1"
$preteOutput = $preteOutput
#####echo " "
#####Echo "Prete Users added to Output script"
#####echo " "
$OutputLists += $preteOutput
$OutputFileName = "CPC Email List Created on  "
$comboList ++
}

if ($choice -eq 'MBRCC Labs'){echo "Adding MBRCC Labs Users" 
& "$myDir\LabsMBRCC.ps1"
$mbrccLabsOutput = $mbrccLabsOutput
#####echo " "
#####Echo "MBRCC Labs Users added to Output script"
#####echo " "
$OutputLists += $mbrccLabsOutput
$OutputFileName = "MBRCC Labs Email List Created on  "
$comboList ++
}

if ($choice -eq 'MBRCC Administration'){echo "Adding MBRCC Administration Users" 
& "$myDir\adminMBRCC.ps1"
$mbrccAdminOutput = $mbrccAdminOutput
#####echo " "
#####Echo "MBRCC Admin Users added to Output script"
#####echo " "
$OutputLists += $mbrccAdminOutput
$OutputFileName = "MBRCC Administration Email List Created on  "
$comboList ++
}

if ($choice -eq 'MBRCC Members'){echo "Adding MBRCC Members" 
$MembersCalled = "Yes"
$Global:MembersCalled2 = $MembersCalled
& "$myDir\MembersALL.ps1"
$membersAllOutput = $membersAllOutput
#####echo " "
#####Echo "MBRCC Members added to Output script"
#####echo " "
$OutputLists += $membersAllOutput
$OutputFileName = "MBRCC Members Email List Created on  "
$comboList ++
}

if ($choice -eq 'MBRCC Members Potential'){echo "Adding Potential MBRCC Members" 
$MembersCalled = "Yes"
$Global:MembersCalled2 = $MembersCalled
& "$myDir\MembersPotential.ps1"
$membersAllOutput = $membersPotentialOutput
#####echo " "
#####Echo "MBRCC Members added to Output script"
#####echo " "
$OutputLists += $membersAllOutput
$OutputFileName = "Potential MBRCC Members Email List Created on  "
$comboList ++
}



if ($choice -eq 'Tina: List for Laura'){echo "Creating Tina: List for Laura" 
echo " "
$MembersCalled = "No"
$Global:MembersCalled2 = $MembersCalled
echo "Adding MBRCC Members"
& "$myDir\MembersALL.ps1"
$AllInOneLauraList += $membersAllOutput
echo "Adding Extras for Laura List"
$ExtraLauraPeople = get-content \\hs-mbrcc\mbrcc\DistroLists\ListsToEdit\Extras_for_Laura_List.txt
$AllinOneLauraList += $ExtraLauraPeople
foreach ($j in $AllinOneLauraList){

if (($j -notlike "lgibson@hsc*")){
$AllinOneLauraListClean += @($j) 
}
}
$AllInOneLauraListClean2 += @($AllInOneLauraListClean | sort | select -Unique)
$OutputLists += $AllInOneLauraListClean2

$OutputFileName = "List for Laura Created on  "
$comboList ++
}


if ($choice -eq 'Everyone'){echo "Creating Everyone List" 
echo " "
$MembersCalled = "No"
$Global:MembersCalled2 = $MembersCalled
#####echo "Adding Clinic Users"
#& "$myDir\Clinic.ps1"
Disconnect-QADService -Service 'wvuh.wvuhs.com'
#echo "Adding BPBCC Users"
#& "$myDir\BPBCC.ps1"
#echo "Adding Bonnies Bus Users"
#& "$myDir\BonniesBus.ps1"
#echo "Adding CCB Users"
#& "$myDir\CCB.ps1"
echo "Adding Clinic Users"
#& "$myDir\Clinic.ps1"
& "$myDir\Clinic_wvuhs.ps1"
echo "Adding CTRU Users"
& "$myDir\CTRU.ps1"
echo "Adding HemOnc Users"
& "$myDir\HemOnc.ps1"
echo "Adding MBRCC Admininstration Users"
& "$myDir\AdminMBRCC.ps1"
echo "Adding MBRCC Labs Users"
& "$myDir\LabsMBRCC.ps1"
echo "Adding MBRCC Members"
& "$myDir\MembersALL.ps1"
echo "Adding Prete Users"
& "$myDir\Prete.ps1"
echo "Adding EmployeeFile Users"
& "$myDir\EmployeeFile.ps1"
#echo "Adding RadOnc Users"
#& "$myDir\RadOnc.ps1"
#####& "$myDir\ExtraUsers.ps1"
$AllInOneList = @()
$AllInOneList += $clinicOutput
$AllInOneList += $clinicOutputwvuhs
$AllInOneList += $bpbccOutput
$AllInOneList += $radOncOutput
$AllInOneList += $BonniesBusOutput
$AllInOneList += $ccbOutput
$AllInOneList += $ctruOutput
$AllInOneList += $hemOncOutput
$AllInOneList += $preteOutput
$AllInOneList += $mbrccLabsOutput
$AllInOneList += $mbrccAdminOutput
$AllInOneList += $membersAllOutput
$AllinOneList += $EmployeeFileOutput
$AllInOneList += $allDirectoryUsers
$AllInOneList = $AllInOneList | sort | select -Unique
$comboList ++
$OutputFileName = "Everyone Email List Created on  "
foreach ($j in $AllinOneList){

if (($j -notlike "cnwatson@hsc*") -and ($j -notlike "colendac@wvu*") -and ($j -notlike "mfarrugia@hsc*") -and ($j -notlike "fontanat@wvu*") -and ($j -notlike ";") -and ($j -notlike "seiranmanesh@hsc*") -and ($j -notlike "bjones@hsc*") -and ($j -notlike "smarkwell@hsc*") -and ($j -notlike "bmoses2@hsc*") -and ($j -notlike "sbsharma@hsc*") -and ($j -notlike "akanate-hsc@*") -and ($j -notlike "jaddison@*") -and ($j -notlike "jzheng@*") -and ($j -notlike "peckc@wvu*") -and ($j -notlike "skennedy@hsc*") -and ($j -notlike "sonikpreet.aulakh.m@wvumedicine.org;") -and ($j -notlike "pius.joseph@cdc.gov;")){
$AllinOneListClean += @($j) 
}
}
##echo " "
##$output = "There are " + $AllInOneListclean.count + " users from all lists combined"
##echo $output
echo " "
}



if ($choice -eq 'eNews List'){echo "Creating eNews List" 
echo " "
$MembersCalled = "No"
$Global:MembersCalled2 = $MembersCalled
#####echo "Adding Clinic Users"
#& "$myDir\Clinic.ps1"
Disconnect-QADService -Service 'wvuh.wvuhs.com'
#echo "Adding BPBCC Users"
#& "$myDir\BPBCC.ps1"
#echo "Adding Bonnies Bus Users"
#& "$myDir\BonniesBus.ps1"
#echo "Adding CCB Users"
#& "$myDir\CCB.ps1"
echo "Adding Clinic Users"
#& "$myDir\Clinic.ps1"
& "$myDir\Clinic_wvuhs.ps1"
echo "Adding CTRU Users"
& "$myDir\CTRU.ps1"
echo "Adding HemOnc Users"
& "$myDir\HemOnc.ps1"
echo "Adding MBRCC Admininstration Users"
& "$myDir\AdminMBRCC.ps1"
echo "Adding MBRCC Labs Users"
& "$myDir\LabsMBRCC.ps1"
echo "Adding MBRCC Members"
& "$myDir\MembersALL.ps1"
echo "Adding Prete Users"
& "$myDir\Prete.ps1"
echo "Adding EmployeeFile Users"
& "$myDir\EmployeeFile.ps1"
#echo "Adding RadOnc Users"
#& "$myDir\RadOnc.ps1"
#####& "$myDir\ExtraUsers.ps1"
echo "Adding Extra eNews Users"
& "$myDir\Extras_for_eNews.ps1"
$OutsideNewsPeople = get-content \\hs-mbrcc\mbrcc\DistroLists\ListsToEdit\addOutsideNewsPeople.txt
$InsideNewsPeople = get-content \\hs-mbrcc\mbrcc\DistroLists\ListsToEdit\addInsideNewsPeople.txt
$AllInOneList = @()
$AllInOneList += $clinicOutput
$AllInOneList += $clinicOutputwvuhs
$AllInOneList += $bpbccOutput
$AllInOneList += $radOncOutput
$AllInOneList += $BonniesBusOutput
$AllInOneList += $ccbOutput
$AllInOneList += $ctruOutput
$AllInOneList += $hemOncOutput
$AllInOneList += $preteOutput
$AllInOneList += $mbrccLabsOutput
$AllInOneList += $mbrccAdminOutput
$AllInOneList += $membersAllOutput
$AllInOneList += $allDirectoryUsers
$AllInOneList += $eNewsExtraUsers
$AllInOneList += $OutsideNewsPeople
$AllInOneList += $InsideNewsPeople
$AllinOneList += $EmployeeFileOutput
$AllInOneList = $AllInOneList | sort | select -Unique
#}

$OutputFileName = "eNews Email List Created on  "
foreach ($j in $AllinOneList){

if (($j -notlike "cnwatson@hsc*") -and ($j -notlike "colendac@wvu*") -and ($j -notlike "mfarrugia@hsc*") -and ($j -notlike "fontanat@wvu*") -and ($j -notlike "ihare@hsc*") -and ($j -notlike ";") -and ($j -notlike "seiranmanesh@hsc*") -and ($j -notlike "bjones@hsc*") -and ($j -notlike "smarkwell@hsc*") -and ($j -notlike "bmoses2@hsc*") -and ($j -notlike "sbsharma@hsc*") -and ($j -notlike "wslone@hsc*") -and ($j -notlike "dvanderbilt@hsc*") -and ($j -notlike "ewalk@hsc*") -and ($j -notlike "akanate-hsc@*") -and ($j -notlike "jaddison@*") -and ($j -notlike "jzheng@*") -and ($j -notlike "peckc@wvu*") -and ($j -notlike "skennedy@hsc*") -and ($j -notlike "sonikpreet.aulakh.m@wvumedicine.org*") -and ($j -notlike "pius.joseph@cdc.gov;")){
$AllinOneListClean += @($j)
}
}
####echo $AllinOneListClean.count

#####echo " "
#####$output = "There are " + $AllInOneListClean.count + " eNews users from all lists combined"
#####echo $output

echo " "
$comboList ++}




$OutputLists += $AllInOneListClean
if ($combolist -eq 0){$OutputFileName = "eNews Email List Created on  "}
}

##########Write-Host "Press any key to create the output file(s) ..."
##########$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
$OutputLists = $OutputLists | sort | select -Unique


#############Splitting the lists into WVUH and NonWVUH Users#################

if (($choice -eq 'eNews List') -or ($choice -eq 'Everyone')){



foreach ($NonWVUHUser in $OutputLists){
if (($NonWVUHUser -notlike "*@wvumed*") -and ($NonWVUHUser -notlike "*@wvuhealth*")) {
#echo "Found one"
#echo $NonWVUHUSER
$OutputListsNonWVUHUsers += @($NonWVUHUser)
}
}
#pause
#echo "*****************"
#echo $OutputListsNonWVUHUsers
#echo $OutputListsNonWVUHUsers.count
#pause

#echo "I am outside the loop"
foreach ($WVUHUser in $OutputLists){
if (($WVUHUser -like "*@wvumed*") -or ($WVUHUser -like "*@wvuhealth*")) {
#echo "Found WVUH User"
#echo $WVUHUSER
$OutputListsWVUHUsers += @($WVUHUser)
}
}
#pause
#echo "*****************"
#echo $OutputListsWVUHUsers
#echo $OutputListsWVUHUsers.count
#Pause


if ($choice -eq 'eNews List'){
$OutputFileName = "eNews Email List Created on  "
$eNewsWVUHUsers = "Yes"
$eNewsNonWVUHUsers = "Yes"
echo "Creating eNews List" 
echo " "
}

if ($choice -eq 'Everyone'){
$OutputFileName = "Everyone Email List Created on  "
$EveryoneWVUHUsers = "Yes"
$EveryoneNonWVUHUsers = "Yes"
echo "Creating Everyone List" 
echo " "
}

}

#Creating the output files 
echo " "
echo "********************************************************"
echo "Beginning Output Process"
echo "********************************************************"
echo " "
#echo " "
#$OutputFileName = Read-Host "Please name the output file(s).  No extensions needed."

if ($comboList -gt 1){
$OutputFileName = "MultiGroup Email List Created on  "
}

echo " "
echo "****************************************************"
echo "Do Not Open lists until prompted to close the window"
echo "****************************************************"
echo " "
echo " "
$output = $MyName.GivenName + ", there are a total of " + $OutputLists.count + " users from your selected lists"
echo $output
if (($choice -eq 'eNews List') -or ($choice -eq 'Everyone')){

echo " "
echo " "
echo "**************************************************"
echo "Generating Lists for WVUH Users and Non-WVUH users"
echo "**************************************************"
echo " "
echo " "
$StuffToSay = "There are " + $OutputListsWVUHUsers.count + " WVUH Users and " + $OutputListsNonWVUHUsers.count + " Non-WVUH Users"
echo $StuffToSay
}

echo " "

if (($choice -ne 'eNews List') -and ($choice -ne 'Everyone')){
if ($OutputLists.count -gt 475){

$split = 475
echo " "}
Else {$split = 475}
$i=1
$part=1
$FilePath = $LogFilePath +  " Part " + $part + " " + $OutputFileName + $Date + " for " + $MyName.GivenName +   ".txt"
$FilePathdelete = $LogFilePath + $OutputFileName + $Date + "*.*"
IF (Test-Path $filepath){
	Remove-Item $filepathdelete
}

if ($OutputLists.count -lt $split){
$FilePath = $LogFilePath + $OutputFileName + $Date + ".txt"}
echo " "
echo "Adding Users to the output file(s)"
##IF (Test-Path $filepath){
##	Remove-Item $filepathdelete
##}

####If statement from Line 546 was here####
foreach ($p in $OutputLists)
{
$output = $p
if ($i -gt $split){
$part++
$FilePath = $LogFilePath + " Part " + $part + " " + $OutputFileName + $Date + " for " + $MyName.GivenName + ".txt"
$screenoutput = "Adding Users to part " + $part + " of the output files"
echo $screenoutput
##IF (Test-Path $filepath){
##	Remove-Item $filepath
##}
$i=0
}
Add-content $filepath  $output 
$i++
}
echo " "
echo " "
$outputlocation = "Output has been saved to " + $LogFilePath
echo $outputlocation
echo " "
echo " "
$ScriptFinished = "Script finished.  There are " + $part + " files this week."
echo $ScriptFinished
#echo $combolist
}

if (($choice -eq 'eNews List') -or ($choice -eq 'Everyone')){

############################################################
if ($choice -eq 'eNews List'){

if ($eNewsWVUHUsers ="Yes"){

$OutputLists = $OutputListsWVUHUsers
$OutputFileName = "eNews List (WVUH Users) Created on  "


if ($OutputLists.count -gt 480){

$split = read-host "How many users do you want to include on each email?  Our suggestion is no more than 300 per email"
echo " "}
Else {$split = 480}
$i=1
$part=1
$FilePath = $LogFilePath +  " Part " + $part + " " + $OutputFileName + $Date + " for " + $MyName.GivenName +  ".txt"
$FilePathdelete = $LogFilePath + $OutputFileName + $Date + " for " + $MyName.GivenName +   "*.*"
IF (Test-Path $filepath){
	Remove-Item $filepathdelete
}

if ($OutputLists.count -lt $split){
$FilePath = $LogFilePath + $OutputFileName + $Date + " for " + $MyName.GivenName +   ".txt"}
echo " "



foreach ($p in $OutputLists)
{
$output = $p
if ($i -gt $split){
$part++
$FilePath = $LogFilePath + " Part " + $part + " " + $OutputFileName + $Date + " for " + $MyName.GivenName +  ".txt"
$screenoutput = "Adding WVUH Users to part " + $part + " of the output files"
echo $screenoutput
##IF (Test-Path $filepath){
##	Remove-Item $filepath
##}
$i=0
}
Add-content $filepath  $output 
$i++
}



$eNewsWVUHUsers = "No"
}


if ($eNewsNonWVUHUsers ="Yes"){


$OutputLists = $OutputListsNonWVUHUsers
$OutputFileName = "eNews List (Non-WVUH Users) Created on  "

if ($OutputLists.count -gt 480){

$split = read-host "How many users do you want to include on each email?  Our suggestion is no more than 300 per email"
echo " "}
Else {$split = 480}
$i=1
$part=1
$FilePath = $LogFilePath +  " Part " + $part + " " + $OutputFileName + $Date + " for " + $MyName.GivenName +  ".txt"
$FilePathdelete = $LogFilePath + $OutputFileName + $Date + " for " + $MyName.GivenName +   "*.*"
IF (Test-Path $filepath){
	Remove-Item $filepathdelete
}

if ($OutputLists.count -lt $split){
$FilePath = $LogFilePath + $OutputFileName + $Date + " for " + $MyName.GivenName +   ".txt"}
echo " "




foreach ($p in $OutputLists)
{
$output = $p
if ($i -gt $split){
$part++
$FilePath = $LogFilePath + " Part " + $part + " " + $OutputFileName + $Date + " for " + $MyName.GivenName +  ".txt"
$screenoutput = "Adding Non-WVUH Users to part " + $part + " of the output files"
echo $screenoutput
##IF (Test-Path $filepath){
##	Remove-Item $filepath
##}
$i=0
}
Add-content $filepath  $output 
$i++
}



$eNewsNonWVUHUsers = "No"
}






$part = "2"

}
#######################################
if ($choice -eq 'Everyone'){

if ($EveryoneWVUHUsers ="Yes"){

$OutputLists = $OutputListsWVUHUsers
$OutputFileName = "Everyone List (WVUH Users) Created on  "


if ($OutputLists.count -gt 480){

$split = read-host "How many users do you want to include on each email?  Our suggestion is no more than 300 per email"
echo " "}
Else {$split = 480}
$i=1
$part=1
$FilePath = $LogFilePath +  " Part " + $part + " " + $OutputFileName + $Date + " for " + $MyName.GivenName +  ".txt"
$FilePathdelete = $LogFilePath + $OutputFileName + $Date + "*.*"
IF (Test-Path $filepath){
	Remove-Item $filepathdelete
}

if ($OutputLists.count -lt $split){
$FilePath = $LogFilePath + $OutputFileName + $Date + " for " + $MyName.GivenName +   ".txt"}
echo " "



foreach ($p in $OutputLists)
{
$output = $p
if ($i -gt $split){
$part++
$FilePath = $LogFilePath + " Part " + $part + " " + $OutputFileName + $Date + " for " + $MyName.GivenName +  ".txt"
$screenoutput = "Adding WVUH Users to part " + $part + " of the output files"
echo $screenoutput
##IF (Test-Path $filepath){
##	Remove-Item $filepath
##}
$i=0
}
Add-content $filepath  $output 
$i++
}



$EveryoneWVUHUsers = "No"
}


if ($EveryoneNonWVUHUsers ="Yes"){


$OutputLists = $OutputListsNonWVUHUsers
$OutputFileName = "Everyone List (Non-WVUH Users) Created on "

if ($OutputLists.count -gt 480){

$split = read-host "How many users do you want to include on each email?  Our suggestion is no more than 300 per email"
echo " "}
Else {$split = 480}
$i=1
$part=1
$FilePath = $LogFilePath +  " Part " + $part + " " + $OutputFileName + $Date + " for " + $MyName + ".txt"
$FilePathdelete = $LogFilePath + $OutputFileName + $Date + "*.*"
IF (Test-Path $filepath){
	Remove-Item $filepathdelete
}

if ($OutputLists.count -lt $split){
$FilePath = $LogFilePath + $OutputFileName + $Date + " for " + $MyName.GivenName + ".txt"}
echo " "




foreach ($p in $OutputLists)
{
$output = $p
if ($i -gt $split){
$part++
$FilePath = $LogFilePath + " Part " + $part + " " + $OutputFileName + $Date + " for " + $MyName + ".txt"
$screenoutput = "Adding Non-WVUH Users to part " + $part + " of the output files for " + $MyName
echo $screenoutput
##IF (Test-Path $filepath){
##	Remove-Item $filepath
##}
$i=0
}
Add-content $filepath  $output 
$i++
}



$EveryoneNonWVUHUsers = "No"
}






$part = "2"

}



$outputlocation = "Output has been saved to " + $LogFilePath
echo $outputlocation
echo " "
echo " "
$ScriptFinished = "Script finished.  There are " + $part + " files this week."
echo $ScriptFinished
#echo $combolist

############################################################
}
echo " "
Write-Host "Press any key to close this window"
ii $LogFilePath
#$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")