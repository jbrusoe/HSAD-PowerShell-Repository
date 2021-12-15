$localVolumes = Get-WMIObject win32_volume | where {$_.DriveLetter -ne $null}

$LocalVolumes | select DriveLetter,
	@{Name="Free(GB)";Expression={[math]::round($_.FreeSpace/1GB, 2)}},
	@{Name="Used(GB)";Expression={[math]::round(($_.Capacity-$_.FreeSpace)/1GB, 2)}}

	#Testing
