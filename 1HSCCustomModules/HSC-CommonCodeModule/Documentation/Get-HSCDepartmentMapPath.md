# Get-HSCDepartmentMapPath

## SYNOPSIS
Returns the path to the department mapping file used during
the account creation process

## SYNTAX

```
Get-HSCDepartmentMapPath [-DirectoryOnly] [<CommonParameters>]
```

## DESCRIPTION
This file returns the path to a department mapping file.
It contains
information such as the OU, home directory path, etc.
for users
based on the department that they are in.

## EXAMPLES

### EXAMPLE 1
```
Get-HSCDepartmentMapPath
<RootPath>\HSC-PowerShell-Repository\2CommonFiles\MappingFiles\DepartmentMap.csv
```

### EXAMPLE 2
```
Get-HSCDepartmentMapPath -DirectoryOnly
<RootPath>\GitHub\HSC-PowerShell-Repository\2CommonFiles\MappingFiles\
```

## PARAMETERS

### -DirectoryOnly
Returns the directory that the department map file is in rather
than the actual file.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES
Written by: Jeff Brusoe
Last Updated: March 19, 2021

PS Version 5.1 Tested:
- June 26, 2020
- February 16, 2021
PS Version 7.0.2 Tested: June 26, 2020
PS Version 7.1.2 Tested: February 16, 2021
PS Version 7.1.3 Tested: March 19, 2021

## RELATED LINKS
