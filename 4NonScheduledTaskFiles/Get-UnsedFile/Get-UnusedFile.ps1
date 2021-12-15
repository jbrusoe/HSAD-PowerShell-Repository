[CmdletBinding()]
param (
	[string]$RootDirectory = "y:\"
)

Set-HSCEnvironment

$AclFile = "$PSScriptRoot\Logs\" + (Get-Date -format yyyy-MM-dd-HH-mm) + "-Pathology-Acl.txt"
New-Item $AclFile -type File -Force

Write-Output "Getting directory list"
$Directories = Get-ChildItem $RootDirectory -Directory

foreach ($Directory in $Directories)
{
	Write-Output $Directory.Name
	Write-Output $Directory.FullName
	
	$DirectoryFullName = $Directory.FullName
	$DirectoryName = $Directory.Name
	
	##$ScriptBlock = {

	$files = Get-ChildItem $DirectoryFullName -Recurse -Verbose
	$files | Export-Csv "$PSScriptRoot\Logs\Pathology-$DirectoryName.csv"

	foreach ($file in $files)
	{
		$FullName = $file.FullName
		$Owner = (Get-Acl $FullName).Owner

		Write-Output "File Path: $FullName"
		Write-Output "Owner: $Owner"
		
		if ([string]::IsNullOrEmpty($Owner))
		{
			Write-Output "Owner is null"
			Add-Content $AclFile -Value (Get-Acl $FullName)
		}
		
		Write-Output "---------------------"
	}

		Write-Output "************************"
	##}
	
	##Start-Job -ScriptBlock $ScriptBlock -ArgumentList $FullName,$Name
}

Invoke-HSCExitCommand