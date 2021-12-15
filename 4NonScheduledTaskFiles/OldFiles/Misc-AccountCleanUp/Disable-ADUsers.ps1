$users = get-qaduser -sizelimit 0 -includedproperties extensionAttribute1,extensionAttriubte7,extensionAttribute10,msExchHideFromAddressLists -searchroot "hs.wvu-ad.wvu.edu/Inactive Accounts" #| where {$_.PasswordLastSet -lt (Get-Date).AddDays(-365) -AND !$_.AccountIsDisabled -AND $_.LastLogonTimeStamp -lt (Get-Date).AddDays(-365)} 

foreach ($usr in $users)
{
	$user = get-qaduser $usr -includedproperties extensionAttribute1,extensionAttribute7,extensionAttribute10,msExchHideFromAddressLists
	
	$user | select samaccountname,account*,password*,lastlog*,dn,whenCreated,ext*,msExchHideFromAddressLists
	Write-Output $user.dn
	Start-Sleep -s 3
	
	if (($user.dn.indexOf("Resource Accounts") -lt 0) -AND ($user.dn.toLower().indexof("sharepoint") -lt 0) -AND ($user.dn.indexof("ISO") -lt 0) -AND ($user.dn.indexof("ITS") -lt 0) -AND ($user.dn.indexof("OU=NETWORK") -lt 0))
	{
		#Get-Mailbox $user.samaccountname
		
		"Before mailbox statistics"
		$Error.Clear()
		
		$MBStat = Get-MailboxStatistics $user.samaccountname
		"Exchange Last Logon: " + $MBStat.LastLogonTime.toString()

		"After mailbox statistics"
		
		"extensionAttribute10: " + $user.extensionAttribute10
		
		#$MBStat.LastLogonTime.toString()
		
		if ($user.extensionAttribute10 -ne "Resource2")
		{
			$Resource = Read-Host "Flag as resource"
			if ($Resource -eq "y")
			{
				"Setting ext10"
				$user | set-qaduser -oa @{extensionAttribute10="Resource"}
				
				Start-Sleep -s 5
			}
			elseif (($Error.Count -eq 0) -AND $MBStat -ne $null)
			{
				"In Error.Count 0"
				
				if ((($MBStat.LastLogonTime -lt (Get-Date).AddDays(-365) -OR $MBStat.LastLogonTime -eq $null) -AND $user.whenCreated -lt (Get-Date).AddDays(-365)))
				{
					$MBStat.LastLogonTime -lt (Get-Date).AddDays(-365)
					$MBStat.LastLogonTime.toString()
					#$MBStat.LastLogonTime -gt (Get-Date).AddDays(-365)
					#$MBStat.LastLogonTime -eq $null
   

					$DisableAD = Read-Host "Disable AD"

					if ($DisableAD -eq "y")
					{
						$user | disable-qaduser

						$user | set-qaduser -accountexpires (Get-Date)

						if ([string]::IsNullOrEmpty($user.extensionAttribute1))
						{
							$user | set-qaduser -oa @{extensionAttribute1=(Get-Date).toString()}
						}
					}

					$ext7 = Read-Host "Set ext7 to No365"

					if ($ext7 -eq "y")
					{
						$user | set-qaduser -oa @{extensionAttribute7="ActiveDirectoryInactiveDisable"}

						$user | set-qaduser -oa @{msExchHideFromAddressLists=$true}
					}

					$MoveUser = Read-Host "Move User"

					if ($MoveUser -eq "y")
					{
						$user | move-qadobject -newparentcontainer "hs.wvu-ad.wvu.edu/Inactive Accounts/DisabledDueToInactivity"
					}

					get-qaduser -samaccountname $user.samaccountname | select samaccountname,acc*,last*,pass*,ext*,msexch*
				}
				else
				{
					$DisableAD = Read-Host "Disable AD"
					
					if ($DisableAD -eq "y")
					{
						$user | disable-qaduser

						$user | set-qaduser -accountexpires (Get-Date)

						if ([string]::IsNullOrEmpty($user.extensionAttribute1))
						{
							$user | set-qaduser -oa @{extensionAttribute1=(Get-Date).toString()}
						}
					}

					$ext7 = Read-Host "Set ext7 to No365"

					if ($ext7 -eq "y")
					{
						$user | set-qaduser -oa @{extensionAttribute7="ActiveDirectoryInactiveDisable"}

						$user | set-qaduser -oa @{msExchHideFromAddressLists=$true}
					}

					$MoveUser = Read-Host "Move User"

					if ($MoveUser -eq "y")
					{
						$user | set-qaduser -AccountExpires (Get-Date).AddDays(3)
						start-sleep -s 1
						$user | move-qadobject -newparentcontainer "hs.wvu-ad.wvu.edu/Inactive Accounts/DisabledDueToInactivity"
					}
					
					get-qaduser -samaccountname $user.samaccountname | select samaccountname,acc*,last*,pass*,ext*,msexch*
				}
			}
			else
			{
				"No Mailbox"

				$DisableAD = Read-Host "Disable AD"

				if ($DisableAD -eq "y")
				{
					$user | disable-qaduser

					$user | set-qaduser -accountexpires (Get-Date)

					if ([string]::IsNullOrEmpty($user.extensionAttribute1))
					{
						$user | set-qaduser -oa @{extensionAttribute1=(Get-Date).toString()}
					}
				}

				$ext7 = Read-Host "Set ext7 to No365"

				if ($ext7 -eq "y")
				{
					$user | set-qaduser -oa @{extensionAttribute7="ActiveDirectoryInactiveDisable"}

					$user | set-qaduser -oa @{msExchHideFromAddressLists=$true}
				}

				$MoveUser = Read-Host "Move User"

				if ($MoveUser -eq "y")
				{
					$user | move-qadobject -newparentcontainer "hs.wvu-ad.wvu.edu/Inactive Accounts/DisabledDueToInactivity"
				}

				get-qaduser -samaccountname $user.samaccountname | select samaccountname,acc*,last*,pass*,ext*,msexch*

			}
		}
	}
	
	"************************************"
}
