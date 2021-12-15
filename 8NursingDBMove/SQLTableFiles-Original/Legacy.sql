USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[HSC\srodman].[Legacy_FK00]') AND parent_object_id = OBJECT_ID(N'[HSC\srodman].[Legacy]'))
ALTER TABLE [HSC\srodman].[Legacy] DROP CONSTRAINT [Legacy_FK00]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Legacy__maiden__7F8BD5E2]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[Legacy] DROP CONSTRAINT [DF__Legacy__maiden__7F8BD5E2]
END

GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[Legacy]    Script Date: 12/09/2021 16:34:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[Legacy]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[Legacy]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[Legacy]    Script Date: 12/09/2021 16:34:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[Legacy](
	[id] [nvarchar](15) NOT NULL,
	[relationship] [nvarchar](50) NOT NULL,
	[fname] [nvarchar](30) NULL,
	[mname] [nvarchar](30) NULL,
	[lname] [nvarchar](30) NULL,
	[maiden] [nvarchar](50) NULL,
	[grad_year] [nvarchar](2) NULL,
	[college] [nvarchar](50) NULL,
	[degree] [nvarchar](50) NULL,
	[comment] [ntext] NULL,
 CONSTRAINT [aaaaaLegacy_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[relationship] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[Legacy]  WITH NOCHECK ADD  CONSTRAINT [Legacy_FK00] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
GO

ALTER TABLE [HSC\srodman].[Legacy] NOCHECK CONSTRAINT [Legacy_FK00]
GO

ALTER TABLE [HSC\srodman].[Legacy] ADD  DEFAULT ('N/A') FOR [maiden]
GO


