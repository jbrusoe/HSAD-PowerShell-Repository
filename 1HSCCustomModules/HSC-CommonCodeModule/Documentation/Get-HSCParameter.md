# Get-HSCParameter

## SYNOPSIS
The purpose of this function is to display any nondefault parameters that were passed to the originating function.

## SYNTAX

```
Get-HSCParameter [-ParameterList] <Hashtable> [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Get-HSCParameter -ParameterList $PSBoundParameters
All input parameters are set to default values.
```

## PARAMETERS

### -ParameterList
This parameter comes from the built-in $PSBoundParameters variable.
See: https://blogs.msdn.microsoft.com/timid/2014/08/12/psboundparameters-and-commonparameters-whatif-debug-etc/

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Displays to the screen any parameters that are not set to default values. This must be called from
### inside a function or ps1 file.
## NOTES
Written by: Jeff Brusoe
Last  Updated by: Jeff Brusoe
Last Updated: June 3, 2020

PS Version 5.1 Tested: June 26, 2020
PS Version 7.0.2 Tested: June 26, 2020

## RELATED LINKS
