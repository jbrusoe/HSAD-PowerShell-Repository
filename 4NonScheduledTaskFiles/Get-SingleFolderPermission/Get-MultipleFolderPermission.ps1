#Get-MultipleFolderPermission
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
    
    .PARAMETER CSCEmail
    this is the email for the CSC.  if provided the file will be sent to the CSC.
    
    .EXAMPLE
    Get-SingleFolderPermission -FolderPath "\\hs.wvu-ad.wvu.edu\public\tools\scripts\clear-msteamscache"
    Get-SingleFolderPermission "C:\SingleFolder" -SavePath "C:\FolderPermissions"
    
    .NOTES
    Author: Kevin Russell
    	Last Updated by: Kevin Russell 
        Last Updated: 02/19/2021       

        Required: ImportExcel module
    #>

Function Get-SingleFolderPermission {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$FolderPath,
        [Parameter(Position=1)]
        [string]$CSCEmail,
        [Parameter(Position=2)]
        [string]$SavePath   
    )
    
    #clear arrays
    $ACLUserProperties = @()
    $ACLGroupProperties = @()
    $NTFSPermissionsUsers = @()
    $NTFSPermissionsGroups = @()
    $NTFSPermissions = @()
    $InstalledModules = @()
    $DirName = $FolderPath.Split('\')[-1]
    $EmailSent = $false
    $error.Clear()

    #Set-HSCEnvironment

    ################################
    #Check for required Excel module
    ################################
    try{
        $InstalledModules = Get-InstalledModule -ErrorAction Stop         
    }
    catch{
        Write-Warning "Error getting installed module, cannot check for Excel module"
        Write-Warning $error[0].Exception.Message
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }
    
    if (($InstalledModules.Name).Contains("ImportExcel")){
        Write-Output "Excel powershell module is installed"
    }
    else {
        #Excl module needs to be installed as admin
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
            try{
                Install-Module ImportExcel -Scope CurrentUser
            }
            catch{
                Write-Warning "There was an error importing the Excel module"
                Write-Warning $error[0].Exception.Message
                Invoke-HSCExitCommand -ErrorCount $Error.Count
            }            
        }
        else{
            Write-Warning "Excel module is not installed."
            Write-Warning "Please restart powershell as admin and run Install-Module ImportExcel -Scope CurrentUser"
            Invoke-HSCExitCommand -ErrorCount $Error.Count
        }        
    }
    ##########
    #end check
    ##########

    ##############################################################################
    #Main program: Check folder path, set save path if not provided and get rights
    ##############################################################################
    try{
        if (Test-Path -Path $FolderPath){
            Write-Output "Scanning directory:  $FolderPath"

            #if no path was given to save the file, save it to currently logged on users desktop 
            if (!$SavePath){
                if ([string]::IsNullOrEmpty((Get-WMIObject -class Win32_ComputerSystem | Select-Object username).username)){                   
                    $SavePath = "C:\Temp\$DirName.xlsx"
                    Write-Output "Results saved:  $SavePath"
                }
                else{
                    $LoggedInUser = (Get-WMIObject -class Win32_ComputerSystem | Select-Object username).username
                    $SavePath = "C:\users\$($LoggedInUser.split('\')[1])\Documents\GitHub\HSC-PowerShell-Repository\4NonScheduledTaskFiles\Get-SingleFolderPermission\$DirName.xlsx"
                    Write-Output "Results saved:  $SavePath"  
                }
            }
            else{
                Write-Output "Results saved:  $SavePath"      
            }    
        }
        else{ 
            Throw "$FolderPath does not exist"           
        }         

        #verify folder length less than 260
        if ($FolderPath.length -gt 259){
            Write-Warning "$FolderPath exceeds 260 characters and is not valid"
        }
        else{
            Try{    
                $FoldersToCheck = Get-ChildItem -Directory -Path $FolderPath -Recurse -Force -ErrorAction Stop
            }
            Catch{
                Write-Warning "There was an error getting the directory structure"
                Write-Warning $error[0].Exception.Message
                Invoke-HSCExitCommand -ErrorCount $Error.Count
            }
        }

        foreach ($Folder in $FoldersToCheck) {
            Write-Host "Checking permissions for: $Folder"
            try {
                $ACL = Get-ACL -Path $Folder.FullName -ErrorAction Stop        
            }
            catch {
                Write-Warning "There was an error getting the folders full name"
                Write-Warning $error[0].Exception.Message
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
        