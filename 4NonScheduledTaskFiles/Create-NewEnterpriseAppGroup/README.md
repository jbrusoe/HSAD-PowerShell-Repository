## Create-NewEnterpriseAppGroups.ps1

**Written by:** Kim Rodney<br>
**Last Updated:** August 4, 2020<br>
**Server:** <br>
**Scheduled Task:** To be determined<br>

**Purpose:** This file creates new Azure security groups based on a list of Enterprise App names.

**Files
	**Add-UsersToEnterpriseAppGroup.ps1 - Adds users from List.Assignment to App.Group (incomplete)
	**Create-NewEnterpriseAppGroups.ps1 - Created new Azure security groups for each enterprise app that I found not using groups for assignments
	**EnterpriseApps.xlsx - Excel file of app and group data
		**Lists - Get-AzureADServicePrincipal -all:$True
		**App2Group - App to Group mapping
	**NewGroups - New groups creating during this wave
	**GroupNames.csv - template of csv for Create-NewEnterpriseAppGroups.ps1
	**README.md - this file