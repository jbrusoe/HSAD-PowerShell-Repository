Function New-HSCVM
{
	<#
		.SYNOPSIS
			Creates a new VM, defaults to generation 1 with 8GB of memory and 50GB of VHDD space.  Also 
			defaults to VLAN 35 and saves to J:\HSHYPERV Machines\Virtual Drives\.  Assumes you are running 
			function on hshyperv2-mgt, needs the hyper-v module to run.  ISO's are stored at 
			\\hs-tools\apps\Windows10Enterprise\current version.  You need to pass in the name and 
			image location.

		.OUTPUTS
			

		.EXAMPLE
			

		.EXAMPLE
			

		.NOTES
			Written by: Kevin Russell
			Last Updated: 

			PS Version 5.1 Tested:  
			PS Version 7.0.2 Tested: 
	#>	
	
	[CmdletBinding()]
    param(	
	[string]$VMName,
	[int]$Gen = 1,
	[int]$StartMem = 8192,	
	[int]$VHDDSize = 51200,
	[string]$Location = "J:\HSHYPERV Machines\Virtual Drives\",
	[string]$ImageLocation,
    [string]$VirtualSwitch = "QLogic BCM5709C Gigabit Ethernet (NDIS VBD Client) #51 - Virtual Switch",
	[int]$VLANNetwork = 35
	)
    
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {	

        if(!$VMName -OR !$ImageLocation)
	    {
		    Write-Host "You need to provide VMName and ImageLocation."  
            Write-Host "Example: PS C:\New-HSCVM -VMName 'SCCM - Windows 10 x64 - 2004' -ImageLocation '\\hs-tools\Apps\Windows10Enterprise\2004\SW_DVD9_Win_Pro_10_2004_64BIT_English_Pro_Ent_EDU_N_MLF_-2_X22-29752'"
            Write-HOst "Re-run function with proper switches.  Exiting"
		    Break
	    }	    
	        
	        #Create VM
	        Try
	        {
		        Write-Host "Attempting to create $VMName" -ForegroundColor Cyan
	            New-VM -Name $VMName -BootDevice LegacyNetworkAdapter -Generation $Gen -MemoryStartupBytes 8GB -NewVHDPath "$VMName.vhdx" -NewVHDSizeBytes 50GB -Path $Location -SwitchName $VirtualSwitch
		        Write-Host "$VMName successfully created" -ForegroundColor Green
	        }
	        Catch
	        {
		        Write-Host "There was an error creating the VM named $VMName " -ForegroundColor Red
	        }
	
	        Start-Sleep -Seconds 5

	        #Set VLAN ID
	        Try
	        {
	        	Write-Host "Attempting to set VLAN to $VLANNetwork" -ForegroundColor Cyan
                Set-VMNetworkAdapterVlan -VMName $VMName -Access -VlanId $VLANNetwork                
	        	Write-Host "VLAN successfully set to $VLANNetwork" -ForegroundColor Green
	        }
	        Catch
	        {
	        	Write-Host "There was an error setting the VLAN to $VLANNetwork" -ForegroundColor Red
	        }
	
	        #Add DVD drive for ISO
	        Try
	        {
	        	Write-Host "Attempting to create the virtual dvd drive to boot $ImageLocation.iso" -ForegroundColor Cyan
	        	Add-VMDvdDrive -VMName $VMName -Path "$ImageLocation.iso" -ErrorAction Stop
	        	Write-Host "Virtual DVD drive successfully added to boot $ImageLocation.iso" -ForegroundColor Green
	        }
	        Catch
	        {
	        	Write-Host "There was an error adding virtual DVD drive" -ForegroundColor Red
	        }

            #Set Boot Order
            Try
            {
                Write-Host "Attempting to set Boot Order to CD, HDD, NIC" -ForegroundColor Cyan
                Set-VMBios $VMName -StartupOrder @("CD","IDE","LegacyNetworkAdapter","Floppy")
                Write-Host "Boot order successfully set" -ForegroundColor Green
            }
            Catch
            {
                Write-Host "Error setting boot order" -ForegroundColor Red
            }
    }
    else
    {
        Write-Host "Relaunch Powershell as Admin to run New-HSCVM function" -ForegroundColor Red
    }
	
}