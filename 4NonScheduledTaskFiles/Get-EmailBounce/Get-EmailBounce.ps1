[CmdletBinding()]
param()

#Initialize environment
$Error.Clear()
Set-HSCEnvironment

$OutputFile = (Get-Date -format yyyy-MM-dd-hh-mm-ss) + "-ADUserOutput.csv"
$ValidAccountFile = (Get-Date -format yyyy-MM-dd-hh-mm-ss) + "-ValidAccountOutput.csv"
$NonValidAccountFile = (Get-Date -format yyyy-MM-dd-hh-mm-ss) + "-NonValidAccountOutput.csv"

$FoundCount = 0
$NotFoundCount = 0

$Users = Import-Csv HSCEmailBounces.csv

foreach ($User in $Users)
{
    $ADUserInfo = New-Object -type psobject

    $ADUserInfo | Add-Member -type NoteProperty -Name EmailFromFile -value $User.Email
    $ADUserInfo | Add-Member -type NoteProperty -Name EmployeeNumberFromFile -Value $User.EmployeeNumber

    Write-Output $("Email from file: " + $User.Email)
    Write-Output $("Employee Number from file: " + $User.EmployeeNumber)

    try {
        $LDAPFilter = "(&(objectCategory=person)(objectClass=user)(extensionAttribute11=" + $User.EmployeeNumber + "))"
        $ADUser = Get-ADUser -Properties * -LDAPFilter $LDAPFilter

        if ($null -ne $ADUser)
        {
            Write-Output "User found"
            $FoundCount++

            $Enabled = $ADUser.Enabled
            $PasswordLastSet = $ADUser.PasswordLastSet
            $DistinguishedName = $ADUser.DistinguishedName
        }
        else {
            Write-Output "User not found"
            $NotFoundCount++

            $Enabled = $false
            $PasswordLastSet = "Not Found"
            $DistinguishedName = "Not Found"
        }
    }
    catch {
        Write-Warning "User not found by 700 number"
        $NotFoundCount++

        $Enabled = $false
        $PasswordLastSet = "Not Found"
        $DistinguishedName = "Not Found"
    }

    $ADUserInfo | Add-Member -type NoteProperty -Name Enabled -Value  $Enabled
    $ADUserInfo | Add-Member -type NoteProperty -Name PasswordLastSet -Value $PasswordLastSet
    $ADUserInfo | Add-Member -type NoteProperty -Name DistinguishedName -Value $DistinguishedName

    $ADUserInfo | Export-Csv "$PSScriptRoot\Logs\$OutputFile" -Append

    if (($DistinguishedName -ne "Not Found") -AND ($DistinguishedName.indexOf("OU=HSC") -gt 0))
    {
        $ADUserInfo | Export-Csv "$PSScriptRoot\Logs\$ValidAccountFile" -Append
    }
    else {
        $ADUserInfo | Export-Csv "$PSScriptRoot\Logs\$NonValidAccountFile" -Append
    }

    Write-Output "***************************"
}

Write-Output "Found Count: $FoundCount"
Write-Output "Not Found Count: $NotFoundCount"

Invoke-HSCExitCommand -ErrorCount $Error.Count