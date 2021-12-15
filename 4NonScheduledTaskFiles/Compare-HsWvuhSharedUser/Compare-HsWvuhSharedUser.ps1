<#
.SYNOPSIS
    Read all files in directory for import and check to see if user is in AD
.DESCRIPTION
    Expects excel file, need to update session transcript path, filename path and export paths.  Put what properties you want in the properties array and if you have
	custom naming put that in piped select-object.
.NOTES
    Author: Kevin Russell
.LINK 
    
.PARAMETER 
	
.EXAMPLE
	
#> 


$SessionTranscript = "C:\AD-Development\Compare-HsWvuhSharedUsers\Logs" + $((Get-Date -Format yyyy-MM-dd) + "-SessionTranscript.txt")
Start-Transcript $SessionTranscript -Force


#add properties needed to array
$SelectedProperties = @('givenName', 'sn', 'extensionAttribute11', 'extensionAttribute12', 'department', 'mail', 'distinguishedName')
$RenamedObjects = @('@{Name="First Name";Expression="givenName"}','@{Name="Last Name";Expression="sn"}','@{Name="WVUID";Expression="extensionAttribute11"}','@{Name="User ID";Expression="extensionAttribute12"}','@{Name="OU";Expression="distinguishedName"}')
$ProfilePath = $env:userprofile

$FileNames = Get-ChildItem -Path "C:\AD-Development\Compare-HsWvuhSharedUsers\" -Recurse | Where-Object {$_.Extension -eq '.xlsx'}    #today's date for shared user file

Write-Output "There are $($FileNames.count) files to be processed`n`n"

ForEach ($name in $FileNames)
{
	#clear variables for each imported file
	$Found = 0
	$NotFound = 0
	$UsersNotFound = @()
	
	$Users = Import-Excel -Path "C:\AD-Development\Compare-HsWvuhSharedUsers\$($name.Name)"
	
	foreach ($user in $users)
	{	
		Try
		{
			Get-ADUser $User."User ID" -Properties $SelectedProperties | select-object @{Name="First Name";Expression="givenName"},@{Name="Last Name";Expression="sn"},@{Name="WVUID";Expression="extensionAttribute11"},@{Name="User ID";Expression="extensionAttribute12"},department,mail,@{Name="OU";Expression="distinguishedName"} |	Export-Excel -Path "C:\AD-Development\UsersFound-$($name.Name)" -Append
									
			$Found++
		}
		Catch
		{			
			$UsersNotFound += $User."User ID"
			$NotFound++
		}	
	}
	
	#write users not found in AD to file
	$UsersNotFound | Export-Excel -Path "$env:userprofile\Desktop\UsersNotFound-$($name.Name)" 

	Write-Output "$($name.Name)"
	Write-Output "------------------------------------"
	Write-Output "There were $Found users found"
	Write-Output "There were $NotFound users not found"
	Write-Output "`n"
}

Stop-Transcript