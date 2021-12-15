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

        #\\hsc-its\its\security services\folder permissions reports\2021\
    #>

#Function Get-HSCNTFSFolderPermission {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                    ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FolderPath,

        [string]$SavePath,

        [string]$Today = (Get-Date -Format MM-dd-yyyy)
    )

    $DirName = $FolderPath.Split('\')[-1]
    
    $FolderCount = 0
    $error.Clear()
    
    #GPEdit location:  Configuration>Administrative Templates>System>FileSystem 
    Set-ItemProperty 'HKLM:\System\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -value 1

    Function Get-UserOrGroup {
        [CmdletBinding()]
        param(
            $UserName 
        )
    
        $GroupOrUser = ""
        $searcher = [adsisearcher]"(SamAccountName=$UserName)"
        $null = $searcher.PropertiesToLoad.Add('objectClass')
    
        $result = $searcher.FindOne()
    
        if ($result) {
            Write-Output ([object[]] $result.Properties['objectClass'])[-1]
            $GroupOrUser = ([object[]] $result.Properties['objectClass'])[-1]
        }
        else {
            Write-Warning "There was a problem finding information for $UserName"
        }
    }


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
        $LoggedInUser = (Get-WMIObject -class Win32_ComputerSystem | Select-Object username).username
        $UserName = $LoggedInUser.split('\')[1]
        if ($UserName){
            $SavePath = "C:\users\$UserName\Documents\$DirName.csv"
            Write-Output = "Results will be saved to:  $SavePath"
        }
        else {
            $SavePath = "C:\Temp\$Date-$DirName.csv"
            Write-Output "Results will be saved to:  $SavePath"            
        }
    }
    ### end setup save path ###

    ### main program: Get ACL info; parse and save ###
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
        
        $LastWriteTime = $(Get-Item -Path $FolderPath).LastWriteTime
        $LastAccessTime = $(Get-Item -Path $FolderPath).LastAccessTime
        
        [PSCustomObject]@{
            'Path' = $FolderPath;
            'LastWriteTime' = $LastWriteTime;
            'Type' = "Folder/File";
            'Name' = "";
            'Email' = "";
            'Domain\User-Group Name'= "";
            'Dept' = "";
            'Permissions'= "";
            'Inherited'= ""
        } | Export-Csv -Path C:\Test\$Today-permissionstest.csv -NoTypeInformation -Append -Force

        foreach ($Member in $ACL.Access) {                
            
            [string]$CheckGroupOrUser = $Member.IdentityReference
            
            $GroupOrUser = Get-UserOrGroup -UserName $CheckGroupOrUser.Split('\')[1]

            if ($GroupOrUser -eq "user") {
                try{
                    Write-Output "Checking User: $($CheckGroupOrUser.Split('\')[1])"
                    
                    if (Get-ADUser $CheckGroupOrUser.Split('\')[1]){

                        $FindUserDept = Get-ADUser $CheckGroupOrUser.Split('\')[1] -Properties Department, Mail, CN                        
                            
                            [PSCustomObject]@{
                                            'Path' = "$FolderPath";
                                            'LastWriteTime' = "";
                                            'Type' = 'User';
                                            'Name' = $FindUserDept.CN;
                                            'Email' = $FindUserDept.Mail;
                                            'Domain\User-Group Name'=$CheckGroupOrUser;
                                            'Dept' = $FindUserDept.Department;
                                            'Permissions'=$Member.FileSystemRights;
                                            'Inherited'=$Member.IsInherited
                                        } | Sort-Object -Property "Domain\User-Group Name" |
                                        Export-Csv -Path C:\Test\$Today-permissionstest.csv -NoTypeInformation -Append -Force       
                    }
                }
                catch{
                    Write-Warning "There was an error getting information on $($CheckGroupOrUser.Split('\')[1])"
                }
            }

            if ($GroupOrUser -eq "group") {
                try{
                    Write-Output "Checking Group: $($CheckGroupOrUser.Split('\')[1])"

                    if (Get-ADGroup $CheckGroupOrUser.Split('\')[1]){
                        if (($CheckGroupOrUser.Split('\')[0] -eq 'BUILTIN') -OR ($CheckGroupOrUser.Split('\')[0] -eq 'NT AUTHORITY')) {
                        }
                        else{                            
                            [PSCustomObject]@{
                                            'Path' = "$FolderPath";
                                            'LastWriteTime' = "";
                                            'Type' = 'Group';
                                            'Name' = "";
                                            'Email' = "";
                                            'Domain\User-Group Name'=$CheckGroupOrUser;
                                            'Dept' = "";
                                            'Permissions'=$Member.FileSystemRights;
                                            'Inherited'=$Member.IsInherited
                                        } | Sort-Object -Property "Domain\User-Group Name" |
                                        Export-Csv -Path C:\Test\$Today-permissionstest.csv -NoTypeInformation -Append -Force
                        }
                    }
                }
                catch{
                    Write-Warning "There was an error getting information on $($CheckGroupOrUser.Split('\')[1])"
                }
            }
        }
    }

    if($FolderCount -gt 1) {    
        Get-ChildItem -Path $FolderPath -Recurse -ErrorAction SilentlyContinue -Directory | ForEach-Object {
            try{
                Write-Output "Checking:  $($_.FullName)"
                $ACL = Get-ACL -Path $_.FullName -ErrorAction Stop
            }
            Catch{
                Write-Warning "There was an error getting the ACL information for $FolderPath"
                Write-Warning $error[0].Exception.Message
            }

            $LastWriteTime = $(Get-Item -Path $_.FullName).LastWriteTime
            $LastAccessTime = $(Get-Item -Path $_.FullName).LastAccessTime

            [PSCustomObject]@{
                'Path' = $_.FullName;
                'LastWriteTime' = $LastAccessTime;
                'Type' = "Folder/File";
                'Name' = "";
                'Email' = "";
                'Domain\User-Group Name'= "";
                'Dept' = "";
                'Permissions'= "";
                'Inherited'= ""
            } | Export-Csv -Path C:\Test\$Today-permissionstest.csv -NoTypeInformation -Append -Force

            foreach ($Member in $ACL.Access) {    
                
                $CheckGroupOrUser = $Member.IdentityReference                
                try {
                    $GroupOrUser = Get-UserOrGroup -UserName $CheckGroupOrUser.Split('\')[1] -ErrorAction Stop
                }
                catch {
                    Write-Output "Error finding information on:  $CheckGroupOrUser"
                    Write-Warning $error[0].Exception.Message
                }

                if ($GroupOrUser -eq "user") {
                    try{
                        Write-Output "Checking User: $($CheckGroupOrUser.Split('\')[1])"
                        
                        if (Get-ADUser $CheckGroupOrUser.Split('\')[1]){

                            $FindUserDept = Get-ADUser $CheckGroupOrUser.Split('\')[1] -Properties Department, Mail, CN
                            
                                [PSCustomObject]@{
                                                'Path' = $_.FullName
                                                'LastWriteTime' = ""
                                                'Type' = 'User'
                                                'Name' = $FindUserDept.CN
                                                'Email' = $FindUserDept.Mail
                                                'Domain\User-Group Name'=$CheckGroupOrUser
                                                'Dept' = $FindUserDept.Department
                                                'Permissions'=$Member.FileSystemRights
                                                'Inherited'=$Member.IsInherited
                                            } | Export-Csv -Path C:\Test\$Today-permissionstest.csv -NoTypeInformation -Append -Force
                        }
                    }
                    catch{
                        Write-Warning "There was an error getting information on $($CheckGroupOrUser.Split('\')[1])"
                    }
                }

                if ($GroupOrUser -eq "group") {
                    try{
                        Write-Output "Checking Group: $($CheckGroupOrUser.Split('\')[1])"

                        if (Get-ADGroup $CheckGroupOrUser.Split('\')[1]){
                            if (($CheckGroupOrUser.Split('\')[0] -eq 'BUILTIN') -OR ($CheckGroupOrUser.Split('\')[0] -eq 'NT AUTHORITY')) {
                            }
                            else{
                                [PSCustomObject]@{
                                                'Path' = $_.FullName
                                                'LastWriteTime' = ""
                                                'Type' = 'Group'
                                                'Name' = ""
                                                'Email' = ""
                                                'Domain\User-Group Name'=$CheckGroupOrUser
                                                'Dept' = ""
                                                'Permissions'=$Member.FileSystemRights
                                                'Inherited'=$Member.IsInherited
                                            } | Export-Csv -Path C:\Test\$Today-permissionstest.csv -NoTypeInformation -Append -Force
                            }
                        }
                    }
                    catch{
                        Write-Warning "There was an error getting information on $($CheckGroupOrUser.Split('\')[1])"
                    }
                }   
            }
          #Added empty PSCustomObject for spaces between directory names in output if needed
        }
    }
    ### end main program ###