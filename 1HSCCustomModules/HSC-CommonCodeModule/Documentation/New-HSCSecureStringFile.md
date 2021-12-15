# New-HSCSecureStringFile

## SYNOPSIS
This function generates a new secure string file.

## SYNTAX

```
New-HSCSecureStringFile [[-OutputDirectoryPath] <String>] [[-UserName] <String>] [[-ServerName] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function generates a new secure string file.
By default, it is stores in the
1HSCCustomModules\EncryptedFiles directory with a name of \<Username\>-\<ServerName\>.txt

## EXAMPLES

### EXAMPLE 1
```
New-HSCSecureStringFile
Creating new secure string file
Username: jbrus
Computer Name: DESKTOP-1MQ9DJO
Enter Current Password: ***********
True
```

### EXAMPLE 2
```
New-HSCSecureStringFile -WhatIf
Creating new secure string file
Username: jbrus
Computer Name: DESKTOP-1MQ9DJO
Output File: C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\\jbrus-DESKTOP-1MQ9DJO.txt
```

What if: Performing the operation "Overwriting file" on target "C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\\\\jbrus-DESKTOP-1MQ9DJO.txt".
Enter Current Password: ************
What if: Performing the operation "Output to File" on target "C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\\\\jbrus-DESKTOP-1MQ9DJO.txt".
True

### EXAMPLE 3
```
New-HSCSecureStringFile -Confirm
Creating new secure string file
Username: jbrus
Computer Name: DESKTOP-1MQ9DJO
Output File: C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\\jbrus-DESKTOP-1MQ9DJO.txt
```

Confirm
Are you sure you want to perform this action?
Performing the operation "Overwriting file" on target
"C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\\\\jbrus-DESKTOP-1MQ9DJO.txt".
\[Y\] Yes  \[A\] Yes to All  \[N\] No  \[L\] No to All  \[S\] Suspend  \[?\] Help (default is "Y"): y
Enter Current Password: ************

Confirm
Are you sure you want to perform this action?
Performing the operation "Output to File" on target
"C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\\\\jbrus-DESKTOP-1MQ9DJO.txt".
\[Y\] Yes  \[A\] Yes to All  \[N\] No  \[L\] No to All  \[S\] Suspend  \[?\] Help (default is "Y"): y
True

## PARAMETERS

### -OutputDirectoryPath
{{ Fill OutputDirectoryPath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Get-HSCEncryptedDirectoryPath)
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
{{ Fill UserName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $((Get-HSCLoggedOnUser).UserName)
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServerName
{{ Fill ServerName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: ComputerName

Required: False
Position: 3
Default value: $(Get-HSCServerName)
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

### There are two outputs generated from this function:
### 1.  A boolean value indicating whether the function was successful in creating
### 	the secure string file.
### 2. 	The actual secure string file located in 1HSCCustomModules/EncryptedFiles
## NOTES
Written by: Jeff Brusoe
Last Updated: June 30, 2020

PS Version 5.1 Tested: June 29, 2020
PS Version 7.0.2 Tested: June 29, 2020

## RELATED LINKS
