# Get-HSCPasswordFromSecureStringFile

## SYNOPSIS
The purpose of this function is to decrypt a secure string file to
handle user authentication to Office 365 or other HSC protected environments.

## SYNTAX

```
Get-HSCPasswordFromSecureStringFile [[-PWFile] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function decrypts a secure string file in order to use that
for authentication.
In order to decrypt it, the file must have
been encrypted on the same machine with the same logged in user
used as the one being used for decryption.
There are also options
to change the secure string file as well as prompt the user for credentials.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -PWFile
The path to the password file that is to be decrypted

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Get-HSCEncryptedFilePath)
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
Last Updated: June 23, 2020

PS Version 5.1 Tested: June 30, 2020
PS Version 7.0.2 Tested: June 30, 2020

## RELATED LINKS
