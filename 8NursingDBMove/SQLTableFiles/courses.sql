USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[HSC\srodman].[courses_FK00]') AND parent_object_id = OBJECT_ID(N'[HSC\srodman].[courses]'))
ALTER TABLE [HSC\srodman].[courses] DROP CONSTRAINT [courses_FK00]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__courses__hours__418EA369]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[courses] DROP CONSTRAINT [DF__courses__hours__418EA369]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__courses__QP__4282C7A2]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[courses] DROP CONSTRAINT [DF__courses__QP__4282C7A2]
END

GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[courses]    Script Date: 12/09/2021 16:33:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[courses]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[courses]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[courses]    Script Date: 12/09/2021 16:33:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[courses](
	[id] [nvarchar](15) NOT NULL,
	[CRN] [nvarchar](8) NOT NULL,
	[subj_code] [nvarchar](8) NULL,
	[Course #] [nvarchar](8) NULL,
	[course title] [nvarchar](50) NULL,
	[semester] [nvarchar](6) NOT NULL,
	[hours] [real] NULL,
	[grade] [nvarchar](4) NULL,
	[writing] [nvarchar](50) NULL,
	[QP] [real] NULL,
	[cluster] [nvarchar](8) NULL,
	[objective] [nvarchar](5) NULL,
	[section] [nvarchar](12) NULL,
 CONSTRAINT [aaaaacourses_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[CRN] ASC,
	[semester] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[courses]  WITH NOCHECK ADD  CONSTRAINT [courses_FK00] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
GO

ALTER TABLE [HSC\srodman].[courses] NOCHECK CONSTRAINT [courses_FK00]
GO

ALTER TABLE [HSC\srodman].[courses] ADD  CONSTRAINT [DF__courses__hours__418EA369]  DEFAULT (0) FOR [hours]
GO

ALTER TABLE [HSC\srodman].[courses] ADD  CONSTRAINT [DF__courses__QP__4282C7A2]  DEFAULT (0) FOR [QP]
GO


