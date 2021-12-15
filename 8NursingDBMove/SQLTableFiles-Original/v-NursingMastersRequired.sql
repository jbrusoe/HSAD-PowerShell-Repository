USE [SON]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__V-Nursing M__PNP__0A096455]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[V-Nursing Masters required] DROP CONSTRAINT [DF__V-Nursing M__PNP__0A096455]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__V-Nursing M__FNP__0AFD888E]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[V-Nursing Masters required] DROP CONSTRAINT [DF__V-Nursing M__FNP__0AFD888E]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__V-Nursing M__NNP__0BF1ACC7]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[V-Nursing Masters required] DROP CONSTRAINT [DF__V-Nursing M__NNP__0BF1ACC7]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__V-Nursing M__DSN__0CE5D100]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[V-Nursing Masters required] DROP CONSTRAINT [DF__V-Nursing M__DSN__0CE5D100]
END

GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[V-Nursing Masters required]    Script Date: 12/09/2021 16:43:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[V-Nursing Masters required]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[V-Nursing Masters required]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[V-Nursing Masters required]    Script Date: 12/09/2021 16:43:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[V-Nursing Masters required](
	[dept abv] [nvarchar](255) NULL,
	[course #] [nvarchar](255) NULL,
	[PNP] [bit] NULL,
	[FNP] [bit] NULL,
	[NNP] [bit] NULL,
	[DSN] [bit] NULL
) ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[V-Nursing Masters required] ADD  DEFAULT (0) FOR [PNP]
GO

ALTER TABLE [HSC\srodman].[V-Nursing Masters required] ADD  DEFAULT (0) FOR [FNP]
GO

ALTER TABLE [HSC\srodman].[V-Nursing Masters required] ADD  DEFAULT (0) FOR [NNP]
GO

ALTER TABLE [HSC\srodman].[V-Nursing Masters required] ADD  DEFAULT (0) FOR [DSN]
GO


