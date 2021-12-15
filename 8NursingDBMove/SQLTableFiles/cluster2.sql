USE [SON2]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster2__asteri__577DE488]') AND type = 'D')
BEGIN
ALTER TABLE [cluster2] DROP CONSTRAINT [DF__cluster2__asteri__577DE488]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster2__plus__587208C1]') AND type = 'D')
BEGIN
ALTER TABLE [cluster2] DROP CONSTRAINT [DF__cluster2__plus__587208C1]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster2__NR__59662CFA]') AND type = 'D')
BEGIN
ALTER TABLE [cluster2] DROP CONSTRAINT [DF__cluster2__NR__59662CFA]
END

GO

USE [SON2]
GO

/****** Object:  Table [cluster2]    Script Date: 12/09/2021 16:27:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[cluster2]') AND type in (N'U'))
DROP TABLE [cluster2]
GO

USE [SON2]
GO

/****** Object:  Table [cluster2]    Script Date: 12/09/2021 16:27:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [cluster2](
	[cluster] [nvarchar](255) NULL,
	[dept] [nvarchar](255) NULL,
	[dept_abv] [nvarchar](255) NULL,
	[course#] [nvarchar](255) NULL,
	[asterix] [bit] NULL,
	[plus] [bit] NULL,
	[NR] [bit] NULL
) ON [PRIMARY]

GO

ALTER TABLE [cluster2] ADD  DEFAULT (0) FOR [asterix]
GO

ALTER TABLE [cluster2] ADD  DEFAULT (0) FOR [plus]
GO

ALTER TABLE [cluster2] ADD  DEFAULT (0) FOR [NR]
GO


