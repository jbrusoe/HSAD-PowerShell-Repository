## HSC-Office365Module.psm1

#### Summary
This module contains functions related to establishing a connection to Office 365 and Exchange Online.

**Functions used for establishing connection to Office 365**
| | Function Name | Function Summary |
| :--- | :------------- | :--- |
| 1. | Connect-HSCOffice365 | |
| 2. | Connect-HSCOffice365MSOL | |
| 3. | Connect-MainCampusOffice365 | |
| 4. | Connect-MainCampusOffice365MSOL | |
| 5. | Connect-WVUFoundationOffice365 | |
| 6. | Connect-WVUFoundationOffice365MSOL | |
| 7. | Get-HSCConnectionAccount | |
| 8. | Test-HSCOffice365Connection | |
| 9. | Test-HSCConnectionRequirement | |

**Functions used to establish connection to Exchange Online**
| | Function Name | Function Summary |
| :--- | :------------- | :--- |
| 1. | Connect-HSCExchangeOnline | |


		Functions used to establish connection to Exchange Online
		1. Connect-HSCExchangeOnline (Exchange Online V2 & V1)
		2. Connect-HSCExchangeOnlineV1 (Exchange Online V1 Only)
		3. Connect-MainCampusExchangeOnline(Connect to main campus Exchange Online) *
		4. Connect-WVUFoundationExchangeOnline (Connect to WVU Foundation Exchange Online) *
		5. Test-HSCExchangeOnlineConnection *
		6. Test-HSCExchangeOnlineConnectionRequirement *

		Functions for AzureAD/MSOnline (* = Funcdtion to be implemented)
		1. Get-HSCGlobalAdminMember
		2. Get-HSCRoleMember
		3. Get-TenantName
		4. Get-TenantNameMSOL
		5. Get-UserLicense *
		6. Set-UserLicense *
		7. Set-BlockCredential (MSOL) *
		8. Enable-HSCCloudUser (AzureAD) *
		9. Disable-HSCCloudUser (AzureAD) *
		10. Set-HSCCommonUserParameter *

		Functions for ExchangeOnline (* = Function to be implemented)
		1. Get-O365MailboxStatus
		2. Disable-HSCIMAP *
		3. Disable-HSCPOP *
		4. Set-HSCCommonExchangeOnlineParameter *
