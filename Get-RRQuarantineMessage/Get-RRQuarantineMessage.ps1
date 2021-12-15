#Get-RRQuarantineMessage.ps1
#Written by: Jeff Brusoe
#Last Updated: March 12, 2021
#
#This file was written at the request of Ray Raylman
#to show him what mail messages he has in quarantine.

[CmdletBinding()]
param (
    [string[]]$RecipientAddresses = @(
        "rraylman@wvumedicine.org",
        "Raymond.Raylman@wvuhealthcare.com",
        "rraylman@hsc.wvu.edu",
        "Ray.Raylman@hsc.wvu.edu",
        "rraylman@wvuhealthcare.com"
    )
)

try {
    Write-Verbose "Configuring environment"

    Set-HSCEnvironment -ErrorAction Stop
    Connect-HSCExchangeOnline -ErrorAction Stop
}
catch {
    Write-Warning "Unable to configure environment"
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}

try {
    Write-Output "Getting quarantine messages..."

    $GetQuarantineMessageParams = @{
        RecipientAddress = $RecipientAddresses
        StartReceivedDate = ((Get-Date).AddDays(-7))
        ErrorAction = "Stop"
    }
    $QuarantineMessages = Get-QuarantineMessage @GetQuarantineMessageParams

    $MsgBody = $QuarantineMessages |
        Select-Object SenderAddress,Subject |
        ConvertTo-Html |
        Out-String

    Write-Output $MsgBody
}
catch {
    Write-Warning "Unable to get recipient address"
}

try {
    Write-Output "Sending Email"

    $SendMailMessageParams = @{
        To = "rraylman@hsc.wvu.edu"
        Bcc = @("jbrusoe@hsc.wvu.edu","sreyes@hsc.wvu.edu")
        Subject = "rraylman@hsc.wvu.edu - Message Quarantine"
        From = "microsoft@hsc.wvu.edu"
        SMTPServer = "hssmtp.hsc.wvu.edu"
        Body = $MsgBody
        BodyAsHTML = $true
        ErrorAction = "Stop"
    }

    Send-MailMessage @SendMailMessageParams

}
catch {
    Write-Warning "Unable to send email message"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count