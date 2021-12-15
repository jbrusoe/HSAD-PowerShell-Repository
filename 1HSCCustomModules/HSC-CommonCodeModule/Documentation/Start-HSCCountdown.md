# Start-HSCCountdown

## SYNOPSIS
This function displays a progress bar and message stating the reason for the delay.
It is basically a more user friendly version of Start-Sleep which may look like the window
has locked up if it is used.

## SYNTAX

```
Start-HSCCountdown [[-Seconds] <Int32>] [[-Message] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Start-HSCCountdown -Message "Test Message" -Seconds 60
<Output is a progress bar>
```

## PARAMETERS

### -Seconds
This is the integer value that tells how long the pause should occur for.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -Message
{{ Fill Message Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: "Pausing for $Seconds seconds..."
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

### System.bool
## NOTES
Written by: Jeff Brusoe
Last Updated by: Jeff Brusoe
Originally Written: October 21, 2016
Last Updated; May 12, 2021

PS Version 5.1 Tested: June 29, 2020
PS Version 7.0.2 Tested: June 29, 2020
PS Version 7.1.3 Tested: May 12, 2021

## RELATED LINKS
