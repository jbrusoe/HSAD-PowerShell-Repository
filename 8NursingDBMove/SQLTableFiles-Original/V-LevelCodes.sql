USE [SON]
GO

/****** Object:  Table [HSC\srodman].[V-Level Codes]    Script Date: 12/09/2021 16:42:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[V-Level Codes]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[V-Level Codes]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[V-Level Codes]    Script Date: 12/09/2021 16:42:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[V-Level Codes](
	[Level_Type] [nvarchar](5) NULL,
	[Level_Description] [nvarchar](50) NULL,
	[Academic_Level] [nvarchar](50) NULL
) ON [PRIMARY]

GO


