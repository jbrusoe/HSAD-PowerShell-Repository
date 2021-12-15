[CmdletBinding()]
param (
    [string]$Path = "\\hs.wvu-ad.wvu.edu\public\SOD\"
)

Set-HSCEnvironment

Write-Output "Generating list of directories"
$Directories = Get-ChildItem $Path -Recurse -Directory -ErrorAction SilentlyContinue

if ($null -ne $Directories)
{
	foreach ($Directory in $Directories)
	{
		Write-Output $("Directory Name: " + $Directory.FullName)
		Write-Output "Directory ACL:"

		$Directory | Get-Acl
		
		Write-Output "***********************"
	}
}
Invoke-HSCExitCommand