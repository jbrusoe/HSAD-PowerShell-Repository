USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-colleges]    Script Date: 12/09/2021 16:41:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[v-colleges]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[v-colleges]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-colleges]    Script Date: 12/09/2021 16:41:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[v-colleges](
	[college] [nvarchar](60) NOT NULL,
 CONSTRAINT [aaaaav-colleges_PK] PRIMARY KEY NONCLUSTERED 
(
	[college] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO


