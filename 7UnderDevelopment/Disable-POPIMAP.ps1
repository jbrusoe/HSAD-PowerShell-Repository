function Disable-POPIMAP
{
	<#
		.SYNOPSIS
			This function disables POP & IMAP on an Office 365 account(s)

		.PARAMETER Account
			The account that will have POP disabled on it.
 
		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Disable-HSCPOP jbrusoe                                                                        
			UserName POPDisabled
			-------- -----------
			jbrusoe         True
			
		.EXAMPLE
			PS C:\Users\jbrusoeadmin> Disable-HSCPOP jbrusoe,krussell,abcdefg                                                      
			WARNING: abcdefg wasn't found
			UserName POPDisabled
			-------- -----------
			jbrusoe         True
			krussell        True
			abcdefg        False
			
		.EXAMPLE
			PS C:\Users\jbrusoeadmin> "jbrusoe","krussell","abcdefg" | Disable-HSCPOP                                               
			WARNING: abcdefg wasn't found

			UserName POPDisabled
			-------- -----------
			jbrusoe         True
			krussell        True
			abcdefg        False
			
		.NOTES
			Last Updated by: Jeff Brusoe
			Last Updated: July 8, 2020
	#>
	
	[CmdletBinding()]
	[OutputType([PSObject])]
	param (
		[Parameter(Mandatory=$true,
                    ValueFromPipeline=$true,
					ParameterSetName = "StringAddresses")]
		[string[]]$EmailAddresses,
		
		[Parameter(Mandatory=$true,
					ValueFromPipeline=$true,
					ParameterSetName = "MailboxObjects")]
		[PSCustomObject[]]$Mailboxes
	)

	process
	{
		if ($PSCmdlet.ParameterSetName -eq "StringAddresses")
		{
			foreach ($EmailAddress in $EmailAddresses)
			{
				try {
					Write-Verbose "Current Email Address: $EmailAddress"
				
					$Mailbox = Get-Mailbox $EmailAddress -ErrorAction Stop
				
					Set-CasMailbox $Mailbox.PrimarySMTPAddress -POPEnabled $false -IMAPEnabled $false -ErrorAction Stop
					
					$CasMailbox = Get-CasMailbox $Mailbox.PrimarySMTPAddress -ErrorAction Stop
					
					$POPIMAPUserObject = [PSCustomObject]@{
						EmailAddress = $Mailbox.PrimarySMTPAddress
						POPEnabled = $CasMailbox.POPEnabled
						IMAPEnabled = $CasMailbox.IMAPEnabled
					}
				}
				catch {
					Write-Warning "Unable to set mailbox"
					$POPIMAPUserObject = [PSCustomObject]@{
						EmailAddress = $EmailAddress
						POPEnabled = $null
						IMAPEnabled = $null
					}
				}
				
				$POPIMAPUserObject
			}
		}
		else
		{
			foreach ($Mailbox in $Mailboxes)
			{
				try {
					Set-CasMailbox $Mailbox.PrimarySMTPAddress -POPEnabled $false -IMAPEnabled $false -ErrorAction Stop
					
					$CasMailbox = Get-CasMailbox $Mailbox.PrimarySMTPAddress -ErrorAction Stop
					
					$POPIMAPUserObject = [PSCustomObject]@{
						EmailAddress = $Mailbox.PrimarySMTPAddress
						POPEnabled = $CasMailbox.POPEnabled
						IMAPEnabled = $CasMailbox.IMAPEnabled
					}
				}
				catch {
					Write-Warning "Unable to set mailbox"
					$POPIMAPUserObject = [PSCustomObject]@{
						EmailAddress = $EmailAddress
						POPEnabled = $null
						IMAPEnabled = $null
					}
				}
				
				$POPIMAPUserObject
			}
		}
	}
	<#
	process
	{	
		foreach ($EmailAddress in $EmailAddresses)
		{
			Write-Verbose "Disbling POP & IMAP for $EmailAddress"
			$DisableUserSummary = New-Object -TypeName PSObject
			
			#First attempt to find user wtih V1 or V2 cmdlets
			$FoundUser = $false

			try {
				$Mailbox = Get-EXOMailbox $EmailAddress -ErrorAction Stop

				if ($null -ne $Mailbox) {
					$FoundUser = $true
					Write-Verbose "Found user with V2 Exchange cmdlets"
				}
			}
			catch {
				Write-Warning "Unable to find user mailbox for $Account with V2 Exchange cmdlets"
			}
			
			if ($FoundUser)
			{
				try {
					Set-CasMailbox -Identity $Mailbox.PrimarySMTPAddress -POPEnabled $false -ErrorAction Stop -WarningAction SilentlyContinue
					Write-Verbose "Successfully disabled POP for account" | Out-Host
					
					$DisableUserSummary | Add-Member -MemberType NoteProperty -Name "UserName" -Value $Account
					$DisableUserSummary | Add-Member -MemberType NoteProperty -Name "POPDisabled" -Value $true
				}
				catch {
					Write-Warning "Error disabling POP" | Out-Host
					$DisableUserSummary | Add-Member -MemberType NoteProperty -Name "UserName" -Value $Account 
					$DisableUserSummary | Add-Member -MemberType NoteProperty -Name "POPDisabled" -Value $false
				}
			}
			else
			{
				Write-Warning "$Account wasn't found"
				$DisableUserSummary | Add-Member -MemberType NoteProperty -Name "UserName" -Value $Account 
				$DisableUserSummary | Add-Member -MemberType NoteProperty -Name "POPDisabled" -Value $false
			}

			$POPUserArray += $DisableUserSummary
		}
	}
	

	end
	{
		Write-Verbose "Done processing users"
		return $POPUserArray
	}
	#>
}

$j = Get-ExoMailbox "jbrusoe"
$k = Get-ExoMailbox "krussell"

$j,$k | Disable-POPIMAP