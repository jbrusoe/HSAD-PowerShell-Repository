Write-Output "Getting AUTest List"
$AUTest = Get-DynamicDistributionGroup "AUTest"

Get-Recipient -RecipientPreviewFilter $AUTest.RecipientFilter -ResultSize Unlimited |
    Export-Csv "AUTestRecipients2.csv"