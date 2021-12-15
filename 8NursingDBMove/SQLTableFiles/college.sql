USE [SON2]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[college_FK00]') AND parent_object_id = OBJECT_ID(N'[college]'))
ALTER TABLE [college] DROP CONSTRAINT [college_FK00]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__college__last GP__47477CBF]') AND type = 'D')
BEGIN
ALTER TABLE [college] DROP CONSTRAINT [DF__college__last GP__47477CBF]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__college__transfe__483BA0F8]') AND type = 'D')
BEGIN
ALTER TABLE [college] DROP CONSTRAINT [DF__college__transfe__483BA0F8]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__college__transfe__492FC531]') AND type = 'D')
BEGIN
ALTER TABLE [college] DROP CONSTRAINT [DF__college__transfe__492FC531]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__college__credit __4A23E96A]') AND type = 'D')
BEGIN
ALTER TABLE [college] DROP CONSTRAINT [DF__college__credit __4A23E96A]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__college__GPA cre__4B180DA3]') AND type = 'D')
BEGIN
ALTER TABLE [college] DROP CONSTRAINT [DF__college__GPA cre__4B180DA3]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__college__quality__4C0C31DC]') AND type = 'D')
BEGIN
ALTER TABLE [college] DROP CONSTRAINT [DF__college__quality__4C0C31DC]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__college__WVU_fre__4D005615]') AND type = 'D')
BEGIN
ALTER TABLE [college] DROP CONSTRAINT [DF__college__WVU_fre__4D005615]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__college__RN__4DF47A4E]') AND type = 'D')
BEGIN
ALTER TABLE [college] DROP CONSTRAINT [DF__college__RN__4DF47A4E]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__college__P/F hou__4EE89E87]') AND type = 'D')
BEGIN
ALTER TABLE [college] DROP CONSTRAINT [DF__college__P/F hou__4EE89E87]
END

GO

USE [SON2]
GO

/****** Object:  Table [college]    Script Date: 12/09/2021 16:30:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[college]') AND type in (N'U'))
DROP TABLE [college]
GO

USE [SON2]
GO

/****** Object:  Table [college]    Script Date: 12/09/2021 16:30:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [college](
	[id] [nvarchar](15) NOT NULL,
	[entry date] [datetime] NOT NULL,
	[level] [nvarchar](10) NULL,
	[termination date] [datetime] NULL,
	[college_name] [nvarchar](65) NULL,
	[degree] [nvarchar](20) NULL,
	[last GPA] [real] NULL,
	[transfer credit hours] [real] NULL,
	[transfer quality hours] [int] NULL,
	[credit hours earned] [real] NULL,
	[GPA credit hours] [real] NULL,
	[quality poinrts] [real] NULL,
	[major] [nvarchar](50) NULL,
	[minor] [nvarchar](50) NULL,
	[advisor] [nvarchar](50) NULL,
	[exit status] [nvarchar](30) NULL,
	[WVU_freshman] [bit] NULL,
	[RN] [bit] NULL,
	[Comment] [ntext] NULL,
	[P/F hours] [int] NULL,
 CONSTRAINT [aaaaacollege_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[entry date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [college]  WITH NOCHECK ADD  CONSTRAINT [college_FK00] FOREIGN KEY([id])
REFERENCES [MAIN] ([id])
GO

ALTER TABLE [college] NOCHECK CONSTRAINT [college_FK00]
GO

ALTER TABLE [college] ADD  DEFAULT (0) FOR [last GPA]
GO

ALTER TABLE [college] ADD  DEFAULT (0) FOR [transfer credit hours]
GO

ALTER TABLE [college] ADD  DEFAULT (0) FOR [transfer quality hours]
GO

ALTER TABLE [college] ADD  DEFAULT (0) FOR [credit hours earned]
GO

ALTER TABLE [college] ADD  DEFAULT (0) FOR [GPA credit hours]
GO

ALTER TABLE [college] ADD  DEFAULT (0) FOR [quality poinrts]
GO

ALTER TABLE [college] ADD  DEFAULT (0) FOR [WVU_freshman]
GO

ALTER TABLE [college] ADD  DEFAULT (0) FOR [RN]
GO

ALTER TABLE [college] ADD  DEFAULT (0) FOR [P/F hours]
GO


