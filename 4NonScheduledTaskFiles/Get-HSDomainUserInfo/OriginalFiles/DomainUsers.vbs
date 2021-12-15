' BDMP v2.0 2009  Contact Eigen Heald with questions 207-541-2311
' This is a VBScript to document all users in Active Directory.
' Outputs name, Domain ID, and various PW parameters into an Excel file.
' 
' ----------------------------------------------------------------------
'The script should be in the same directory as the script and will return 
' an Excel spreadsheet in the root directory named DomainUsers.xls. 
'Change the name of this text file to domainusers.vbs
'This script should be run at a command prompt using cscript. 
' For example: C:\cscript //nologo DomainUsers.vbs
'

Set objExcel = CreateObject("Excel.Application")
objExcel.Visible = True
objExcel.Workbooks.Add
Set objWorkbook = objExcel.Workbooks.Add()
Set objWorksheet = objWorkbook.Worksheets(1)
intRow = 2

objExcel.Cells(1, 1).Value = "Domain Name"
objExcel.Cells(1, 2).Value = "Full Name"
objExcel.Cells(1, 3).Value = "Description"
objExcel.Cells(1, 4).Value = "Acct Expiration Date"
objExcel.Cells(1, 5).Value = "Acct Locked?"
objExcel.Cells(1, 6).Value = "Acct Disabled?"
objExcel.Cells(1, 7).Value = "LastLogin"
objExcel.Cells(1, 8).Value = "Current PWD Age"
objExcel.Cells(1, 9).Value = "Max PWD Age"
objExcel.Cells(1, 10).Value = "Min PWD Age"
objExcel.Cells(1, 11).Value = "Min PWD Length"
objExcel.Cells(1, 12).Value = "# of PWDs Remembered"
objExcel.Cells(1, 13).Value = "PWD Expir Date"
objExcel.Cells(1, 14).Value = "PWD Required?"

On Error Resume Next
Set Fso = CreateObject("Scripting.FileSystemObject")

Const SEC_IN_MIN = 60
Const SEC_IN_DAY = 86400
Const MIN_IN_DAY = 1440 

strDomainName = InputBox("Enter Domain Name To Query") 
Set objDomain = GetObject("WinNT://" & strDomainName)  
objDomain.Filter = Array("user") 

For Each objItem In objDomain
objExcel.Cells(intRow, 1).Value = objItem.Name
objExcel.Cells(intRow, 2).Value = objItem.FullName
objExcel.Cells(intRow, 3).Value = objItem.Description
objExcel.Cells(intRow, 4).Value = objItem.AccountExpirationDate
objExcel.Cells(intRow, 5).Value = objItem.IsAccountLocked
objExcel.Cells(intRow, 6).Value = objItem.AccountDisabled
objExcel.Cells(intRow, 7).Value = objItem.LastLogin
objExcel.Cells(intRow, 8).Value = objItem.PasswordAge
objExcel.Cells(intRow, 9).Value = objItem.MaxPasswordAge
objExcel.Cells(intRow, 10).Value = objItem.MinPasswordAge
objExcel.Cells(intRow, 11).Value = objItem.MinPasswordLength
objExcel.Cells(intRow, 12).Value = objItem.PasswordHistoryLength
objExcel.Cells(intRow, 13).Value = objItem.PasswordExpirationDate
objExcel.Cells(intRow, 14).Value = objItem.PasswordRequired

intRow = intRow + 1
Next
Set objDomain = Nothing
 
objExcel.Range("A1:Y1").Select
objExcel.Selection.Interior.ColorIndex = 19
objExcel.Selection.Font.ColorIndex = 11
objExcel.Selection.Font.Bold = True
objExcel.Cells.EntireColumn.AutoFit

WScript.Echo "Complete"
objWorkbook.SaveAs "/DomainUsers.xls"
objExcel.Quit
