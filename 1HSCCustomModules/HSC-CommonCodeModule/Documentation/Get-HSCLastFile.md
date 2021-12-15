# Get-HSCLastFile

## SYNOPSIS
Returns the last x number of files from a directory

## SYNTAX

```
Get-HSCLastFile [-DirectoryPath] <String> [[-NumberOfFiles] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
This function searches a directory and returns the last
$NumberOfFiles based on the last write time

## EXAMPLES

### EXAMPLE 1
```
dir -file | sort lastwritetime
```

Directory: C:\users\jbrus\OneDrive\Documents\GitHub\HSC-PowerShell-Repository


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---l          2/3/2021  11:19 AM            227 .gitignore
-a---l          2/3/2021  11:19 AM           3313 DisableAccountProcess.md
-a---l          2/3/2021  11:19 AM            367 HSCExclusionList.md
-a---l          2/3/2021  11:19 AM           1759 README.md
-a---l          2/4/2021   1:58 PM           2408 WVUHSCPowerShellCodingStandards.md
-a---l          2/5/2021   3:09 PM           1180 ADExtensionAttributes.md
-a---l         2/17/2021   4:12 PM           4487 PowerShellDevelopmentGoals.md
-a---l         3/10/2021   3:35 PM            792 PSSavedLinks.md
-a---l         3/15/2021   4:16 PM          17887 HSCPowerShellSummaryFile.md
-a---l         3/15/2021   4:16 PM           8681 ScheduledTaskSummary.md

Get-HSCLastFile -DirectoryPath .
C:\users\jbrus\OneDrive\Documents\GitHub\HSC-PowerShell-Repository\ScheduledTaskSummary.md

## PARAMETERS

### -DirectoryPath
The path to the directory to be searched

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -NumberOfFiles
Specifies the number of files to return

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String[]
## NOTES
Written by: Jeff Brusoe
Last Update: March 29, 2021

## RELATED LINKS
