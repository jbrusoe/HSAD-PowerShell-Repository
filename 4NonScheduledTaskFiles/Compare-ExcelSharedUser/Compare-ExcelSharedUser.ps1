#Requires ImportExcel module
#Installation Method:
#1. Run PowerShell as administrator
#2. Enter "Install-Module ImportExcel"
#3. Close PowerShell window when complete

Import-Module ImportExcel

Clear-Host

$ReferenceFile = "LV1.xlsx"
$DifferenceFile = "LV2.xlsx"

Write-Output "First File"
$ReferenceInputs = Import-Excel $ReferenceFile
$ReferenceInputs | ft

Write-Output "`nSecond File"
$DifferenceInputs = Import-Excel $DifferenceFile
$DifferenceInputs | ft

Write-Output "`nFinding Differences"
#Compare-Object -ReferenceObject $ReferenceInput2 -DifferenceObject $DifferenceInput2

foreach ($ReferenceInput in $ReferenceInputs)
{
	if ($DifferenceInputs.Name -match $ReferenceInput.Name)
	{
		Write-Output ("Service Name: " + $ReferenceInput.Name)
		Write-Output ("Service Display Name: " + $ReferenceInput.DisplayName)
		Write-Output ("Reference Status: " + $ReferenceInput.Status)
		
		$DifferenceStatus = $DifferenceInputs | where {$_.Name -eq $ReferenceInput.Name}
		
		Write-Output ("Difference Status: " + $DifferenceStatus.Status)
		
		if ($DifferenceStatus.Status -eq $ReferenceInput.Status)
		{
			Write-Host -ForegroundColor Green "Status is the same"
		}
		else
		{
			Write-Host -ForegroundColor Red "Status is different"
		}
	}
	
	Write-Output "****************************"
}