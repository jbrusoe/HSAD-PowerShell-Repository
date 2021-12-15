# Add-HSCADUserO365BaseLicensingGroup

## SYNOPSIS
This function adds a user(s) to the Office 365 Base Licensing Group.

## SYNTAX

```
Add-HSCADUserO365BaseLicensingGroup [-SamAccountName] <String[]> [-BaseLicensingGroup <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This function adds a user(s) to the Office 365 Base Licensing Group
in Active Directory.
This group is the one that is used to license
users for Office 365.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -SamAccountName
An array of Sam Account Names that contain users to be added to the
Office 365 Base Licensing Group

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

### -BaseLicensingGroup
The name of the base licensing group.
This probably won't need to be changed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: M365 A3 for Faculty Licensing Group
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
Last Updated: July 26, 2021

## RELATED LINKS
