# Get-HSCEncryptedFilePath

## SYNOPSIS
Returns the path to the encrypted files used to establish O365 tenant connection

## SYNTAX

```
Get-HSCEncryptedFilePath [-UseSysscriptDefault] [[-ServerName] <String>] [[-UserName] <String>]
 [[-EncryptedDirectoryPath] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function assumes that the \GitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\
directory exists on the computer.
If it does, it will return the full path to it.

## EXAMPLES

### EXAMPLE 1
```
Get-HSCLoggedOnUser
```

UserName Domain
-------- ------
jbrus    DESKTOP-1MQ9DJO

PS C:\Users\jbrus\> Get-HSCEncryptedDirectoryPath
C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\
PS C:\Users\jbrus\> Get-HSCEncryptedFilePath
C:\HSCGitHub\HSC-PowerShell-Repository\1HSCCustomModules\EncryptedFiles\jbrus-DESKTOP-1MQ9DJO.txt

## PARAMETERS

### -UseSysscriptDefault
Forces the function to only process values contained in the SysscriptServers array

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

### -ServerName
The name of the server to get the encrypted file path

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Get-HSCServerName)
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
Name of the user who will be decrypting the file.
This must be
the same user who encrypted the file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: ((Get-HSCLoggedOnUser).UserName)
Accept pipeline input: False
Accept wildcard characters: False
```

### -EncryptedDirectoryPath
Path to where the encrypted files should be stored on the local machine

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: (Get-HSCEncryptedDirectoryPath)
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
Last Updated: February 17, 2021

PS Version 5.1 Tested:
- June 26, 2020
- February 17, 2021
PS Version 7.0.2 Tested: June 26, 2020
PS Version 7.1.2 Tested: February 17, 2021

## RELATED LINKS
