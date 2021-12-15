#Find-UnusedFolder.ps1
#Written by: Jeff Brusoe
#Last Updated: December 18, 2020
#
#The purpose of this file is to search for file system folders that
#are orphaned because the account owner has been disabled/deleted.

[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]$Path = "\\hs.wvu-ad.wvu.edu\public\sod\",

    [ValidateNotNullOrEmpty()]
    [string]$OrphanedFolderFile = ("$PSScriptRoot\Logs\" +
                                    (Get-Date -Format yyyy-MM-dd-HH-mm) +
                                    "-OrphanedFolders.txt")
)

try {
    Write-Output "Configuring Environment"
    Set-HSCEnvironment -ErrorAction Stop

    New-Item -Type File -Path $OrphanedFolderFile -Force

    $ACLExcludes = @(
        "jbrusoe",
        "jbrusoeadmin",
        "kadmin",
        "krodney",
        "mkondrla",
        "mlkadmin",
        "jnesselrodt",
        "jnesselrodtadmin",
        "krussell",
        "kevinadmin",
        "rnichols",
        "r.nichols",
        "microsoft",
        "microsoft1",
        "microsoft2",
        "microsoft3",
        "microsoft4",
        "jlga",
        "mattadmin",
        "j.nesselrodt",
        "CREATOR OWNER",
        "ITS Systems Server Admins",
        "Administrator",
        "CSC",
        "NT Authority",
        "BUILTIN",
        "rcgamble",
        "S-1", #Used to filter out SIDs
        "Administrators",
        "Network Systems Group",
        "Desktop Support Group",
        "HelpServicesGroup",
        "HSC Windows Admins",
        "Help Desk",
        "Networking",
        "NT_Admins",
        "Domain Admins",
        "HS Sharepoint Site Admins",
        "SCCM Full Admin",
        "SCCM OSD Group",
        "FIMSyncAdmins",
        "ITS Web Infoblox",
        "SCCM Windows Update Group",
        "HS Group Policy Admins",
        "Network Infrastructure Group",
        "Network and Voice Services Group"
    )
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "`n`nPath to Search: $Path"

    if (Test-Path $Path) {
        Write-Verbose "Path exists"
    }
}
catch {
    Write-Warning "Search path doesn't exist"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Output "Getting directory list"

$GetChildItemParams = @{
    Path = $Path
    Directory = $true
    ErrorAction = "SilentlyContinue"
    Depth = 2
}
$Directories = Get-ChildItem @GetChildItemParams

foreach ($Directory in $Directories)
{
    $CleanedFolderAcl = @()

    Write-Output $("Current Directory: " + $Directory.FullName)

    $FolderAclEntries = Get-Acl $Directory.FullName

    $OrphanedFolder = $true

    foreach ($FolderAclEntry in $FolderAclEntries.Access)
    {
        $ExcludeList = $false

        foreach ($AclExclude in $AclExcludes)
        {
            if ($FolderAclEntry.IdentityReference -like "*$AclExclude*") {
                Write-Output $("In exclude list - " + $FolderAclEntry.IdentityReference)

                $ExcludeList = $true
                break
            }
            elseif ($FolderAclEntry.IdentityReference -like '*\$*')
            {
                Write-Output $("Dollar sign group - " + $FolderAclEntry.IdentityReference)

                $ExcludeList = $true
                break
            }
        }

        if (!$ExcludeList) {
            $IdentityReference = $FolderAclEntry.IdentityReference -replace "HS\\",""

            if ($CleanedFolderAcl -notcontains $IdentityReference)
            {
                Write-Output "In if statement - $IdentityReference"

                #Now search for AD user to see if in the deleted user OU
                Write-Output "Searching AD for: $IdentityReference"

                try {
                    $ADUser = Get-ADUser $IdentityReference -ErrorAction Stop

                    if ($null -eq $ADUser) {
                        Write-Output "ADUser user from ACL not found"
                    }
                    else {
                        Write-Output "AD user in ACL found"

                        if ($ADUser.DistinguishedName.indexOf("OU=HSC") -gt 0) {
                            $OrphanedFolder = $false
                        }
                    }
                }
                catch {
                    Write-Output "ADUser not found. Looking for group name"
                    
                    try {
                        $ADGroup = Get-ADGroup $IdentityReference -ErrorAction Stop
                    }
                    catch {
                        Write-Output "Unable to find AD Group: $IdentityReference"
                    }
                    
                    if ($null -eq $ADGroup) {
                        Write-Output "AD Group from ACL not found"
                    }
                    else {
                        Write-Output "AD Group in ACL found"
                        $OrphanedFolder = $false
                    }
                }
                $CleanedFolderAcl += $FolderAclEntry.IdentityReference
            }
        }
    }

    if ($OrphanedFolder)
    {
        Write-Output "Writing to orphaned folder file - $Directory.FullName"
        Add-Content -Path $OrphanedFolderFile -Value $Directory.FullName
    }

    Write-Output "`n`nOrphaned Folder: $OrphanedFolder"
    Write-Output `n`n'Printing $CleanedFolderAcl'
    $CleanedFolderAcl

    Write-Output "*****************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count