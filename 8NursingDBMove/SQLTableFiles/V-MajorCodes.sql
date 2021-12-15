USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-major codes]    Script Date: 12/09/2021 16:42:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[v-major codes]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[v-major codes]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-major codes]    Script Date: 12/09/2021 16:42:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[v-major codes](
	[Major Code] [nvarchar](8) NULL,
	[Major Code Description] [nvarchar](255) NULL,
	[College] [nvarchar](255) NULL
) ON [PRIMARY]

GO


