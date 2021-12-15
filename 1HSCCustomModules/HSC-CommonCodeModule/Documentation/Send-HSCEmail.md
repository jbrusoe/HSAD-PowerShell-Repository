# Send-HSCEmail

## SYNOPSIS
This function is used to send email from HSC PowerShell files

## SYNTAX

```
Send-HSCEmail [-To] <String[]> [[-From] <String>] [-Subject] <String> [-MessageBody] <String>
 [[-Attachments] <String[]>] [[-SMTPServer] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The purpose of this function is to serve as a wrapper for the
Send-MailMessage cmdlet.
It was originally written to make it easier
to decrypt the password to send email.
However, this isn't necessary anymore,
so this function is here for legacy purposes now.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -To
Specifies the email recipient

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -From
Specifies the email sender

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Microsoft@hsc.wvu.edu
Accept pipeline input: False
Accept wildcard characters: False
```

### -Subject
Specifies the email subject

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MessageBody
A string which is the email message body

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Attachments
The path (or array of paths) to the attachments which will be sent

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SMTPServer
The IP address of the SMTP relay server.
The default is hssmtp.hsc.wvu.edu

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: Hssmtp.hsc.wvu.edu
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

### System.bool
## NOTES
Written by: Jeff Brusoe
Last Updated by: Jeff Brusoe
Last Updated: April 21, 2021

## RELATED LINKS
