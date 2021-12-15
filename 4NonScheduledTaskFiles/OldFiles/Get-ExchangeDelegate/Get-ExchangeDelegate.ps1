$SessionTranscript = (Get-Date -Format yyyy-MM-dd-HH-mm-ss) + "-ExchangeDelegate-SessionTranscript.txt"
Start-Transcript $SessionTranscript

$ErrorLogFile = (Get-Date -Format yyyy-MM-dd-HH-mm-ss) + "-ExchangeDelegate-ErrorFile.txt"
New-Item -type file -Path $ErrorLogFile

$DelegateLogFile = $InboxRuleFile = (Get-Date -format yyyy-MM-dd-HH-mm-ss) + "-ExchangeDelegates.csv"

$Users = Get-MsolUser -All -EnabledFilter EnabledOnly | Where-Object {($_.UserPrincipalName -notlike "*#EXT#*") -AND ($_.UserPrincipalName -notlike "*wvuh.wvuhs.com*")} | select ObjectID, UserPrincipalName, FirstName, LastName, StrongAuthenticationRequirements, StsRefreshTokensValidFrom, StrongPasswordRequired, LastPasswordChangeTimestamp

$UserCount = 1

foreach ($User in $Users)
{
	Write-Output $("Current user: " + $User.UserPrincipalName)
	Write-Output "User Count: $UserCount"
	
	try
	{
		Write-Object "Attempting to get delegate information."
		Get-MailboxPermission -Identity $User.UserPrincipalName -ErrorAction STOP | Where-Object {($_.IsInherited -ne "True") -and ($_.User -notlike "*SELF*")} | Export-Csv $DelegateLogFile -Append -NoTypeInformation
		Write-Object "Successfully obtained delegate information."
	}
	catch
	{
		Write-Warning "Unable to pull delegates for this account."
		
		Add-Content -Value $User.UserPrincipalName -Path $ErrorLogFile
	}
	
	$UserCount++
	Write-Output "************************"
}

Stop-Transcript