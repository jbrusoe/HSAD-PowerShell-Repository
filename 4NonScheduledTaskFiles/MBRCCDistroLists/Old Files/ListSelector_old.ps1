Add-PSSnapin Quest.ActiveRoles.ADManagement -ea "SilentlyContinue"

$me = $env:USERNAME
$MyName = get-qaduser -SamAccountName $me
#####echo $MyName.GivenName

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
#echo $GroupName

if (!$LogFilePath.EndsWith("\"))
{
	$LogFilePath = $LogFilePath + "\"
}
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
$objForm.Size = New-Object System.Drawing.Size(325,300) 
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
$OKButton.Location = New-Object System.Drawing.Size(75,210)
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
$CancelButton.Location = New-Object System.Drawing.Size(150,210)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "Please make selections from list below:"
$objForm.Controls.Add($objLabel) 

$objListbox = New-Object System.Windows.Forms.Listbox 
$objListbox.Location = New-Object System.Drawing.Size(10,40) 
$objListbox.Size = New-Object System.Drawing.Size(290,20) 

$objListbox.SelectionMode = "MultiExtended"


[void] $objListbox.Items.Add("Betty Puskar BCC")
[void] $objListbox.Items.Add("Bonnie's Bus")
[void] $objListbox.Items.Add("CCB")
[void] $objListbox.Items.Add("Clinic")
[void] $objListbox.Items.Add("Clinical Trials")
[void] $objListbox.Items.Add("Hematology Oncology Section")
[void] $objListbox.Items.Add("MBRCC Administration")
[void] $objListbox.Items.Add("MBRCC Labs")
[void] $objListbox.Items.Add("MBRCC Members")
[void] $objListbox.Items.Add("Prete")
[void] $objListbox.Items.Add("Radiation Oncology")

[void] $objListbox.Items.Add("Everyone")


$objListbox.Height = 170
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
& "$myDir\Clinic.ps1"
$clinicOutput = $clinicOutput
#####echo " "
#####Echo "Clinic Users added to Output script"
#####echo " "
$OutputLists += $clinicOutput
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

if ($choice -eq 'CCB'){echo "Adding CCB Users" 
& "$myDir\CCB.ps1"
$ccbOutput = $ccbOutput
#####echo " "
#####Echo "CCB Users added to Output script"
#####echo " "
$OutputLists += $ccbOutput
$OutputFileName = "CCB Email List Created on  "
$comboList ++
}

if ($choice -eq 'Clinical Trials'){echo "Adding Clinical Trials Users" 
& "$myDir\CTRU.ps1"
$ctruOutput = $ctruOutput
#####echo " "
#####Echo "CTRU Users added to Output script"
#####echo " "
$OutputLists += $ctruOutput
$OutputFileName = "CTRU Email List Created on  "
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

if ($choice -eq 'Prete'){echo "Adding Prete Users" 
& "$myDir\Prete.ps1"
$preteOutput = $preteOutput
#####echo " "
#####Echo "Prete Users added to Output script"
#####echo " "
$OutputLists += $preteOutput
$OutputFileName = "Prete Email List Created on  "
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
& "$myDir\MembersALL.ps1"
$membersAllOutput = $membersAllOutput
#####echo " "
#####Echo "MBRCC Members added to Output script"
#####echo " "
$OutputLists += $membersAllOutput
$OutputFileName = "MBRCC Members Email List Created on  "
$comboList ++
}

if ($choice -eq 'Everyone'){echo "Creating Everyone List" 
echo " "
#####echo "Adding Clinic Users"
& "$myDir\Clinic.ps1"
Disconnect-QADService -Service 'wvuh.wvuhs.com'
echo "Adding BPBCC Users"
& "$myDir\BPBCC.ps1"
echo "Adding Bonnies Bus Users"
& "$myDir\BonniesBus.ps1"
echo "Adding CCB Users"
& "$myDir\CCB.ps1"
echo "Adding Clinic Users"
#####& "$myDir\Clinic.ps1"
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
echo "Adding RadOnc Users"
& "$myDir\RadOnc.ps1"
& "$myDir\ExtraUsers.ps1"
$AllInOneList = @()
$AllInOneList += $clinicOutput
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
$AllInOneList = $AllInOneList | sort | select -Unique
$output = "There are " + $AllInOneList.count + " users from all lists combined"
echo $output
echo " "}
$OutputLists += $AllInOneList
if ($combolist -eq 0){$OutputFileName = "Everyone Email List Created on  "}
}

##########Write-Host "Press any key to create the output file(s) ..."
##########$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
$OutputLists = $OutputLists | sort | select -Unique

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
$output = $MyName.GivenName + " there are a total of " + $OutputLists.count + " users from your selected lists"
echo $output
echo " "
$split = read-host "How many users do you want to include on each email?  Our suggestion is no more than 200 per email"
echo " "
$i=1
$part=1
$FilePath = $LogFilePath + $OutputFileName + $Date + " Part " + $part + ".txt"
$FilePathdelete = $LogFilePath + $OutputFileName + $Date + "*.*"
IF (Test-Path $filepath){
	Remove-Item $filepathdelete
}

if ($OutputLists.count -lt $split){
$FilePath = $LogFilePath + $OutputFileName + $Date + ".txt"}
echo " "
echo "Adding Users to the output file"
##IF (Test-Path $filepath){
##	Remove-Item $filepathdelete
##}


foreach ($p in $OutputLists)
{
$output = $p
if ($i -gt $split){
$part++
$FilePath = $LogFilePath + $OutputFileName + $Date + " Part " + $part + ".txt"
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

Write-Host "Press any key to close this window"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")