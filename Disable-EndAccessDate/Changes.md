#Disable-EndAccessDate.ps1
#
#Written by: Jeff Brusoe
#Last Modified: January 21, 2020
#Version: 2.0
#
#This file searches all users in the HS domain to look at their end access date (extensionAttribute1).
#For any users with an end access date that has passed, the account is disabled. See description block
#below for summary of what happens at various dates past the end access date.
#
#This file assumes a connection to Office 365 has been established. If it isn't, then it will 
#look for the Connect-ToOffice365-MS3.ps1 file to attempt a connection.

#Version Updates:
#October 4, 2019
#	- Moved to GitHub directory & scheduled task
#	- Changed to new common parameters
#
#November 8, 2019
#	- Began writing data to SQL instance in Office 365
#
#January 2020
#	- Implemented automatic deletions of accounts
#	- Further testing and changes with writing to database
#	- Added primary SMTP address to DB
#	- Added original OU to DB
#	- Switched to AzureAD cmdlets