USE [SON]
GO

/****** Object:  Table [HSC\srodman].[academic action]    Script Date: 12/09/2021 16:25:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[academic action]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[academic action]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[academic action]    Script Date: 12/09/2021 16:25:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[academic action](
	[id] [nvarchar](50) NOT NULL,
	[date] [nvarchar](50) NOT NULL,
 CONSTRAINT [aaaaaacademic action_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO


