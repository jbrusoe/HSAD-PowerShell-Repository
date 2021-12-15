<#
.SYNOPSIS
    This script will look for network printers and cycle through the list trying to
    rename printer to fully qualified domain name and delete non-FQDN from list.
    
.DESCRIPTION
    Can be run as standard user
    Intended for use for WVUH users with printing issues to non-FQDN names printers


.PARAMETER


.NOTES
Author: Kevin Russell
Last Updated by: Kevin Russell
Last Updated: 1/14/2021

If you get a rights error removing printers its probably a printer pushed via GPO

#>

#get network printers
$printerList = Get-Printer | where-object {$_.Type -eq "Connection"}

Write-Output "There were $($printerList.Count) network printers found." | Out-Host

foreach ($printer in $printerList) {
    $printServer = $printer.Name.Split('\\,\')[2]
    
    if ($printServer.Length -eq 8) {
        $printerName = $printer.Name.Split('\\,\')[3]
        $FQDNprinterName = "\\$($printServer).hs.wvu-ad.wvu.edu\$($printerName)"
        
        ###################
        #Remove old printer
        ###################
        $error.clear()

        try {            
            Remove-Printer -Name $printer.Name -ErrorAction Stop
            Write-Output "$($printer.Name) was removed" | Out-Host
        }
        catch {            
            Write-Output "There was an error removing $($printer.Name).  $($error[0].Exception.Message)" | Out-Host
        }        
        ###################
        #End remove printer
        ###################

        #################
        #Add FQDN printer
        #################
        $error.clear()
        
        #Check to make sure printer is not already FQDN'd         
        if ($printerList.Name -like $FQDNprinterName) {
            Write-Output "Printer already exists."            
        }
        else {
            try {            
                Add-Printer -ConnectionName $FQDNprinterName -ErrorAction Stop
                Write-Output "$FQDNprinterName added"
            }
            catch {
                Write-Output "There was an error adding $FQDNprinterName.  $($error[0].Exception.Message)"
            }
        }
        #####################
        #End add FQDN printer
        #####################
    }
    else {        
        Write-Output "$($printer.Name) already has FQDN naming"
    }    
}