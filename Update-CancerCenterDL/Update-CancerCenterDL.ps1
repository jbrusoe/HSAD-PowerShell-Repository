# Update-CancerCenterDL.ps1
# Written by: Jeff Brusoe
# Last Updated: August 18, 2021

# Site level address: https://wvuhsc.sharepoint.com/sites/mbrcc/DL
# List level: https://wvuhsc.sharepoint.com/sites/mbrcc/DL/Lists/DL

[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]$SiteURL = "https://wvuhsc.sharepoint.com/sites/mbrcc/DL",

    [ValidateNotNullOrEmpty()]
    [string]$OutputFileDirectory = "$PSScriptRoot\GeneratedLists\",

	[ValidateNotNullOrEmpty()]
	[string]$NetworkOutputDirectory = "\\hs.wvu-ad.wvu.edu\Public\MBRCC\DistroLists\Generated_Lists\",

	[ValidateNotNullOrEmpty()]
	[string]$InternalUserEmailField = "Email_x0020_Address_x0020__x002d",

	[ValidateNotNullOrEmpty()]
	[string]$ExternalEmailField = "EmailAddress"
)

try {
    Write-Output "Configuring Environment"

    $SessionTranscriptFile = Set-HSCEnvironment -ErrorAction Stop
    Write-Output "Session Transcript File: $SessionTranscriptFile"

    Write-Output "`nConnecting to SharePoint"

    Write-Output "Site URL: $SiteURL"
    $SPConnection = Connect-HSCSPOnline -SiteURL $SiteURL -Verbose

    if (!$SPConnection) {
        throw "Could not connect to SharePoint site."
    }

    #Test GitHub file directory
    Write-Output "Output File Directory: $OutputFileDirectory"
    if (!(Test-Path $OutputFileDirectory)) {
        Write-Warning "Output File Directory does not exist."
        throw "Output File Directory does not exist."
    }
    else {
        Write-Output "Output File Directory exists."
    }

	#Test Network file directory
	Write-Output "Network File Directory: $NetworkOutputDirectory"
    if (!(Test-Path $NetworkOutputDirectory)) {
        Write-Warning "Output File Directory does not exist."
        throw "Output File Directory does not exist."
    }
    else {
        Write-Output "Output File Directory exists."
    }
}
catch {
    Write-Warning "Error configuring PowerShell environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#Get List Items
try {
    Write-Output "Connected to SharePoint... Getting List Items"

	$GetHSCSPOCancerCenterDLParams = @{
		SiteURL = $SiteURL
		Verbose = $true
		ErrorAction = "Stop"
	}

    $ListItems = Get-HSCSPOCancerCenterDL @GetHSCSPOCancerCenterDLParams
}
catch {
    Write-Warning "Unable to get list items"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#Generate file names for distribution lists
foreach ($ListItem in $ListItems) {
    if (![string]::IsNullOrEmpty($ListItem["DLName"])) {
        $DLNames += $ListItem["DLName"]
    }
}

$DLNames = $DLNames | Select-Object -Unique
Write-Output "Distribution List Names:"
Write-Output $DLNames
Write-Output $("DL Names Count: " + $DLNames.Count)

[PSObject[]]$OutputFileMappings = @()
foreach ($DLName in $DLNames) {
    Write-Output "DLName: $DLName"
    $FileName = $DLName -Replace "'",""
    $FileName = $FileName -Replace " ",""
	$FileName = $FileName -Replace "/",""

	$NetworkFilePath = $NetworkOutputDirectory +
						(Get-Date -Format yyyy-MM-dd) + "-" +
						$FileName + ".txt"

    $FileName = "$PSScriptRoot\GeneratedLists\" +
                    (Get-Date -Format yyyy-MM-dd) + "-"+
                    $FileName + ".txt"

    New-Item -Path $FileName -ItemType File -Force
	New-Item -Path $NetworkFilePath -ItemType File -Force

    $OutputFileMappings += [PSCustomObject]@{
        DLName = $DLName
        OutputFilePath = $FileName
		NetworkFilePath = $NetworkFilePath
    }
}
Write-Output "`n`nFileName Array:"
$OutputFileMappings

Write-Output "`n`nGenerating Cancer Center Lists"
foreach ($ListItem in $ListItems) {
    [string[]]$DistributionListNames = $ListItem["DLName"]

	foreach ($DLName in $DistributionListNames) {
		Write-Output "DLName: $DLName"

		Write-Output $("DLName Count: " + $DLName.Count)

		$OutputFilePath = ($OutputFileMappings |
			Where-Object {$_.DLName -eq $DLName}).OutputFilePath

		$NetworkFilePath = ($OutputFileMappings |
			Where-Object {$_.DLName -eq $DLName}).NetworkFilePath

		Write-Output "Output File Path: $OutputFilePath"

		$FieldUserValues = [Microsoft.SharePoint.Client.FieldUserValue[]]$ListItem[$InternalUserEmailField]

		#Internal Email Field
		[string]$InternalEmail = $null
		foreach ($FieldUserValue in $FieldUserValues) {
			try {
				[string]$InternalEmail = $fieldUserValue.LookupValue.ToString()

				if ($null -eq $InternalEmail) {
					Write-Output "Internal Email is null"
				}
				else {
					Write-Output "Internal Email: $InternalEmail"
					Add-Content -Path $OutputFilePath -Value $InternalEmail
					Add-Content -Path $NetworkFilePath -Value $InternalEmail
				}
			}
			catch {
				Write-Warning "Internal Email is Null"
				$InternalEmail = $null
			}
		}

		#External Email Field
		try {
			$ExternalEmail = $ListItem[$ExternalEmailField]

			if ($null -eq $ExternalEmail) {
				Write-Output "External Email is null"
				Write-Output "External Email: $ExternalEmail"
			}
			else {
				Write-Output "External Email: $ExternalEmail"
				$ExternalEmail = $ExternalEmail.Trim()
			}
		}
		catch {
			Write-Warning "External email is null"
			$ExternalEmail = $null
		}

		if ($null -ne $ExternalEmail) {
			Add-Content -Path $OutputFilePath -Value $ExternalEmail
			Add-Content -Path $NetworkFilePath -Value $ExternalEmail
		}

		Write-Output "*********************"
	}
}

Invoke-HSCExitCommand -ErrorCount $Error.Count