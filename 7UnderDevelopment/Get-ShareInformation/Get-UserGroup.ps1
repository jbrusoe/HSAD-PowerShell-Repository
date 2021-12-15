# Get-UserGroup.ps1

$Directory = (Get-HSCGitHubRepoPath) +
                "Backup-ADGroupMemberShip\Logs\*.csv"

foreach ($File in Get-ChildItem $Directory) {
    if ($null -ne (Select-String $File.FullName -Pattern "Carol Stocks")) {
        Write-Output $File.Name
    }
}
