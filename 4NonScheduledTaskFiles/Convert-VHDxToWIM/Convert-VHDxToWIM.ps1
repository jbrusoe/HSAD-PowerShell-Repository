#Get name and description
$StartTime = Get-Date -Format "MM/dd/yyyy HH:mm"
$Imagename = Read-Host "Enter the name of the image"
$Desc = Read-Host "Enter a description for the image"

#mount image 
Try
{
	Write-Host "Trying to mount $Imagename"
	Mount-WindowsImage -ImagePath "J:\HSHYPERV Machines\Virtual Drives\$Imagename.vhdx" -Path J:\Mount-Temp -Index 1
	Write-Host "$Imagename mounted successfully" -Foregroundcolor Green
}
Catch
{
	Write-Host "There was an error mounting $Imagename.  Stopping program." -Foregroundcolor Red
	Break
}

#create WIM from image
Try
{
	Write-Host "Trying to convert $Imagename to WIM.  This may take up to an hour, started on $StartTime"
	New-WindowsImage -CapturePath J:\Mount-Temp -Name "$Imagename" -ImagePath "J:\CompletedWIM\$Imagename.wim" -Description "$Desc" -CompressionType max -Verify
	Write-Host "$Imagename successfully converted" -Foregroundcolor Green
}
Catch
{
	Write-Host "There was an error converting $Imagename" -Foregroundcolor Red
}

#dismount image
Try
{
	Write-Host "Attempting to dismount $Imagename"
	Dismount-WindowsImage -Path J:\Mount-Temp -Discard
	Write-Host "$Imagename dismounted successfully" -Foregroundcolor Green
}
Catch
{
	Write-Host "There was an error dismounting the $Imagename" -Foregroundcolor Red
}