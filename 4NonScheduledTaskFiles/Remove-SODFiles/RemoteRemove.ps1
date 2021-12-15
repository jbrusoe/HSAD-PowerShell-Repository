$FileLocations = @(
            "c:\windows\DBUtil_2_3.sys",
            "c:\windows\temp\DBUTIL_2_3.sys"
        )

$Users = Get-ChildItem c:\Users\ -Directory
foreach ($User in $Users)
{
    $FileLocations += "c:\users\" +
                        $User.Name +
                        "\AppData\Local\Temp\DBUTIL_2_3.sys"
}

foreach ($FileLocation in $FileLocations) {
    try {
        Write-Output "Current File Location: $FileLocation"

        if (Test-Path $FileLocation) {
            Remove-Item -Path $FileLocation -Force -ErrorAction Stop #-WhatIf
        }
        else {
            Write-Output "File doesn't exist"
        }
    }
    catch {
        Write-Warning "Unable to remove file"
    }

	return
    Write-Output "******************"
}