Function Publish-HSCModule {
    <#
        .SYNOPSIS
            The purpose of this function is to publish the HSC custom powershell 
            modules to the HSCPSRepo.  When modules publish they get stored at
            \\hs-tools\tools\HSCCustomModules as NUPKG files.
    
        .EXAMPLE
            Publish-HSCModule "C:\users\krussell\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules" -Verbose

        .EXAMPLE
            Publish-HSCModule -HSCModulesLocation "C:\users\krussell\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules"

        .NOTES
            Written by: Kevin Russell
            Written on: 6/7/21

            Last Updated by: Kevin Russell
            Last Updated on: 6/8/21
        
            PS Version 5 Tested: 6/8/21
            PS Version 7 Tested:
        
            Requires being run as admin
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]	
        [string]$HSCModuleLocation
    )

    $error.Clear()
    $HSCModule = @()
    $HSCModule = Get-ChildItem -Path $HSCModuleLocation -Name
    
    try {
        if ((Get-PSRepository).Name -contains "HSCPSRepo") {
            Write-Verbose "HSCPSRepo:  Installed"
        }
    }
    catch {
        Write-Verbose "HSCPSRepo is not installed."
    }
    
    Write-Verbose "Modules found:  $($HSCModule.Count)"

    ForEach ($Module in $HSCModule) {
        
        $HSCModuleParam = @{
            Path = "$HSCModuleLocation\$Module"
            Repository = "HSCPSRepo"
            NuGetApiKey = "AnyStringWillDo"
        }
        
        if (($Module -ne "EncryptedFiles") -AND ($Module -ne "MappingFiles") -AND ($Module -ne "README.md")) {
            
            Write-Verbose "Checking HSCPSRepo:  $Module"

            try {
                Find-Module -Name "$Module" -Repository "HSCPSRepo" -ErrorAction Stop | Out-Null

                Write-Verbose "$Module found.  Moving to next module."
            }
            catch {
                Write-Verbose "Attempting to publish:  $Module"

                try {
                    Publish-Module @HSCModuleParam -Force -ErrorAction Stop
                    Write-Verbose "$Module published fine"
                }
                catch {
                    Write-Verbose "There was an error trying to install $Module"
                    Write-Warning $error[0].Exception.Message
                }
            }    
        }
    }
}

Function Update-HSCModule {
    <#
        .SYNOPSIS
            The purpose of this function is to update all HSC modules
    
        .EXAMPLE
            

        .EXAMPLE
            

        .NOTES
            Written by: Kevin Russell
            Written on: 

            Last Updated by: 
            Last Updated on:
        
            PS Version 5 Tested: 6/8/21
            PS Version 7 Tested:
        
            Requires being run as admin
    #>    

    [CmdletBinding()]
    param(

        [string]$FileShareLocation = "\\hs-tools\tools\HSCCustomModules",

        [array]$PublishedModules = (Get-ChildItem $FileShareLocation | Split-Path -Leaf),

        [string]$HSCRepository = "HSCPSRepo",

        [array]$InstalledModules = (Get-InstalledModule).Name
    
    )
    
    ForEach ($Module in $PublishedModules) {

        $ModuleName = $Module.Split(".")[0]

        Write-Output "Checking for $ModuleName"

        if ("$InstalledModules" -contains "$ModuleName") {
            Write-Verbose "$($ModuleName):  Installed"
            Write-Verbose "Removing $ModuleName"

            try {
                Uninstall-Module -Name "$ModuleName" -AllVersions -Force -ErrorAction Stop
            }
            catch {
                Write-Verbose "There was an error removing $ModuleName"
                Write-Warning $error[0].Exception.Message
            }            
        }
        else {
            Write-Verbose "$($ModuleName):  Not Installed"
        }

        try {
            $InstallParam = @{
                Name = "$ModuleName"
                Repository = "HSCPSRepo"
            }

            Install-Module @InstallParam -Force -AllowClobber -ErrorAction Stop
            Write-Output "$ModuleName was installed successfully"
        }
        catch {
            Write-Warning $error[0].Exception.Message
        }
    }    
}

Function Install-HSCModule {
    <#
        .SYNOPSIS
            The purpose of this function is to install the HSC module
    
        .EXAMPLE
            

        .EXAMPLE
            

        .NOTES
            Written by: Kevin Russell
            Written on: 6/7/21

            Last Updated by: Kevin Russell
            Last Updated on: 6/8/21
        
            PS Version 5 Tested: 6/8/21
            PS Version 7 Tested:
        
            Requires being run as admin
    #>

    [CmdletBinding()]
    param(        
        [Parameter(Mandatory=$true,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true)]
        [string[]]$HSCModule = @(    
            "HSC-ActiveDirectoryModule",
            "HSC-CommonCodeModule",
            "HSC-GeneratedDocumentation",
            "HSC-MiscFunctions",
            "HSC-MSTeamsModule",
            "HSC-Office365Module",
            "HSC-PSADHealth",
            "HSC-SharePointOnlineModule",
            "HSC-SQLModule",
            "HSC-TestModule",
            "HSC-TestingModule-Kevin",
            "HSC-VMModule",
            "HSC-WindowsModule"
        )
    )

    ForEach ($Module in $HSCModule) {
        if ((Find-Module -Repository HSCPSRepo).Name -contains $Module) {
            Write-Verbose "$Module is already installed."
        }
        else {
            try {

                $InstallParam = @{
                    Name = "$Module"
                    Repository = "HSCPSRepo"
                }
                
                Install-Module @InstallParam -Force -AllowClobber -ErrorAction Stop
                Write-Output "$Module was installed successfully"
            }
            catch {
                Write-Warning $error[0].Exception.Message
            }
        }

        #This is for specific error that was happening
        if (Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\$Module\2.0.0") {

            Write-Verbose "An inconsistancy was found.  $module subfolder should be 2.0 not 2.0.0; renaming"
            
            try {
                $RenameParam = @{
                    Path = "C:\Program Files\WindowsPowerShell\Modules\$Module\2.0.0"
                    NewName = "2.0"
                }
                
                Rename-Item @RenameParam -ErrorAction Stop
                Write-Verbose "Subfolder successfully renamed 2.0" -ForegroundColor Green
            }
            catch {
                Write-Error "There was an error renaming folder."  
                Write-Error "Commands will not show up until you rename subfolder 2.0 from 2.0.0"
                Write-Error "Path is C:\Program Files\WindowsPowerShell\Modules\$Module\"
            }
        }
    }
    #End add module loop

    #Check for and add EncryptedFiles folder    
    if (Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\HSC-CommonCodeModule\EncryptedFiles") {

        Write-Verbose "EncryptedFiles folder already exists"
    }
    else {

        Write-Verbose "EncryptedFiles folder does not exist.  Adding."

        try {

            $ItemParam = @{
                Path = "C:\Program Files\WindowsPowerShell\Modules\HSC-CommonCodeModule\EncryptedFiles"
                ItemType = "Directory"
            }

            New-Item @ItemParam -ErrorAction Stop
            Write-Output "Folder created successfully"    
        }
        catch {

            Write-Error "There was an error creating the EncryptedFiles directory"
        }        
    }
    #End add EncryptedFiles folder
}

Function Get-HSCSecurityGroupUserByOU {
    <#
        .SYNOPSIS
        The purpose of this function is to get the group members of each security 
        group in a specific OU provided by user input.  
    
        .DESCRIPTION
        Step 1: It checks if dept was passed in.  If so verify dept does exist in AD and
        get the distinguished name for dept.  Set $SearchBase to distinguished name.  If
        more than one dept found alert user and exit program.
    
        Step 2: Get list of security groups in OU
    
        Step 3: Loop through all security groups in OU and generate a list of users for
        each group.  Build a custom object for each user in the group that includes
        enabled/disabled, lastlogontimestamp, name, username.  If a group is not found
        it gets added to a seperate custom object to be exported in a different CSV.
    
        Step 4: If ExportCSV parameter is set to $true, which it is by default, the script checks
        for the ExportCSVPath parameter.  If provided it tests the path and sets the save path and
        exits if path fails check.  If ExportCSVPath was not provided it attempts to generate its
        own save path.  It will check for the FileName paramater, if not set FileName will be set
        to dept pulled from SearchBase string.  Then it will find the currently logged in user
        and sets the export path to their desktop with the FileName created.
    
        .PARAMETER SearchBase
        This is the OU the function will search in.
    
        .PARAMETER Dept
        For this you need to enter the Dept name how it is in AD
    
        .PARAMETER ExportCSV
        Defaults to $true, if you do not want a CSV of the results set to $false to turn off
    
        .PARAMETER ExportCSVPath
        This is the path to where you would like to save the CSV
    
        .PARAMETER  FileName
        This allows you to name the file
    
        .EXAMPLE
        .\Get-HSCSecurityGroupUserByOU.ps1 -Dept "BRNI"
        .\Get-HSCSecurityGroupUserByOU.ps1 -SearchBase "OU=BRNI,OU=ADMIN,OU=HSC,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU"
        .\Get-HSCSecurityGroupUserByOU.ps1 -Dept "BRNI" -ExportCSVPath "C:\users\krussell\desktop\MyBRNIFile.csv"
        .\Get-HSCSecurityGroupUserByOU.ps1 -SearchBase "OU=BRNI,OU=ADMIN,OU=HSC,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU" -FileName "BRNI-Apr20"
        .\Get-HSCSecurityGroupUserByOU.ps1 -Dept "BRNI" -ExportCSV "$false"
    
        .NOTES
    
    #>
    
    [CmdletBinding()]    
    param(        
        [string]$SearchBase,
    
        [string]$Dept,
    
        [Boolean]$ExportCSV = $true,
        
        [string]$ExportCSVPath,
    
        [string]$FileName
    )
    
    $error.Clear()
    $GroupNotFound = @()
    $GroupMember = @()
    $SecurityGroup = @()
    $Users = @()
    $GroupMemberNotFoundInfo = @()
    
    ### Step 1
    if ($Dept) {        
        
        $SearchBase = "OU=HSC,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU"
        Write-Output "`nSearching $SearchBase for $Dept`n"
    
        try {
            $FindOU = Get-ADOrganizationalUnit -Filter "Name -like '$Dept'" -SearchBase $SearchBase  -ErrorAction Stop
        }
        catch {
            Write-Warning "There was an error finding $Dept in $SearchBase"
            Write-Warning "You done messed up"
            Break
        }
    
        $SearchBase = (Get-ADOrganizationalUnit -Filter "Name -like '$Dept'" -SearchBase $SearchBase  -ErrorAction Stop).DistinguishedName
    
        
        if (@($FindOU).Count -gt "1") {
            $i = 0
            Write-Output "There was more than one department found for $Dept"
            Write-Output "-----------------------------------------------------"
            ForEach ($OU in $FindOU) {
                Write-Output $SearchBase.Split(" ")[$i]
                $i++
            }
            Write-Output ""
            Break
        }
        
        Write-Output "SearchBase: $SearchBase"
    }
    ### End Step 1
    
    ### Step 2: Get list of security groups in OU ###
    try {
        $SecurityGroup = Get-ADGroup -Filter * -SearchBase $SearchBase -ErrorAction Stop
    }
    catch {
        Write-Warning "Cannot find security groups at: $SearchBase"
        Write-Warning "Game Over Try Again..."
        Write-Warning $error[0].Exception.Message
        Break
    }
    ### End Step 2
    
    ### Step 3: Loop through all security groups in OU ###
    ForEach ($Group in $SecurityGroup) {
    
        $error.Clear()
    
        ### Get list of user in security group ###
        try {
            $GroupMember = Get-ADGroupMember -Identity $Group.SamAccountName |
            Select-Object  Name, objectClass, SamAccountName, distinguishedName |
            Sort-Object Name -ErrorAction Stop
        }
        catch {
            $GroupMemberNotFoundInfo = [PSCustomObject]@{
                Name = $Group.name
                Username = $Group.SamAccountName
            }
            
            $GroupNotFound += $GroupMemberNotFoundInfo
        }
        ###
    
        Write-Output "$($Group.SamAccountName)  Total: $(@($GroupMember).Count)"
        Write-Output "----------------------------------"
        
        $GroupMemberInfo = [PSCustomObject]@{
            Name = $Group.Name
            Type = $Group.objectClass
            Username = ""#$Group.SamAccountName
            Count = @($GroupMember).Count
            Status = ""
            LastLogon = ""
        }        
        
        $Users += $GroupMemberInfo | Select-Object Name,Username,Count,Status,LastLogon
        $Users += ""    
        
        ### Loop through each member to build custom object ###
        ForEach ($Member in $GroupMember) {
    
            ### Check is user is enabled
            try{
                $AccountEnabled = Get-ADUser $($Member.sAMAccountName) -Properties Enabled |
                    Select-Object Enabled -ErrorAction Stop
            }
            catch{
                $Status = "Unknown"
            }
            
            #set values
            if ($AccountEnabled.Enabled) {
                $Status = "Enabled"
            }
            else {
                $Status = "Disabled"
            }
            ### End user account check
    
            ### Get Lastlogon timestamp
            try{
                $LastLogonTime = Get-ADUser $($Member.sAMAccountName) -properties lastlogontimestamp |
                    Select-Object @{Name="LastLogon";Expression={[datetime]::FromFileTime($_.lastlogontimestamp)}} -ErrorAction Stop
            }
            catch{
                $LastLogonTime = "Unknown" 
            }
            ### End lastlogon timestamp
    
            
            $MemberInfo = [PSCustomObject]@{
                Name = $Member.name
                Type = $Member.objectClass
                Username = $Member.SamAccountName
                Count = ""
                Status = $Status
                LastLogon = $LastLogonTime.LastLogon
            }
    
            Write-Output $MemberInfo | Select-Object Name, Username, Status, LastLogon
    
            $Users += $MemberInfo
        }
        ###
        $Users += ""
        $Users += ""
        $Users += ""
        Write-Output " "
    }
    
    ### Display warning if there were any issues with reading security groups ###
    If ($GroupNotFound -ne 0) {
        Write-Warning "There where $(@($GroupNotFound).Count) security groups with issues"
        ForEach ($GroupWithError in $GroupNotFound) {
            Write-Output $GroupWithError.Name           
        }
    }
    ### End Step 3
    
    ### Step 4: Export to CSV Section ###
    If ($ExportCSV -eq $true) {
        Write-Output "`nResults for search of $SearchBase will be saved at:"
    
        If ($ExportCSVPath -eq $true) {
            
            If (Test-Path $ExportCSVPath) {
                Write-Output $ExportCSVPath
            }
            Else {
                Write-Warning "The provided export path does not exist"
                Write-Warning $ExportCSVPath
                Break
            }
        }
        Else {
            Write-Output "No save path provided.  Attempting to set one up..."
            
            ### Check for filename ###
            if ($FileName -eq $true) {
            }
            else {
                $FileName = ($SearchBase.Split("=")[1]).Split(",")[0]
            }
            ###
    
            $Username = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name).Split("\")[1]
    
            $ExportCSVPath = "C:\Users\$Username\Desktop\$Filename.csv"
            Write-Output "File will be saved at:"
            Write-Output $ExportCSVPath
    
            $Users | Export-CSV -Path $ExportCSVPath -NoTypeInformation
    
            if ($(@($GroupNotFound).Count) -ne 0) {
                
                $ExportCSVPath = "C:\Users\$Username\Desktop\Missing-$Filename.csv"
                Write-Output "Missing department file saved at:"
                Write-Output $ExportCSVPath
    
                Try {
                    $GroupNotFound | Export-CSV -Path $ExportCSVPath -NoTypeInformation -ErrorAction Stop
                }
                Catch {
                    Write-Warning "There was an error creating CSV file."
                    Write-Warning $error[0].Exception.Message
                }
            }
    
        }
    }
    Else {
        Write-Output "You have choosen to not export a CSV.  No files created."
    }
    ### End Step 4
    }


Function Enable-HSCRemoteSettings {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                    ValueFromPipeline = $true)]
                    [string]$ComputerName
    )

    Set-ExecutionPolicy -ExecutionPolicy Bypass

    Write-Host "This is a test"

    try {
        Enter-PSSession -ComputerName $ComputerName -ErrorAction Stop
        Write-Host "Connected to $ComputerName" -ForegroundColor Green
    }
    catch {
        Write-Warning "There was an error connecting to machine"
        #Break
    }
   
    Write-Host "Checking fDenyTSConnetions value"

    try {
        $fDenyValue = (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -ErrorAction Stop).fDenyTSConnections

        if ($fDenyValue -eq 0){
            Write-Host "fDenyTSConnections value is already 0" -ForegroundColor Green
        }
        else {
            try{
                Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0 -ErrorAction Stop
            }
            catch{
                Write-Warning "there was an error enabling fDenyTSConections"
            }
        }
    }
    catch {
        Write-Warning "There was an error fines the value for fDenyTSConnections.  Will not set"
    }


    try{
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction Stop
        Write-Host "Firewall successfully enabled" -ForegroundColor Green
    }
    catch{
        Write-Warning "there was an error setting the firewall"
    }
    
    try{

        $UserAuthValue = (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -ErrorAction Stop).UserAuthentication

        if ($UserAuthValue -eq 1) {
            Write-Host "UserAuthentication is already set to 1" -ForegroundColor Green
        }
        else {
            try {
                Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1 -ErrorAction Stop
            }
            catch {
                Write-Warning "there was an error setting user authentication"
            }
        }        
    }
    catch{
        Write-Warning "There was an error finding the value for userauthentication"
    }

    Exit-PSSession
}



Function Test-HSCFolderPath {
    <#
        .SYNOPSIS
            The purpose of this function is to confirm that the folder path exists
            and is not over 260 characters long.  It will also tell you how many
            folders exist in the directory.


        .PARAMETER FolderPath
            This is a mandatory parameter.  This is the location of the folder to 
            confirm.

        .DESCRIPTION
            Step 1: Takes the folderpath and tests to make sure it exists

            Step 2: Check to make sure folderpath does not exceed 260 characters

            Step 3: Get folder count of the directory
        
        .EXAMPLE

        
        .NOTES

    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [string]$FolderPath,

        [string]$FolderCount,

        [string]$FolderExist
    )

   $DirProperties = [PSCustomObject]@{
        FolderCount = $FolderCount
        FolderExist = $FolderExist
    }


    #Step 1    
    try{
        if (Test-Path -Path $FolderPath){
            Write-Output "Checking directory:  $FolderPath"
        }
        else{
            throw
        }
    }
    catch{
        Write-Warning "$FolderPath does not exist"
        $FolderExist = $false
        Invoke-HSCExitCommand
    }
    #End Step 1

    #Step 2
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
        $FolderExist = $false
        Invoke-HSCExitCommand
    }
    #End Step 2

    #Step 3
    try{
        $FolderCount = (Get-ChildItem "$FolderPath" -ErrorAction Stop).count
        Write-Output "Folder Count:  $FolderCount"
    }
    catch{
        Write-Warning "There was an error getting the folder count for $DirName"
        Write-Warning $error[0].Exception.Message
    }
    #End Step 3
    
    $FolderExist = $true   
}




Function Clear-HSCMSTeamsCacheMac {
    [CmdletBinding()]
    param()

    #Add ability to do to remote machines
    #Does not run versions prior to 6
    
    $FoldersToCheck = @("Application Cache\Cache","Blob_storage","Cache","databases","GPUCache","IndexedDB","Local Storage","tmp")

    $teams = Get-Process -Name "Teams" -ErrorAction SilentlyContinue

    if ($teams)
    {
        $teams | Stop-Process -Force
        Write-Host "Teams has been shut down" -ForegroundColor Green
        Start-Sleep -Seconds 2
    }
    else
    {
        Write-Host "Teams in not currently running" -ForegroundColor Green
    }
        
    ForEach ($Folder in $FoldersToCheck)
    {
        if ($IsMacOS)
        {
            $folderPath = "~/Library/Application Support/Microsoft/Teams/$Folder"
        }
        elseif ($IsWindows)
        {
            $folderPath = "$env:appdata\Microsoft\teams\$Folder"
        }

        if (Test-Path -Path $folderPath)
        {
            Write-Host "Deleting files in $Folder folder"
            Get-ChildItem -Path $folderPath -File -Recurse | ForEach {$_.Delete()}
        }
        else
        {
            Write-Host "$Folder does not exist" -ForegroundColor Magenta
        }
    }
}



function Connect-VM
{

  #found at https://www.powershellmagazine.com/2012/10/11/connecting-to-hyper-v-virtual-machines-with-powershell/
    #requires -Version 3.0
    
  [CmdletBinding(DefaultParameterSetName='name')]
 
  param(
    [Parameter(ParameterSetName='name')]
    [Alias('cn')]
    [System.String[]]$ComputerName=$env:COMPUTERNAME,
 
    [Parameter(Position=0,
        Mandatory,ValueFromPipelineByPropertyName,
        ValueFromPipeline,ParameterSetName='name')]
    [Alias('VMName')]
    [System.String]$Name,
 
    [Parameter(Position=0,
        Mandatory,ValueFromPipelineByPropertyName,
        ValueFromPipeline,ParameterSetName='id')]
    [Alias('VMId','Guid')]
    [System.Guid]$Id,
 
    [Parameter(Position=0,Mandatory,
        ValueFromPipeline,ParameterSetName='inputObject')]
    [Microsoft.HyperV.PowerShell.VirtualMachine]$InputObject,
 
    [switch]$StartVM
  )
 
  begin
  {
    Write-Verbose "Initializing InstanceCount, InstanceCount = 0"
    $InstanceCount=0
  }
 
  process
  {
    try
    {
      foreach($computer in $ComputerName)
      {
        Write-Verbose "ParameterSetName is '$($PSCmdlet.ParameterSetName)'"
 
        if($PSCmdlet.ParameterSetName -eq 'name')
        {
              # Get the VM by Id if Name can convert to a guid
              if($Name -as [guid])
              {
         Write-Verbose "Incoming value can cast to guid"
         $vm = Get-VM -Id $Name -ErrorAction SilentlyContinue
              }
              else
              {
         $vm = Get-VM -Name $Name -ErrorAction SilentlyContinue
              }
        }
        elseif($PSCmdlet.ParameterSetName -eq 'id')
        {
              $vm = Get-VM -Id $Id -ErrorAction SilentlyContinue
        }
        else
        {
          $vm = $InputObject
        }
 
        if($vm)
        {
          Write-Verbose "Executing 'vmconnect.exe $computer $($vm.Name) -G $($vm.Id) -C $InstanceCount'"
          vmconnect.exe $computer $vm.Name -G $vm.Id -C $InstanceCount
        }
        else
        {
          Write-Verbose "Cannot find vm: '$Name'"
        }
 
        if($StartVM -and $vm)
        {
          if($vm.State -eq 'off')
          {
            Write-Verbose "StartVM was specified and VM state is 'off'. Starting VM '$($vm.Name)'"
            Start-VM -VM $vm
          }
          else
          {
            Write-Verbose "Starting VM '$($vm.Name)'. Skipping, VM is not not in 'off' state."
          }
        }
 
        $InstanceCount+=1
        Write-Verbose "InstanceCount = $InstanceCount"
      }
    }
    catch
    {
      Write-Error $_
    }
  }
}


Function Start-HSCSpeech {
    param(
       [Parameter (Mandatory=$true)]
       [string]$Phrase
    )
          Add-Type -AssemblyName System.Speech 
          $Speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
          
          $Speak.Speak($Phrase)    
}


Function Get-HSCSCCMPrimaryPC {
<#
    .SYNOPSIS
		The purpose of this function is to get the SCCM resource field
		that has the primary machine for a user	listed

    .DESCRIPTION

    .PARAMETER
		SiteCode - This the SCCM site code which is HS1

		ProviderMachineName - this is the SCCM server that has the provider
							  machine role

		UserName - user you want to lookup

    .INPUTS

    .OUTPUTS
        Syntax.String

    .EXAMPLE
		PS C:\> Get-HSCSCCMPrimaryPC -UserName "krussell"

    .EXAMPLE
        PS C:\> Get-HSCSCCMPrimaryPC krussell

    .LINK

    .NOTES
        Author: Kevin Russell
		Created: 03/16/21
        Last Updated: 11/03/21
        Last Updated By:

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                    ValueFromPipelineByPropertyName,
                    Position=0)]
        [string]$UserName,
    
        [string]$SiteCode = "HS1",

        [string]$ProviderMachineName = "hssccm.hs.wvu-ad.wvu.edu",

        $initParams = @{},   

        [string]$CurrentLocation = (Get-Location)
    )

    # Import the ConfigurationManager.psd1 module 
    if((Get-Module ConfigurationManager) -eq $null) 
    {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
    }

    # Connect to the site's drive if it is not already present
    if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) 
    {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
    }

    # Set the current location to be the site code.
    Set-Location "$($SiteCode):\" @initParams
            
    #pass username to variable $user
    $User = "HS\" + $UserName
    $ComputerArray = @()
    $ComputerArray = (Get-CMUserDeviceAffinity -UserName $User).ResourceName
    #End Primary machine


    $PrimaryMachineObject = [PSCustomObject]@{
        UserName = $UserName
        PrimaryMachine = $ComputerArray
    }

    if ($ComputerArray.Count -eq 0) {
        $ComputerArray = "No Primary machine found"
    }
    elseif ($ComputerArray.Count -gt 1) {
        for ( $index = 0; $index -lt $ComputerArray.length; $index++) {
            $PrimaryMachineObject | add-member NoteProperty PrimaryMachine$index $ComputerArray[$index]
        }
    }

    $PrimaryMachineObject
    return $PrimaryMachineObject

    Set-Location $CurrentLocation
}


Function Update-HSCModule {
    <#
    .SYNOPSIS
		
    .DESCRIPTION

    .PARAMETER
		

    .INPUTS

    .OUTPUTS
        

    .EXAMPLE
		

    .EXAMPLE
        

    .LINK

    .NOTES
        Author: Kevin Russell
		Created: 11/03/21
        Last Updated: 
        Last Updated By:

        Assumes you have HSCPSRepo access
        Assumes you are running with an elevated account
    #>

    [CmdletBinding()]
    param (
        [string]$NuGetPackagePath = "\\hs.wvu-ad.wvu.edu\Public\Tools\HSCCustomModules",

        [string]$HSCModuleLocation = "C:\users\krussell\Documents\GitHub\HSC-PowerShell-Repository\1HSCCustomModules",

        [array]$Module = @(),

        [string]$HSRepo = "HSCPSRepo"
    )

    if (Test-Path -Path $NuGetPackagePath) {
        $Module | ForEach-Object {
            
            Write-Output "Preparing to remove:  $Module"
            
            try {
                Get-ChildItem -Path $NuGetPackagePath -Include $Module* -Recurse -ErrorAction Stop|
                    Remove-Item

                Write-Output "$Module was successfully removed"
            }
            catch {
                Write-Output "There was a problem finding:  $Module"
                Write-Warning $error[0].Exception.Message
            }    
        
            Start-Sleep -Seconds 1.5
            
            Write-Output "Preparing to publish:  $Module"
            try {
                $HSCModuleParam = @{
                Path = "$HSCModuleLocation\$Module"
                Repository = $HSRepo
                NuGetApiKey = "AnyStringWillDo"
                }
        
                Publish-Module @HSCModuleParam -Force -ErrorAction Stop
                Write-Output "$Module successfully published"
            }
            catch {
                Write-Output "There was a problem publishing:  $Module"
                Write-Warning $error[0].Exception.Message
            }
        
            Write-Output "Preparing to uninstall:  $Module"
            try {
                Uninstall-Module -Name $Module -ErrorAction Stop
                Write-Output "$Module was successfully removed"
            }
            catch {
                Write-Output "There was a problem uninstalling:  $Module"
                Write-Warning $error[0].Exception.Message
            }
        
            Start-Sleep -Seconds 1.5
            
            Write-Output "Preparing to install:  $Module"
            try {
                Install-Module -Name $Module -Repository $HSRepo -ErrorAction Stop
                Write-Output "$Module was successfully installed"
            }
            catch {
                Write-Output "There was a problem installing:  $Module"
                Write-Warning $error[0].Exception.Message
            }
        }
        Write-Output "You will need to restart powershell to use the updated module"
    }
    else {
        Write-Output "It appears you do not have access to:  $NuGetPackagePath"
        Write-Output "Please check your access and try again."
    }
}












