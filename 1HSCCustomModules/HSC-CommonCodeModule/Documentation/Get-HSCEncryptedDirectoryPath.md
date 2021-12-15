# Get-HSCEncryptedDirectoryPath

## SYNOPSIS
Returns the file path to the 2CommonFiles\EncryptedFiles directory in
the HSC GitHub repository.

## SYNTAX

```
Get-HSCEncryptedDirectoryPath [<CommonParameters>]
```

## DESCRIPTION
The encrypted directory folder holds the encrypted files needed to automate
notifications to Office 365 or SQL Servers.

## EXAMPLES

### EXAMPLE 1
```
Get-HSCEncryptedDirectoryPath
C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\
```

### EXAMPLE 2
```
Get-HSCEncryptedDirectoryPath -Verbose
VERBOSE: Current Module Path: C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\HSC-CommonCodeModule\HSC-CommonCodeModule.psd1
VERBOSE: Directory: C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\
VERBOSE: Directory exists
C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES
Written by: Jeff Brusoe
Last Updated: March 23, 2021

PS Version 5.1 Tested:
- June 26, 2020
- February 16, 2021
PS Version 7.0.2 Tested: June 26, 2020
PS Version 7.1.2 Tested: February 16, 2021

## RELATED LINKS
