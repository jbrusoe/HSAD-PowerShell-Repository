#Find printer name and TCP/IP address and display on screen
$printers = Get-WmiObject win32_printer | %{ $printer = $_.Name; $port = $_.portname; Get-WmiObject win32_tcpipprinterport | where { $_.Name -eq $port } | select @{name="printername";expression={$printer}}, hostaddress}

#make sure printers is not null to run loop
if ($printers -ne $null)
{
	$Computer = $env:computername	
	Write-Output $printers 
	
	#Loop to remove printers that are TCP/IP printing and their port
	#Note printers/ports will not delete and give error if print spooler is stopped
	ForEach ($printer in $printers)
	{
		Try
		{
			$printer = $printer.printername			
			(Get-WmiObject win32_printer -filter "Name = '$printer'").delete()
			Write-Output "$printer has been removed"
		}
		Catch
		{
			Write-Output "$printer was not able to be removed"
		}		
	}	
}
else
{
	Write-Output "No IP printers were found" 
}
