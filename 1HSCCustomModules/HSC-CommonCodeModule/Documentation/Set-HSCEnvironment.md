# Set-HSCEnvironment

## SYNOPSIS
This function configures the HSC PowerShell environment.

## SYNTAX

```
Set-HSCEnvironment [[-NoSessionTranscript] <Boolean>] [[-LogFilePath] <String>] [[-StopOnError] <Boolean>]
 [[-DaysToKeepLogFiles] <Int32>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function configures the environment for files that use this module.
It performs the follwing tasks.
0.
Stop transcript if it is currently running
1.
Sets strictmode to the latest version
2.
Clear $Error variable
3.
Clear PS window
4.
Sets the PowerShell window title
5.
Set location to root of ps1 directory
6.
Generates transcript log file path
7.
Start transcript log file
8.
Removes old .txt log files
9.
Set $ErrorActionPreference
10.
Display parameter information

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -NoSessionTranscript
By default, a session transcript is created.
This parameter prevents creating that file.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogFilePath
THe path to write any logs files and the session transcript.
It defaults to $PSScriptRoot\Logs

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $($MyInvocation.PSScriptRoot + "\Logs\")
Accept pipeline input: False
Accept wildcard characters: False
```

### -StopOnError
Stops program execution if an error is detected

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DaysToKeepLogFiles
Determines how long old log files should be kept for

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 5
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

### System.String
## NOTES
Written by: Jeff Brusoe
Last Updated by: Jeff Brusoe
Last Updated: May 10, 2021

## RELATED LINKS
