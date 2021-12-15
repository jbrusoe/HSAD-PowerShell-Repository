# Get-HSCPowerShellVersion

## SYNOPSIS
Returns the version of PowerShell

## SYNTAX

```
Get-HSCPowerShellVersion [<CommonParameters>]
```

## DESCRIPTION
The purpose of this function is to return the version of PowerShell
that the current host is running.
This is needed since modules such
as the Active Directory and Office 365 one only semi-work on PowerShell 7.

## EXAMPLES

### EXAMPLE 1
```
Get-HSCPowerShellVersion
5.1
```

### EXAMPLE 2
```
Get-HSCPowerShellVersion -Verbose
VERBOSE: PowerShell Version: 5.1
5.1
```

### EXAMPLE 3
```
Get-HSCPowerShellVersion -Verbose
VERBOSE: PowerShell Version: 7.0
7
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES
Written by: Jeff Brusoe
Last Updated: March 29, 2021

PS Version 5.1 Tested:
- June 26, 2020
- February 17, 2021
PS Version 7.0.2 Tested: June 26, 2020
PS Version 7.1.2 Tested: February 17, 2021
PS Version 7.1.3 Tested: March 29, 2021

## RELATED LINKS
