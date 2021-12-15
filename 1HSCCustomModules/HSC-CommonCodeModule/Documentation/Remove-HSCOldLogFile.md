# Remove-HSCOldLogFile

## SYNOPSIS
Removes old log files to avoid cluttering up directory

## SYNTAX

```
Remove-HSCOldLogFile [[-Path] <String>] [[-Days] <Int32>] [-CSV] [-TXT] [-LOG] [-LBB] [-Delete] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function searches for log files older than three days
(or a value specified by the user) and removes (or copies)
the files from a specified directory.

The function returns a -1 if any errors occur when trying to
clean up the old log files.
If no errors occur, then it wil return
the total number of log files removed.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
The path to the directory that will be looked in to remove any old log files

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $($MyInvocation.PSScriptRoot + "\Logs\")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Days
The number of days from the current date to keep any log files

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 3
Accept pipeline input: False
Accept wildcard characters: False
```

### -CSV
Switch parameter to indicate searching directory for .csv files

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

### -TXT
Switch parameter to indicate searching directory for .txt files

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

### -LOG
Switch parameter to indicate searching directory for .log files

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

### -LBB
Switch parameter to indicate searching directory for .lbb files
(From backing up the SAN encryption keys)

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

### -Delete
Generated from SAN encryption key backup

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

### System.Int32
## NOTES
Written by: Kevin Russell
Last updated by: Jeff Brusoe
Last Updated: April 14, 2021

PS 5.1 Tested - June 30, 2020
PS 7.0.2 Tested - June 30, 2020

## RELATED LINKS
