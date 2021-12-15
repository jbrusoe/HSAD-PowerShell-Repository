#$pcs = Get-ADComputer -SearchBase "OU=ClinicPCs,OU=SOD,OU=HS Computers,DC=HS,DC=wvu-ad,DC=wvu,DC=edu" -Filter *

param ([string]$ComputerName)
"Current Computer: " + $ComputerName
		
$path = "\\" + $ComputerName + "\c$\windows\temp\*"
"Current Path: $path"
	
Remove-Item $path -force -recurse -verbose -ea "SilentlyContinue"
	
Start-Sleep -s 2
	
"*****************************************"

#Get-ADComputer -SearchBase "OU=ClinicPCs,OU=SOD,OU=HS Computers,DC=HS,DC=wvu-ad,DC=wvu,DC=edu" -Filter * | foreach {$_.Name  ; start-job -FilePath .\Clean-TempDirectories2.ps1 -ArgumentList $_.Name ; start-sleep -s 4}