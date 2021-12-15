WITH cte AS (
    SELECT 
      PrimarySMTPAddress,
	  ISEnabled,
        ROW_NUMBER() OVER (
            PARTITION BY 
				PrimarySMTPAddress,
				IsEnabled
            ORDER BY 
				PrimarySMTPAddress,
				IsEnabled
        ) row_num
     FROM 
       MailboxClutterInfo
)
DELETE FROM cte
WHERE row_num > 1;