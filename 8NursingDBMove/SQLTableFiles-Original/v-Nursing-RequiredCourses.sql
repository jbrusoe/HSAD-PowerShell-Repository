USE [SON]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__V-Nursing__nursi__1486F2C8]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[V-Nursing - required courses] DROP CONSTRAINT [DF__V-Nursing__nursi__1486F2C8]
END

GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[V-Nursing - required courses]    Script Date: 12/09/2021 16:43:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[V-Nursing - required courses]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[V-Nursing - required courses]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[V-Nursing - required courses]    Script Date: 12/09/2021 16:43:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[V-Nursing - required courses](
	[dept abv] [nvarchar](255) NULL,
	[course #] [nvarchar](255) NULL,
	[course_Level] [nvarchar](255) NULL,
	[sort_level] [nvarchar](50) NULL,
	[nursing_requirement] [bit] NULL
) ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[V-Nursing - required courses] ADD  DEFAULT (0) FOR [nursing_requirement]
GO


