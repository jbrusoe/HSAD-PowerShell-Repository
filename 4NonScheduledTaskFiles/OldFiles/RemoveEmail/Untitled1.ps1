C:\AD-Development\Connect-ToOffice365-MS2.ps1

Get-Recipient -ResultSize unlimited | where {$_.EmailAddresses -like '*rni.0501*'}
