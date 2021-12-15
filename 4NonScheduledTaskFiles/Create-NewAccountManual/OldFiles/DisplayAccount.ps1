[CmdletBinding()]
param (
	Parameter(Mandatory=$true)
	[string]$SamAccountName
)

$ADUser = Get-ADUser $SamAccountName
$ADUser | Set-ADUser -Replace @{msExchHideFromAddressLists=$false}