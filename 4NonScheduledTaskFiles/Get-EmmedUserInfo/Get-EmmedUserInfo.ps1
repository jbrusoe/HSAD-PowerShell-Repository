# Get-EmmedUserInfo.ps1
# Written by: Jeff Brusoe
# Last Updated: November 5, 2021

[CmdletBinding()]
param ()

Clear-Host
$Error.Clear()

try {
    $EmmedUsers = Import-Csv EmmedUsers.csv -ErrorAction Stop
}
catch {
    Write-Warning "Unable to open emmed csv file"
    return
}

foreach ($EmmedUser in $EmmedUsers) {
    $ADProperties = @(
        "samAccountName",
        "Enabled",
        "Department",
        "whenCreated",
        "whenChanged",
        "PasswordLastSet",
        "LastLogonTimeStamp",
        "extensionAttribute1",
        "extensionAttribute7",
        "UserPrincipalName",
        "distinguishedName"
    )

    $SamAccountName = ($EmmedUser.Username -split "\\")[1]
    $Domain = ($EmmedUser.Username -split "\\")[0]

    Write-Output "Domain: $Domain"
    Write-Output "Sam AccountName: $SamAccountName"

    $DomainFQDN = $null
    switch ($Domain) {
        "HS" {$DomainFQDN = "hs.wvu-ad.wvu.edu"}
        "WVU-AD" {$DomainFQDN = "wvu-ad.wvu.edu"}
        "WVUHS" {$DomainFQDN = "wvuhs.com"}
    }

    Write-Output "Domain FQDN: $DomainFQDN"
    $ADUser = Get-ADUser -Identity $SamAccountName -Properties $ADProperties -server $DomainFQDN
    $ADUser
    
    #$ADUserObject = [PSCustomObject]@{
    ##    SamAccountName = $SamAccountName
    #}
    
    Write-Output "************************"
}

