# Get-HSCGitHubRepoPath

## SYNOPSIS
This function returns the root path of the HSC GitHub repository

## SYNTAX

### SearchLocations (Default)
```
Get-HSCGitHubRepoPath [-FirstSearchLocations <String[]>] [-HSCRepositoryName <String>] [<CommonParameters>]
```

### TopLevelPath
```
Get-HSCGitHubRepoPath [-TopLevelPath <String>] [-HSCRepositoryName <String>] [<CommonParameters>]
```

## DESCRIPTION
The purpose of this function is to return the path to the root of the
GitHub repository.
This is done by looking for the .git directory
associated with the repository name (HSC-PowerShell-Repository).

## EXAMPLES

### EXAMPLE 1
```
Get-HSCGitHubRepoPath
C:\users\jbrus\OneDrive\Documents\GitHub\HSC-PowerShell-Repository\
```

### EXAMPLE 2
```
Get-HSCGitHubRepoPath -Verbose
VERBOSE: Beginning search for HSC GitHub Repo Path:
VERBOSE: GitHubDirectory: C:\users\jbrus\OneDrive\Documents\GitHub\HSC-PowerShell-Repository\.git
C:\users\jbrus\OneDrive\Documents\GitHub\HSC-PowerShell-Repository\
```

## PARAMETERS

### -FirstSearchLocations
This array provides the function with "hints" of where to start searching
for the GitHub repo path.
This is a way to help speed up the function.

```yaml
Type: String[]
Parameter Sets: SearchLocations
Aliases:

Required: False
Position: Named
Default value: @(
			"C:\users\Jeff\Documents\GitHub\HSC-PowerShell-Repository",
			"C:\users\jbrus\OneDrive\Documents\GitHub\HSC-PowerShell-Repository",
			"C:\users\microsoft\Documents\GitHub\HSC-PowerShell-Repository",
			"C:\Users\krussell\Documents\GitHub\HSC-PowerShell-Repository",
			"C:\Users\kevinadmin\Documents\Github\HSC-PowerShell-Repository"
		)
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -TopLevelPath
The path to search if the paths from the $FirstSearchLocations array
aren't found

```yaml
Type: String
Parameter Sets: TopLevelPath
Aliases:

Required: False
Position: Named
Default value: C:\users\
Accept pipeline input: False
Accept wildcard characters: False
```

### -HSCRepositoryName
The name of the HSC (or really any repository) to be searched for.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: HSC-PowerShell-Repository
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
Last Updated: March 16, 2021

PS Version 5.1 Tested: March 16, 2021
PS Version 7.1.3 Tested: March 16, 2021

## RELATED LINKS
