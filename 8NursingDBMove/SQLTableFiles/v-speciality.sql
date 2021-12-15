USE [SON]
GO

/****** Object:  Table [dbo].[v-specialty]    Script Date: 12/09/2021 16:23:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[v-specialty]') AND type in (N'U'))
DROP TABLE [dbo].[v-specialty]
GO

USE [SON]
GO

/****** Object:  Table [dbo].[v-specialty]    Script Date: 12/09/2021 16:23:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[v-specialty](
	[specialty] [varchar](100) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


