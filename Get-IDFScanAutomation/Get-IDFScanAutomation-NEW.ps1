<#
.SYNOPSIS
     The script looks for attachements using outlook for CSV exports of ID Finder scans,
     creates a pivot table daily, then the most recent scan gets uploaded
     to a sharepoint document library by Get-IDFinderReports.ps1 
     running on the on-premise sharepoint node
    
.DESCRIPTION
 	Requires
	1. Connection to the shared folder path and modify the permissions
    2. Outlook with profile setup for the idfinder@hsc.wvu.edu email account

    The file does the following:
    1. Stops any existing Outlook processes
    2. Looks for most recent report sent to idfinder@hsc.wvu.edu
 	
.PARAMETER
	No required parameters

.NOTES
    Originally Written by: Matt Logue
    Last Updated by: Jeff Brusoe
    Last Updated: January 13, 2021
#>

[CmdletBinding()]
param (
	#File specific param
    [string]$scriptTest = $false,
	[string]$filepath = "\\hs.wvu-ad.wvu.edu\Public\ITS\security services\ID Finder Scan Files\"
	)

try {
    Set-HSCEnvironment -ErrorAction Stop
}
catch {
    Write-Output "Error configuring environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

#########################################
#          Main Script Function         #
#########################################

#Stops any existing Outlook process
Write-Output "`n Step 1: Stop any existing Outlook processes"

$AttemptNumber = 1

While ($true) {
    Write-Output "Attempt Number: $AttemptNumber"

    If ($null -ne (Get-process Outlook -ErrorAction SilentlyContinue)) {
        Get-Process Outlook | Stop-Process -Force
        $AttemptNumber++
    }
    else {
        Write-Output "All Outlook processes have stopped"
        break
    }

    if ($AttemptNumber -gt 10) {
        Write-Warning "Unable to stop Outlook process"
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }
}

# Step 2: Search for the most recent report sent to idfinder@hsc.wvu.edu
Write-Output "`nStep 2: Search for most recent report sent to idfinder@hsc.wvu.edu"

try {
    Add-Type -Assembly “Microsoft.Office.Interop.Outlook” | Out-Null
    $Outlook = New-Object -COMObject Outlook.Application
}
catch {
    Write-Warning "Unable to create Outlook object"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Opening ID Finder Mailbox"

    $NameSpace = $outlook.GetNameSpace("MAPI")
    $SourceFolder = $namespace.Folders.Item("ID Finder").Folders.Item("Inbox")
}
catch {
    Write-Warning "Unable to connect to idfinder mailbox"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

$inbox = $sourceFolder.items |
    Select-Object -Property senderName,SenderEmailAddress,Subject,ReceivedTime,Attachments |
    Select-Object -first 25

Write-Output "Processing Emails..."

$emails = $inbox |
    Where-Object -Property SenderEmailAddress -eq "infosec@mail.wvu.edu" |
    Sort-Object ReceivedTime -Descending |
    Select-Object -first 25 -Property Subject,Attachments,ReceivedTime

$filepath = "\\hs\public\ITS\security services\ID Finder Scan Files\"

$folderpath = $($filepath + $(Get-Date -Format yyyy-MM-dd))

if (!(Test-Path -Path $folderpath)) {
    try {
        New-Item -Path $folderpath -ItemType Directory -Force -ErrorAction Stop
    }
    catch {
        Write-Warning "There was an error creating $folderpath"
    }
}

$emails.attachments |
    ForEach-Object {
        Write-Host "Found File:" $_.filename
        #$attr = $_.filename 
        $AttachedFile = $_.filename
        $fileName = "$(Get-Date -Format yyyyMMdd)" + "_" + $a
        If (($AttachedFile.Contains("csv")) -AND ($AttachedFile -notlike "*count*") -AND ($AttachedFile.Contains("IDF2")))
        { 
            $filename = $filename -replace "_Locations",""
            $_.saveasfile((Join-Path $folderpath $fileName)) 
            Write-Output "Attachment Saved: $folderpath\$filename"
        } 
    }

Write-Output "Number of attachments saved: $((Get-ChildItem $folderpath |
    Where-Object{!($_.PSIsContainer)}).count)"

Write-Output "***************************`n`n"


############################################################
#        Code block for creating the Pivot table           #     
#        from saved attachments                            #
############################################################

#following formats the date for use in the file names and searching for the file
$date = Get-Date -Format u
$date = $date -split " "
$date = $date[0] -replace "-",""

$filetypes = @("CCs","SSNs","ePHI","TAXES")
foreach ($filetype in $filetypes)
{
    $nofilecount=0
    $filename = $date+'_IDF2_HSC_'+$filetype+'.csv'
    if (!(Test-Path "$folderpath\$filename")){
        Write-Output "No CSV Found called $filename"
        $nofilecount++
        if($nofilecount -ge 2) {
        Write-Output "Not enough CSV's Found"
            Exit 1
        }
    }
    $csvFile = (Get-ChildItem "$folderpath\$filename") #| sort LastWriteTime | select -last 1
    $filedirectory = Split-Path -Path $csvFile -Parent
    $csvfilename = Split-Path -Path $csvFile -leaf
    Write-Output "File Found: $filedirectory\$csvfilename"
    $finalFilename = $csvfilename -replace ".csv",""

    #Create excel COM object
    $excel = New-Object -ComObject excel.application

    #Make Visible
    $excel.Visible = $false
    $excel.Caption = "IDFinder_HSC_"+$filetype
    $xlWindowState = [Microsoft.Office.Interop.Excel.XLWindowState]
    $excel.DisplayAlerts = $FALSE
    #$excel.Application.WindowState = $xlWindowState::xlMinimized

    #Add a workbook
    $workbook = $excel.Workbooks.Add()
    $ws1 = $workbook.Worksheets.Add()


    #Connect to first worksheet to rename and make active
    $dataSheet2 = $workbook.Worksheets.Item(1)
    $dataSheet2.Name = "PivotTable"
    $dataSheet2.Activate() | Out-Null
    $dataSheet = $workbook.Worksheets.Item(2)
    $dataSheet.Name = "DataDump"
    Write-Output "Excel Workbook created"

    if ((Get-Content $csvFile).Contains("sep=,"))
    {
       (Get-Content $csvFile) | Select-Object -Skip 1 | Set-Content $csvFile #removes "sep=," line from begining of csv
    }

    $csvFileProcessed = Import-Csv -Path $csvFile
    $processes = $csvFileProcessed

	
	if ($filetype -eq "TAXES") 
    {
		$dataSheet.cells.item(1,1) = "Endpoint"
		$dataSheet.cells.item(1,2) = "Tag Name"
		$dataSheet.cells.item(1,3) = "Location"
		$dataSheet.cells.item(1,4) = "Unprotected Quantity"
        
    }
	else {
		$dataSheet.cells.item(1,1) = "Tag Name"
		$dataSheet.cells.item(1,2) = "Endpoint"
		if ($filetype -eq "CCs") 
		{
			$dataSheet.cells.item(1,3) = "Unprotected CreditCards"
		}
		if ($filetype -eq "SSNs") 
		{
			$dataSheet.cells.item(1,3) = "Unprotected SSNs"
		}
		if ($filetype -eq "ePHI") 
		{
			$dataSheet.cells.item(1,3) = "Unprotected Quantity"
		}
		
		$dataSheet.cells.item(1,4) = "Location"
	}

    Write-Output "Importing Raw data to DataDump Worksheet..."
    $i = 2
    if ($filetype -eq "CCs") 
    {
        foreach($process in $processes) 
        { 
         $dataSheet.cells.item($i,1) = $process.'Tag Name'
         $dataSheet.cells.item($i,2) = $process.Endpoint
         $dataSheet.cells.item($i,3) = $process.'Unprotected CreditCards'
         $dataSheet.cells.item($i,4) = $process.Location
         $i++ 
        } #end foreach process
    } #end if
    if ($filetype -eq "SSNs") 
    {
        foreach($process in $processes) 
        { 
         $dataSheet.cells.item($i,1) = $process.'Tag Name'
         $dataSheet.cells.item($i,2) = $process.Endpoint
         $dataSheet.cells.item($i,3) = $process.'Unprotected SSNs'
         $dataSheet.cells.item($i,4) = $process.Location
         $i++ 
        } #end foreach process
    } #end if

    if ($filetype -eq "ePHI") 
    {
        foreach($process in $processes) 
        { 
         $dataSheet.cells.item($i,1) = $process.'Tag Name'
         $dataSheet.cells.item($i,2) = $process.Endpoint
         $dataSheet.cells.item($i,3) = $process.'Unprotected Quantity'
         $dataSheet.cells.item($i,4) = $process.Location
         $i++ 
        } #end foreach process
    } #end if
	
	if ($filetype -eq "TAXES") 
    {
        foreach($process in $processes) 
        { 
         $dataSheet.cells.item($i,1) = $process.'Endpoint Name'
		 $dataSheet.cells.item($i,2) = $process.'Tag Name'
		 $dataSheet.cells.item($i,3) = $process.Location
         $dataSheet.cells.item($i,4) = $process.'Unprotected Quantity'
         $i++ 
        } #end foreach process
    } #end if


    # rename workbook
    $workbook = $workbook

    # looks for names of worksheets
    $ws3 = $workbook.worksheets | where {$_.name -eq "PivotTable"} #<------- Selects sheet 3
    $ws1 = $workbook.worksheets | where {$_.name -eq "DataDump"}

    $xlPivotTableVersion15     = 5
    $xlPivotTableVersion14     = 4
    $xlPivotTableVersion12     = 3
    $xlPivotTableVersion10     = 1
    $xlCount                 = -4112
    $xlDescending             = 2
    $xlDatabase                = 1
    $xlHidden                  = 0
    $xlRowField                = 1
    $xlColumnField             = 2
    $xlPageField               = 3
    $xlDataField               = 4
    $xlDirection        = [Microsoft.Office.Interop.Excel.XLDirection]

    #looks for final non-empty row
    $finalrow=$ws1.Cells.End($xlDirection::xlDown).Row

    #creates pivot datasource on $ws1 then creates pivot table on $ws3 at position R1C1
    $PivotTable = $workbook.PivotCaches().Create($xlDatabase, $ws1.name + "!R1C1:R"+ $finalrow +"C4", $xlPivotTableVersion15)
    $PivotTable.CreatePivotTable($ws3.name + "!R1C1","Tables1") | Out-Null 
    [void]$ws3.Select();
    $ws3.Cells.Item(1,1).Select() | Out-Null
    #hide Pivot Table field list
    $workbook.ShowPivotTableFieldList = $false  

    #creates pivot table fields
    $PivotFields1 = $ws3.PivotTables("Tables1").PivotFields("Tag Name")
    $PivotFields1.Orientation = $xlRowField
    $PivotFields1.Caption = "Units"

    $PivotFields2 = $ws3.PivotTables("Tables1").PivotFields("Endpoint")
    $PivotFields2.Orientation = $xlRowField

    $PivotFields5 = $ws3.PivotTables("Tables1").PivotFields("Location")
    $PivotFields5.Orientation = $xlRowField

    $PivotFields3 = $ws3.PivotTables("Tables1").PivotFields("Location")
    $PivotFields3.Orientation = $xlDataField
    #looks at $filetype for naming of 2nd column of pivot table
    if ($filetype -eq "CCs") 
    {
	    $PivotFields3.Name = "Files with Unprotected CreditCards"
    }
    if ($filetype -eq "SSNs") 
    {
	    $PivotFields3.Name = "Files with Unprotected SSNs"
    }
    if ($filetype -eq "ePHI") 
    {
	    $PivotFields3.Name = "Files with Unprotected Quantities"
    }
	if ($filetype -eq "TAXES") 
    {
	    $PivotFields3.Name = "Files with Unprotected Quantities"
    }

    #looks at $filetype for creating 3rd column of pivot table
    if ($filetype -eq "CCs") 
    {
	    $PivotFields4 = $ws3.PivotTables("Tables1").PivotFields("Unprotected CreditCards")
	    $PivotFields4.Orientation = $xlDataField
	    $PivotFields4.Function = $xlSum
	    $PivotFields4.Caption = "Sum of Unprotected CreditCards"
    }

    if ($filetype -eq "SSNs") 
    {
	    $PivotFields4 = $ws3.PivotTables("Tables1").PivotFields("Unprotected SSNs")
	    $PivotFields4.Orientation = $xlDataField
	    $PivotFields4.Function = $xlSum
	    $PivotFields4.Caption = "Sum of Unprotected SSNs"
    }
    if ($filetype -eq "ePHI") 
    {
	    $PivotFields4 = $ws3.PivotTables("Tables1").PivotFields("Unprotected Quantity")
	    $PivotFields4.Orientation = $xlDataField
	    $PivotFields4.Function = $xlSum
	    $PivotFields4.Caption = "Sum of Unprotected Quantities"
    }
	if ($filetype -eq "TAXES") 
    {
	    $PivotFields4 = $ws3.PivotTables("Tables1").PivotFields("Unprotected Quantity")
	    $PivotFields4.Orientation = $xlDataField
	    $PivotFields4.Function = $xlSum
	    $PivotFields4.Caption = "Sum of Unprotected Quantities"
    }

    #sorts pivot table by the largest numbers in the 4th pivot field
    $PivotFields1.AutoSort($xlDescending, $PivotFields4.Name)

    #collapses all row fields
    Foreach ($PivotField in $ws3.PivotTables("Tables1").PivotFields()) {
        try {
        $PivotField.ShowDetail = $False
        }
        catch {
        #this throws and unhanded exception if it's not in a try/catch block to ignore the error
        }
    }

    Write-Output "Created PivotTable"
    #Changes formating of table also based on file type
    $row = 1
    $Column = 1
    $ws3.Cells.Item($row,$column)= 'Units'
    if ($filetype -eq "CCs")
    {
	    $ws3.PivotTables("Tables1").TableStyle2 = "PivotStyleMedium14" 
    }
    if ($filetype -eq "SSNs")
    {
	    $ws3.PivotTables("Tables1").TableStyle2 = "PivotStyleMedium12" 
    }
    if ($filetype -eq "ePHI")
    {
	    $ws3.PivotTables("Tables1").TableStyle2 = "PivotStyleMedium13" 
    }
	if ($filetype -eq "TAXES")
    {
	    $ws3.PivotTables("Tables1").TableStyle2 = "PivotStyleMedium10" 
    }
    $ws3.columns.item(1).columnWidth = 60
    $ws3.PivotTables("Tables1").HasAutoFormat = $false
	$ws3.PivotTables("Tables1").ShowTableStyleRowStripes = $true
    Write-Output "PivotTable Formatted"

    #script block for testing to make excel table visible
    if ($scriptTest -eq $true)
    {
     $excel.Visible = $true
     $excel.Application.WindowState = $xlWindowState::xlMaximized
    }

    if (!(Test-Path "$filedirectory\Processed"))
    {
        New-Item -Path "$filedirectory\Processed" -ItemType Directory
    }
    #save files
    $workbook.activate()
    $workbook.SaveAs($filedirectory+"\Processed\"+$finalfilename+".xlsx")
    #if $script test is false then it will close the workbook and release the variables
    if ($scriptTest -eq $false)
    {
	    $Excel.Workbooks.Close()
	    $Excel.Quit()
    }
    $fileCreated = Get-ChildItem ($filedirectory+"\Processed\"+$finalfilename+".xlsx")
    Write-Output "Report created: $fileCreated"

    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ws1) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ws3) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null


    Write-Output "`nReport created for the $filetype file`n"
}

Get-Process EXCEL | Stop-Process

#Writes Errors to log file
if ($Error.Count -gt 0)
{	
	Write-Verbose $("Error Count: " + $Error.count)
			
	for ($i=0 ; $i -lt $Error.count ; $i++) 
	{
		Add-Content -path $ErrorLogFile -value $Error[$i].InvocationInfo.Line
		Add-Content -path $ErrorLogFile -value $Error[$i].InvocationInfo.PositionMessage
		Add-Content -path $ErrorLogFile -value "******************************"
	}
}

try {
    
}
catch {
    Get-Process Outlook -ErrorAction Stop |
        Stop-Process -Force -ErrorAction Stop
}

Invoke-HSCExitCommand -ErrorCount $Error.Count