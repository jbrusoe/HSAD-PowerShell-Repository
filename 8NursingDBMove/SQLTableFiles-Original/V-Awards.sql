USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-awards]    Script Date: 12/09/2021 16:41:13 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[v-awards]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[v-awards]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-awards]    Script Date: 12/09/2021 16:41:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[v-awards](
	[award] [nvarchar](50) NULL
) ON [PRIMARY]

GO


