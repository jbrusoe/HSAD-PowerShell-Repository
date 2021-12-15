#$UserCredential = Get-Credential "mattadmin@hsc.wvu.edu" -Message "Enter your O365 Credentials"
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
if (!(Get-PSSession -Name "EOShell*")) {
    Connect-ExchangeOnlineShell
}
$projectfolder = Read-host -Prompt 'Input group name'
$members1 = Read-Host -Prompt 'Enter Faculty members usernames (ex. mlogue,krodney)'
$members1 = $members1.Split(",")
$members2 = Read-Host -Prompt 'Enter Student & External members usernames (ex. mlogue,krodney)'
$members2 = $members2.Split(",")
$projectfolder = $($projectfolder.ToString()).Trim()

#Import-PSSession $Session

$project = $projectfolder
$project = $project -Replace ',',''
$project = $project -Replace '[\[]','_'
$project = $project -Replace '[\]]',''

New-ADGroup -Name "HS VDI $project Faculty" -SamAccountName "HS VDI $project Faculty" -Path "OU=VDI and RDSH,OU=HSC AD Groups,OU=HSC,DC=HS,DC=wvu-ad,DC=wvu,DC=edu" -GroupScope Global -GroupCategory Security -Server hsdc4
New-ADGroup -Name "HS VDI $project Student" -SamAccountName "HS VDI $project Student" -Path "OU=VDI and RDSH,OU=HSC AD Groups,OU=HSC,DC=HS,DC=wvu-ad,DC=wvu,DC=edu" -GroupScope Global -GroupCategory Security -Server hsdc4


#Add Faculty
do  {
Write-Host "Waiting for Faculty project group to become available to set permissions"
sleep 15
$facgroup = (Get-ADGroup "HS VDI $project Faculty" -Server hsdc4).Name

}until ($facgroup -eq "HS VDI $project Faculty")

Add-ADGroupMember -Identity "RedCap Faculty and Staff Group" -Members $facgroup -Server hsdc4
add-adgroupmember -Identity "RDSH RedCap" $facgroup -Server hsdc4

$memberemails1 = $members1 | ForEach-Object {"$_@hsc.wvu.edu"}

Add-UnifiedGroupLinks -Identity "HorizonView@hsc.wvu.edu" -LinkType Members -Links $memberemails1


#Add Students
do  {
Write-Host "Waiting for Student project group to become available to set permissions"
sleep 15
$stugroup = (Get-ADGroup "HS VDI $project Student" -Server hsdc4).Name

}until ($stugroup -eq "HS VDI $project Student")

Add-ADGroupMember -Identity "RedCap Students and External Users Group" -Members $stugroup -Server hsdc4
add-adgroupmember -Identity "RDSH RedCap" -Members $stugroup -Server hsdc4


$memberemails2 = $members2 | ForEach-Object {"$_@hsc.wvu.edu"}

Add-UnifiedGroupLinks -Identity "HorizonView@hsc.wvu.edu" -LinkType Members -Links $memberemails2


#Add users to groups
$members1 | ForEach-Object { Add-ADGroupMember -Identity $facgroup "$_" -Server hsdc4}
$members2 | ForEach-Object { Add-ADGroupMember -Identity $stugroup "$_" -Server hsdc4}

$members = $members1 + $members2
#getting ad first and last name for home folder creation
$users = $members | ForEach-Object { Get-ADUser $_ | select samaccountname,Givenname,surname}

$server = 'HSRDSHFILE'

Write-Host "Waiting for groups to sync to dc's for adding share permissions"
sleep 30





$server | %{
         Invoke-Command -ComputerName $_ -ArgumentList $project,$projectfolder,$users -ScriptBlock { 
             param($project,$projectfolder,$users)

             $setupFolder = "E:\RDSHCLFolders\$($projectfolder)"
             Write-Host "Creating $setupFolder Folder"
             New-Item -Path $setupFolder -type directory -Force
             Write-Host "Folder creation complete"
             Write-Host "Creating Group Share Folder"
             New-Item -Path "$setupFolder\Group Share" -type directory -Force
             Write-Host "Folder creation complete"

             #$setupfolder = $setupfolder -Replace '[\[]','`['
             #$setupfolder = $setupfolder -Replace '[\]]','`]'

             #setting full control for group on project folder
             $Acl = Get-Acl -literalpath $setupfolder
             $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("HS\HS VDI $project Faculty", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
             $Acl.AddAccessRule($Ar)
			       $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("HS\RedCap Mgmt Group", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
             $Acl.AddAccessRule($Ar)
             $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("HS\HS VDI $project Student", "Read", "None", "None", "Allow")
             $Acl.AddAccessRule($Ar)
			 
             Set-Acl -literalpath $setupfolder $Acl

             $Acl = Get-Acl -literalpath "$setupfolder\Group Share"
             $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("HS\HS VDI $project Student", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
             $Acl.AddAccessRule($Ar)
             Set-Acl -literalpath "$setupfolder\Group Share" $Acl

             #gets acl on group folder
             (get-acl -literalpath $setupfolder).access | ft IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -auto
             (get-acl -literalpath "$setupfolder\Group Share").access | ft IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -auto


           foreach ($user in $users) {
             
             $userHomefolder = $user.samaccountname

             $setupFolder2 = "E:\RDSHCLFolders\$($projectfolder)\$($userHomefolder)"
             Write-Host "Creating $setupFolder2 Folder"
             New-Item -Path $setupFolder2 -type directory -Force
             Write-Host "Folder creation complete for $($user.Samaccountname)"

             #setting full control for user
             $Acl = Get-Acl -literalpath $setupfolder2
             $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("HS\$($user.samaccountName)", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
             $Acl.SetAccessRule($Ar)
             Set-Acl -literalpath "$setupfolder2" $Acl

             #gets acl on home folder
             (get-acl -literalpath "$setupfolder2").access | ft IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -auto

           }
       }
}