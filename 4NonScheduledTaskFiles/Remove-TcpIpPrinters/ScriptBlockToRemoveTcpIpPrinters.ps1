#Find and list local printers
Write-Output "Local Printers"
Write-Output "--------------"
Get-WmiObject -Class Win32_Printer | Select Name, DriverName, PortName, Shared, Sharename | ft -auto

#Find IP printers and display on screen
$printers = Get-WmiObject -Class Win32_Printer |
		%{ $printer = $_.Name; $port = $_.portname; Get-WmiObject win32_tcpipprinterport |
		where { $_.Name -eq $port } |
		select @{name="printername";expression={$printer}}, @{name="port";expression={$port}}, hostaddress}

#make sure printers is not null to run loop
if ($printers -ne $null)
{
	$Computer = $env:computername
	Write-Output "TCP/IP Printers Found"
	Write-Output "---------------------"
	Write-Output $printers 	
	
	#Loop to remove printers that are TCP/IP printing and their port *Note 172 IP's will not be removed.
	#Note printers/ports will not delete and give error if print spooler is stopped
	ForEach ($printer in $printers)
	{								
			$port = $printer.port
			$printer = $printer.printername
			
			if ($port -like '*172*')
			{				
				Write-Output "$printer has a 172 IP and will not be removed at this time."
			}
			
			else
			{				
				Try
				{
					Remove-Printer -Name "$printer"
					Write-Output "$printer has been removed"				
				}
				Catch
				{
					Write-Output "$printer was not able to be removed"
				}				
				Try
				{					
					Remove-PrinterPort -Name "$port"
					Write-Output "$port has been removed"
				}
				Catch
				{
					Write-Output "$port was not able to be removed"
				}
			}			
	}	
}
else
{
	Write-Output "No IP printers were found" 
}
