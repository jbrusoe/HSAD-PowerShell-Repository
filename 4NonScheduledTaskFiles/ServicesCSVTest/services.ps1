Import-Csv services.csv | Foreach-Object { 

    foreach ($property in $_.PSObject.Properties)
    {
        Write-Output $property.Name
        Write-Output $property.Value

        if ([string]::IsNullOrEmpty($property.Value))
        {
            Write-Output "Null Value"
            exit
        }
    }

    Write-Output "***********"

    exit
}