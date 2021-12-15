USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[HSC\srodman].[High school_FK00]') AND parent_object_id = OBJECT_ID(N'[HSC\srodman].[High school]'))
ALTER TABLE [HSC\srodman].[High school] DROP CONSTRAINT [High school_FK00]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__High scho__state__1E45672C]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[High school] DROP CONSTRAINT [DF__High scho__state__1E45672C]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__High scho__count__1F398B65]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[High school] DROP CONSTRAINT [DF__High scho__count__1F398B65]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__High scho__GPA_o__202DAF9E]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[High school] DROP CONSTRAINT [DF__High scho__GPA_o__202DAF9E]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__High scho__ACT_m__2121D3D7]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[High school] DROP CONSTRAINT [DF__High scho__ACT_m__2121D3D7]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__High scho__ACT_s__2215F810]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[High school] DROP CONSTRAINT [DF__High scho__ACT_s__2215F810]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__High scho__ACT_e__230A1C49]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[High school] DROP CONSTRAINT [DF__High scho__ACT_e__230A1C49]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__High scho__SAT_o__23FE4082]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[High school] DROP CONSTRAINT [DF__High scho__SAT_o__23FE4082]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__High scho__SAT_m__24F264BB]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[High school] DROP CONSTRAINT [DF__High scho__SAT_m__24F264BB]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__High scho__SAT_v__25E688F4]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[High school] DROP CONSTRAINT [DF__High scho__SAT_v__25E688F4]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__High scho__ACT_c__26DAAD2D]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[High school] DROP CONSTRAINT [DF__High scho__ACT_c__26DAAD2D]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__High scho__ACT_r__27CED166]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[High school] DROP CONSTRAINT [DF__High scho__ACT_r__27CED166]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__High scho__SAT_w__28C2F59F]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[High school] DROP CONSTRAINT [DF__High scho__SAT_w__28C2F59F]
END

GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[High school]    Script Date: 12/09/2021 16:34:13 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[High school]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[High school]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[High school]    Script Date: 12/09/2021 16:34:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[High school](
	[id] [nvarchar](15) NOT NULL,
	[name] [nvarchar](50) NULL,
	[county] [nvarchar](30) NULL,
	[state] [nvarchar](2) NULL,
	[country] [nvarchar](50) NULL,
	[GPA_overall] [real] NULL,
	[ACT_math] [real] NULL,
	[ACT_sci_reason] [real] NULL,
	[ACT_english] [real] NULL,
	[SAT_overall] [real] NULL,
	[SAT_math] [real] NULL,
	[SAT_verbal] [real] NULL,
	[ACT_composite] [real] NULL,
	[Class standing] [nvarchar](50) NULL,
	[grad_year] [nvarchar](50) NULL,
	[exit_status] [nvarchar](15) NULL,
	[ACT_read] [real] NULL,
	[SAT_writing] [real] NULL,
	[ACT_writing] [real] NULL,
	[class_rank] [real] NULL,
	[class_size] [real] NULL,
	[RSAT_EBRW] [real] NULL,
	[RSAT_Math] [real] NULL,
	[RSAT_Total] [real] NULL,
 CONSTRAINT [aaaaaHigh school_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[High school]  WITH NOCHECK ADD  CONSTRAINT [High school_FK00] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
GO

ALTER TABLE [HSC\srodman].[High school] NOCHECK CONSTRAINT [High school_FK00]
GO

ALTER TABLE [HSC\srodman].[High school] ADD  DEFAULT ('WV') FOR [state]
GO

ALTER TABLE [HSC\srodman].[High school] ADD  DEFAULT ('USA') FOR [country]
GO

ALTER TABLE [HSC\srodman].[High school] ADD  DEFAULT (0) FOR [GPA_overall]
GO

ALTER TABLE [HSC\srodman].[High school] ADD  DEFAULT (0) FOR [ACT_math]
GO

ALTER TABLE [HSC\srodman].[High school] ADD  DEFAULT (0) FOR [ACT_sci_reason]
GO

ALTER TABLE [HSC\srodman].[High school] ADD  DEFAULT (0) FOR [ACT_english]
GO

ALTER TABLE [HSC\srodman].[High school] ADD  DEFAULT (0) FOR [SAT_overall]
GO

ALTER TABLE [HSC\srodman].[High school] ADD  DEFAULT (0) FOR [SAT_math]
GO

ALTER TABLE [HSC\srodman].[High school] ADD  DEFAULT (0) FOR [SAT_verbal]
GO

ALTER TABLE [HSC\srodman].[High school] ADD  DEFAULT (0) FOR [ACT_composite]
GO

ALTER TABLE [HSC\srodman].[High school] ADD  DEFAULT (0) FOR [ACT_read]
GO

ALTER TABLE [HSC\srodman].[High school] ADD  DEFAULT (0) FOR [SAT_writing]
GO


