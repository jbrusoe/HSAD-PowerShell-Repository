USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-ethnic]    Script Date: 12/09/2021 16:42:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[v-ethnic]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[v-ethnic]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-ethnic]    Script Date: 12/09/2021 16:42:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[v-ethnic](
	[code] [nvarchar](4) NOT NULL,
	[description] [nvarchar](50) NULL,
 CONSTRAINT [aaaaav-ethnic_PK] PRIMARY KEY NONCLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO


