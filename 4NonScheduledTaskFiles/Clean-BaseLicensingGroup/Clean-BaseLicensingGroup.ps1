$BLGroupMembers = Get-ADGroupMember 'Office 365 Base licensing group'
$A1GroupMembers = Get-ADGroupMember 'Office 365 A1 group based'

$CompareObjectParams = @{
    ReferenceObject = $BLGroupMembers.DistinguishedName
    DifferenceObject = $A1GroupMembers.DistinguishedName
    IncludeEqual = $true
    ExcludeDifferent = $true
}

Compare-Object @CompareObjectParams | Export-Csv  $((Get-Date -Format yyyy-MM-dd-HH-mm) + "-BLG.csv")

$UsersToRemove = Compare-Object @CompareObjectParams

$BLG = Get-ADGroup "Office 365 Base Licensing Group"

$BLG

Start-Sleep -s 3

foreach ($UserToRemove in $UsersToRemove)
{
    Write-Output "Current Group Member: "
    Write-Output $UserToRemove.InputObject

    try {
        $BLG | Remove-ADGroupMember -Members $UserToRemove.InputObject -ErrorAction Stop -Confirm:$false

        Start-Sleep -s 2
    }
    catch {
        Write-Warning "Error removing user from group"
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }
    
    Write-Output "*******************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count