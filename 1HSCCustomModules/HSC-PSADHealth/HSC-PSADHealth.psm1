function Test-HSCDCConnection {
    <#
        .SYNOPSIS
            Determines if AD domain controllers are online or not

        .DESCRIPTION
            The purose of this function is use the Test-Connection cmdlet
            to see the status of AD domain controllers. A PSCustomObject is
            returned that gives the DC name, IP Address and whether or not
            Test-Connection was able to connect to the domain controller

        .OUTPUTS
            PSCustomObject

        .EXAMPLE
            Test-HSCDCConnection

            Name       IPAddress       Connected
            ----       ---------       ---------
            HSAZUREDC1 10.3.202.20          True
            HSAZUREDC2 10.3.202.25          True
            HSDC2      157.182.102.168      True
            HSDC1      157.182.102.167      True
            HSDC3      157.182.102.165      True
            CHSDC1     157.182.160.18       True
            CHSDC2     157.182.160.16       True
            HSCA       157.182.102.175      True
            HSDC6      157.182.102.177      True
            HSDC4      157.182.102.166      True

        .EXAMPLE
            Test-HSCDCConnection -Verbose

            VERBOSE: Current DC: HSAZUREDC1
            VERBOSE: Successfully connected to DC
            VERBOSE: **************************
            VERBOSE: Current DC: HSAZUREDC2
            VERBOSE: Successfully connected to DC
            VERBOSE: **************************
            VERBOSE: Current DC: HSDC2
            VERBOSE: Successfully connected to DC
            VERBOSE: **************************
            VERBOSE: Current DC: HSDC1
            VERBOSE: Successfully connected to DC
            VERBOSE: **************************
            VERBOSE: Current DC: HSDC3
            VERBOSE: Successfully connected to DC
            VERBOSE: **************************
            VERBOSE: Current DC: CHSDC1
            VERBOSE: Successfully connected to DC
            VERBOSE: **************************
            VERBOSE: Current DC: CHSDC2
            VERBOSE: Successfully connected to DC
            VERBOSE: **************************
            VERBOSE: Current DC: HSCA
            VERBOSE: Successfully connected to DC
            VERBOSE: **************************
            VERBOSE: Current DC: HSDC6
            VERBOSE: Successfully connected to DC
            VERBOSE: **************************
            VERBOSE: Current DC: HSDC4
            VERBOSE: Successfully connected to DC
            VERBOSE: **************************
            Name       IPAddress       Connected
            ----       ---------       ---------
            HSAZUREDC1 10.3.202.20          True
            HSAZUREDC2 10.3.202.25          True
            HSDC2      157.182.102.168      True
            HSDC1      157.182.102.167      True
            HSDC3      157.182.102.165      True
            CHSDC1     157.182.160.18       True
            CHSDC2     157.182.160.16       True
            HSCA       157.182.102.175      True
            HSDC6      157.182.102.177      True
            HSDC4      157.182.102.166      True

        .NOTES
            Written by: Jeff Brusoe
            Last Updated: April 26, 2021

            Based on:
            https://github.com/compwiz32/PSADHealth/blob/master/PSADHealth/Public/Test-DCsOnline.ps1
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param()

    try {
        $DCs = Get-ADDomainController -Filter * -ErrorAction Stop
    }
    catch {
        Write-Warning "Unable to query domain controllers"
        return $null
    }

    foreach ($DC in $DCs)
    {
        Write-Verbose $("Current DC: " + $DC.Name)

        try {
            if ($null -eq (Test-Connection -ComputerName $DC.Name -Count 1 -ErrorAction Stop))
            {
                Write-Verbose "Could not connect to DC"

                $DCResults = [PSCustomObject]@{
                    Name = $DC.Name
                    IPAddress = $DC.IPv4Address
                    Online = $false
                }
            }
            else
            {
                Write-Verbose "Successfully connected to DC"

                $DCResults = [PSCustomObject]@{
                    Name = $DC.Name
                    IPAddress = $DC.IPv4Address
                    Online = $true
                }
            }
        }
        catch {
            Write-Warning "Error querying domain controller"
        }

        $DCResults
        Write-Verbose "**************************"
    }
}

# Test-ADServices.ps1
function Test-HSCADService {
     <#
        .SYNOPSIS
            Monitor AD Domain Controller Services

        .DESCRIPTION
            This function is used to Monitor AD Domain Controller services

        .NOTES
            Based on: https://github.com/compwiz32/PSADHealth/blob/master/PSADHealth/Public/Test-ADServices.ps1
            Last Updated By: Jeff Brusoe
            Last Updated: June 2, 2021
    #>

    [CmdletBinding()]
    Param()
   
    begin {
        try {
            Write-Verbose "Generating Domain Controller List..."
    
            $DCs = Get-ADDomainController -Filter * -ErrorAction Stop

            Write-Verbose "Finished Getting Domain Controller List"
        }
        catch {
            Write-Warning "Unable to query domain controllers"
            return $null
        }

        $Collection = @('ADWS',
            'DHCPServer',
            'DNS',
            'DFS',
            'DFSR',
            'Eventlog',
            'EventSystem',
            'KDC',
            'LanManWorkstation',
            'LanManServer',
            'NetLogon',
            'NTDS',
            'RPCSS',
            'SAMSS',
            'W32Time')
        $ServiceFilter = ($Collection | ForEach-Object { "name='$_'" }) -join " OR "
        $ServiceFilter = "State='Stopped' and ($ServiceFilter)"
    }

    process {
        try {
            $services = Get-CimInstance Win32_Service -filter $ServiceFilter -Computername $DClist -ErrorAction Stop
        }
        catch {
            Out-Null
        }

        foreach ($service in $services) {
            $Subject = "Windows Service: $($service.Displayname), is stopped on $service.PSComputerName "
                $EmailBody = @"
                            Service named <font color=Red><b>$($service.Displayname)</b></font> is stopped!
                            Time of Event: <font color=Red><b>"""$((get-date))"""</b></font><br/>
                            <br/>
                            THIS EMAIL WAS AUTO-GENERATED. PLEASE DO NOT REPLY TO THIS EMAIL.
"@
                $mailParams = @{
                    To         = $Configuration.MailTo
                    From       = $Configuration.MailFrom
                    SmtpServer = $Configuration.SmtpServer
                    Subject    = $Subject
                    Body       = $EmailBody
                    BodyAsHtml = $true
                }
                Send-MailMessage @mailParams
        }
    } #Process
}