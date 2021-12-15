Write-Output "Getting file list"
$Files = Get-ChildItem -Path "\\hs.wvu-ad.wvu.edu\Public\SOD\Axiummaster\" -File -Recurse -ErrorAction SilentlyContinue

Write-Output $("Files Count: " + $Files.Count)

Write-Output "Selecting files"
$LargeFiles = $Files | sort -Descending -Property Length | Select -First 20 -Property FullName,LastWriteTime,@{N='SizeInGB';E={[math]::round($_.Length/1GB,2)}}

Write-Output $("Files Count: " + $LargeFiles.Count)
$LargeFiles