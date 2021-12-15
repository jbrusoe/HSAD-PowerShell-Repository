<#
.SYNOPSIS
Generate a report of ActiveSync devices in an Office 365 tenant.

.DESCRIPTION 
Generate a report of all ActiveSync devices in an Office 365 tenant, filterable
by domain.

.PARAMETER AddExistingAllowedDeviceIDs
Add the existing allowed ActiveSync DeviceIDs to the user's ActiveSyncAllowedDeviceIDs
list. This is useful if you want to turn on Exchange ActiveSync Quarantine without
disrupting existing users.

.PARAMETER Append
Append to an existing report.

.PARAMETER Domains
Server-side filter based on domain or subdomain.

.PARAMETER ExcludeSecondaryDomains
Filter out users whose primary SMTP address doesn't match the pattern specified
by the Domain parameter.

.PARAMETER ReportName
Specify the name of the report.

.PARAMETER ResultSize
Specify resultsize for report. Useful for testing data output. Default is
"Unlimited."

.EXAMPLE
.\Get-ActiveSyncDeviceReport.ps1
Create report of all ActiveSync devices for an Office 365 tenant.

.EXAMPLE
.\Get-ActiveSyncDeviceReport.ps1 -Domains contoso.com
Create report of all ActiveSync devices for the domain contoso.com in an 
Office 365 tenant.

.EXAMPLE
.\Get-ActiveSyncDeviceReport.ps1 -Domains contoso.com,fabrikam.com
Create report of all ActiveSync devices for the domains contoso.com and fabrikam.com
in an Office 365 tenant.

.EXAMPLE
.\Get-ActiveSyncDeviceReport.ps1 -Domain contoso.com -ResultSize 100 
Create report of ActiveSync devices for the first 100 mailboxes of type UserMaibox
returned.

.EXAMPLE
.\Get-ActiveSyncDeviceReport.ps1 -Domain contoso.com -ExcludeSecondaryDomains 
Create report of ActiveSync devices for all users, excluding users for whom the 
domain specified in the Domain parameter is not their PrimarySmtpAddress.

.EXAMPLE
.\Get-ActiveSyncDeviceReport.ps1 -AddExistingAllowedDeviceIDs
Create a report of ActiveSync devices and add existing configured ActiveSyncDevices to
the user's allowed device list.

.LINK
https://gallery.technet.microsoft.com/Office-365-D-and-MT-Active-9ff2db6a
#>

param (
	[Parameter(Mandatory = $false)]
		[switch]$AddExistingAllowedDeviceIDs,
	[Parameter(Mandatory=$false)]
		[switch]$Append,
	[Parameter(Mandatory=$false)]
		[array]$Domains,
	[Parameter(Mandatory=$false)]
		[switch]$ExcludeSecondaryDomains,
	[Parameter(Mandatory=$false)]
		[string]$ReportName = "ExchangeActiveSyncReport.csv",
	[Parameter(Mandatory=$false)]
		[string]$ResultSize = "Unlimited"
	)
$StartDate = Get-Date
$Report = @()
[array]$EASColumns = ("DeviceID","DeviceAccessState","DeviceAccessStateReason","DeviceModel","DeviceType","DeviceFriendlyName","DeviceOS","LastSyncAttemptTime","LastSuccessSync")
[array]$CASColumns = ("ActiveSyncEnabled","OWAEnabled","PopEnabled","ImapEnabled","MapiEnabled")
[array]$CASArrayColumns = ("ActiveSyncAllowedDeviceIDs","ActiveSyncBlockedDeviceIDs")

$EASMailboxes = @()
$EASDeviceStatistics = @()

If ($Domains)
	{
	Foreach ($Domain in $domains)
		{
		If ($Domain.StartsWith("*"))
    			{
     			# Value already starts with an asterisk
    			}
		Else
    			{
     			$Domain = "*" + $Domain
    			}
		$Filter = [scriptblock]::Create("{EmailAddresses -like `"$Domain`" -and HasActiveSyncDevicePartnership -eq `$True}")
		Write-Host -NoNewline "Current domain filter is ";Write-Host -ForegroundColor Green $Filter
		$cmd = "Get-CASMailbox -ResultSize $ResultSize -Filter $Filter -WarningAction SilentlyContinue"
		Write-Host "Command to be executed is:"
		Write-Host -ForegroundColor Green $cmd
		$EASMailboxes += Invoke-Expression $cmd
        }
	}
Else
	{
	$cmd = "Get-CASMailbox -ResultSize $ResultSize -WarningAction SilentlyContinue -Filter { HasActiveSyncDevicePartnership -eq `$True }"
	Write-Host "Command to be executed is:"
	Write-Host -ForegroundColor Green $cmd
	$EASMailboxes = Invoke-Expression $cmd
	}	

Write-Host "$($EASMailboxes.count) mailboxes with linked ActiveSync devices found."

$i = 1
[array]$TotalEASMailboxes = $EASMailboxes.Count
Foreach ($Mailbox in $EASMailboxes)
	{
	$EASDeviceStatistics = Get-ActiveSyncDeviceStatistics -Mailbox $Mailbox.Identity -WarningAction SilentlyContinue
    $MailboxStatistics = Get-Mailbox $Mailbox.Identity | Select DisplayName,PrimarySmtpAddress
	Write-Host -NoNewLine "Processing mailbox "; Write-Host -NoNewLine -ForegroundColor Green "[ $($i) / $($TotalEASMailboxes) ]"; Write-Host ", $($MailboxStatistics.DisplayName)"
	$j = 1
	$TotalEASDevices = $EASDeviceStatistics.Count
    If (!($TotalEASDevices)) { $TotalEASDevices = "1" }
	Foreach ($EASDevice in $EASDeviceStatistics)
    	{
        Write-Host -NoNewLine "     Processing device [ $($j) / $($TotalEASDevices) ] ";Write-Host -NoNewLine -ForegroundColor Green "$($EASDevice.DeviceID)"; Write-Host 
        $line = New-Object PSObject
        Add-Member -InputObject $line -MemberType NoteProperty -Name "DisplayName" -Value $MailboxStatistics.DisplayName
        Add-Member -InputObject $line -MemberType NoteProperty -Name "PrimarySmtpAddress" -Value $MailboxStatistics.PrimarySmtpAddress
        Foreach ($Column in $EASColumns)
    		{
            Add-Member -InputObject $line -MemberType NoteProperty -Name $Column -Value $EASDevice.$Column
            }
        Foreach ($Column in $CASColumns)
			{
			Add-Member -InputObject $line -MemberType NoteProperty -Name $Column -Value $Mailbox.$Column
			}
		Foreach ($Column in $CASArrayColumns)
			{
			$ColumnData = $Mailbox.$Column -join ";"
			Add-Member -InputObject $line -MemberType NoteProperty -Name $Column -Value $ColumnData
			}
			$Report += $line
		$j++
        }
	$i++
    }

If ($ExcludeSecondaryDomains -and $Domain)
	{
	$PrimarySmtpDomain = $Domain.Substring(1)
	$TempReport = $Report | ? { $_.PrimarySmtpAddress -match $PrimarySmtpDomain }
	If ($Append) 
		{ 
		$TempReport | Export-Csv -NoTypeInformation $ReportName -Append
		}
	Else 
		{ 
		$TempReport | Export-Csv -NoTypeInformation $ReportName 
		}
	}
Else
	{
	If ($Append) { $Report | Export-Csv -NoTypeInformation $ReportName -Append; invoke-expression $cmd }
	Else { $Report | Export-Csv -NoTypeInformation $ReportName }
}

If ($AddExistingAllowedDeviceIDs)
{
	$DevicesByGroup = $Report | Group-Object -Property PrimarySmtpAddress
	foreach ($line in $DevicesByGroup)
	{
		[array]$Mailbox = $line.Group.PrimarySmtpAddress
		[array]$ActiveSyncAllowedDeviceIDs = $line.Group.DeviceID | ? { $line.Group.DeviceAccessState -eq "Allowed" }
		[array]$ActiveSyncBlockedDeviceIDs = $line.Group.DeviceID | ? { $line.Group.DeviceAccessState -eq "Blocked" }
		[string]$Mailbox = $Mailbox[0]
		Write-Host -NoNewLine "Processing user mailbox: "; Write-Host -ForegroundColor Green $Mailbox
		Write-Host -NoNewLine "      Allowed DeviceIDs: "; Write-Host -ForegroundColor DarkGreen $ActiveSyncAllowedDeviceIDs
		Write-Host -NoNewLine "      Blocked DeviceIDs: "; Write-Host -ForegroundColor Red $ActiveSyncBlockedDeviceIDs
		Set-CASMailbox -Identity $Mailbox -ActiveSyncAllowedDeviceIDs $ActiveSyncAllowedDeviceIDs
	}
}
$EndDate = Get-Date
$ElapsedTime = $EndDate - $StartDate
Write-Host "Report started at $($Startdate)."
Write-Host "Report ended at $($EndDate)."
Write-Host "Total Elapsed Time: $($ElapsedTime)"