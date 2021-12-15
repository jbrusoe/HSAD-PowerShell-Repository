# Get-HSCNetworkLogFileName

## SYNOPSIS
This function generates the names of the various log files and their
corresponding path on the network file share.

## SYNTAX

```
Get-HSCNetworkLogFileName [-ProgramName] <String[]> [-LogFileType <String>] [-FileExtension <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The purpose of this function is to generate the names of log
files used by the calling file/function, and the path that is
generated is on the network file share instead of the GitHub repo.
The date format used is Year-Month-Day(2 digit)-Hour(24 hour time)-Minute(2 digit).

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ProgramName
ProgramName is the user provided name of the program and is used to specifiy the log name.

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

### -LogFileType
Specifies the type of log file to generate.
Valid types are: SessionTranscript,
Error, Output, and Other.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: SessionTranscript
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileExtension
Specifies the file extension to be used for the log file.
The default value is .txt.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Txt
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSObject
## NOTES
Written by: Jeff Brusoe
Last Updated by: Jeff Brusoe
Last Updated: November 17, 2021

## RELATED LINKS
