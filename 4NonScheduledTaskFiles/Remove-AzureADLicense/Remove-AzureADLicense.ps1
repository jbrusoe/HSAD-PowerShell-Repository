Set-HSCEnvironment

$Users = Import-Csv .\Licenses.csv
$Users = $Users #| Select -First 200

$UserCount = 1
foreach ($User in $Users)
{
    Write-Output $("Current User: " + $User.UPN)
    Write-Output "User Count: $UserCount"
    $UserCount++

    $AzureADUser = Get-AzureADUser -SearchString $User.UPN
    if ($null -ne $AzureADUser)
    {
        Write-Output "AzureAD User"
        $AssignedLicenses = $AzureADUser.AssignedLicenses

        if (($AssignedLicenses.SkuID -contains "4b590615-0888-425a-a965-b3bf7789848d") -AND
            ($AssignedLicenses.SkuID -contains "e578b273-6db4-4691-bba0-8d691f4da603")) {
            Write-Output "In O365 Base Licensing Group"
            Remove-HSCAzureADO365A3License -SamAccountName $User.UPN -Verbose
        }
        else {
            Write-Output "Not in Base Licensing Group or not licensed for A3"
        }
    }
    else {
        Write-Output "AzureAD User Not Found"
    }

    Start-Sleep -s 1
    Write-Output "*******************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count