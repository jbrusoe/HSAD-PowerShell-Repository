<#
    .SYNOPSIS
        The purpose of this script is to get the file permissions on a single folder
    
    .DESCRIPTION
        1.  Has mandatory input of $FolderPath.  You can also pass in a location to save your file, $SavePath;
            and csc email address, $CSCEmail
        2.  Check for ImportExcel module and exit if its not installed
        3.  If no save location was specified, find logged in user and save it to the Get-SingleFolderPermission Github  
            folder with directory name as filename
        4.  Verify folder name is less that 260 characters
        5.  Get ACL information for specified folder
        6.  Loop through ACL information and split into two categories:
            a)  Users
                -Exclude NT AUTHORITY account
                -Create custom object with attributes: Name,Email,Domain\User-Group Name, Dept, Permissions and Inherited
                -Sort by Domain\User-Group Name
            b)  Groups
                -Exclude BUILTIN
                -Create custom object with attributes: Name,Email,Domain\User-Group Name, Dept, Permissions and Inherited
                -Sort by Domain\User-Group Name
        7.  Combine the two arrays and export to save location
        8.  Email CSC if email paramater is provided.  Remove file after emailing it to CSC.	
    
    .PARAMETER FolderPath
        this is a mandatory parameter with a position of 0.  this is the location of the folder to retrieve
        the rights from
    
    .PARAMETER SavePath
        this is the path to where the output will be saved.  defaults to Get-SingleFolderPermission directory in
        local Github folder if not supplied
    
    
        
    
    .EXAMPLE
        Get-SingleFolderPermission -FolderPath "\\hs.wvu-ad.wvu.edu\public\tools\scripts\clear-msteamscache"
        Get-SingleFolderPermission "C:\SingleFolder" -SavePath "C:\FolderPermissions"
    
    .NOTES
        Author: Kevin Russell
    	Last Updated by: Kevin Russell 
        Last Updated: 02/19/2021       

        Required: ImportExcel module
    #>

Function Get-HSCNTFSFolderPermission {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$FolderPath,

        [string]$SavePath
    )
    
    try{                               
        $ACL = Get-ACL -Path $FolderPath -ErrorAction Stop            
    }
    Catch{
        Write-Warning "There was an error getting the ACL information for $FolderPath"
        Write-Warning $error[0].Exception.Message
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }        

    foreach ($UserAccess in $ACL.Access){
        
        [string]$CheckGroupOrUser = $UserAccess.IdentityReference                    
        write-host $CheckGroupOrUser
        try{                        
            if (Get-ADUser $CheckGroupOrUser.Split('\')[1]){                    
                    
                    $FindUserDept = Get-ADUser $CheckGroupOrUser.Split('\')[1] -Properties Department, Mail, CN            
                    write-host "hi"
                    $ACLUserProperties = [PSCustomObject]@{
                                    'Type' = 'User';
                                    'Name' = $FindUserDept.CN;
                                    'Email' = $FindUserDept.Mail;
                                    'Domain\User-Group Name'=$CheckGroupOrUser;                
                                    'Dept' = $FindUserDept.Department;
                                    'Permissions'=$Access.FileSystemRights;
                                    'Inherited'=$Access.IsInherited
                                }                                
                    
                    $NTFSPermissionsUsers += $ACLUserProperties
                    write-host $NTFSPermissionsUsers                    
            }
        }
        catch{
        }
        
        try{
            if (Get-ADGroup $CheckGroupOrUser.Split('\')[1]){                            
                if (($CheckGroupOrUser.Split('\')[0] -eq 'BUILTIN') -OR ($CheckGroupOrUser.Split('\')[0] -eq 'NT AUTHORITY')){                        
                }
                else{                                          
                    write-host "bye"
                    $ACLGroupProperties = [PSCustomObject]@{
                                    'Type' = 'Group';
                                    'Name' = 'N/A';
                                    'Email' = 'N/A';
                                    'Domain\User-Group Name'=$CheckGroupOrUser;                            
                                    'Dept' = 'N/A';
                                    'Permissions'=$Access.FileSystemRights;
                                    'Inherited'=$Access.IsInherited
                                }                                
                    
                    $NTFSPermissionsGroups += $ACLGroupProperties
                    write-host $NTFSPermissionsGroups                 
                }      
            }                              
        }    
        catch{                                                   
        }
    }
    $NTFSPermissionsUsers = $NTFSPermissionsUsers | Sort-Object -Property 'Domain\User-Group Name'
    $NTFSPermissionsGroups = $NTFSPermissionsGroups | Sort-Object -Property 'Domain\User-Group Name'        

$NTFSPermissions = $NTFSPermissionsUsers + $NTFSPermissionsGroups                   
$NTFSPermissions | Export-Excel -Path $SavePath -AutoSize -WorksheetName $DirName        
}