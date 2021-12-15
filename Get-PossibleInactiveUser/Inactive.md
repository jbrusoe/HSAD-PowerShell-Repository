1. If PwdLastSet within last year AND <br>
    LastLogon within last year AND<br>
    Valid end access date -> Active
    
2. If PwdLastSet over 1 year ago AND<br>
    Enabled = true AND<br>
    LastLogon is within last year -> Resource Account

3. If ext10 not equal to TRUE/FALSE -> Resource Account

4. If PwdLastSet over 1 year ago AND<br>
    LastLogon is over 1 year ago -> Inactive

5. If Current Date > ext1 -> Inactive><br>

6. If in Inactive/Deleted OU -> Inactive<br>

For Cloud - Check LastDirSyncTime
