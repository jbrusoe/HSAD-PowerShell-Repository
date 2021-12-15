# Get-HSCLogFileName

## SYNOPSIS
This function generates the names of the various log files.

## SYNTAX

```
Get-HSCLogFileName [[-ProgramName] <String>] [[-LogFileType] <String>] [[-FileExtension] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The purpose of this function is to generate the names of log
files used by the calling file/function.
The date format used is
Year-Month-Day(2 digit)-Hour(24 hour time)-Minute(2 digit).

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ProgramName
ProgramName is the user provided name of the program.
It is used to help
build the session transcript log name.
If it is null, then its use is omitted.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogFileType
Specifies the type of log file to generate.
Valid types are: SessionTranscript,
Error, Output, and Other.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: SessionTranscript
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileExtension
Specifies the file extension to be used for the log file.
The default value is .txt

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Txt
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
Last Updated: March 29, 2021

## RELATED LINKS
