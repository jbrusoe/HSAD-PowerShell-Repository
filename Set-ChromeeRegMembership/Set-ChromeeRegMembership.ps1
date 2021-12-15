<#
	.SYNOPSIS
        The purpose of this file is to run as a scheduled task which
        checks the CTRU OU for any user with a department name of SOM 
        Clinical Research Trials L4 or HSC Clinical and Translational 
        Science L3 and a job title of Sponsor Monitor or Senior CRA.

        The users who meet those criteria will be stored in an array.
        The script will loop through the user array and check if they 
        are in the RDSH Chrome eReg group.  If they are already in the
        group, nothing will be done.  If they are not in the group they
        will get added. 

    .PARAMETER SponseredUsers
        The SponseredUsers are the users which meet a predefined criteria
        for Department and Title in the CTRU OU.

    .PARAMETER OU
        This is the OU which will be searched.

    .PARAMETER GroupName
        This is the AD group name the sponsered users will be added to.
    
    .NOTES
        Written by: Kevin Russell
		Last Modified by: Kevin Russell
		Last Modified: 7/16/21
#>

[CmdletBinding()]
param(
    [array]$SponseredUsers = @(),

    [string]$OU = "OU=HSC,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU",

    [string[]]$GroupName = @("RDSH Chrome eReg",
                            "eReg Monitors Clientless VPN",
                            "HSC DUO MFA")
)

$error.Clear()

#initial setup
try {
	[string]$TranscriptLogFile = Set-HSCEnvironment

	if ($null -eq $TranscriptLogFile) {
		Write-Warning "There was an error configuring the environment. Program is exiting."
		Invoke-HSCExitCommand -ErrorCount $Error.Count
	}
	Write-Verbose "Transcript Log file: $TranscriptLogFile"
	Write-Verbose "Start Date: $StartDate"
}
catch {
	Write-Warning "Error configuing environment"
	Invoke-HSCExitCommand -ErrorCount $Error.Count
}
#setup done

#Step 1:  Get array of sponsersed users
try {
    $SponseredUsers = Get-ADUser -Filter {((department -eq "SOM Clinical Research Trials L4") -OR
        (department -eq "HSC Clinical and Translational Science L3")) -AND
        ((title -eq "Sponsor Monitor") -OR
        (title -eq "Senior CRA"))} -SearchBase $OU -ErrorAction Stop
}
catch {
    Write-Warning $error[0].Exception.Message
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

Write-Verbose "Users found:  $($SponseredUsers.Count)"
#End Step 1

#Step 2:  Loop through users and add to group
ForEach ($User in $SponseredUsers) {    
    Write-Verbose "Checking user:  $($User.Name)"
    ForEach ($Group in $GroupName) {        
        if ((Get-ADGroupMember -Identity $Group).Name -contains $User.Name) {
            Write-Verbose "$($User.Name) already exists in $Group"
        }
        else {    
            Write-Verbose "Adding $($User.Name) to $Group"            
            try {
                Add-ADGroupMember -Identity $Group -Members $User.distinguishedName -ErrorAction Stop
            }
            catch {
                Write-Verbose "There was an error adding $($User.Name) to $Group"
                Write-Warning $error[0].Exception.Message
            }    
        }
    }
}
#end Step 2