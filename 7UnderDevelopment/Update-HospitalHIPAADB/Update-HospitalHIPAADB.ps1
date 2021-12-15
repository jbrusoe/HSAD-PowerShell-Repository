#Update-SharedUserDB.ps1
#Written by: Jeff Brusoe
#Last Updated: September 25, 2020

#The purpose of this file is to updated the shared user database based on information
#in the shared user file that is sent over daily.

[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]$SharedUserPath = "\\hs\public\tools\SharedUsersRpt\",

    [switch]$Testing
)

#Configure Environment
Set-HSCEnvironment

$NotProcessedUsers = "$PSScriptRoot\Logs\" + (Get-Date -Format yyyy-MM-dd-HH-mm) + "-NotProcessedUsers.csv"
Write-Verbose "Not Processed User File $NotProcessedUsers"

$Count = 0

#Get O365 SQL instance connection string
$SQLPassword = Get-HSCSQLPassword -Verbose

Write-Output "SQL Password: $SQLPassword"

$ConnectionString = Get-HSCSQLConnectionString -DataSource "hscpowershell.database.windows.net" -Database "HSCPowerShell" -Username "HSCPowerShell" -SQLPassword $SQLPassword

if (Test-Path $SharedUserPath)
{
    $SharedFile = Get-HSCLastFile -DirectoryPath $SharedUserPath
    Write-Output "SharedFile: $SharedFile"

    #Begin looping through shared user file
    $SharedUsers = Import-Excel $SharedFile

    #Copy shared user file
    Copy-Item -Path $SharedFile -Destination "$PSScriptRoot\SharedUserFiles\"
}
else {
    Write-Warning "Unable to reach shared user file path. Program is exisitng."
    Invoke-HSCExitCommand -ErrorCount $Error.Count
}


foreach ($SharedUser in $SharedUsers)
{
    #Search for blank fields in shared user file
    $BlankField = $false
    foreach ($SharedUserProperty in $SharedUser.PSObject.Properties)
    {
        Write-Verbose $("Checking Property " + $SharedUserProperty.Name)

        if ([string]::IsNullOrEmpty($SharedUserProperty.Value) -AND $SharedUserProperty.Name -ne "mid")
        {
            $BlankField = $true
            Write-Verbose "Field is blank"
            break
        }
        else {
            Write-Verbose "Field is not blank"
        }
    }

    if ($SharedUser.Status -eq "Accepted")
    {
         Write-Output $("Processing: " + $SharedUser.wvu_id)

         if ($BlankField)
         {
             Write-Output "User has a blank field and will not processed"
             $SharedUser | Export-Csv $NotProcessedUsers -Append
         }
         else {
             Write-Output "User will be added to database"

             #Determine if they are HSC or WVUM users
             $HSCEmail = $false

             if ($SharedUser.email.ToLower().indexOf("hsc.wvu.edu") -gt 0)
             {
                 Write-Verbose "User has an HSC email address"
                 $HSCEmail = $true
             }
             elseif ($SharedUser.cost_center_name.indexOf("HVI") -ge 0)
             {
                 Write-Verbose "User is in HVI"
                 $HSCEmail = $true
             }
             else {
                 Write-Verbose "Hospital User"
             }

             $LastName = $SharedUser.lastname
             Write-Output "Last Name: $LastName"

             if ($LastName.indexOf("'") -gt 0)
             {
                $LastName = $LastName -Replace "'",""
             }

             $FirstName = $SharedUser.firstname
             if ($FirstName.indexOf("'") -gt 0)
             {
                 $FirstName = $FirstName -Replace "'",""
             }

             $InsertQuery = "Insert into SharedUserTable (Status,wvu_id,uid,firstname,lastname,email,HSCEmail) " +
             "Values ('$($SharedUser.Status)','$($SharedUser.wvu_id)','$($SharedUser.uid)'," +
             "'$FirstName','$LastName','$($SharedUser.email)','$HSCEmail');"

             Write-Output "Count: $Count"
             $Count++

             Write-Output "Insert Query:"
             Write-Output $InsertQuery

             try {
                Write-Output "Attempting to write to DB"
                Invoke-SQLCmd -Query $InsertQuery -ConnectionString $ConnectionString -ErrorAction Stop
                Write-Output "Successfuly wrote user to DB"
             }
             catch {
                #Should get here if user exists in DB already. Insert query errors out and must run update query.
                $Error.Clear()

                Write-Output "Error running insert query. Trying SQL update query"
                $UpdateQuery = "Update SharedUserTable " +
                                "SET uid = '$($SharedUser.uid)',firstname='$FirstName'," +
                                "lastname='$LastName',email='$($SharedUser.email)',HSCEmail='$HSCEmail' " +
                                "where wvu_id = '$($SharedUser.wvu_id)'"

                Write-Output "Update Query:"
                Write-Output $UpdateQuery

                try {
                    Invoke-SQLCmd -Query $UpdateQuery -ConnectionString $ConnectionString -ErrorAction Stop
                    Write-Output "Successfully ran update query"
                }
                catch {
                    Write-Warning "Error running update query."

                    if ($Testing) {
                        Write-Warning "Program is exiting."
                        Invoke-HSCExitCommand -ErrorCount $Error.Count
                    }

                }
             }
         }
    }

    Write-Output "******************************"
}

Invoke-HSCExitCommand -ErrorCount $Error.Count