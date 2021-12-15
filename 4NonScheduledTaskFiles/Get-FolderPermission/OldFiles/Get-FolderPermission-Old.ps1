#Get-FolderPermissions
<#
.SYNOPSIS
    The purpose of this script is to get the file permissions on NTFS shares for CSC's to review

.DESCRIPTION
 	Requires
	
 	
.PARAMETER
	No required parameters

.NOTES
	Author: Kevin Russell
    	Last Updated by: 
        Last Updated:
        
        For a single folder you can use (Get-Acl -Path $FolderPath).Access.IdentityReference to return users/groups on 
        that single folder
#>

[CmdletBinding()]
param (
    [string]$FolderPath = "\\hs.wvu-ad.wvu.edu\public\Tools\Scripts\Clear-MSTeamsCache"    
)

$error.Clear()

#Set environment
try {
    $NTFSPermissionsUsers = @()
    $NTFSPermissionsGroups = @()
    $NTFSPermissions = @() 
    #$Permissions = @()   
    if (Test-Path $FolderPath){
        Write-Output "Checking NTFS permissions for path: $FolderPath"

        #check if folder has subfolders, if it does recurse paramater will be used later
        $FolderCount = (Get-ChildItem -Directory -Path $FolderPath).Count
    }
    else {
        throw "$FolderPath does not exist"
    }
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}
#End environment setup

#Section for single folder, get-childitem -recurse not needed
if ($FolderCount -eq 0){
    if ($FolderPath.length -gt 259){
        Write-Warning "$FolderPath exceeds 260 characters and is not valid"
    }
    else{
        Try{                               
            $ACL = Get-ACL -Path $FolderPath -ErrorAction Stop            
        }
        Catch{
            Write-Warning "There was an error getting the ACL information for $FolderPath"
            Invoke-HSCExitCommand -ErrorCount $Error.Count
        }
    
        foreach ($Access in $ACL.Access) {        
            
            [string]$CheckGroupOrUser = $Access.IdentityReference
            
            try{
                if (Get-ADUser $CheckGroupOrUser.Split('\')[1]){                
                    if ($CheckGroupOrUser.Split('\')[0] -eq 'NT AUTHORITY'){
    
                    }
                    else{
                        $FindUserDept = Get-ADUser $CheckGroupOrUser.Split('\')[1] -Properties Department, Mail, CN
    
                        $ACLProperties = [ordered]@{#'Folder Name'=$FolderPath;
                                        'Domain' = $CheckGroupOrUser.Split('\')[0];
                                        'Type' = 'User';
                                        'Name' = $FindUserDept.CN;
                                        'Email' = $FindUserDept.Mail;
                                        'User/Group Name'=$CheckGroupOrUser.Split('\')[1];                
                                        'Dept' = $FindUserDept.Department;
                                        'Permissions'=$Access.FileSystemRights;
                                        'Inherited'=$Access.IsInherited
                                        }
                        $NTFSPermissionsUsers += New-Object -TypeName PSObject -Property $ACLProperties
                    }                
                }
            }
            catch{                        
            }
    
            try{
                if (Get-ADGroup $CheckGroupOrUser.Split('\')[1]){                
                    if ($CheckGroupOrUser.Split('\')[0] -eq 'BUILTIN'){
                        
                    }
                    else {
                        $ACLProperties = [ordered]@{#'Folder Name'=$FolderPath;
                                                    'Domain' = $CheckGroupOrUser.Split('\')[0];
                                                    'Type' = 'Group';
                                                    'Name' = '';
                                                    'Email' = '';
                                                    'User/Group Name'=$CheckGroupOrUser.Split('\')[1];                            
                                                    'Dept' = '';
                                                    'Permissions'=$Access.FileSystemRights;
                                                    'Inherited'=$Access.IsInherited
                        }
                        $NTFSPermissionsGroups += New-Object -TypeName PSObject -Property $ACLProperties 
                    }                
                }
            }
            catch{            
            }        
        }   
        
        $FolderPath | Export-Csv -Path 'c:\users\krussell\desktop\permissions.csv' -NoTypeInformation -Append 
        Write-Output '---------------------------------' | Export-Csv -Path 'c:\users\krussell\desktop\permissions.csv' -NoTypeInformation -Append
        $NTFSPermissionsUsers = $NTFSPermissionsUsers | Sort-Object -Property 'Folder Name'
        $NTFSPermissionsGroups = $NTFSPermissionsGroups | Sort-Object -Property 'Folder Name'        
        $NTFSPermissions = $NTFSPermissionsUsers + $NTFSPermissionsGroups
        $NTFSPermissions  | Export-Csv -Path 'c:\users\krussell\desktop\permissions.csv' -NoTypeInformation -Append -Force
    }    
}
#end single folder section

#multiple folder section, need to use get-childitem -recurse along with get-acl
else {
    Try{    
        $CheckFolderRights = Get-ChildItem -Directory -Path $FolderPath -Recurse -Force -ErrorAction Stop
    }
    Catch{
        Write-Warning "There was an error getting the directory structure"
    }
    
    foreach ($Folder in $CheckFolderRights) {    
        if ($Folder.FullName -gt 259){
            Write-Warning "$FolderPath exceeds 260 characters and is not valid"
        }
        else{
            Write-Host "Checking permissions for: $Folder"
            try {
                $ACL = Get-ACL -Path $Folder.FullName -ErrorAction Stop        
            }
            catch {
                Write-Warning "There was an error getting the folders full name"
            }        

            foreach ($Access in $ACL.Access) {        
            
                [string]$CheckGroupOrUser = $Access.IdentityReference
                
                try{
                    if (Get-ADUser $CheckGroupOrUser.Split('\')[1]){                
                        if ($CheckGroupOrUser.Split('\')[0] -eq 'NT AUTHORITY'){
        
                        }
                        else{
                            $FindUserDept = Get-ADUser $CheckGroupOrUser.Split('\')[1] -Properties Department, Mail, CN
        
                            $ACLProperties = [ordered]@{'Folder Name'=$Folder.FullName;
                                            'Domain' = $CheckGroupOrUser.Split('\')[0];
                                            'Type' = 'User';
                                            'Name' = $FindUserDept.CN;
                                            'Email' = $FindUserDept.Mail;
                                            'User/Group Name'=$CheckGroupOrUser.Split('\')[1];                
                                            'Dept' = $FindUserDept.Department;
                                            'Permissions'=$Access.FileSystemRights;
                                            'Inherited'=$Access.IsInherited
                                            }
                            $NTFSPermissionsUsers += New-Object -TypeName PSObject -Property $ACLProperties
                        }                
                    }
                }
                catch{                        
                }
        
                try{
                    if (Get-ADGroup $CheckGroupOrUser.Split('\')[1]){                
                        if ($CheckGroupOrUser.Split('\')[0] -eq 'BUILTIN'){
                            
                        }
                        else {
                            $ACLProperties = [ordered]@{'Folder Name'=$Folder.FullName;
                                                        'Domain' = $CheckGroupOrUser.Split('\')[0];
                                                        'Type' = 'Group';
                                                        'Name' = '';
                                                        'Email' = '';
                                                        'User/Group Name'=$CheckGroupOrUser.Split('\')[1];                            
                                                        'Dept' = '';
                                                        'Permissions'=$Access.FileSystemRights;
                                                        'Inherited'=$Access.IsInherited
                            }
                            $NTFSPermissionsGroups += New-Object -TypeName PSObject -Property $ACLProperties 
                        }                
                    }
                }
                catch{            
                }        
            }   
            
            $NTFSPermissionsUsers = $NTFSPermissionsUsers | Sort-Object -Property 'User/Group Name'
            $NTFSPermissionsGroups = $NTFSPermissionsGroups | Sort-Object -Property 'User/Group Name'        
            $NTFSPermissions = $NTFSPermissionsUsers + $NTFSPermissionsGroups
            $NTFSPermissions | Export-Csv -Path 'c:\users\krussell\desktop\permissions.csv' -NoTypeInformation
        }        
    }
    
}