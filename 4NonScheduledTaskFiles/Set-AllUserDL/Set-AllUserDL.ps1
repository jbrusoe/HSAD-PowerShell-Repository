Set-HSCEnvironment

$MailBoxFilter = "((CustomAttribute7 -eq 'Yes365') -and" +
" (RecipientType -eq 'UserMailbox'))"

$WVUMGroup = "(PrimarySMTPAddress -eq 'WVUMSharedUsersGroup@hsc.wvu.edu')"
$WVUFGroup = "(PrimarySMTPAddress -eq 'WVUF-AU@hsc.wvu.edu')"
$MiscGroup = "(PrimarySMTPAddress -eq 'MiscUsers@hsc.wvu.edu')"

$NewAllUsersFilter = "$MailboxFilter -OR $WVUMGroup -OR $WVUFGroup -OR $MiscGroup"
Write-Output "NewAllUsersFilter: $NewAllUsersFilter"

Write-Output "Getting All Users Group"
$AUGroup = Get-DynamicDistributionGroup "All Users"

Write-Output "Current Recipient Filter"
$AUGroup | select RecipientFilter | fl

Write-Output "Setting Recipient Filter"
$AUGroup | Set-DynamicDistributionGroup -RecipientFilter $NewAllUsersFilter

Write-Output "Successfully set all users recipient filter"
Start-Sleep -s 5

Write-Output "Getting All Users Recipient Filter"
Get-DynamicDistributionGroup "All Users" | select RecipientFilter | fl

Invoke-HSCExitCommand -ErrorCount $Error.Count