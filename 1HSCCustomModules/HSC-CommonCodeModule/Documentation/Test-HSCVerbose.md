# Test-HSCVerbose

## SYNOPSIS
This function determines if the verbose common parameter has been used.

## SYNTAX

```
Test-HSCVerbose [<CommonParameters>]
```

## DESCRIPTION
The purpose of this function is to return true/false depending on whether
the verbose parameter has been passed to the calling PowerShell file.

## EXAMPLES

### EXAMPLE 1
```
Test-HSCVerbose
False
```

### EXAMPLE 2
```
Test-HSCVerbose -Verbose
VERBOSE: Testing for verbose parameter
VERBOSE: Verbose parameter is present
True
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Retuns a boolean value depending on if the -Verbose parameter has been used.
## NOTES
Written by: Jeff Brusoe
Last Updated by: Jeff Brusoe
Last Updated: February 17, 2021

PS Version 5.1 Tested:
- June 29, 2020
- February 17, 2021
PS Version 7.0.2 Tested: June 29, 2020
PS Version 7.1.2 Tested: February 17, 2021

## RELATED LINKS
