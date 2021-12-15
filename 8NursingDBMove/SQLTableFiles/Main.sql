USE [SON2]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__MAIN__citizenshi__0A3E6E7F]') AND type = 'D')
BEGIN
ALTER TABLE [MAIN] DROP CONSTRAINT [DF__MAIN__citizenshi__0A3E6E7F]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__MAIN__citizenshi__0B3292B8]') AND type = 'D')
BEGIN
ALTER TABLE [MAIN] DROP CONSTRAINT [DF__MAIN__citizenshi__0B3292B8]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__MAIN__currently __0C26B6F1]') AND type = 'D')
BEGIN
ALTER TABLE [MAIN] DROP CONSTRAINT [DF__MAIN__currently __0C26B6F1]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__MAIN__disability__0D1ADB2A]') AND type = 'D')
BEGIN
ALTER TABLE [MAIN] DROP CONSTRAINT [DF__MAIN__disability__0D1ADB2A]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__MAIN__military__0E0EFF63]') AND type = 'D')
BEGIN
ALTER TABLE [MAIN] DROP CONSTRAINT [DF__MAIN__military__0E0EFF63]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__MAIN__country of__0F03239C]') AND type = 'D')
BEGIN
ALTER TABLE [MAIN] DROP CONSTRAINT [DF__MAIN__country of__0F03239C]
END

GO

USE [SON2]
GO

/****** Object:  Table [HSC\srodman].[MAIN]    Script Date: 12/09/2021 16:29:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[MAIN]') AND type in (N'U'))
DROP TABLE [MAIN]
GO

USE [SON2]
GO

/****** Object:  Table [HSC\srodman].[MAIN]    Script Date: 12/09/2021 16:29:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [MAIN](
	[id] [nvarchar](15) NOT NULL,
	[lname] [nvarchar](25) NULL,
	[fname] [nvarchar](20) NULL,
	[mname] [nvarchar](20) NULL,
	[maiden] [nvarchar](35) NULL,
	[suffix] [nvarchar](8) NULL,
	[title] [nvarchar](15) NULL,
	[dob] [datetime] NULL,
	[ethnic_code] [nvarchar](8) NULL,
	[citizenship] [nvarchar](8) NULL,
	[citizenship_status] [nvarchar](25) NULL,
	[visa_status] [nvarchar](8) NULL,
	[gender] [nvarchar](8) NULL,
	[currently married] [bit] NULL,
	[spouse] [nvarchar](50) NULL,
	[disability] [nvarchar](50) NULL,
	[military] [nvarchar](20) NULL,
	[comment] [ntext] NULL,
	[country of birth] [nvarchar](30) NULL,
	[alternate] [nvarchar](50) NULL,
	[e_mail] [nvarchar](50) NULL,
	[last_updated] [datetime] NULL,
	[updated_by] [nvarchar](6) NULL,
	[parents] [nvarchar](50) NULL,
	[relationship] [nvarchar](50) NULL,
 CONSTRAINT [aaaaaMAIN_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [MAIN] ADD  DEFAULT ('USA') FOR [citizenship]
GO

ALTER TABLE [MAIN] ADD  DEFAULT ('US Citizen') FOR [citizenship_status]
GO

ALTER TABLE [MAIN] ADD  DEFAULT (0) FOR [currently married]
GO

ALTER TABLE [MAIN] ADD  DEFAULT ('None stated') FOR [disability]
GO

ALTER TABLE [MAIN] ADD  DEFAULT ('N/A') FOR [military]
GO

ALTER TABLE [MAIN] ADD  DEFAULT ('USA') FOR [country of birth]
GO


