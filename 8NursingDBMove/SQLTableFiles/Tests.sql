USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[HSC\srodman].[tests_FK00]') AND parent_object_id = OBJECT_ID(N'[HSC\srodman].[tests]'))
ALTER TABLE [HSC\srodman].[tests] DROP CONSTRAINT [tests_FK00]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__tests__pass__452A2A23]') AND type = 'D')
BEGIN
ALTER TABLE [HSC\srodman].[tests] DROP CONSTRAINT [DF__tests__pass__452A2A23]
END

GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[tests]    Script Date: 12/09/2021 16:40:13 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[tests]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[tests]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[tests]    Script Date: 12/09/2021 16:40:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[tests](
	[id] [nvarchar](15) NOT NULL,
	[date] [datetime] NOT NULL,
	[pass] [bit] NULL,
	[state] [nvarchar](6) NULL,
 CONSTRAINT [aaaaatests_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[tests]  WITH NOCHECK ADD  CONSTRAINT [tests_FK00] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
GO

ALTER TABLE [HSC\srodman].[tests] NOCHECK CONSTRAINT [tests_FK00]
GO

ALTER TABLE [HSC\srodman].[tests] ADD  CONSTRAINT [DF__tests__pass__452A2A23]  DEFAULT ((0)) FOR [pass]
GO


