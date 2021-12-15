USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-states]    Script Date: 12/09/2021 16:44:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[v-states]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[v-states]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[v-states]    Script Date: 12/09/2021 16:44:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[v-states](
	[abbrev] [nvarchar](2) NOT NULL,
	[state] [nvarchar](25) NULL,
 CONSTRAINT [aaaaav-states_PK] PRIMARY KEY NONCLUSTERED 
(
	[abbrev] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO


