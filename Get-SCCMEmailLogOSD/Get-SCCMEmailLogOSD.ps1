<#
.SYNOPSIS
    The script looks for in a shared log directory under \\HSSCCM\Packages\Logs for machines that have written their
    log files to the path.  Then it emails the log file to the helpdesk that contains information such as MAC
    address, machine name, etc

.DESCRIPTION
 	Requires
	1. Connection to the shared folder path and read permissions
    2. Mailbox permissions - SendAs hssccm@hsc.wvu.edu

.PARAMETER
	No required parameters

.NOTES
	Originally Written by: Matt Logue
    Updated & Maintained by: Kevin Russell
    Last Updated by: Kevin Russell
	Last Updated: March 8, 2021
#>

Param (
    [string]$Date = (Get-Date),
    [string]$LogDir = "\\hssccm\packages\logs\sccmimagetranscripts\machines",
    [string]$ArchiveDir = "\\hssccm\packages\logs\sccmimagetranscripts\machines\Archive",
    [string]$EmailUser = "microsoft@hsc.wvu.edu",
    [string]$EmailFrom = "hssccm@hsc.wvu.edu",
    [string]$EmailTo = "hscitdss@hsc.wvu.edu",
    [string]$body = "",
    [string]$EncryptedPasswordPath = "$PSScriptRoot\SCCMEmailLogOSDPassword.txt",
    [string]$SMTPServer = "smtp.office365.com",
    [Int]$SMTPPort = "587"
)

try {
    Set-HSCEnvironment -ErrorAction Stop
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

### Credentials for sending mail message ###
$UserName = $EmailUser.Split("@")[0]

try {
    If (Test-Path $EncryptedPasswordPath) {
        $Password = Get-Content -Path $EncryptedPasswordPath | ConvertTo-SecureString
    }
    else {
        throw "The folder path does not exist"
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }

    $Object = "System.Management.Automation.PSCredential"
    $Credentials = New-Object $Object -ArgumentList $UserName, $Password
}
catch {
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}
### End Credentials ###

### Main Program ###
$error.Clear()
While ($true){
    #Checking for existing log files if not, it waits 10 minutes
    try{
        while ((Get-ChildItem $LogDir -File | Measure-Object).Count -le 0) {
            Write-Output "No Log Files Found - Waiting 5 Minutes";
            Start-Sleep 300;}
    }
    catch{
        Write-Warning "There was an error checking the log file"
        Write-Warning $error[0].Exception.Message
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }

    try{
        $LogFiles = Get-ChildItem -Path $LogDir -file | Select-Object *
    }
    catch{
        Write-Warning "There was an error getting the logs files"
        Write-Warning $error[0].Exception.Message
        Invoke-HSCExitCommand -ErrorCount $Error.Count
    }

    #Reading each log files and creating the body for the message for each one it finds
    foreach ($file in $LogFiles.FullName) {
        try{
            $body = Get-Content $file
        }
        catch{
            Write-Warning "There was a problem getting the content of $file"
            Write-Warning $error[0].Exception.Message
        }

        try{
            $ComputerName = ($(Get-content $file |
                        Select-string "ComputerName") -replace "ComputerName:").Trim()
        }
        catch{
            Write-Warning "There was a problem getting the computer name"
            Write-Warning $error[0].Exception.Message
        }

        $body = $body | Out-string

        $body += "Previous machine images can be found at: $ArchiveDir"

        $From = $EmailFrom
        $To = $EmailTo
        $Subject = "Machine Imaged by SCCM: $computername"
        

        Write-Output "From: "$From
        Write-Output "To: "$To
        Write-Output "Subject: "$Subject
        Write-Output "Body: `n"$body
        Write-Output "Sending Email...`t $subject"

        try {
            $MailProperties = @{
                'From' = $From
                'To' = $To
                'Subject' = $Subject
                'Body' = $Body
                'SmtpServer' = $SMTPServer
                'Port' = $SMTPPort
                'Credential' = $Credentials
            }

            Send-MailMessage $MailProperties -UseSsl
            Start-sleep 3
            Write-Output "Email Sent...`t $subject"
        }
        catch {
            Write-Warning "There was an issue sending the email"
            Write-Warning $error[0].Exception.Message
            Invoke-HSCExitCommand -ErrorCount $Error.Count
        }

        try{
            Move-Item $file $ArchiveDir -Force
        }
        catch{
            Write-Warning "There was an issue moving $file to $ArchiveDir"
            Write-Warning $error[0].Exception.Message
            Invoke-HSCExitCommand -ErrorCount $Error.Count
        }
    }
}

Invoke-HSCExitCommand -ErrorCount $Error.Count