# Test-HSCLogFilePath

## SYNOPSIS
Verifies that the log file path exists.

## SYNTAX

```
Test-HSCLogFilePath [-LogFilePath] <String> [-CreatePath] [<CommonParameters>]
```

## DESCRIPTION
This function verifies that the log file path exists.
An option exists to create the path if it doesn't exist.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -LogFilePath
This is a mandatory parameter that is the log file path
that needs to be tested.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreatePath
This is a switch parameter to indicate that the path should be
created if the log file path doesn't exist.

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

### System.bool
## NOTES
Written by: Jeff Brusoe
Last Updated by: Jeff Brusoe
Originally Written: April 10, 2018
Last Updated: May 12, 2021

## RELATED LINKS
