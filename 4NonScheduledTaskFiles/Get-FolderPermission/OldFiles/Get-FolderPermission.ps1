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

Function Get-FolderPermission {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$FolderPath,
        [string]$CSCEmail,
        [string]$SavePath  
    )
    
    $ACLUserProperties = @()
    $ACLGroupProperties = @()
    $NTFSPermissionsUsers = @()
    $NTFSPermissionsGroups = @()
    $NTFSPermissions = @()
    $InstalledModules = @()    
    $DirName = $FolderPath.Split('\')[-1]
    $EmailSent = $false
    $FolderCount = 0    
    $error.Clear()

    #Set-HSCEnvironment

    ### Check for required Excel module ###
    try{
        $InstalledModules = Get-InstalledModule -ErrorAction Stop         
    }
    catch{
        Write-Warning "Error getting installed module, cannot check for ImportExcel module"
        Write-Warning $error[0].Exception.Message
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }
    
    if(($InstalledModules.Name).Contains("ImportExcel")){
        Write-Output "ImportExcel module:  Installed"
    }
    else{        
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
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
            Write-Warning "ImportExcel module:  Not installed."
            Write-Warning "Please restart powershell as admin and run Install-Module ImportExcel -Scope CurrentUser"
            Invoke-HSCExitCommand -ErrorCount $Error.Count
        }        
    }
    ### end check ###

    ### check folder ###
    try{
        if (Test-Path -Path $FolderPath){
            Write-Output "Directory:  $FolderPath"
        }
        else{ 
            throw            
        }    
    }
    catch{
        Write-Warning "$FolderPath does not exist"
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }    
    
    try{
        $FolderCount = (Get-ChildItem "$FolderPath").count
        Write-Output "Folder Count:  $FolderCount"
    }
    catch{
        Write-Warning "There was an error getting the folder count for $DirName"
        Write-Warning $error[0].Exception.Message
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }

    try{   
        if ($FolderPath.length -le 259){
            Write-Output "Folder path does not exceed 260 characters"
        }
        else{
            throw 
        }
    }
    catch{
        Write-Warning "$FolderPath exceeds 260 characters and is not valid"
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }
    ### end check folder ###

    ### check/Set save path ###
    if(![string]::IsNullOrEmpty($SavePath)){
        try{   
            if(Test-Path -Path $SavePath){                
            }
            else{
                throw
            }
        }
        catch{
            Write-Warning "$SavePath is not valid"
            Invoke-HSCExitCommand -ErrorCount $Error.Count
        }
    }
    else{
        if ([string]::IsNullOrEmpty((Get-WMIObject -class Win32_ComputerSystem | Select-Object username).username)){                   
            $SavePath = "C:\Temp\$DirName.xlsx"
            Write-Output "Results will be save at:  $SavePath"
        }
        else{
            $LoggedInUser = (Get-WMIObject -class Win32_ComputerSystem | Select-Object username).username
            $SavePath = "C:\users\$($LoggedInUser.split('\')[1])\Documents\GitHub\HSC-PowerShell-Repository\4NonScheduledTaskFiles\Get-FolderPermission\$DirName.xlsx"
            try{
                if(Test-Path -Path $SavePath){
                    #Write-Output "Results will be save at:  $SavePath"
                }
                else{
                    throw
                }
            }
            catch{
                $SavePath = "C:\users\$($LoggedInUser.split('\')[1])\Desktop\$DirName.xlsx"
                Write-Output "Results will be save at:  $SavePath"
            }      
        }
    }
    ### end setup save path ###

    ###########################################
    #Main program: Get ACL info; parse and save
    ###########################################
    if($FolderCount -eq 0){
        Write-Warning "There where no folders found at $FilePath"
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }
    if($FolderCount -eq 1){        
        try{                               
            $ACL = Get-ACL -Path $FolderPath -ErrorAction Stop            
        }
        Catch{
            Write-Warning "There was an error getting the ACL information for $FolderPath"
            Write-Warning $error[0].Exception.Message
            Invoke-HSCExitCommand -ErrorCount $Error.Count
        }        
        foreach ($Access in $ACL.Access) { 
            [string]$CheckGroupOrUser = $Access.IdentityReference                    
            try{                        
                if (Get-ADUser $CheckGroupOrUser.Split('\')[1]){                    
                        $FindUserDept = Get-ADUser $CheckGroupOrUser.Split('\')[1] -Properties Department, Mail, CN            
                        $ACLUserProperties = [PSCustomObject]@{'Type' = 'User';
                                        'Name' = $FindUserDept.CN;
                                        'Email' = $FindUserDept.Mail;
                                        'Domain\User-Group Name'=$CheckGroupOrUser;                
                                        'Dept' = $FindUserDept.Department;
                                        'Permissions'=$Access.FileSystemRights;
                                        'Inherited'=$Access.IsInherited
                                        }                                
                        $NTFSPermissionsUsers += $ACLUserProperties                                
                                    
                }                        
            }
            catch{                       
            }
            
            try{
                if (Get-ADGroup $CheckGroupOrUser.Split('\')[1]){                            
                    if (($CheckGroupOrUser.Split('\')[0] -eq 'BUILTIN') -OR ($CheckGroupOrUser.Split('\')[0] -eq 'NT AUTHORITY')){                        
                    }
                    else{                                          
                        $ACLGroupProperties = [PSCustomObject]@{'Type' = 'Group';
                                        'Name' = 'N/A';
                                        'Email' = 'N/A';
                                        'Domain\User-Group Name'=$CheckGroupOrUser;                            
                                        'Dept' = 'N/A';
                                        'Permissions'=$Access.FileSystemRights;
                                        'Inherited'=$Access.IsInherited
                                        }                                
                        $NTFSPermissionsGroups += $ACLGroupProperties                        
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
    if($FolderCount -ge 2){
        #Multi folder added later
        Write-Host $FolderPath
    }    
    #################
    #End main program
    #################
    
    
    ##########################
    #Email CSC section if true
    ##########################
    $error.Clear()

    if ($CSCEmail){
        Write-Output "Pausing 60 seconds for file creation..."
        Start-Sleep -Seconds 60

        $EmailParams = @{
            SmtpServer = "hssmtp.hsc.wvu.edu"    
            From = 'no-reply@hsc.wvu.edu'
            To = $CSCEmail
            Subject = "Permissions for $DirName"
            Body = "Attached is an excel file with permissions for:`n $FolderPath"
            Attachments = $SavePath
        }
        
        try{
            Send-MailMessage @EmailParams -ErrorAction Stop
            Write-Output "Email was sent to $CSCEmail"
            $EmailSent = $true
        }
        catch{
            Write-Warning "There was an issue sending the email to $CSCEmail"
            Write-Warning "Please send the file manually to the apporiate user"
            Write-Warning "Location: $SavePath"
            Write-Warning $error[0].Exception.Message           
            Invoke-HSCExitCommand -ErrorCount $Error.Count
        }
        
        if ($EmailSent){
            Write-Output "Pausing 90 seconds before file deletion..."
            Start-Sleep -Seconds 90
            try{
                Remove-Item -Path $SavePath -Force -ErrorAction Stop
                Write-Output "$DirName was removed"
            }
            catch{
                Write-Warning "There was an error removing $SavePath"
                Write-Warning $error[0].Exception.Message
                Invoke-HSCExitCommand -ErrorCount $Error.Count
            }            
        }
        else{        
        }
    }
    else{
        Write-Output "No CSC email address was provided"
        Write-Output "Results saved at:  $SavePath"
    }    
    ##############
    #End email CSC
    ##############    
}