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