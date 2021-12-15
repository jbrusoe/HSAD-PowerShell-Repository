$Residents = Import-Csv IncomingResidents.csv

foreach ($Resident in $Residents)
{
    Write-Output $("Resident: " + $Resident.SAMAccountName)

    $ADUserInfo = $null
    $ADUserInfo = [PSCustomObject]@{
        SamAccountNameFromFile = $Resident.SAMAccountName.Trim()
    }
    
    try {
        $HSADUser = Get-ADUser -Identity $Resident.SAMAccountName.Trim() -Server "hs.wvu-ad.wvu.edu" -Properties PasswordLastSet -ErrorAction Stop
        
        Write-Output "HS AD Domain Account Found"
        $ADUserInfo | Add-Member -MemberType NoteProperty -Name "HSPasswordLastSet" -Value $HSADUser.PasswordLastSet
    }
    catch {
        Write-Output "HS User not found"
        $ADUserInfo | Add-Member -MemberType NoteProperty -Name "HSPasswordLastSet" -Value "UserNotFound"
    }
    
    try {
        $WVUMADUser = Get-ADUser -Identity $Resident.SAMAccountName.Trim() -Server "wvuhs.com" -Properties PasswordLastSet -ErrorAction Stop
    
        Write-Output "WVUHS AD Domain Account Found"
        $ADUserInfo | Add-Member -MemberType NoteProperty -Name "WVUHSPasswordLastSet" -Value $WVUMADUser.PasswordLastSet
    }
    catch {
        Write-Output "WVUHS User not found"
        $ADUserInfo | Add-Member -MemberType NoteProperty -Name "WVUHSPasswordLastSet" -Value "UserNotFound"
    }
    
    $ADUserInfo

    $ADUserInfo | Export-Csv PasswordLastSetComparison.csv -Append

    Write-Output "**********************"
}