$UserCredential = Get-Credential -Message "Enter your O365 Credentials"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
$project = Read-host -Prompt 'Input group name'
$members = Read-Host -Prompt 'Enter group members usernames (ex. mlogue,krodney)'
$members = $members.Split(",")

Import-PSSession $Session

New-ADGroup -Name "HS VDI $project Group" -SamAccountName "HS VDI $project Group" -Path "OU=VDI and RDSH,OU=HSC AD Groups,OU=HSC,DC=HS,DC=wvu-ad,DC=wvu,DC=edu" -GroupScope Universal -GroupCategory Security -Server hsdc4
#get-help Add-ADGroupMember  -detailed
Add-ADGroupMember "HS CTSI VDI Research Group" "HS VDI $project Group" -Server hsdc4
add-adgroupmember "SAS 9.3 Research Application" "HS VDI $project Group" -Server hsdc4
add-adgroupmember "R Studio" "HS VDI $project Group" -Server hsdc4
add-adgroupmember "Adobe Acrobat XI" "HS CTSI $project Group" -Server hsdc4
Add-ADGroupMember "HSC VDI Research Projects Parent Group" "HS VDI $project Group" -Server hsdc4


$members | ForEach-Object { Add-ADGroupMember "HS VDI $project Group" "$_" -Server hsdc4}
$members | ForEach-Object { Add-ADGroupMember "FTP Users" "$_" -Server hsdc4}

$memberemails = $members | ForEach-Object {"$_@hsc.wvu.edu"}

Add-UnifiedGroupLinks -Identity "HorizonView@hsc.wvu.edu" -LinkType Members -Links $memberemails


Remove-PSSession $Session

#getting ad first and last name for home folder creation
$users = $members | ForEach-Object { Get-ADUser $_ | select samaccountname,Givenname,surname}

$ctsiserver = 'HSVDICTSI'

Write-Host "Waiting for 15 seconds for project group to become available to set permissions on share"
Start-Sleep 15

$ctsiserver | %{
         Invoke-Command -ComputerName $_ -ArgumentList $project,$users -ScriptBlock { 
             param($project,$users)

             $setupFolder = "D:\HSC Research\$($project)"
             Write-Host "Creating $project Folder"
             New-Item -Path $setupFolder -type directory -Force
             Write-Host "Folder creation complete"

             #setting full control for group on project folder
             $Acl = Get-Acl $setupfolder
             $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("HS\HS CTSI $project Group", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
             $Acl.SetAccessRule($Ar)
             Set-Acl $setupfolder $Acl

             #gets acl on group folder
             (get-acl $setupfolder).access | ft IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -auto


           foreach ($user in $users) {
             
             $userHomefolder = $user.surname.tolower() + $user.Givenname.substring(0,1).tolower()

             $setupFolder = "D:\HSC Research\Home\$($userHomefolder)"
             Write-Host "Creating $userHomeFolder Folder"
             New-Item -Path $setupFolder -type directory -Force
             Write-Host "Folder creation complete for $($user.Samsccountname)"

             #setting full control for user
             $Acl = Get-Acl $setupfolder
             $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("HS\$($user.samaccountName)", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
             $Acl.SetAccessRule($Ar)
             Set-Acl $setupfolder $Acl

             #gets acl on home folder
             (get-acl $setupfolder).access | ft IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -auto

           }
       }
}