$users = get-qaduser -OrganizationalUnit "DeletedAccounts" -IncludedProperties extensionAttribute1 | where {($_.SamAccountName -ne "bdillow") -AND ([datetime]$_.extensionAttribute1 -lt "01/01/2017")} | sort -Property extensionAttribute1 | select samaccountname,extensionAttribute1,Accountisdisabled

foreach ($user in $users)
{
	"SamAccountName: " + $user.samaccountname
	"Last Logon Time Stamp: " + $user.lastlogontimestamp
	"PasswordLastChanged: " + $user.PasswordLastSet
	"Ext1: " + $user.extensionAttribute1
	"DN: " +  $user.DN

	Remove-QADObject -Identity $user.DN
	"**************************"

	
}