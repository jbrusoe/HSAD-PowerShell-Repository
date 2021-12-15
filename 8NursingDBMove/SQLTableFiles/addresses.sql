USE [SON2]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[addresses_FK00]') AND parent_object_id = OBJECT_ID(N'[addresses]'))
ALTER TABLE [addresses] DROP CONSTRAINT [addresses_FK00]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__addresses__count__7AC720C5]') AND type = 'D')
BEGIN
ALTER TABLE [addresses] DROP CONSTRAINT [DF__addresses__count__7AC720C5]
END

GO

USE [SON2]
GO

/****** Object:  Table [HSC\srodman].[addresses]    Script Date: 12/09/2021 16:25:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[addresses]') AND type in (N'U'))
DROP TABLE [addresses]
GO

USE [SON2]
GO

/****** Object:  Table [HSC\srodman].[addresses]    Script Date: 12/09/2021 16:25:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [addresses](
	[id] [nvarchar](15) NOT NULL,
	[type] [nvarchar](30) NOT NULL,
	[effective date] [datetime] NULL,
	[institution] [nvarchar](30) NULL,
	[street 1] [nvarchar](50) NULL,
	[street 2] [nvarchar](30) NULL,
	[city] [nvarchar](35) NULL,
	[state] [nvarchar](2) NULL,
	[zip] [nvarchar](20) NULL,
	[county] [nvarchar](30) NULL,
	[country] [nvarchar](50) NULL,
	[phone 1] [nvarchar](255) NULL,
	[phone 2] [nvarchar](50) NULL,
	[phone1_ext] [nvarchar](10) NULL,
	[PO Box] [nvarchar](8) NULL,
 CONSTRAINT [aaaaaaddresses_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [addresses]  WITH NOCHECK ADD  CONSTRAINT [addresses_FK00] FOREIGN KEY([id])
REFERENCES [MAIN] ([id])
GO

ALTER TABLE [addresses] NOCHECK CONSTRAINT [addresses_FK00]
GO

ALTER TABLE [addresses] ADD  DEFAULT ('USA') FOR [country]
GO


