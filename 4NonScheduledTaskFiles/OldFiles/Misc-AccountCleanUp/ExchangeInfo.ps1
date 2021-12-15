$Error.Clear()
$FileName = "c:\ad-development\ExchangeInfo.csv"

New-Item $FileName -type File -Force

$users = get-mailbox -resultsize unlimited

Add-content $FileName -value "UserFromFile,PrimarySMTPAddress,ActiveDirectoryEnabled,OWAEnabled,MAPIEnabled,ActiveSyncEnabled"

$Count = 0

foreach ($Mailbox in $users)
{
	$Error.Clear()
	
	$user = $Mailbox.Alias
	
	"Current user: " + $user
	$Count++
	
	"Count: " + $Count
	
	$Usr = $user.trim()
	
	$ADUser = Get-qaduser -samaccountname $usr
	
	$PrimarySMTPAddress = $ADUser.PrimarySMTPAddress
	
	"Primary SMTP Address: " + $ADUser.PrimarySMTPAddress
	
	"Getting mailbox"
	if ([string]::IsNullOrEmpty($PrimarySMTPAddress) -OR $PrimarySMTPAddress -like "*@mix.wvu.edu")
	{
		$PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
		
		if ([string]::IsNullOrEmpty($PrimarySMTPAddress))
		{
			$PrimarySMTPAddress = "No primary SMTP address set"
		}
	}
	
	$MB = get-mailbox $PrimarySMTPAddress
	
	"Error Count: " + $Error.Count
	
	"After getting mailbox"
	$FileOutput = ""
	
	$ADUser = Get-qaduser -samaccountname $usr
	
	"Beginning if then statement" 
	
	if ($Error.Count -gt 0)
	{
		$FileOutput = $usr + ",No Mailbox"
		
		if ($ADUser -eq $null)
		{
			$FileOutput += ",No AD Account"
		}
		else
		{
			$FileOutput += "," + !$ADUser.AccountIsDisabled
		}
	}
	else
	{
		$CAS = Get-Casmailbox $PrimarySMTPAddress
		$MBStat = Get-MailboxStatistics $PrimarySMTPAddress
		
		$FileOutput = $user + "," + $PrimarySMTPAddress + "," + !$ADUser.AccountIsDiabled + "," + $MBStat.LastLogonTime + "," + $CAS.OWAEnabled + "," + $CAS.MAPIEnabled + "," + $CAS.ActiveSyncEnabled
		
		$Error.Clear()
	}
	
	Add-Content $FileName  -Value $FileOutput
	
	"******************************"
}