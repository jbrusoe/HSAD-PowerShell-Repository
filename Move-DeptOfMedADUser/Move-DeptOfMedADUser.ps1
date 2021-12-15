# Move-ADUserDeptOfMedUser.ps1
# Written by: Jeff Brusoe
# Last Updated: August 27, 2021

# Step 0: Search Holding OU and have use select the user to move
# Step 1: Move user to the correct OU
# Step 2: Refresh AD Object
# Step 3: Create home directory
# Step 4: Add user to correct groups based on OU

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$HoldingOUDN = "OU=Holding,OU=MED,OU=SOM,OU=HSC,DC=HS,DC=wvu-ad,DC=wvu,DC=edu",

    [ValidateNotNullOrEmpty()]
    [string]$MedOUDN = "OU=MED,OU=SOM,OU=HSC,DC=HS,DC=wvu-ad,DC=wvu,DC=edu",

    [ValidateNotNullOrEmpty()]
    [string]$MappingFile = "DeptOFMedUserMapping.csv",

    [switch]$Testing
)

#Configure Environment
Clear-Host
$Error.Clear()

$DefaultGroupMemberships = @(
    "Office 365 Base Licensing Group",
    "HSC DUO MFA",
    "Block Legacy Authentication Group",
    "HSC Conditional Access Policy"
)

$ADProperties = @(
            "extensionAttribute11",
            "extensionAttribute15",
            "whenCreated",
            "PasswordLastSet",
            "Department"
        )

try {
    $UserMappingFile = Import-Csv $MappingFile -ErrorAction Stop

    Write-Output "Successfully imported mapping file"
}
catch {
    Write-Warning "Unable to open mapping file"
    return
}
Write-Output "Department of Medicine User Configuration"
Write-Output "------------------------------------------"

try {
    $ADUsers = Get-ADUser -SearchBase $HoldingOUDN -Filter * -ErrorAction Stop

    if ($ADUsers.Count -eq 0) {
        Write-Output "No Users Found"
    }
    else {
        Write-Output "`nUsers in Holding OU:"

        $UserNumber = 1
        foreach ($ADUser in $ADUsers) {
            Write-Output $($UserNumber.toString() + " - " + $ADUser.SamAccountName)

            $UserNumber++
        }

        Write-Output "------------------------------------------"
    }
}
catch {
    Write-Warning "Unable to get list of AD Users"
}

try {
    $SamAccountNames = $ADUsers.SamAccountName
    while ($true)
    {
        $UserToMove = Read-Host "Which user do you want to move" -ErrorAction Stop

        if ($SamAccountNames -Contains $UserToMove) {
            $ADUser = $ADUsers |
                Where-Object {$_.SamAccountName -eq $UserToMove}

            break
        }
        elseif ([int]$UserToMove -in 1..$SamAccountNames.Count) {
            $ADUser = $ADUsers |
                Where-Object { $_.SamAccountName -eq $ADUsers[$UserToMove - 1].SamAccountName }

            break
        }
        else {
            Write-Warning "Invalid Selection"
        }
    }

    Write-Output "User Being Moved:"
    Write-Output $("Sam Account Name: " + $ADUser.SamAccountName)
    Write-Output $("Distinguished Name: " + $ADUser.DistinguishedName)
}
catch {
    Write-Warning "Unable to read users to move"
    return
}

try {
    Write-Output "`n`nDepartment of Medicine Org Units:"

    $GetADOrgUnitParams = @{
        Filter = "*"
        SearchBase = $MedOUDN
        SearchScope = "OneLevel"
        ErrorAction = "Stop"
    }
    $MedOUs = Get-ADOrganizationalUnit @GetADOrgUnitParams |
        Where-Object {$_.Name -ne "Holding"}

    $OUNames = $MedOUs.Name

    $MedOUCount = 1
    foreach ($MedOU in $MedOUs){
        Write-Output $("$MedOUCount - " + $MedOU.Name)

        $MedOUCount++
    }
}
catch {
    Write-Warning "Unable to generate list of OUs in the Department of Medicine"
    return
}

try {
    while($true)
    {
        [string]$TargetOUDN = $null

        $DestinationOU = Read-Host "Which OU do you want to move the user to" -ErrorAction Stop

        if ($MedOUs.Name -Contains $DestinationOU) {
            $TargetOUDN = ($MedOUs |
                Where-Object {$_.Name -eq $DestinationOU}).DistinguishedName
    
            break
        }
        elseif ([int]$DestinationOU -in 1..$MedOUs.Count) {
            $TargetOUDN = $MedOUs[$DestinationOU - 1].DistinguishedName
            
            break
        }
    }
}
catch {
    Write-Warning "Unable to determine which OU to move user to"
    return
}

try {
    Write-Output "`nStep 1: Moving User to correct OU"
    Write-Output "Destination DN: $TargetOUDN"

    Write-Output "Successfully moved user"

    Start-HSCCountdown -Message "Delay after moving user" -Seconds 3
}
catch {
    Write-Warning "Error trying to move user to target OU"
    return
}

try {
    Write-Output "`nStep 2: Refreshing AD Object after move"

	$LDAPFilter = "(sAMAccountName=" + $ADUser.SamAccountName + ")"
	Write-Verbose "LDAPFilter: $LDAPFilter"

    $GetADUserParams = @{
        LDAPFIlter = $LDAPFilter
        Properties = $ADProperties
        ErrorAction = "Stop"
    }

		$NewADUser = Get-ADUser @GetADUserParams
    Write-Output "Successfully refreshed AD object"
}
catch {
    Write-Warning "Unable to refresh AD object"
    return
}

try
{
    Write-Output "`nStep 3: Create home directory"

    $HomeDirectoryPath  = ($UserMappingFile |
        Where-Object {$_.TargetOUDN -eq $TargetOUDN}).HomeDirectoryPath

    Write-Output "Home Directory Path: $HomeDirectoryPath"

    if ($HomeDirectoryPath -eq "NoHomeDirectory") {
		Write-Output $("Home Directory Path: " + $HomeDirectoryPath)
		Write-Output "Not creating a home directory"
	}
    else {
        #Create home directory
		$UserHomeDirectory = $HomeDirectoryPath + "\" + $NewADUser.SamAccountName
		Write-Output "User Home Directory: $UserHomeDirectory"

        if ($Testing) {
            Write-Output "Home directory not being created because of -Testing parameter"
			New-Item -ItemType Directory -Path $UserHomeDirectory -WhatIf
        }
        else {
            try {
				New-Item -ItemType Directory -Path $UserHomeDirectory -ErrorAction Stop
			}
			catch {
				Write-Warning "Error creating home directory: $UserHomeDirctory"
			}
        }
    }
}
catch {
    Write-Warning "Unable to determine path to user's home directory"
}

Start-HSCCountdown -Message "Home Directory Created. Delay before adding permissions." -Seconds 10

if (!$Testing) {
    #Now add file system permissions
    try {
        $UserName = "HS\" + $NewADUser.SamAccountName
        $Acl = (Get-Item $UserHomeDirectory -ErrorAction Stop).GetAccessControl('Access')

        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username,
                                                                            'FullControl',
                                                                            'ContainerInherit,ObjectInherit',
                                                                            'None',
                                                                            'Allow'
                                                                            )

        $Acl.SetAccessRule($Ar)
        Set-Acl -Path $UserHomeDirectory -AclObject $Acl -ErrorAction Stop

        Write-Output "Finished creating home directory"
    }
    catch {
        Write-Warning "Unable to set ACL on home directory: $UserHomeDirectory"
    }
}
else {
    Write-Output "Testing: Adding file system permissions"
}

#Add user to groups
try {
    Write-Output "`nStep 4: Adding user to groups"
    
    $UserDN = $NewADUser.DistinguishedName

    Write-Output "User DN: "
    Write-Output $UserDN

    Write-Output "Adding user to default groups"
    foreach ($DefaultGroupMembership in $DefaultGroupMemberships) {
        Write-Output "Current Default Group: $DefaultGroupMembership"

        try {
            $GroupToAdd = Get-ADGroup $DefaultGroupMembership -ErrorAction Stop

            $GroupToAdd |
				Add-ADGroupMember -Members $UserDN -ErrorAction Stop

            Write-Output "Successfully added user to group"
        }
        catch {
            Write-Warning "Unable to add user to group"
            continue
        }
    }

    Write-Output "Now adding user to OU specific groups"
    Write-Output "User OU: $TargetOUDN"

    $GroupsFromFile  = ($UserMappingFile |
                            Where-Object {$_.TargetOUDN -eq $TargetOUDN}).Groups

    $OUGroups = $GroupsFromFile -Split ";"

    foreach ($OUGroup in $OUGroups) {
        Write-Output "Current Group: $OUGroup"

        try {
            $ADGroup = Get-ADGroup $OUGroup -ErrorAction Stop
            Write-Output "Found group to add"

            $ADGroup |
                Add-ADGroupMember -Members $UserDN -ErrorAction Stop
            Write-Output "Successfully added user to group"
        }
        catch {
            Write-Warning "Unable to add user to group"
            continue
        }
    }
}
catch {
    Write-Warning "Unable to add user to groups"
}

Write-Output "Finished configuring user"