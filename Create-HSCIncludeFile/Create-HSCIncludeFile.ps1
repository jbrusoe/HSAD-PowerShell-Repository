Function Create-HSCIncludeFile {
    <#
        .SYNOPSIS
            The purpose of this function is to create the Include File for the ADMT.

        .DESCRIPTION

        .PARAMETER

        .NOTES
            Author: Kevin Russell
            Last Updated by: Kevin Russell
            Last Updated: 11/29/2021
    #>

    [CmdletBinding()]
    param (	
        [ValidateNotNullOrEmpty()]
        [string]$Dept = "",

        [string]$OU = "OU=$Dept,OU=HSC,DC=HS,DC=WVU-AD,DC=WVU,DC=EDU",
        
        [string]$HSADUPN = "",

        [string]$SavePath = "\\hs.wvu-ad.wvu.edu\public\ITS\Network and Voice Services\microsoft\HSC-Logs\$Dept-IncludeFile.csv"
    )
    
    if (Test-Path -Path $SavePath) {
    }
    else {
        $SavePath = "C:\Temp\$Dept-IncludeFile.csv"
    }

    Write-Verbose "SavePath:  $SavePath"
    
    try {
        Get-ADUser -Filter * -SearchBase $OU -ErrorAction Stop |
        Select-Object SamAccountName |
        ForEach-Object {    
            if ($HSADUPN -eq $null) {
                $HSADUPN = "$($_.SamAccountName)@hsad.hsc.wvu.edu"
            }   
        
            [PSCustomObject]@{
                SourceName = $_.SamAccountName
                TargetSam = $_.SamAccountName
                TargetUPN = $HSADUPN
            } |
            try {
                Export-CSV -Path $SavePath -NoTypeInformation -Append -ErrorAction Stop
            }
            catch {
                Write-Warning "SavePath:  $SavePath"
                Write-Warning "There was a problem saving the include file."
                Write-Warning $error[0].Exception.Message
                Invoke-HSCExitCommand -ErrorCount $Error.Count
            }    
        }
    }
    catch {
        Write-Warning "SearchBase:  $OU"
        Write-Warning "There was an error generating a list of users for the include file."
        Write-Warning $error[0].Exception.Message
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }
}