# Get-HSCServerName

## SYNOPSIS
This function returns the name of the server currently running the ps1 file.

## SYNTAX

```
Get-HSCServerName [-MandatoryServerNames] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Get-HSCServerName
<return server name>
```

### EXAMPLE 2
```
Get-HSCServeName -MandatoryServerNames
- sysscript2 (if on sysscript2)
- $null if not on sysscript2, 3, or 4
```

## PARAMETERS

### -MandatoryServerNames
This paramter tells the function to only return the server name
if the name is included in the $AllowedServerNames array.
Currently, this array contains the four sysscript servers
(sysscript2, sysscript3, sysscript4, sysscript5) as well
as my personal workstation and Surface for testing purposes.

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
Last Updated by: Jeff Brusoe
Last Updated: April 5, 2021

## RELATED LINKS
