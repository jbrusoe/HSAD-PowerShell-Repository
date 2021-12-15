USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[HSC\srodman].[GPA by semester_FK00]') AND parent_object_id = OBJECT_ID(N'[HSC\srodman].[GPA by semester]'))
ALTER TABLE [HSC\srodman].[GPA by semester] DROP CONSTRAINT [GPA by semester_FK00]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__GPA by se__t_Cre__30641767]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[GPA by semester] DROP CONSTRAINT [DF__GPA by se__t_Cre__30641767]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__GPA by se__overa__31583BA0]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[GPA by semester] DROP CONSTRAINT [DF__GPA by se__overa__31583BA0]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__GPA by se__overa__324C5FD9]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[GPA by semester] DROP CONSTRAINT [DF__GPA by se__overa__324C5FD9]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__GPA by se__term___33408412]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[GPA by semester] DROP CONSTRAINT [DF__GPA by se__term___33408412]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__GPA by se__term___3434A84B]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[GPA by semester] DROP CONSTRAINT [DF__GPA by se__term___3434A84B]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__GPA by se__term___3528CC84]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[GPA by semester] DROP CONSTRAINT [DF__GPA by se__term___3528CC84]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__GPA by se__total__361CF0BD]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[GPA by semester] DROP CONSTRAINT [DF__GPA by se__total__361CF0BD]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__GPA by se__cur_G__371114F6]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[GPA by semester] DROP CONSTRAINT [DF__GPA by se__cur_G__371114F6]
END

GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[GPA by semester]    Script Date: 12/09/2021 16:33:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[GPA by semester]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[GPA by semester]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[GPA by semester]    Script Date: 12/09/2021 16:33:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[GPA by semester](
	[id] [nvarchar](15) NOT NULL,
	[semester] [nvarchar](8) NOT NULL,
	[t_Credit_hrs] [int] NULL,
	[overall_hrs] [int] NULL,
	[overall QP] [int] NULL,
	[term_hrs] [int] NULL,
	[term_qp] [int] NULL,
	[term_gpa] [float] NULL,
	[total_GPA_hrs] [int] NULL,
	[cur_GPA] [float] NULL,
 CONSTRAINT [aaaaaGPA by semester_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[semester] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[GPA by semester]  WITH NOCHECK ADD  CONSTRAINT [GPA by semester_FK00] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
GO

ALTER TABLE [HSC\srodman].[GPA by semester] NOCHECK CONSTRAINT [GPA by semester_FK00]
GO

ALTER TABLE [HSC\srodman].[GPA by semester] ADD  DEFAULT (0) FOR [t_Credit_hrs]
GO

ALTER TABLE [HSC\srodman].[GPA by semester] ADD  DEFAULT (0) FOR [overall_hrs]
GO

ALTER TABLE [HSC\srodman].[GPA by semester] ADD  DEFAULT (0) FOR [overall QP]
GO

ALTER TABLE [HSC\srodman].[GPA by semester] ADD  DEFAULT (0) FOR [term_hrs]
GO

ALTER TABLE [HSC\srodman].[GPA by semester] ADD  DEFAULT (0) FOR [term_qp]
GO

ALTER TABLE [HSC\srodman].[GPA by semester] ADD  DEFAULT (0) FOR [term_gpa]
GO

ALTER TABLE [HSC\srodman].[GPA by semester] ADD  DEFAULT (0) FOR [total_GPA_hrs]
GO

ALTER TABLE [HSC\srodman].[GPA by semester] ADD  DEFAULT (0) FOR [cur_GPA]
GO


