USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-counties]    Script Date: 12/09/2021 16:42:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[v-counties]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[v-counties]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-counties]    Script Date: 12/09/2021 16:42:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[v-counties](
	[County] [nvarchar](40) NOT NULL,
 CONSTRAINT [aaaaav-counties_PK] PRIMARY KEY NONCLUSTERED 
(
	[County] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO


