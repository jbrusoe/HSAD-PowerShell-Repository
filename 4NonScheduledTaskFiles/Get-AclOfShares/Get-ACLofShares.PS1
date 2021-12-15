<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Get-ACLNetworkShare

Created by Matt Logue
Created on 11/15/2018

Last Modified on 10/17/2019
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#region begin GUI{ 

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '573,444'
$Form.text                       = "Form"
$Form.TopMost                    = $false

$pathname1                       = New-Object system.Windows.Forms.TextBox
$pathname1.multiline             = $false
$pathname1.width                 = 406
$pathname1.height                = 20
$pathname1.location              = New-Object System.Drawing.Point(66,95)
$pathname1.Font                  = 'Microsoft Sans Serif,12'

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Enter Network Share Path"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(71,71)
$Label1.Font                     = 'Microsoft Sans Serif,10'

$SavePath                        = New-Object system.Windows.Forms.TextBox
$SavePath.multiline              = $false
$SavePath.width                  = 408
$SavePath.height                 = 20
$SavePath.location               = New-Object System.Drawing.Point(67,196)
$SavePath.Font                   = 'Microsoft Sans Serif,12'

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Where do you want the CSV saved? (Leave Blank for Desktop)"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(71,171)
$Label2.Font                     = 'Microsoft Sans Serif,10'

$Submit                          = New-Object system.Windows.Forms.Button
$Submit.BackColor                = "#9b9b9b"
$Submit.text                     = "GO!"
$Submit.width                    = 109
$Submit.height                   = 40
$Submit.Anchor                   = 'top'
$Submit.location                 = New-Object System.Drawing.Point(74,315)
$Submit.Font                     = 'Microsoft Sans Serif,15,style=Bold'

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "Get Permissions Network Share"
$Label3.AutoSize                 = $true
$Label3.enabled                  = $false
$Label3.width                    = 25
$Label3.height                   = 10
$Label3.location                 = New-Object System.Drawing.Point(154,14)
$Label3.Font                     = 'Microsoft Sans Serif,20'

$Result                          = New-Object system.Windows.Forms.Label
$Result.AutoSize                 = $true
$Result.visible                  = $false
$Result.width                    = 25
$Result.height                   = 10
$Result.Anchor                   = 'top'
$Result.location                 = New-Object System.Drawing.Point(215,329)
$Result.Font                     = 'Microsoft Sans Serif,8,style=Bold'
$Result.ForeColor                = "#7ed321"

$FilenameUI                      = New-Object system.Windows.Forms.TextBox
$FilenameUI.multiline            = $false
$FilenameUI.width                = 232
$FilenameUI.height               = 20
$FilenameUI.location             = New-Object System.Drawing.Point(66,257)
$FilenameUI.Font                 = 'Microsoft Sans Serif,12'

$Label4                          = New-Object system.Windows.Forms.Label
$Label4.text                     = "Give the file a name (Ex. AdminACL)"
$Label4.AutoSize                 = $true
$Label4.width                    = 25
$Label4.height                   = 10
$Label4.location                 = New-Object System.Drawing.Point(70,238)
$Label4.Font                     = 'Microsoft Sans Serif,10'

$RecurseCheck                    = New-Object system.Windows.Forms.CheckBox
$RecurseCheck.text               = "Check Subfolders (Recursive)"
$RecurseCheck.AutoSize           = $false
$RecurseCheck.width              = 274
$RecurseCheck.height             = 20
$RecurseCheck.location           = New-Object System.Drawing.Point(69,131)
$RecurseCheck.Font               = 'Microsoft Sans Serif,10'

$Form.controls.AddRange(@($pathname1,$RecurseCheck,$Label1,$SavePath,$Label2,$Label3,$Result,$FilenameUI,$Label4,$Submit))

#region gui events {
$Submit.Add_Click({ RunACL })
#endregion events }

#endregion GUI }



#Write your logic code here
$Error.Clear()

function RunACL() 
{
    cls;
    Clear-History;
    $result.Visible = $false
    $share = @()


    if ($SavePath.Text -eq "") {
        $SavePath = "$env:USERPROFILE\Desktop"
    }
    else {
        $SavePath = $SavePath.text
    }

    $FullSavePath = "$SavePath\$($FilenameUI.text).csv"

    $sharename = "$($pathname1.text)"

    if ($sharename.IndexOf(":") -eq -1) {
        New-PSDrive Z -PSProvider FileSystem -Root $sharename
        $drive = "z:\"
    }
    else {
        $drive = $sharename
    }

    ####################################################################
    if ($RecurseCheck.Checked -eq $True) {
        #$x = 0

        Write-Host "Getting filepaths for $sharename"

        $share1 = Get-ChildItem -Path $drive -Recurse -Directory -ErrorAction Ignore

        $toolong = $share1 | Where-Object {$_.Fullname.length -gt 259} 
            if ($toolong) {
                foreach ($fntl in $toolong) {
                Write-Host "`nCan't get permissions on this directory directory path is too long" -ForegroundColor Red
                Write-Host "File Length: $($fntl.FullName.Length)" -ForegroundColor Yellow -BackgroundColor Black
                Write-Host "$($fntl.FullName)`n" -ForegroundColor Yellow -BackgroundColor Black
                }
            }

        $share = $share1 | Where-Object {$_.Fullname.length -le 259}

        Remove-Variable "toolong"
    }
    else {

        Write-Host "Getting filepaths for $sharename)"
        $share1 = Get-ChildItem -Path $drive -Directory

        $toolong = $share1 | Where-Object {$_.Fullname.length -gt 259} 
            if ($toolong) {
                Write-Host "`nCan't get permissions on this directory directory path is too long" -ForegroundColor Red
                Write-Host "File Length: $($toolong.FullName.Length)`n" -ForegroundColor Yellow -BackgroundColor Black
                Write-Host $toolong.FullName -ForegroundColor Yellow -BackgroundColor Black
            }

        $share = $share1 | Where-Object {$_.Fullname.length -le 259}

        Remove-Variable "toolong"
    }
    ########################################################################

    Write-Host "Getting Permissions for $sharename...."

    $share | ForEach-Object {
        $Path = $_.FullName.Trim()
                
        Get-Acl -LiteralPath $Path -ErrorAction Continue|
            Select-Object -ExpandProperty Access |
            Where-Object { ($_.IdentityReference -notlike "Builtin\*" -and $_.IdentityReference -notlike "NT AUTHORITY\SYSTEM" -and $_.IdentityReference -notlike "CREATOR OWNER") } |
            Add-Member -MemberType NoteProperty -Name Path -Value $Path -PassThru 
    
    } | Export-CSV $FullSavePath -NoTypeInformation -Append -Force

    $formErrors = $error.count
    #######################################################################

    Write-Host "Finding Group Permissions for $sharename"
    $adgroupacl = (Get-Acl -literalpath $sharename | select -ExpandProperty Access).IdentityReference | Where {$_.Value -like "HS\*"}
    foreach ($adgroup in $adgroupacl){
    If ($adgroup -like "HS\*") 
        {
        $ErrorActionPreference = "SilentlyContinue"
            $gpname = $($adgroup.Value.ToString()).Replace('HS\',"")
            $gpname = $gpname.Replace('HS\',"")
            
            $adgroupcheck = $false
            $Adgroupcheck = ((Get-ADGroup $gpname | Get-ADObject).ObjectClass -eq "group")
            if ($Adgroupcheck) 
            { 
                $Adgroupmembers = Get-ADGroupMember $gpname | select SamAccountName,objectClass 
                Write-Host "Found Group Name: $gpname"

                    Write-Output "`n" (Get-Content "$FullSavePath" | Out-String) | Set-Content "$FullSavePath"
                    $ADgroupmembers.SamAccountName + (Get-Content "$FullSavePath" | Out-String) | Set-Content "$FullSavePath"
                    Write-Output "$gpname - Group Members:" (Get-Content "$FullSavePath" | Out-String) | Set-Content "$FullSavePath"
            
            foreach ($Adgroupmember in $Adgroupmembers.SamAccountName) {
                    $adgroupcheck = $false
                    $Adgroupcheck = ((Get-ADGroup $Adgroupmember | Get-ADObject).ObjectClass -eq "group")

                    if ($Adgroupcheck) 
                    {                        
                            $Adgroupmembers1 = Get-ADGroupMember $adgroupmember | select SamAccountName,objectClass 
                            Write-Host "Found Group Name: $adgroupmember"

                            Write-Output "`n" (Get-Content "$FullSavePath" | Out-String) | Set-Content "$FullSavePath"
                            $ADgroupmembers1.SamAccountName + (Get-Content "$FullSavePath" | Out-String) | Set-Content "$FullSavePath"
                            Write-Output "$adgroupmember - Group Members:" (Get-Content "$FullSavePath" | Out-String) | Set-Content "$FullSavePath"
                    }
            
            }
            }

            
        
        $error.clear()
        $ErrorActionPreference = "Continue"
        
        }
    }

    If ($formErrors -le 0) {
        $result.text = "File Created! - $FullSavePath"
        $Result.ForeColor = "#7ed321"
        $result.Visible = $true
        $formErrors = 0
        #& $FullSavePath
    }
    Else {
        $result.text = "There was an error, check powershell window for error information"
        $result.ForeColor = "#f70000"
        $result.Visible = $true
        $formErrors = 0
    }
    Write-Host "Done"
}

[void]$Form.ShowDialog()