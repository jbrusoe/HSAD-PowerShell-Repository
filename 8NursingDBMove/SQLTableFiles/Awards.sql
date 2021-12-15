USE [SON2]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Awards_FK00]') AND parent_object_id = OBJECT_ID(N'[Awards]'))
ALTER TABLE [Awards] DROP CONSTRAINT [Awards_FK00]
GO

USE [SON2]
GO

/****** Object:  Table [Awards]    Script Date: 12/09/2021 16:26:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Awards]') AND type in (N'U'))
DROP TABLE [Awards]
GO

USE [SON2]
GO

/****** Object:  Table [Awards]    Script Date: 12/09/2021 16:26:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Awards](
	[id] [nvarchar](15) NOT NULL,
	[award] [nvarchar](50) NOT NULL,
	[year] [nvarchar](50) NOT NULL,
 CONSTRAINT [aaaaaAwards_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[award] ASC,
	[year] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [Awards]  WITH NOCHECK ADD  CONSTRAINT [Awards_FK00] FOREIGN KEY([id])
REFERENCES [MAIN] ([id])
GO

ALTER TABLE [Awards] NOCHECK CONSTRAINT [Awards_FK00]
GO


