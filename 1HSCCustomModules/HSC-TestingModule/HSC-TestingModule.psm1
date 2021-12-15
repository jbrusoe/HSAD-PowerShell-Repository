#These are all functions currently being developed and tested.
#None of them should be used in anything from production.

[CmdletBinding()]
param ()

#Import-Module ActiveDirectory

function Move-HSCADUser {

	[CmdletBinding()]
	param (
		[string]$UserName,
		[string]$TargetDN
	)
	
	#To do:
	#1. Accept pipeline input
	#2. beging/process/end block
	#3. Accept ADUser object or string as username
	#4. Comment based help
	#5. Verify $TargetDN exists

	begin
	{
		Write-Output "Preparing to move $UserName" | Out-Host
		Write-Output "Target DN: $TargetDN" | Out-Host
	}

	process
	{
		try {
			$ADUser = Get-ADUser $UserName -ErrorAction Stop
		}
		catch {
			Write-Warning "Unable to find AD user to move"
			return $null
		}
		
		try {
			$ADUser |  Move-ADObject -TargetPath $TargetDN -ErrorAction Stop
			Write-Verbose "Successfully moved user"
			return $true
		}
		catch {
			Write-Warning "Unable to move $UserName"
			return $null	
		}
	}
}

function Update-HSCSQLLitigationHoldDB
{
	<#
		.SYNOPSIS

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: September 9, 2020
	#>

	[CmdletBinding()]
	param ()

	$SQLSecureFile = Get-HSCSQLSecureFile
	Write-Verbose "SQL Secure file: $SQLSecureFile"

	#Determine if V1 or V2 Exchange cmdlets are loaded
	$V2 = Get-Command Get-Exo*

	if (($V2 | Measure).Count -gt 0)
	{
		Write-Verbose "Exchange V2 cmdlets are loaded"
		$LitigationHolds = Get-HSCLitigationHold
	}
	elseif (($v1 | Measure).Count -gt 0)
	{
		Write-Verbose "Exchange V1 cmdlets are loaded"
		$LitigationHolds = Get-HSCLitigationHoldV1
	}
	else {
		Write-Warning "No Exchange cmdlets are loaded"
		return $null
	}

	if ($null -ne $LitigationHolds)
	{
		$SQLConnectionstring = Get-HSCConnectionString
	}
}

function Get-HSCSQLConnectionStringSOLE
{

}

function Get-HSCSQLConnectionStringAzureSQL
{
	
}

function Get-WVUMEnterpriseID
{
	<#
		.SYNOPSIS
			Returns the WVUM Enterprise ID for a user

		.NOTES
			Written by: Jeff Brusoe
			Last Updated: November 11, 2020
	#>

	[CmdletBinding()]
	[OutputType([String])]
	param (
		[Parameter(ValueFromPipeline=$true,
		ParameterSetName="UserNameArray",
		Mandatory=$true,
		Position=0)]
		[string]$SAMAccountName,

		[Parameter(ValueFromPipeline=$true,
		ParameterSetName="ADUserArray",
		Mandatory=$true,
		Position=0)]
		[Microsoft.ActiveDirectory.Management.ADAccount[]]$ADUsers
	)

	begin
	{
		Write-Verbose "SAM Account Name: $SAMAccountName"
		[string]$WVUMEnterpriseID = $null
	}

	process
	{
		Write-Debug $("In process block - Parameter Set Name: " + $PSCmdlet.ParameterSetName)
		
		try {

			if ($PSCMdlet.ParameterSetName -eq "UserNameArray")
			{
				$GetADUserParams = @{
					Identity = $SAMAccountName
					Properties = "extensionAttribute13"
					ErrorAction = "Stop"
					Verbose = $true
				}

				$ADUser = Get-ADUser @GetADUserParams
			}
			
			if ([string]::IsNullOrEmpty($ADUser.extensionAttribute13))
			{
				Write-Verbose "ext13 is Null"
				$WVUMEnterpriseID = $null
			}
			else {
				$WVUMEnterpriseID = $ADUser.extensionAttribute13
			}
		}
		catch {
			Write-Warning "Unable to find AD User"
			$WVUMEnterpriseID = $null
		}
	}

	end
	{	
		Write-Verbose "WVUM Enterprise ID: $WVUMEnterpriseID"
		return $WVUMEnterpriseID
	}
}

function Get-HSCADUserProxyAddress {

}

function Set-HSCADUserProxyAddress {

}

function Set-HSCNTFSFolderPermission {
    
}

function Get-HSCMailboxWithClutter
{
	<#
		.SYNOPSIS

		.DESCRIPTION

        .PARAMETER PrimarySMTPAddress
		
		.OUTPUTS
			PSCustomObject

		.NOTES
			Writen by: Jeff Brusoe
			Last Updated: April 21, 2021
	#>

	[CmdletBinding()]
	[OutputType([PSCustomObject[]])]
	param (
		[Parameter(ValueFromPipeline = $true,
					ValueFromPipelineByPropertyName = $true,
					Position = 0)]
		[string[]]$PrimarySMTPAddress = $null
	)

	try {
		Write-Verbose "Generating list of O365 Mailboxes"
		if ($null -eq $PrimarySMTPAddress) {
			$O365Mailboxes = Get-EXOMailbox -RecipientTypeDetails UserMailbox -ErrorAction Stop |
				Where-Object {$_.PrimarySMTPAddress -notlike "*rni.*" -AND $_.PrimarySMTPAddress -notlike "*wvurni*"}
		}
		else {
			$O365Mailboxes = $PrimarySMTPAddress | Get-EXOMailbox -ErrorAction Stop
		}
	}
	catch {
		Write-Warning "Unable to generate list of O365 mailboxes"
	}

	foreach ($O365Mailbox in $O365Mailboxes) {
		$IsClutterEnabled = ($O365Mailbox | Get-Clutter).IsEnabled

		if ($IsClutterEnabled) {
			Write-Verbose $O365Mailbox.PrimarySMTPAddress
		}
	}
}

function Get-HSCADUserProperty
{
	[CmdletBinding()]
	[OutputType([string])]
	param (
		[Parameter(Mandatory=$true,
					ValueFromPipeline = $true,
					ValueFromPipelineByPropertyName = $true,
					Position = 0)]
		[string[]]$SamAccountName,

		[Parameter(Mandatory = $true,
					ValueFromPipeline = $false,
					Position = 1)]
		[string]$PropertyToQuery
	)

	process
	{
		Write-Verbose "SamAccountName: $SamAccountName"
		Write-Verbose "Property to Query: $PropertyToQuery"
	
		$LDAPFilter = "(SamAccountName=$SamAccountName)"
		Write-Verbose "LDAP Filter: $LDAPFilter"
	
		try {
			$HSCADUser = Get-ADUser -LDAPFilter $LDAPFilter -Properties $PropertyToQuery -ErrorAction Stop
		}
		catch {
			Write-Warning "Unable to find user"
			return $null
		}
	
		if ($null -ne $HSCADUser) {
			Write-Verbose "HSC AD User Found"
	
			try {
				$PropertyToQueryValue = $HSCADUser.$PropertyToQuery
			}
			catch {
				Write-Warning "Error pulling property value"
				return $null
			}
			
			if ($null -eq $PropertyToQueryValue) {
				Write-Verbose "Property Value: Null"
			}
			else {
				Write-Verbose "Property Value $PropertyToQueryValue"
			}
	
			return $PropertyToQueryValue
		}
		else {
			Write-Warning "AD user not found"
			return $null
		}
	}
}

function Write-HSCIDFLog([string]$logMsg)  
{   
    if(!$isLogFileCreated){   
        Write-Host "Creating Log File..."   
        if(!(Test-Path -path $directoryPath))  
        {  
            Write-Host "Please Provide Proper Log Path" -ForegroundColor Red   
        }   
        else   
        {   
            $script:isLogFileCreated = $True   
            Write-Host "Log File ($logFileName) Created..."   
            [string]$logMessage = [System.String]::Format("[$(Get-Date)] - {0}", $logMsg)   
            Add-Content -Path $logPath -Value $logMessage   
        }   
    }   
    else   
    {   
        [string]$logMessage = [System.String]::Format("[$(Get-Date)] - {0}", $logMsg)   
        Add-Content -Path $logPath -Value $logMessage   
    }   
}

Function Get-HSCEnabledMailbox
{
	<#
		.SYNOPSIS
			This function gets the OWAEnabled, MAPIEnabled, and ActiveSyncEnabled
			values from O365 of all mailboxes.

		.OUTPUTS
			PSObject

		.NOTES
			Needed for Export-ToSole.ps1
			Originally Written by: Matt Logue(?)
			Last Updated by: Jeff Brusoe
			Last Updated: May 27, 2021
	#>

	[CmdletBinding()]
	[OutputType([PSObject])]
	param ()

	try {
		Write-Verbose "Getting Mailboxes in Office 365"
		$CASMailboxes = Get-ExoCASMailbox -ResultSize Unlimited -ErrorAction Stop |
			Where-Object { $_.PrimarySMTPAddress -notlike "*rni.*" -AND
							$_.PrimarySMTPAddress -notlike "*wvurni" }
	}
	catch {
		Write-Warning "Unable to generate CASMailbox list"
		return $null
	}

    Write-Verbose "Getting information for users with SIP addresses...."
    foreach ($CASMailbox in $CASMailboxes)
    {
        $M365UserInfo = New-Object -TypeName PSObject
        
		if ($CASMailbox.EmailAddresses -clike "SMTP:*")
        {
            $UserSMTP = $CASMailbox.EmailAddresses -clike "SMTP:*" | Select-String 'SMTP:'
            $UserSMTP = $UserSMTP -replace "SMTP:"
            $UserSMTP = $UserSMTP.ToLower()

            $M365UserInfo | Add-Member -Name "O365EmailAddress" -Value $UserSMTP -MemberType NoteProperty
            $M365UserInfo | Add-Member -Name "OWAEnabled" -Value $CASMailbox.OWAEnabled -MemberType NoteProperty
            $M365UserInfo | Add-Member -Name "MAPIEnabled" -Value $CASMailbox.MAPIEnabled -MemberType NoteProperty
            $M365UserInfo | Add-Member -Name "ActiveSyncEnabled" -Value $CASMailbox.ActiveSyncEnabled -MemberType NoteProperty
			
            if (($M365UserInfo.OWAEnabled -eq $true) -AND
				($M365UserInfo.MAPIEnabled -eq $true) -AND
				($M365UserInfo.ActiveSyncEnabled -eq $true)) {
				$M365UserInfo
            }
			else {
				Write-Verbose "Not outputing user to pipeline"
			}
        }
    }
	
    ##Write-Verbose '$MailboxStatus Array created, Exporting to CSV' 
	##$MailboxStatus |
	##	Select-Object o365emailaddress,owaenabled,mapienabled,activesyncenabled |
	##	Export-Csv -Path $ExportFile -NoTypeInformation

    ##Write-Verbose "CSV Exported - Mailbox Count: $(($MailboxStatus.O365EmailAddress | Measure-Object).Count)"
	
    #return $O365Enabled
}

function Get-HSCCASMailbox {
	
	[CmdletBinding()]
	param(
		[string]$ExportFile = $((Get-HSCGitHubRepoPath) + 
								"2CommonFiles\MailboxFiles\" +
								(Get-Date -Format yyyy-MM-dd-HH-mm) +
								"-O365CASMailbox.csv")
	)


	Get-CASMailbox -ResultSize Unlimited -ErrorAction Stop |
		Where-Object { $_.PrimarySMTPAddress -notlike "*rni.*" -AND
					$_.PrimarySMTPAddress -notlike "*wvurni" } |
		Export-Csv $ExportFile
}

