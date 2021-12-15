Import-Module ImportExcel

$ReferenceFile = "LV1.xlsx"
$DifferenceFile = "LV2.xlsx"

$ReferenceInput = Import-Excel $ReferenceFile
$ReferenceInput | Select Name,Status