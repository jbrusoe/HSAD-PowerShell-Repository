USE [SON]
GO

/****** Object:  Table [dbo].[tblTest]    Script Date: 12/09/2021 16:13:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTest]') AND type in (N'U'))
DROP TABLE [dbo].[tblTest]
GO

USE [SON]
GO

/****** Object:  Table [dbo].[tblTest]    Script Date: 12/09/2021 16:13:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tblTest](
	[Testabc] [char](50) NOT NULL,
 CONSTRAINT [PK_tblTest] PRIMARY KEY CLUSTERED 
(
	[Testabc] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


