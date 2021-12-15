USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-advisors]    Script Date: 12/09/2021 16:40:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[v-advisors]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[v-advisors]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-advisors]    Script Date: 12/09/2021 16:40:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[v-advisors](
	[advisor] [nvarchar](50) NULL
) ON [PRIMARY]

GO


