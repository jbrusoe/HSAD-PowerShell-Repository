[CmdletBinding()]
param (
    [string]$Project = $null,
    [string[]]$Members = $null,
    [string[]]$CTSIServers = "HSVDICTSI",
    [string]$GroupOU = "OU=VDI and RDSH,OU=HSC AD Groups,OU=HSC,DC=HS,DC=wvu-ad,DC=wvu,DC=edu",
    [string]$Server = "hsdc4",
    [string[]]$DefaultGroups =@(
    "HSC VDI Research Projects Parent Group",
    "SAS 9.3 Research Application",
    "R Studio",
    "Adobe Acrobat XI"
    )
)

try {
    Connect-HSCExchangeOnline -ErrorAction Stop
}
catch {
    Write-Warning "Unable to configure environment"
}

while ($null -eq $Project) {
    $Project = Read-Host "Input group name"
}

while ($null -eq $Members) {
    $Member = Read-Host -Prompt 'Enter Group Member(Enter to finish)'
    $Members += $Member
}

try {
    $NewADGroupName = "HS VDI $Project Group"
    Write-Output "New AD Group Name: $NewADGroup"

    $NewADGroupParams = @{
        Name = $NewADGroupName
        SamAccountName = $NewADGroupName
        Path = $GroupOU
        GroupScope = "Universal"
        GroupCategory = "Security"
        Server = $Server
        ErrorAction = "Stop"
    }

    New-ADGroup @NewADGroupParams

    Start-HSCCountdown -Message "Delay to allow group to sync" -Seconds 30

    Write-Output "Checking to ensure group has been created"

    $NewGroup = Get-ADGroup $NewADGroupName

    if ($null -eq $NewGroup) {
        throw
    }
    else {
        Write-Output "Group was created successfully"
    }
}
catch {
    Write-Warning "Unable to create new AD group"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Adding members to $NewGroupName"

    foreach ($DefaultGroup in $DefaultGroups) {
        Write-Output "Adding $NewADGroupName to $DefaultGroup"

        $AddADGroupMemberParams = @{
            Identity = $DefaultGroup
            Members = $NewADGroupName
            Server = $Server
            ErrorAction = "Stop"
        }

        Add-ADGroupMember @AddADGroupMemberParams
    }

  $members | ForEach-Object { Add-ADGroupMember "HS VDI $project Group" "$_" -Server hsdc4}
}
catch {
    Write-Warning "Error adding members to $NewADGroupName"
}

try {
    Write-Output "Adding members to FTP Users Group"

    foreach ($Member in $Members) 
    {

    }
}
catch {
    Write-Warning "Unable to add $Member to "
}
$members | ForEach-Object { Add-ADGroupMember "FTP Users" "$_" -Server hsdc4}

$memberemails = $members | ForEach-Object {"$_@hsc.wvu.edu"}

Add-UnifiedGroupLinks -Identity "HorizonView@hsc.wvu.edu" -LinkType Members -Links $memberemails


<#
#getting ad first and last name for home folder creation
$users = $members | ForEach-Object { Get-ADUser $_ | select samaccountname,Givenname,surname}

$ctsiserver = 'HSVDICTSI'

Write-Host "Waiting for groups to sync to dc's for adding share permissions"
sleep 30

$ctsiserver | %{
         Invoke-Command -ComputerName $_ -ArgumentList $project,$users -ScriptBlock { 
             param($project,$users)

             $setupFolder = "E:\HSC Research\$($project)"
             Write-Host "Creating $project Folder"
             New-Item -Path $setupFolder -type directory -Force
             Write-Host "Folder creation complete"

             #setting full control for group on project folder
             $Acl = Get-Acl $setupfolder
             $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("HS\HS VDI $project Group", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
             $Acl.SetAccessRule($Ar)
             Set-Acl $setupfolder $Acl

             #gets acl on group folder
             (get-acl $setupfolder).access | ft IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -auto


           foreach ($user in $users) {
             
             $userHomefolder = $user.surname.tolower() + $user.Givenname.substring(0,1).tolower()

             $setupFolder = "E:\HSC Research\Home\$($userHomefolder)"
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
#>