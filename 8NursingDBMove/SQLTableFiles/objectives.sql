USE [SON]
GO

/****** Object:  Table [HSC\srodman].[objectives]    Script Date: 12/09/2021 16:35:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[objectives]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[objectives]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[objectives]    Script Date: 12/09/2021 16:35:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[objectives](
	[Objective] [nvarchar](255) NULL,
	[Subj code] [nvarchar](15) NULL,
	[course#] [nvarchar](8) NULL,
	[group] [nvarchar](255) NULL,
	[obj] [float] NULL
) ON [PRIMARY]

GO


