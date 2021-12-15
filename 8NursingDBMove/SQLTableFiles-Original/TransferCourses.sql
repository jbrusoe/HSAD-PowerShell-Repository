USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[HSC\srodman].[transfer courses_FK00]') AND parent_object_id = OBJECT_ID(N'[HSC\srodman].[transfer courses]'))
ALTER TABLE [HSC\srodman].[transfer courses] DROP CONSTRAINT [transfer courses_FK00]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__transfer __hours__3F7150CD]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[transfer courses] DROP CONSTRAINT [DF__transfer __hours__3F7150CD]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__transfer cou__QP__40657506]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[transfer courses] DROP CONSTRAINT [DF__transfer cou__QP__40657506]
END

GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[transfer courses]    Script Date: 12/09/2021 16:40:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[transfer courses]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[transfer courses]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[transfer courses]    Script Date: 12/09/2021 16:40:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[transfer courses](
	[id] [nvarchar](15) NOT NULL,
	[CRN] [nvarchar](8) NULL,
	[subj_code] [nvarchar](8) NOT NULL,
	[course #] [nvarchar](8) NOT NULL,
	[course title] [nvarchar](50) NOT NULL,
	[semester] [nvarchar](6) NOT NULL,
	[hours] [real] NULL,
	[grade] [nvarchar](4) NULL,
	[writing] [nvarchar](8) NULL,
	[QP] [real] NULL,
	[cluster] [nvarchar](4) NULL,
	[objective] [nvarchar](4) NULL,
 CONSTRAINT [aaaaatransfer courses_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[course title] ASC,
	[semester] ASC,
	[subj_code] ASC,
	[course #] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[transfer courses]  WITH NOCHECK ADD  CONSTRAINT [transfer courses_FK00] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
GO

ALTER TABLE [HSC\srodman].[transfer courses] NOCHECK CONSTRAINT [transfer courses_FK00]
GO

ALTER TABLE [HSC\srodman].[transfer courses] ADD  DEFAULT (0) FOR [hours]
GO

ALTER TABLE [HSC\srodman].[transfer courses] ADD  DEFAULT (0) FOR [QP]
GO


