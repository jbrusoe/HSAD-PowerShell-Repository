# Write-HSCColorOutput

## SYNOPSIS
This function changes the output color and uses Write-Output to log stuff to the session transcript.

## SYNTAX

```
Write-HSCColorOutput [-Message] <String[]> [-ForegroundColor <String>] [<CommonParameters>]
```

## DESCRIPTION
This function allows color output in combination with Write-Output.
It's needed since Write-Output doesn't support this feature found in Write-Host.
Write-Output is used due to some issues writing log files.
Write-Output is also considered
a better option to display output than Write-Host.
(https://github.com/PowerShell/PSScriptAnalyzer/blob/master/RuleDocumentation/AvoidUsingWriteHost.md)

In this code, ForegroundColor refers to the color of the text.

## EXAMPLES

### EXAMPLE 1
```
Write-ColorOutput -Message "Test Message"
Test Message (Shown in the green which is the default)
```

### EXAMPLE 2
```
Write-HSCColorOutput -Message "Test Message" -ForegroundColor "Blue"
Test Message (Shown in blue)
```

## PARAMETERS

### -Message
{{ Fill Message Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ForegroundColor
{{ Fill ForegroundColor Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Green
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### The output of this function is the same as Write-Output but with the specified color displayed.
## NOTES
Written by: Jeff Brusoe
Last Updated: June 5, 2020

PS Version 5.1 Tested: June 29, 2020
PS Version 7.0.2 Tested: June 29, 2020

## RELATED LINKS
