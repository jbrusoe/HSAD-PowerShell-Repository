# Get-HSCRandomPassword

## SYNOPSIS
The purpose of this function is to generate a random password.

## SYNTAX

```
Get-HSCRandomPassword [[-PasswordLength] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
The password generated meets WVU password complexity requirements:
1.
Must be between 8 and 20 characters in length.
2.
Must contain characters from at least three
   of the following four categories:
	a.
Uppercase letters: A-Z
	b.
Lowercase letters: a-z
	c.
Numbers: 0-9
d.
Only these special characters: !
^ ?
: .
~ - _

## EXAMPLES

### EXAMPLE 1
```
Get-HSCRandomPassword
Fk]D%fE?pul\O4b1Y_)v
```

## PARAMETERS

### -PasswordLength
The length of the randomly generated password

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 20
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
Last Updated: April 5, 2021

## RELATED LINKS
