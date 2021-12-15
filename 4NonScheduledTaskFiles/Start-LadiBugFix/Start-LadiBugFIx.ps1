<#
    .SYNOPSIS    
        The purpose of this scirpt is to address the LadiBug software issue that occurs
        if Chrome has not been launched first.  This is accomplished by creating a 
        shortcut on the desktop to this PS1 file and changing the icon to look like
        LadiBug.  WHen user launches LadiBug this scirpt launches instead and checks
        if Chrome is running, and if it is not it opens Chrome.  Chrome is requried to be
        running to launch LadiBug.  Once Chrome is running the script launchs chromne
        again with the profile id and app id for LadiBugChrome.   

        Steps:
        
        
    .NOTES
        Written By:  Kevin Russell
        Last Updated: 10/5/21
        Last Updated By: Kevin Russell


        You have to create a shortcut on the desktop to launch the ps1 file and change the 
        icon to look like LadiBug
#>

[CmdletBinding()]
param(
    [array]$ChromeSaveLocations = @("C:\Program Files (x86)\Google\Chrome\Application",
                                    "C:\Program Files\Google\Chrome\Application"),

    [string]$ChromeLocation = ""
)

foreach ($Location in $ChromeSaveLocations) {
    
    $ChromeInstalledHere = Test-Path $Location

    if ($ChromeInstalledHere -eq "$true") {
        $ChromeLocation = $Location
    }
}

try {
    $IsChromeRunning = Get-Process -ProcessName chrome -ErrorAction Stop
}
catch {    
}

if ($IsChromeRunning.Count -eq '0') {
    try {
        Start-Process chrome.exe -ErrorAction Stop
        Start-Sleep -Seconds 1
        $ChromeRunning = 'No'
    }
    catch {        
    }    
}

try {    
    $profile = '--profile-directory=Default'
    $AppID = '--app-id=lcdijnmoplgogkeenjbjmoehmpppcbmb'
    
    Start-Process "$ChromeLocation\chrome.exe" -ArgumentList $profile,$AppID -ErrorAction Stop
}
catch {    
}

#if ($ChromeRunning -eq 'No') {  #need to get process ID for ladibug so that when i stop-process on chrome it leaves that open
#    try {
#        Get-Process chrome.exe | Stop-Process -ErrorAction Stop
#    }
#    catch {        
#    }
#}
