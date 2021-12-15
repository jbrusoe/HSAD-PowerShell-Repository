# Get-HSCNetworkLogPath

## SYNOPSIS
This function returns the path to the network log file.

## SYNTAX

```
Get-HSCNetworkLogPath [[-NetworkLogPathRoot] <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Get-HSCNetworkLogPath
\\hs.wvu-ad.wvu.edu\public\ITS\Network and Voice Services\microsoft\HSC-Logs\
```

### EXAMPLE 2
```
Get-HSCNetworkLogPath -Verbose
VERBOSE: Network Log Path: \\hs.wvu-ad.wvu.edu\public\ITS\Network ...
\\hs.wvu-ad.wvu.edu\public\ITS\Network and Voice Services\microsoft\HSC-Logs\
```

## PARAMETERS

### -NetworkLogPathRoot
{{ Fill NetworkLogPathRoot Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: \\hs.wvu-ad.wvu.edu\public\ITS\Network and Voice Services\microsoft\HSC-Logs\
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
Last Updated: November 17, 2021

## RELATED LINKS
