$UniversalGroup = @()
$GlobalGroup = @()
$DomainLocalGroup = @()

#Order to migrate groups: Universal, Global, DomainLocal
$SourceOU = "OU=HSC,DC=HS,DC=wvu-ad,DC=wvu,DC=edu"

$SourceOUSearchProperties = @(
    "CanonicalName"
    "SamAccountName"
)

#Universal groups
$UniversalGroup = Get-ADGroup -Filter * -SearchBase $SourceOU -Properties $SourceOUSearchProperties |
    Where-Object {$_.GroupScope -eq 'Universal'} |
    Select-Object $SourceOUSearchProperties

#Global groups
$GlobalGroup = Get-ADGroup -Filter * -SearchBase $SourceOU -Properties $SourceOUSearchProperties |
    Where-Object {$_.GroupScope -eq 'Global'} |
    Select-Object $SourceOUSearchProperties

#DomainLocal
$DomainLocalGroup = Get-ADGroup -Filter * -SearchBase $SourceOU -Properties $SourceOUSearchProperties |
    Where-Object {$_.GroupScope -eq 'DomainLocal'} |
    Select-Object $SourceOUSearchProperties

Write-Host ""
Write-Host "Universal Groups:  $(($UniversalGroup).Count)"
Write-Host "Global Groups:  $(($GlobalGroup).Count)"
Write-Host "DomainLocal Groups:  $(($DomainLocalGroup).Count)"

ForEach ($UGroup in $UniversalGroup) {
        $RemoveDomainU = $UGroup.CanonicalName.Replace('HS.wvu-ad.wvu.edu/','')
        $SourceOUForADMTU = $RemoveDomainU.Replace("/$($UGroup.SamAccountName)",'')    
        $TargetOUForADMTU = "HS Users/$SourceOUForADMTU"
        [PSCustomObject]@{
            SamAccountName = $UGroup.SamAccountName
            SourceOU = $SourceOUForADMTU
            TargetOU = $TargetOUForADMTU
        } | Sort-Object "SourceOU" | Export-Csv -Path ".\UniversalGroup.csv" -NoTypeInformation -Force -Append
}
ForEach ($GGroup in $GlobalGroup) {
    $RemoveDomainG = $GGroup.CanonicalName.Replace('HS.wvu-ad.wvu.edu/','')
    $SourceOUForADMTG = $RemoveDomainG.Replace("/$($GGroup.SamAccountName)",'')
    $TargetOUForADMTG = "HS Users/$SourceOUForADMTG"
    [PSCustomObject]@{
        SamAccountName = $GGroup.SamAccountName
        SourceOU = $SourceOUForADMTG
        TargetOU = $TargetOUForADMTG
    } | Sort-Object "SourceOU" | Export-Csv -Path ".\GlobalGroup.csv" -NoTypeInformation -Force -Append
}
ForEach ($DLGroup in $DomainLocalGroup) {
    $RemoveDomainDL = $DLGroup.CanonicalName.Replace('HS.wvu-ad.wvu.edu/','')
    $SourceOUForADMTDL = $RemoveDomainDL.Replace("/$($DLGroup.SamAccountName)",'')
    $TargetOUForADMTDL = "HS Users/$SourceOUForADMTDL"
    [PSCustomObject]@{
        SamAccountName = $DLGroup.SamAccountName
        SourceOU = $SourceOUForADMTDL
        TargetOU = $TargetOUForADMTDL
    } | Sort-Object "SourceOU" | Export-Csv -Path ".\DomainLocalGroup.csv" -NoTypeInformation -Force -Append
}