<#
	.SYNOPSIS    
    
    .NOTES
    
#>

[CmdletBinding()]
param(
    [array]$DirectoryName = @(
        "abaus_medicaid_claims"
        "Adcock Stroke"
        "Adcock Stroke Combined"
        "Allen 115 Waiver"
        "Allen Methadone"
        "Allen SNAP Work Requirements"
        "Baus Chronic Disease"
        "BMS COVID Eval"
        "Collaborate"
        "COVID-19 Testing Results"
        "DADS"
        "Dai Endocarditis"
        "Dai OD Mortality"
        "Data Governance Directory"
        "Davis Telehealth"
        "DHHR Project 1"
        "DHHR Project 2"
        "DHHRHonestBroker"
        "DHHRUploads"
        "Grossman birth control"
        "Grossman Diabetes"
        "Health Affairs Share"
        "Hendricks Heart Failure"
        "Hendricks pregnant telehealth"
        "HMA Training Datasets"
        "Match"
        "Medical Training"
        "MODRN"
        "Moran Support Grant"
        "MOTOR Claims"
        "Nathan"
        "Rudisill MAT"
        "SOR"
        "Stansbury OSA"
        "Stocks Exploratory COVID"
        "WVU Office of Health Services Research"
    ),

    [string]$SourceDirectory = "\\secure.securedepot.hsc.wvu.edu\healthaffairs\",

    [string]$TargetDirectory = "\\ROCRDSHCL01.hs.wvu-ad.wvu.edu\SASWorkingData\"
)


ForEach ($Directory in $DirectoryName){
    try {
        New-Item -Path $TargetDirectory -Name $Directory -ItemType "directory" -Force -ErrorAction Stop
    }
    catch {
        Write-Warning $error[0].Exception.Message
    }
    
    try {
        (Get-Item -Path "$SourceDirectory\$Directory").GetAccessControl('Access') | Set-Acl -Path "$TargetDirectory\$Directory"
    }
    catch {
        Write-Warning $error[0].Exception.Message
    }     
}

