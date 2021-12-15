USE [SON]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__v-masters__semes__185783AC]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[v-masters program] DROP CONSTRAINT [DF__v-masters__semes__185783AC]
END

GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-masters program]    Script Date: 12/09/2021 16:43:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[v-masters program]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[v-masters program]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-masters program]    Script Date: 12/09/2021 16:43:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[v-masters program](
	[Track] [nvarchar](255) NULL,
	[option] [nvarchar](255) NULL,
	[course#] [nvarchar](8) NULL,
	[title] [nvarchar](255) NULL,
	[hrs] [float] NULL,
	[Year] [float] NULL,
	[Semester] [nvarchar](255) NULL,
	[semester #] [smallint] NULL
) ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[v-masters program] ADD  DEFAULT (0) FOR [semester #]
GO


