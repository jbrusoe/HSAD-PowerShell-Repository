<#
    .SYNOPSIS
        These functions are ones that are more specific than in other
        modules. They are mainly written to accompish tasks for specific
        PS files to avoid rewriting code.

    .DESCRIPTION
        The following functions are included in this module:
        1. Get-HSCADGroupMember
        2. Get-HSCDepartmentDirectoryFromWebr

    .NOTES
        Written by: Jeff Brusoe
        Last Updated: February 4, 2021
#>

function Get-HSCADGroupMember
{
    <#
        .SYNOPSIS
            This function generates an array of email addresses for all users
            in an AD group along with all of the subgroups contained in that group.

        .PARAMETER ADGroupName
            This is the group name(s) that is to be searched for.

        .NOTES
            Written by: Jeff Brusoe
            Last Updated: February 4, 2021
    #>

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory=$true,
                    ValueFromPipeline=$true)]
        [string[]]$ADGroupNames
    )

    begin 
    {
        Write-Verbose "AD Group Name: $ADGroupName"

        $EmailArray = @()
    }

    process
    {
        foreach ($ADGroupName in $ADGroupNames)
        {
            try {
                Write-Verbose "Attempting to find AD Group"
                $ADGroup = Get-ADGroup $ADGroupName -ErrorAction Stop
    
                if ($null -eq $ADGroup) {
                    Write-Verbose "Group not found"
                }
                else {
                    Write-Verbose "Group found"
    
                    Write-Verbose $("Group SamAccountName: " + $ADGroup.SamAccountName)
    
                    $GroupMembers = Get-ADGroupMember -Identity $ADGroup.DistinguishedName -Recursive
    
                    foreach ($GroupMember in $GroupMembers)
                    {
                        Write-Verbose $("Current Group Member: " + $GroupMember.SamAccountName)
                        
                        $PrimarySMTPAddress = ($GroupMember.SamAccountName |
                                        Get-HSCPrimarySMTPAddress -ErrorAction Stop).PrimarySMTPAddress
    
                        $EmailArray += $PrimarySMTPAddress
                        Write-Verbose "PrimaraySMTPAddress: $PrimarySMTPAddress"
                        Write-Verbose $("Email Array Count: " + $EmailArray.Length)
                        Write-Verbose "----------------------------"
                    }
                }
            }
            catch {
                Write-Warning "Unable to find group"
            }
        }
    }

    end {
        Write-Verbose "Returning email array"
        return $EmailArray
    }
}

function Get-HSCDepartmentDirectoryFromWeb
{
    <#
    .SYNOPSIS

    .DESCRIPTION

    .NOTES
        Written by: Jeff Brusoe
        Last Updated: February 2, 2021
    #>

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true)]
        [string[]]$URLs,

        [Parameter(Mandatory=$true)]
        [string]$EmailSeparator
    )

    begin 
    {
        Write-Verbose "URL: $URL"
        Write-Verbose "Email Separator: $EmailSeparator"
        Write-Verbose "Department Name: $Departmentname"

        $EmailArray = @()
    }

    process
    {
        Write-Verbose "Looping through URLs"

        foreach ($URL in $URLs)
        {
            Write-Verbose "Current URL: $URL"
            $Links = (Invoke-WebRequest -URI $URL).Links


            for ($i = 0; $i -lt $Links.Count; $i++)
            {
                if (($Links[$i].OuterText -like "*@*") -AND
                ($Links[$i+1].OuterText -eq $EmailSeparator)) {
                    $EmailArray += $Links[$i].OuterText
                }
            }
        }
    }


    end {
        return $EmailArray
    }
}



function Get-HSCCancerCenterLabGroupMember
{
    [CmdletBinding()]
    param()

    begin{}
    process{}
    end{}
}

function New-HSCResearchProjectGroup
{
    <#
        .SYNOPSIS

        .DESCRIPTION
            This function adds research users to several default groups.
            Currently, these default groups are:
            1. HSC VDI Research Projects Parent Group
            2. SAS 9.3 Research Application
            3. R Studio
            4. Adobe Acrobat XI

        .PARAMETER DefaultGroups

        .PARAMETER SamAccountName

        .PARAMETER ProjectName

        .NOTES
            Written by: Jeff Brusoe
            Last Updated: April 8, 2021
    #>

    [CmdletBinding(SupportsShouldProcess=$true,
                    ConfirmImpact = "Medium")]
    [OutputType([bool])]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$DefaultGroups = @(
            "HSC VDI Research Projects Parent Group",
            "SAS 9.3 Research Application",
            "R Studio",
            "Adobe Acrobat XI"
        ),

        [Parameter(Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    Position = 0)]
        [string[]]$SamAccountName,

        [Parameter(Mandatory = $true,
                    Position = 1)]
        [string]$ProjectName
    )

    begin {
        Write-Verbose "SamAccountName: $SamAccountName"
        Write-Verbose "Project Name: $ProjectName"
    }

    process
    {
        $NewADGroupName = "HS VDI $ProjectName Group"
        Write-Verbose "New AD Group Name: $NewADGroupName"

        $NewADGroupParams = @{
            Name = $NewADGroupName
            SamAccountName = $NewADGroupName
            Path = $GroupOU
            GroupScope = "Universal"
            GroupCategory = "Security"
            Server = $Server
            ErrorAction = "Stop"
        }

        try {
            New-ADGroup @NewADGroupParams
        }
        catch {
            Write-Warning "Unable to create default group"
        }
    }
}
