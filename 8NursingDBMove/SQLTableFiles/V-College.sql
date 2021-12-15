USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-college]    Script Date: 12/09/2021 16:41:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[v-college]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[v-college]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-college]    Script Date: 12/09/2021 16:41:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[v-college](
	[college] [nvarchar](50) NOT NULL,
 CONSTRAINT [aaaaav-college_PK] PRIMARY KEY NONCLUSTERED 
(
	[college] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO


