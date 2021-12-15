[CmdletBinding()]
param()

try {
    Set-HSCEnvironment -ErrorAction Stop
    Connect-HSCExchangeOnline -ErrorAction Stop
    Connect-HSCOffice365 -ErrorAction Stop

    Write-Output "Successfully configured environment"
}
catch {
    Write-Warning "Unable to configure HSC environment"
}

try {
    $GetEXOMailboxParams = @{
        Properties = @("CustomAttribute7")
        Filter = "CustomAttribute7 -eq 'Yes365'"
        ResultSize = "Unlimited"
        ErrorAction = "Stop"
    }
    
    $O365Mailboxes= Get-EXOMailbox @GetEXOMailboxParams
    Write-Output $("O365 Mailbox Count: " + $O365Mailboxes.Count)
}
catch {
    Write-Warning "Unable to query mailboxes"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$O365MailboxIndex = 0
$EMSRemovedCount = 0
foreach ($O365Mailbox in $O365Mailboxes)
{
    $PrimarySMTPAddress = $O365Mailbox.PrimarySMTPAddress
    $UPN = $O365Mailbox.UserPrincipalName

    Write-Output "Current User: $PrimarySMTPAddress"
    Write-Output "UPN: $UPN"
    Write-Output "O365 Mailbox Index: $O365MailboxIndex"
    $O365MailboxIndex++

    try {
        $AzureADUser = Get-AzureADUser -ObjectID $UPN -ErrorAction Stop

        Write-Output $("Object ID: " + $AzureADUser.ObjectId)

        $AssignedLicenses = $AzureADUser.AssignedLicenses

        if ($AssignedLicenses.SkuID -Contains "efccb6f7-5641-4e0e-bd10-b4976e1bf68e") {
            Write-Output "User has EMS License"

            try {
                $SamAccountName = $AzureADUser.UserPrincipalName
                $SamAccountName = $SamAccountName.Split('@')[0]
                $SamAccountName = $SamAccountName.Trim()

                Remove-HSCAzureADEMSLicense -SamAccountName $SamAccountName -ErrorAction Stop
                Write-Output "Successfully removed license"
                
                $EMSRemovedCount++
                Write-Output "EMS Removed Count: $EMSRemovedCount"

                if ($EMSRemovedCount -eq 400) {
                    Invoke-HSCExitCommand -ErrorCount $Error.Count
                }
            }
            catch {
                Write-Warning "Unable to remove EMS License"   
            }
        }
        else {
            Write-Output "User doesn't have EMS License"
        }
    }
    catch {
        Write-Warning "Unable to find Azure AD User"
    }

    Write-Output "************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count