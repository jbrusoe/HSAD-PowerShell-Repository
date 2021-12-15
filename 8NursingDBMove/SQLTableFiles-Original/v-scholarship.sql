USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-scholarship]    Script Date: 12/09/2021 16:44:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[v-scholarship]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[v-scholarship]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-scholarship]    Script Date: 12/09/2021 16:44:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[v-scholarship](
	[scholarship] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_v-scholarship] PRIMARY KEY CLUSTERED 
(
	[scholarship] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


