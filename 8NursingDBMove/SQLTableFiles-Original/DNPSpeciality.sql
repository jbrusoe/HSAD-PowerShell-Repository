USE [SON]
GO

/****** Object:  Table [HS\cnolan].[DNP specialty]    Script Date: 12/09/2021 16:07:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HS\cnolan].[DNP specialty](
	[id] [nvarchar](100) NOT NULL,
	[app_date] [datetime] NOT NULL,
	[specialty] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_DNP specialty] PRIMARY KEY CLUSTERED 
(
	[id] ASC,
	[app_date] ASC,
	[specialty] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


