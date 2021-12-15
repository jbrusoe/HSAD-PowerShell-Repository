function Get-HSCCancerCenterClinicalGroupUser
{
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Domain = "wvuh.wvuhs.com",

        [ValidateNotNullOrEmpty()]
        [string]$SearchPattern = @(
            "MBRCC",
            "9 West",
            "bmtu",
            "WVUM surgical Oncology Expansion (9E)"
        )
    )

    try {
        Write-Verbose "Attempting to find AD Group"
        Write-Verbose "Domain: $Domain"

        $ADGroups = Get-ADGroup -Filter *
    }
    catch {
        
    }
}