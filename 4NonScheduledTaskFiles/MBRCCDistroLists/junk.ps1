if ($choice -eq 'eNews List'){

if ($eNewsWVUHUsers ="Yes"){

$OutputLists = $OutputListsWVUHUsers
$OutputFileName = "eNews Email List for WVUH Users Created on  "


foreach ($p in $OutputLists)
{
$output = $p
if ($i -gt $split){
$part++
$FilePath = $LogFilePath + " Part " + $part + " " + $OutputFileName + $Date + ".txt"
$screenoutput = "Adding WVUH Users to part " + $part + " of the output files"
echo $screenoutput
##IF (Test-Path $filepath){
##	Remove-Item $filepath
##}
$i=0
}
Add-content $filepath  $output 
$i++
}



$eNewsWVUHUsers = "No"
}


if ($eNewsNonWVUHUsers ="Yes"){


$OutputLists = $OutputListsNonWVUHUsers
$OutputFileName = "eNews Email List for Non-WVUH Users Created on  "

foreach ($p in $OutputLists)
{
$output = $p
if ($i -gt $split){
$part++
$FilePath = $LogFilePath + " Part " + $part + " " + $OutputFileName + $Date + ".txt"
$screenoutput = "Adding Non-WVUH Users to part " + $part + " of the output files"
echo $screenoutput
##IF (Test-Path $filepath){
##	Remove-Item $filepath
##}
$i=0
}
Add-content $filepath  $output 
$i++
}



$eNewsNonWVUHUsers = "No"
}








}
echo " "
echo " "
$outputlocation = "Output has been saved to " + $LogFilePath
echo $outputlocation
echo " "
echo " "
$ScriptFinished = "Script finished.  There are " + $part + " files this week."
echo $ScriptFinished
#echo $combolist