USE [SON]
GO

/****** Object:  Table [dbo].[TestImport]    Script Date: 12/09/2021 16:14:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestImport]') AND type in (N'U'))
DROP TABLE [dbo].[TestImport]
GO

USE [SON]
GO

/****** Object:  Table [dbo].[TestImport]    Script Date: 12/09/2021 16:14:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TestImport](
	[Track] [nvarchar](255) NULL,
	[option] [nvarchar](255) NULL,
	[course#] [nvarchar](255) NULL,
	[title] [nvarchar](255) NULL,
	[hrs] [float] NULL,
	[Year] [float] NULL,
	[Semester] [nvarchar](255) NULL,
	[semester #] [float] NULL
) ON [PRIMARY]

GO


  