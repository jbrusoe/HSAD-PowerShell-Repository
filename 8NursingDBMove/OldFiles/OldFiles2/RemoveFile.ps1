[CmdletBinding()]
param (
	[ValidateNotNullOrEmpty()]
	[string[]]$PathToSearch = @(
		"c:\windows\",
		"c:\windows\temp\",
		"c:\PathToUserProfile\"
	)
	
	[ValidateNotNullOrEmpty()]
	[string]$FileName
	)
	
	foreach ($Path in $PathToSearch)
	{
		$FullFileName = $Path + $FileName
		
		Write-Output "Current Path: $FullFileName"
		Get-ChildItem $FullName #Verify this works then pipe to Remove-Item
	}