USE [SON2]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Application_FK00]') AND parent_object_id = OBJECT_ID(N'[Application]'))
ALTER TABLE [Application] DROP CONSTRAINT [Application_FK00]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Application_id]') AND type = 'D')
BEGIN
ALTER TABLE [Application] DROP CONSTRAINT [DF_Application_id]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Applicati__gre_v__70499252]') AND type = 'D')
BEGIN
ALTER TABLE [Application] DROP CONSTRAINT [DF__Applicati__gre_v__70499252]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Applicati__gre_q__713DB68B]') AND type = 'D')
BEGIN
ALTER TABLE [Application] DROP CONSTRAINT [DF__Applicati__gre_q__713DB68B]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Applicati__gre_w__7231DAC4]') AND type = 'D')
BEGIN
ALTER TABLE [Application] DROP CONSTRAINT [DF__Applicati__gre_w__7231DAC4]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Applicati__Colle__7325FEFD]') AND type = 'D')
BEGIN
ALTER TABLE [Application] DROP CONSTRAINT [DF__Applicati__Colle__7325FEFD]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Applicati__Resid__741A2336]') AND type = 'D')
BEGIN
ALTER TABLE [Application] DROP CONSTRAINT [DF__Applicati__Resid__741A2336]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Applicati__state__750E476F]') AND type = 'D')
BEGIN
ALTER TABLE [Application] DROP CONSTRAINT [DF__Applicati__state__750E476F]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Applicati__count__76026BA8]') AND type = 'D')
BEGIN
ALTER TABLE [Application] DROP CONSTRAINT [DF__Applicati__count__76026BA8]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Application_applicant]') AND type = 'D')
BEGIN
ALTER TABLE [Application] DROP CONSTRAINT [DF_Application_applicant]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Application_materials]') AND type = 'D')
BEGIN
ALTER TABLE [Application] DROP CONSTRAINT [DF_Application_materials]
END

GO

USE [SON2]
GO

/****** Object:  Table [Application]    Script Date: 12/09/2021 16:26:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Application]') AND type in (N'U'))
DROP TABLE [Application]
GO

USE [SON2]
GO

/****** Object:  Table [Application]    Script Date: 12/09/2021 16:26:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Application](
	[id] [nvarchar](15) NOT NULL,
	[app_date] [datetime] NOT NULL,
	[decision_date] [datetime] NULL,
	[decision] [nvarchar](50) NULL,
	[Proposed start date] [nvarchar](12) NULL,
	[gre_date] [nvarchar](50) NULL,
	[gre_verbal] [real] NULL,
	[gre_quantative] [real] NULL,
	[gre_writing] [real] NULL,
	[degree_sought] [nvarchar](20) NULL,
	[College] [nvarchar](20) NULL,
	[Highest] [nvarchar](20) NULL,
	[Resident] [bit] NULL,
	[reason] [nvarchar](50) NULL,
	[county] [nvarchar](20) NULL,
	[state] [nvarchar](3) NULL,
	[country] [nvarchar](50) NULL,
	[Intended_spec] [nvarchar](50) NULL,
	[provisional info] [nvarchar](50) NULL,
	[adm_adv] [nvarchar](50) NULL,
	[highest_nursing] [nvarchar](15) NULL,
	[applicant] [bit] NULL,
	[app_campus] [nvarchar](50) NULL,
	[comment] [ntext] NULL,
	[materials] [bit] NULL,
	[adm_type] [nvarchar](15) NULL,
	[deposit_status] [nvarchar](10) NULL,
	[deposit_date] [datetime] NULL,
 CONSTRAINT [aaaaaApplication_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[app_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [Application]  WITH NOCHECK ADD  CONSTRAINT [Application_FK00] FOREIGN KEY([id])
REFERENCES [MAIN] ([id])
GO

ALTER TABLE [Application] NOCHECK CONSTRAINT [Application_FK00]
GO

ALTER TABLE [Application] ADD  CONSTRAINT [DF_Application_id]  DEFAULT ((0)) FOR [id]
GO

ALTER TABLE [Application] ADD  CONSTRAINT [DF__Applicati__gre_v__70499252]  DEFAULT ((0)) FOR [gre_verbal]
GO

ALTER TABLE [Application] ADD  CONSTRAINT [DF__Applicati__gre_q__713DB68B]  DEFAULT ((0)) FOR [gre_quantative]
GO

ALTER TABLE [Application] ADD  CONSTRAINT [DF__Applicati__gre_w__7231DAC4]  DEFAULT ((0)) FOR [gre_writing]
GO

ALTER TABLE [Application] ADD  CONSTRAINT [DF__Applicati__Colle__7325FEFD]  DEFAULT ('SON') FOR [College]
GO

ALTER TABLE [Application] ADD  CONSTRAINT [DF__Applicati__Resid__741A2336]  DEFAULT ((0)) FOR [Resident]
GO

ALTER TABLE [Application] ADD  CONSTRAINT [DF__Applicati__state__750E476F]  DEFAULT ('WV') FOR [state]
GO

ALTER TABLE [Application] ADD  CONSTRAINT [DF__Applicati__count__76026BA8]  DEFAULT ('USA') FOR [country]
GO

ALTER TABLE [Application] ADD  CONSTRAINT [DF_Application_applicant]  DEFAULT ((0)) FOR [applicant]
GO

ALTER TABLE [Application] ADD  CONSTRAINT [DF_Application_materials]  DEFAULT ((0)) FOR [materials]
GO


