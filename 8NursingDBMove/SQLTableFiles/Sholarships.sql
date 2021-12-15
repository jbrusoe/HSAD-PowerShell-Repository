USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[HSC\srodman].[scholarships_FK00]') AND parent_object_id = OBJECT_ID(N'[HSC\srodman].[scholarships]'))
ALTER TABLE [HSC\srodman].[scholarships] DROP CONSTRAINT [scholarships_FK00]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[scholarships]    Script Date: 12/09/2021 16:39:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[scholarships]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[scholarships]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[scholarships]    Script Date: 12/09/2021 16:39:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[scholarships](
	[id] [nvarchar](15) NOT NULL,
	[scholarship] [nvarchar](50) NOT NULL,
	[begin] [nvarchar](6) NOT NULL,
 CONSTRAINT [aaaaascholarships_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[scholarship] ASC,
	[begin] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[scholarships]  WITH NOCHECK ADD  CONSTRAINT [scholarships_FK00] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
GO

ALTER TABLE [HSC\srodman].[scholarships] NOCHECK CONSTRAINT [scholarships_FK00]
GO


