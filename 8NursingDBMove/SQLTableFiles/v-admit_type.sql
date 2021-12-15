USE [SON]
GO

/****** Object:  Table [HS\cnolan].[v-admit_type]    Script Date: 12/09/2021 16:25:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HS\cnolan].[v-admit_type]') AND type in (N'U'))
DROP TABLE [HS\cnolan].[v-admit_type]
GO

USE [SON]
GO

/****** Object:  Table [HS\cnolan].[v-admit_type]    Script Date: 12/09/2021 16:25:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HS\cnolan].[v-admit_type](
	[code] [nvarchar](10) NOT NULL,
	[description] [nvarchar](50) NULL,
 CONSTRAINT [PK_admit_type] PRIMARY KEY CLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


