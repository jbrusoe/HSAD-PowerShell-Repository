Set-HSCEnvironment

$UsersToTest = Import-Csv SoleNames.csv

foreach ($UserToTest in $UsersToTest)
{
    Write-Output $("Current User: " + $UserToTest.SamAccountName)

    try {
        $ADUser = Get-ADUser $UserToTest.SamAccountName -ErrorAction Stop
        $UserEnabled = $ADUser.Enabled
        $UserDistinguishedName = $ADUser.DistinguishedName
        $UserExists = $true
    }
    catch {
        $UserExists = $false
        $UserEnabled = $false
        $UserDistinguishedName = "NotFound"
    }
   

    $UserToTest | Add-Member -MemberType NoteProperty -Name UserExists -Value $UserExists
    $UserToTest | Add-Member -MemberType NoteProperty -Name UserEnabled -Value $UserEnabled
    $UserToTest | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value $UserDistinguishedName

    $UserToTest | Export-Csv "$PSScriptRoot\Logs\SoleNames-Output.csv" -Append
    
    Write-Output "**********************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count