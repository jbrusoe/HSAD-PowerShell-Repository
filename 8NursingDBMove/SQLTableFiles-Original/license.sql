USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[HSC\srodman].[license_FK00]') AND parent_object_id = OBJECT_ID(N'[HSC\srodman].[license]'))
ALTER TABLE [HSC\srodman].[license] DROP CONSTRAINT [license_FK00]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[license]    Script Date: 12/09/2021 16:34:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[license]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[license]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[license]    Script Date: 12/09/2021 16:34:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[license](
	[id] [nvarchar](15) NOT NULL,
	[state] [nvarchar](5) NOT NULL,
	[lic #] [nvarchar](20) NULL,
	[date] [datetime] NULL,
 CONSTRAINT [aaaaalicense_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[state] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[license]  WITH NOCHECK ADD  CONSTRAINT [license_FK00] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
GO

ALTER TABLE [HSC\srodman].[license] NOCHECK CONSTRAINT [license_FK00]
GO


