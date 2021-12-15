#--------------------------------------------------------------------------------------------------
#3Set-YammerLicense.ps1
#
#Written by: Jeff Brusoe
#
#Last Modified: July 29, 2016
#
#Version: 1.0
#
#Purpose:
#
#To be done
#1. Implement -identity switch
#--------------------------------------------------------------------------------------------------

<#
.SYNOPSIS
 	This file imports mailboxes from the WVU tenant to the HSC tenant as mail contacts.
    	Input to the file is provided from the 6Get-MainCampusMailboxes.ps1 file.
    
.DESCRIPTION
 	Requires
	1. Connection to the HSC tenant (Get-MsolUser etc)
	2. Connectoin to Exchange online and PowerShell cmdlets
 	
.PARAMETER
	Paramter information.

.NOTES
	Author: Jeff Brusoe
    	Last Updated: July 28, 2016
#>


param (
    [string]$Identity=$null, #used for single user and isn't implemented yet,
    [string]$SesstionTranscriptPath = "c:\AD-Development\YammerLicense\",
    [switch]$RecordSessionTranscript = $true,
    [int]$MaximumNumberOfUsers = 40000,
    [switch]$StopOnError = $false #$true for debugging
)

. ..\5Misc-Functions.ps1

cls

$SessionLogFile = $SesstionTranscriptPath + (Get-FileDatePrefix) + "-YammerLicense-SessionOutput.txt"

New-Item $SessionLogFile -Force -ItemType file

if ($RecordSessionTranscript)
{
    Start-Transcript -Path $SessionLogFile -Force
}

"`nStart-Time: " + (Get-Date -Format G)
"Computer Name: " + $env:COMPUTERNAME

Write-Output "`nSession Variables"
if ([string]::IsNullOrEmpty($Identity))
{
    $Identity = "Null"
}

"Session Transcript Log Path: " + $SessionLogFile
"Record Session Transcript: " + $RecordSessionTranscript
"Stop on Error: " + $StopOnError
"Identity: " + $Identity
"Maximum numnber of users: " + $MaximumNumberOfUsers

$DoNotDisable = "jbrusoe","krodney","mkondrla","jnesselrodt","jlgodwin","rnichols","microsoft","jmarton","llroth","jwshaffer","jnesselrodtadmin","jbrusoeadmin","kadmin","mlkadmin","jlga","r.nichols","rcgamble"

Write-Output "`nThese users will not have Yammer disabled"
$DoNotDisable

Write-Output "`nGetting all MSOLUsers in the HSC Tenant"
$MsolUsers = Get-MsolUser -All #-userprincipalname jbrusoe@hsc.wvu.edu
$UserCount = 0

Write-Output "`nBeginning to process users`n"

foreach ($MsolUser in $MsolUsers)
{
    if ($Error.Count -gt 0)
    {
        if ($StopOnError)
        {
            $Error

            Stop-Transcript

            Return
        }
        else
        {
            $Error.Clear()
        }
    }

    $UPN = $MsolUser.UserPrincipalName
    $UserName = $UPN.substring(0,$UPN.IndexOf("@")).Trim()
    
    if ($DoNotDisable -contains $UserName)
	{
		#Do Nothing - This is a safety measure to ensure our accounts won't be disabled and/or deleted.
		"SamAccountName: " + $UPN
        $UserCount ++
		Write-Output "Skipping this account"

        "******************************"
	}
    elseif ($UserCount -lt 40000)
    {
        $UserCount++
       
	    "Current User: " + $UPN
        "User Count: " + $UserCount
        "Username: " + $UserName

	    $Licenses = $MsolUser.Licenses
	
	    if ($Licenses -ne $null)
	    {
		    $i = 0
		
		    foreach ($License in $Licenses)
		    {
                $LicenseName = $Licenses.AccountSkuId.Split(" ")[$i]
                Write-Output $("`nLicense Name: " + $LicenseName)
			    #Write-Output $("`nLicense Name: " + $Licenses.AccountSkuId.Split(" ")[$i])
                Write-Output "Service Status"

                $DisableOptions = @()
			    $i++
			
			    foreach ($Service in $License.ServiceStatus)
			    {
                    Write-Output $($Service.ServicePlan.ServiceName + ": " + $Service.ProvisioningStatus)

                    if ($Service.ProvisioningStatus -eq "Disabled" -OR $Service.ServicePlan.ServiceName -like "*YAMMER*")
                    {
                        $DisableOptions += $Service.ServicePlan.ServiceName.ToString()
                    }
			    }

                Write-Output "`nDisable Options"
                $DisableOptions

                Write-Output "`nGenerating license options object"
                $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $LicenseName -DisabledPlans $DisableOptions

                Write-Output "Setting license information"
                Set-MsolUserLicense -UserPrincipalName $UPN -LicenseOptions $LicenseOptions
                Write-Output "Done setting license information"
		    }
	    }
	    else
	    {
	        Write-Output "Unlicensed User"
	    }
	
	    "******************************"
    }
    else
    {
        #Ideally we should never get here
        Stop-Transcript

        Return
    }
}

Stop-Transcript

