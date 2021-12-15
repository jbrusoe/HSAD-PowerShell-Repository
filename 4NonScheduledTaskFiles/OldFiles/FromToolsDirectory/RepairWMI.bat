IF NOT EXIST "%windir%\ccmsetup\logs" MKDIR "%windir%\ccmsetup\logs"
@ECHO Uninstalling client...
 
C:\Windows\ccmsetup\ccmsetup.exe" /uninstall
@ECHO Post uninstall cleanup...
IF EXIST %windir%\CCM RMDIR /S /Q %windir%\CCM
IF EXIST %windir%\ccmcache RMDIR /S /Q %windir%\ccmcache
IF EXIST %windir%\ccmsetup RMDIR /S /Q %windir%\ccmsetup
GOTO REPAIR_WMI
 
:REPAIR_WMI
@ECHO Repairing WMI...
sc config winmgmt start= disabled
net stop winmgmt /y
%SYSTEMDRIVE% >nul
 
cd %windir%\system32\wbem
For /f %%s in ('dir /b *.dll') do regsvr32 /s %%s
wmiprvse /regserver
REM winmgmt /regserver
net start winmgmt
for /f %%s in ('dir /b *.mof *.mfl') do mofcomp %%s
@ECHO Waiting for WMI repair to finish...
@ping -n 90 %computername%>nul