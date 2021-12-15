<#
	.SYNOPSIS
		This file imports the hospital's unique ID numbers to extensionAttribute13 and
		is needed for the shared user distribution list project.

	.PARAMETER Domains
		The domains that are to be searched.

	.NOTES
		Written by: Jeff Brusoe
		Last Updated: October 27, 2020
#>

[CmdletBinding()]
param (
	[ValidateNotNullOrEmpty()]
	[string[]]$Domains = @("WVUH","WVUHS"),

	[switch]$Testing
)

Set-HSCEnvironment

#Build path to import files
$PathToImportFile = $PSScriptRoot
$PathToImportFile = $PathToImportFile.substring(0,$PathToImportFile.lastIndexOf("\")+1)
$PathToImportFile += "Get-WVUMExt13\Logs\"
Write-Output "Path to Import File: $PathToImportFile"

#Change these to be more domain independent
$WVUHImportFile = Get-ChildItem -Path $PathToImportFile -Filter "*wvuh.wvuhs.com*" |
	Sort-Object LastWriteTime -Desc | Select-Object -first 1
Write-Output $("WVUH Import File: " + $WVUHImportFile.FullName)

$WVUHSImportFile = Get-ChildItem -Path $PathToImportFile -Filter "*-wvuhs.com*" |
	Sort-Object LastWriteTime -Desc | Select-Object -first 1
Write-Output $("WVUHS Import File: " + $WVUHSImportFile.FullName)

#Create output file
$UserFoundFile = "$PSScriptRoot\Logs\" + (Get-Date -Format yyyy-MM-dd-HH-mm) + "-Ext13MatchFile.csv"
New-Item -type file $UserFoundFile -Force

Write-Output "Importing CSV Files"
$WVUHUsers = Import-Csv $WVUHImportFile.FullName
$WVUHSUsers = Import-Csv $WVUHSImportFile.FullName

foreach ($Domain in $Domains)
{
	Write-Output "Processing $Domain"

	switch ($Domain)
	{
		"WVUH" { $DomainUsers = $WVUHUsers }
		"WVUHS" { $DomainUsers = $WVUHSUsers }
	}

	$Error.Clear()

	foreach ($DomainUser in $DomainUsers)
	{
		$SamAccountName = $DomainUser.SamAccountName
		$ext13 = $DomainUser.extensionAttribute13

		Write-Output "Current $Domain Account: $SamAccountName"
		Write-Output "extensionAttribute13 From File: $ext13"

		if ([string]::IsNullOrEmpty($ext13)) {
			Write-Output "extensionAttribute13 is empty"
		}
		else
		{
			#ext13 has a value. Need to see if it should be added to the HS domain
			$LDAPFilter = "(SamAccountName=$SamAccountName)"
			Write-Output "LDAPFilter: $LDAPFilter"

			try
			{
				$GetADUserParams = @{
					LDAPFilter = $LDAPFilter
					Properties = "extensionAttribute13"
					ErrorAction = "Stop"
				}

				$HSCADUser = Get-ADUser @GetADUserParams

				if ($null -ne $HSCADUser)
				{
					Write-Output "User found in HS domain" #Should go to the catch block if user not found.

					$UserInfo = New-Object -TypeName PSObject

					$AddMemberParams = @{
						MemberType = "NoteProperty"
						Name = "SamAccountName"
						Value = $SamAccountName
						ErrorAction = "Stop"
					}

					$UserInfo | Add-Member @AddMemberParams

					$AddMemberParams["Name"] = "HospitalDomain"
					$AddMemberParams["Value"] = $Domain
					$UserInfo | Add-Member @AddMemberParams

					$AddMemberParams["Name"] = "ExtensionAttribute13"
					$AddMemberParams["Value"] = $ext13
					$UserInfo | Add-Member @AddMemberParams

					$AddMemberParams["Name"] = "HSDomainOU"
					$AddMemberParams["Value"] = $($HSCADUser.DistinguishedName)
					$UserInfo | Add-Member @AddMemberParams

					$UserInfo | Export-Csv $UserFoundFile -Append

					Write-Output $("Ext13 From Domain: " + $HSCADUser.extensionAttribute13)

					try
					{
						Write-Output "Attempting to set extensionAttribute13 in the HS domain"

						if([string]::IsNullOrEmpty($HSCADUser.extensionAttribute13)) {
							$HSCADUser |
								Set-ADUser -Add @{extensionAttribute13=$ext13} -ErrorAction Stop
						}
						else
						{
							$HSCADUser |
								Set-ADUser -Replace @{extensionAttribute13=$ext13} -ErrorAction Stop
						}
						
						Write-Output "Successfully set extensionAttribute13"

						if ($Testing) {
							Start-Sleep -s 2

							if ($Error.Count -gt 0) {
								Invoke-HSCExitCommand -ErrorCount $Error.Count
							}
						}
					}
					catch {
						Write-Warning "Error setting extensionAttribute13 in the HS domain"
					}
				}
				else {
					Write-Output "User not found in HS domain"
				}
			}
			catch {
				Write-Warning "Unable to find user in HS domain"
			}
		}

		Write-Output "*******************************"
	}
}

Invoke-HSCExitCommand -ErrorCount $Error.Count