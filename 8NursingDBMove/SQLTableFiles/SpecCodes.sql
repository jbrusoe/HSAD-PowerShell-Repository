USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[HSC\srodman].[spec codes_FK00]') AND parent_object_id = OBJECT_ID(N'[HSC\srodman].[spec codes]'))
ALTER TABLE [HSC\srodman].[spec codes] DROP CONSTRAINT [spec codes_FK00]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[spec codes]    Script Date: 12/09/2021 16:39:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[spec codes]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[spec codes]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[spec codes]    Script Date: 12/09/2021 16:39:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[spec codes](
	[id] [nvarchar](15) NOT NULL,
	[code] [nvarchar](50) NOT NULL,
 CONSTRAINT [aaaaaspec codes_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[spec codes]  WITH NOCHECK ADD  CONSTRAINT [spec codes_FK00] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
GO

ALTER TABLE [HSC\srodman].[spec codes] NOCHECK CONSTRAINT [spec codes_FK00]
GO


