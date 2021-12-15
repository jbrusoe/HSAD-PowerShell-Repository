# Update-HSCPowerShellDocumentation

## SYNOPSIS
This function updates the documentation files for the functions
contained in the HSC PowerShell modules.

## SYNTAX

```
Update-HSCPowerShellDocumentation [[-ModuleNames] <String[]>] [[-RootOutputDirectory] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The purpose of this function is to automatically update the markdown
files for the HSC PowerShell modules.
It does this using the
platyPS module - https://github.com/PowerShell/platyPS

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ModuleNames
This parameter are the module names to generate the markdown files for.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: @(
			"HSC-CommonCodeModule",
			"HSC-ActiveDirectoryModule"
		)
Accept pipeline input: False
Accept wildcard characters: False
```

### -RootOutputDirectory
The root directory to place the markdown files.
It assumes that there is
a subdirectory contained here called Documentation.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Get-HSCGitHubRepoPath)
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
Last Updated: May 12, 2021

## RELATED LINKS
