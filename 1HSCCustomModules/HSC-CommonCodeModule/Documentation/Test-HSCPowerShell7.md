# Test-HSCPowerShell7

## SYNOPSIS
This function tests to see if a version of PowerShell
greater than 7 is being used.

## SYNTAX

```
Test-HSCPowerShell7 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
$null is returned in this example since running on PS7
returns a null value
```

$null -eq (Test-HSCPowerShell7)
True

### EXAMPLE 2
```
Test-HSCPowerShell7 -Verbose
VERBOSE: PowerShell Version: 7.1
VERBOSE: Running PowerShell 7
```

### EXAMPLE 3
```
Test-HSCPowerShell7 -Verbose
VERBOSE: PowerShell Version: 5.1
VERBOSE: Incorrect PowerShell Version
Test-HSCPowerShell7 : Incorrect PowerShell Version
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### - Exception if PS7 is not being used
### - $null if PS7 is being used
## NOTES
Last Updated by: Jeff Brusoe
Last Updated: November 16, 2021

## RELATED LINKS
