
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                    ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FolderPath,

        [string]$CSCEmail,

        [string]$SavePath
    )

    $ACLUserProperties = @()
    $ACLGroupProperties = @()
    $NTFSPermissionsUsers = @()
    $NTFSPermissionsGroups = @()
    $DirName = $FolderPath.Split('\')[-1]
    $EmailSent = $false
    $FolderCount = 0
    $error.Clear()
    $Test = @()
    $SubDirName = @()
    $FilePathToLong = @()
    $FailedDirectory = @()



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
            $SavePath = "C:\Temp\$DirName.csv"
            Write-Output "Results will be saved to:  $SavePath"
        }
        else{
            $LoggedInUser = (Get-WMIObject -class Win32_ComputerSystem | Select-Object username).username
            $SavePath = "C:\users\$($LoggedInUser.split('\')[1])\Documents\GitHub\HSC-PowerShell-Repository\4NonScheduledTaskFiles\Get-FolderPermission\$DirName.csv"
            try{
                if(Test-Path -Path $SavePath){
                    #Write-Output "Results will be save at:  $SavePath"
                }
                else{
                    throw
                }
            }
            catch{
                $SavePath = "C:\users\$($LoggedInUser.split('\')[1])\Desktop\$DirName.csv"
                Write-Output "Results will be saved to:  $SavePath"
            }
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

        $NTFSPermissionsFolderPath = [PSCustomObject]@{
            'Path' = $FolderPath;
            'LastWriteTime' = $LastWriteTime;
            'Type' = "Folder/File";
            'Name' = "";
            'Email' = "";
            'Domain\User-Group Name'= "";
            'Dept' = "";
            'Permissions'= "";
            'Inherited'= ""
        }

        $Test += $NTFSPermissionsFolderPath | Select-Object Path,LastWriteTime,Type,'Domain\User-Group Name',Name,Permissions,Inherited
        $Test += ""
        $Test += ""

        foreach ($Member in $ACL.Access) {                
            
            [string]$CheckGroupOrUser = $Member.IdentityReference
            
            $GroupOrUser = Get-UserOrGroup -UserName $CheckGroupOrUser.Split('\')[1]

            if ($GroupOrUser -eq "user") {
                try{
                    Write-Output "Checking User: $($CheckGroupOrUser.Split('\')[1])"
                    
                    if (Get-ADUser $CheckGroupOrUser.Split('\')[1]){

                        $FindUserDept = Get-ADUser $CheckGroupOrUser.Split('\')[1] -Properties Department, Mail, CN
                        
                            $ACLUserProperties = [PSCustomObject]@{
                                            'Path' = "$FolderPath";
                                            'LastWriteTime' = "";
                                            'Type' = 'User';
                                            'Name' = $FindUserDept.CN;
                                            'Email' = $FindUserDept.Mail;
                                            'Domain\User-Group Name'=$CheckGroupOrUser;
                                            'Dept' = $FindUserDept.Department;
                                            'Permissions'=$Member.FileSystemRights;
                                            'Inherited'=$Member.IsInherited
                                        }
    
                            $NTFSPermissionsUsers += $ACLUserProperties
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
                            $ACLGroupProperties = [PSCustomObject]@{
                                            'Path' = "$FolderPath";
                                            'LastWriteTime' = "";
                                            'Type' = 'Group';
                                            'Name' = "";
                                            'Email' = "";
                                            'Domain\User-Group Name'=$CheckGroupOrUser;
                                            'Dept' = "";
                                            'Permissions'=$Member.FileSystemRights;
                                            'Inherited'=$Member.IsInherited
                                        }
    
                            $NTFSPermissionsGroups += $ACLGroupProperties
                        }
                    }
                }
                catch{
                    Write-Warning "There was an error getting information on $($CheckGroupOrUser.Split('\')[1])"
                }
            }
        }
        
        $NTFSPermissionsUsers = $NTFSPermissionsUsers | Sort-Object -Property 'Domain\User-Group Name'
        $NTFSPermissionsGroups = $NTFSPermissionsGroups | Sort-Object -Property 'Domain\User-Group Name'
       
       $Test += $NTFSPermissionsUsers
       $Test += $NTFSPermissionsGroups

        try{           
            $Test | Export-CSV -Path $SavePath -NoTypeInformation -ErrorAction Stop
        }
        catch{
            Write-Warning "There was an error writing to $SavePath"
            Write-Warning $error[0].Exception.Message
        }
    }

    if($FolderCount -gt 1) {
        
        try {
            $SubDirName = Get-ChildItem -Path $FolderPath -Recurse -ErrorAction SilentlyContinue -Directory
        }
        catch {
            Write-Warning "There was an error finding directory information for $($SubDirName.FullName)"
            Write-Warning $error[0].Exception.Message
        }

        $FilePathToLong = $SubDirName | Where-Object {$_.FullName.Length -gt 259}
        
        if ($FilePathToLong) {
            
            Write-Output "@($($FilePathToLong.Count)) directories with names too long found"
            
            ForEach ($DirToLong in $FilePathToLong) {
                Write-Output "FileName Length:  $($DirToLong.FullName.Length)"
                $FailedDirectory += $DirToLong
            }
        }
        else {
            Write-Output "No directories found over 259 character filename"
        }


        $DirToCheck = $SubDirName | Where-Object {$_.FullName.Length -le 259}

        foreach ($Dir in $DirToCheck) {
            try{
                Write-Output "Checking:  $($Dir.FullName)"
                $ACL = Get-ACL -Path $Dir.FullName -ErrorAction Stop
            }
            Catch{
                Write-Warning "There was an error getting the ACL information for $FolderPath"
                Write-Warning $error[0].Exception.Message
            }

            $LastWriteTime = $(Get-Item -Path $FolderPath).LastWriteTime
            $LastAccessTime = $(Get-Item -Path $FolderPath).LastAccessTime

            $NTFSPermissionsFolderPath = [PSCustomObject]@{
                'Path' = $Dir.FullName;
                'LastWriteTime' = $LastAccessTime;
                'Type' = "Folder/File";
                'Name' = "";
                'Email' = "";
                'Domain\User-Group Name'= "";
                'Dept' = "";
                'Permissions'= "";
                'Inherited'= ""
            }

            $Test += $NTFSPermissionsFolderPath | Select-Object Path,LastWriteTime,Type,'Domain\User-Group Name',Name,Permissions,Inherited
            $Test += ""

            foreach ($Member in $ACL.Access) {                
                
                [string]$CheckGroupOrUser = $Member.IdentityReference
                
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
                            
                                $ACLUserProperties = [PSCustomObject]@{
                                                'Path' = $Dir.FullName
                                                'LastWriteTime' = ""
                                                'Type' = 'User'
                                                'Name' = $FindUserDept.CN
                                                'Email' = $FindUserDept.Mail
                                                'Domain\User-Group Name'=$CheckGroupOrUser
                                                'Dept' = $FindUserDept.Department
                                                'Permissions'=$Member.FileSystemRights
                                                'Inherited'=$Member.IsInherited
                                            }
                                $Test += $ACLUserProperties
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
                                $ACLGroupProperties = [PSCustomObject]@{
                                                'Path' = $Dir.FullName
                                                'LastWriteTime' = ""
                                                'Type' = 'Group'
                                                'Name' = ""
                                                'Email' = ""
                                                'Domain\User-Group Name'=$CheckGroupOrUser
                                                'Dept' = ""
                                                'Permissions'=$Member.FileSystemRights
                                                'Inherited'=$Member.IsInherited
                                            }
                                $Test += $ACLGroupProperties
                            }
                        }
                    }
                    catch{
                        Write-Warning "There was an error getting information on $($CheckGroupOrUser.Split('\')[1])"
                    }
                }   
            }
            $Test += ""
            $Test += ""
            $Test += ""
        }

        try{           
            $Test | Export-CSV -Path $SavePath -NoTypeInformation -ErrorAction Stop
        }
        catch{
            Write-Warning "There was an error writing to $SavePath"
            Write-Warning $error[0].Exception.Message
        }

        if ($FailedDirectory -ne $null) {
            if (Test-Path "C:\AuditReport" -eq $false) {
            New-Item -Path "C:\AuditReport" -ItemType Directory -Force
            $FailedDirectory | Export-CSV -Path "C:\AuditReport\FailedDirectory.CSV" -NoTypeInformation
            }
            else {
                $FailedDirectory | Export-CSV -Path "C:\AuditReport\FailedDirectory.CSV" -NoTypeInformation
            } 
        }        
    }
    ### end main program ###

    ### email CSC section if true ###
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
    }
    ### end email CSC ###
#}