# Set-HSCWindowTitle

## SYNOPSIS
Sets the PowerShell window title

## SYNTAX

```
Set-HSCWindowTitle [[-WindowTitle] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The purpose of this function is to change the title in the PowerShell window.
It can do this by either passing in a value or by parsing up the file path to
the ps1 file that called this function.

## EXAMPLES

### EXAMPLE 1
```
Set-HSCWindowTitle
<Changes window title to name of ps1 file that called this function>
```

### EXAMPLE 2
```
Set-HSCWindowTitle -WindowTitle "Jeff's PowerShell Window"
<Window title set to "Jeff's PowerShell Window"
```

## PARAMETERS

### -WindowTitle
This is a string parameter that specifies the PowerShell window title.
If it
isn't provided, it will be determined by the $PSCommandPath variable.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $MyInvocation.PSCommandPath
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by: Jeff Brusoe
Last Updated by: Jeff Brusoe
Last Updated: June 2, 2020

PS Version 5.1 Tested: June 29, 2020
PS Version 7.0.2 Tested: June 29, 2020

## RELATED LINKS
