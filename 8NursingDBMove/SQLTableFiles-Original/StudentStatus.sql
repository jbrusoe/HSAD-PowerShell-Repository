USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[HSC\srodman].[student status_FK00]') AND parent_object_id = OBJECT_ID(N'[HSC\srodman].[student status]'))
ALTER TABLE [HSC\srodman].[student status] DROP CONSTRAINT [student status_FK00]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__student s__not_f__49EEDF40]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[student status] DROP CONSTRAINT [DF__student s__not_f__49EEDF40]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__student s__athle__4AE30379]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[student status] DROP CONSTRAINT [DF__student s__athle__4AE30379]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__student s__Honor__4BD727B2]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[student status] DROP CONSTRAINT [DF__student s__Honor__4BD727B2]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__student s__Inter__4CCB4BEB]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[student status] DROP CONSTRAINT [DF__student s__Inter__4CCB4BEB]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__student s__Chang__4DBF7024]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[student status] DROP CONSTRAINT [DF__student s__Chang__4DBF7024]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__student s__seque__4EB3945D]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[student status] DROP CONSTRAINT [DF__student s__seque__4EB3945D]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__student s__accel__4FA7B896]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[student status] DROP CONSTRAINT [DF__student s__accel__4FA7B896]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__student s__comm___509BDCCF]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[student status] DROP CONSTRAINT [DF__student s__comm___509BDCCF]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__student s__pot_s__51900108]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[student status] DROP CONSTRAINT [DF__student s__pot_s__51900108]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__student s__direc__52842541]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[student status] DROP CONSTRAINT [DF__student s__direc__52842541]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_student status_First_gen]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[student status] DROP CONSTRAINT [DF_student status_First_gen]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_student status_Probation]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[student status] DROP CONSTRAINT [DF_student status_Probation]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_student status_stopout]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[student status] DROP CONSTRAINT [DF_student status_stopout]
END

GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[student status]    Script Date: 12/09/2021 16:39:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[student status]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[student status]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[student status]    Script Date: 12/09/2021 16:39:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[student status](
	[id] [nvarchar](15) NOT NULL,
	[start_date] [nvarchar](50) NOT NULL,
	[Grad_ term] [nvarchar](6) NULL,
	[status] [nvarchar](15) NULL,
	[Level] [nvarchar](20) NULL,
	[Major] [nvarchar](12) NULL,
	[not_full_time] [bit] NULL,
	[athletics] [bit] NULL,
	[Honors] [bit] NULL,
	[prog_completion] [nvarchar](12) NULL,
	[Prog_exit] [nvarchar](50) NULL,
	[comment] [ntext] NULL,
	[Program] [nvarchar](16) NULL,
	[Campus] [nvarchar](50) NULL,
	[International] [bit] NULL,
	[Change_level] [bit] NULL,
	[sequence] [bit] NULL,
	[Advisor] [nvarchar](50) NULL,
	[accelerated] [bit] NULL,
	[comm_serv] [float] NULL,
	[pot_state] [bit] NULL,
	[direct] [bit] NULL,
	[UG/G] [nvarchar](8) NULL,
	[Grad_Track] [nvarchar](8) NULL,
	[Grad-Op_Plan] [nvarchar](15) NULL,
	[Mentor] [nvarchar](50) NULL,
	[Break_semester] [nvarchar](50) NULL,
	[First_gen] [bit] NULL,
	[Probation] [bit] NULL,
	[TimeStamp] [timestamp] NULL,
	[stopout] [bit] NULL,
 CONSTRAINT [aaaaastudent status_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[start_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[student status]  WITH NOCHECK ADD  CONSTRAINT [student status_FK00] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
GO

ALTER TABLE [HSC\srodman].[student status] NOCHECK CONSTRAINT [student status_FK00]
GO

ALTER TABLE [HSC\srodman].[student status] ADD  DEFAULT (0) FOR [not_full_time]
GO

ALTER TABLE [HSC\srodman].[student status] ADD  DEFAULT (0) FOR [athletics]
GO

ALTER TABLE [HSC\srodman].[student status] ADD  DEFAULT (0) FOR [Honors]
GO

ALTER TABLE [HSC\srodman].[student status] ADD  DEFAULT (0) FOR [International]
GO

ALTER TABLE [HSC\srodman].[student status] ADD  DEFAULT (0) FOR [Change_level]
GO

ALTER TABLE [HSC\srodman].[student status] ADD  DEFAULT (0) FOR [sequence]
GO

ALTER TABLE [HSC\srodman].[student status] ADD  DEFAULT (0) FOR [accelerated]
GO

ALTER TABLE [HSC\srodman].[student status] ADD  DEFAULT (0) FOR [comm_serv]
GO

ALTER TABLE [HSC\srodman].[student status] ADD  DEFAULT (0) FOR [pot_state]
GO

ALTER TABLE [HSC\srodman].[student status] ADD  DEFAULT (0) FOR [direct]
GO

ALTER TABLE [HSC\srodman].[student status] ADD  CONSTRAINT [DF_student status_First_gen]  DEFAULT ((0)) FOR [First_gen]
GO

ALTER TABLE [HSC\srodman].[student status] ADD  CONSTRAINT [DF_student status_Probation]  DEFAULT ((0)) FOR [Probation]
GO

ALTER TABLE [HSC\srodman].[student status] ADD  CONSTRAINT [DF_student status_stopout]  DEFAULT ((0)) FOR [stopout]
GO


