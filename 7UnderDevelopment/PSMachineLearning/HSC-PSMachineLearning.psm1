function Get-HSCDistance
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [float[]]$TrainingPoint,

        [Parameter(Mandatory=$true)]
        [float[]]$TestingPoint
    )

    begin {
        $Distance = 0

        if ($TrainingPoint.Length -ne $TestingPoint.Length) {
            Write-Verbose "Points have different dimensions"
            $Distance = -1
        }
    }
    
    process
    {
        if ($Distance -eq -1) {
            Write-Warning "Unable to calculate distance"
        }
        else {
            Write-Verbose "Calculating Distance"

            for($i = 0; $i -lt $TrainingPoint.Length; $i++) {
                $Distance = $Distance + [Math]::Pow($TrainingPoint[$i] - $TestingPoint[$i],2)
            }
        }

        $Distance = [Math]::Sqrt($Distance)
    }

    end {
        return $Distance
    }
}

function Get-HSCkNearestNeighbors
{
    #https://www.geeksforgeeks.org/k-nearest-neighbours/
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$PathToTrainingData,

        [int]$k = 3,

        [Parameter(Mandatory=$true)]
        [string]$PathToTestData
    )

    begin
    {

    }

    process
    {

    }

    end
    {

    }
}

function Get-HSCCleanADData
{
    [CmdletBinding()]
    param ()

    begin
    {

    }

    process
    {

    }

    end
    {
        
    }
}