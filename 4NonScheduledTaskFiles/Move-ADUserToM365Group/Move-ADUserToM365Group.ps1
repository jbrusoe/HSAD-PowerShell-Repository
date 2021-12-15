$OldGroup = "Office 365 Base Licensing Group"
$NewGroup = "M365 A3 for Faculty Licensing Group"

$OldGroupMembers = Get-ADGroup $OldGroup -Properties Members
$NewGroupObject = Get-ADGroup $NewGroup

foreach ($OldGroupMember in $OldGroupMembers.Members)
{
    Write-Output "Currently Adding:"
    Write-Output $OldGroupMember
    Add-ADGroupMember -Identity $NewGroupObject.DistinguishedName -Members $OldGroupMember

    Start-Sleep -Milliseconds 50
    Write-Output "********************"
}