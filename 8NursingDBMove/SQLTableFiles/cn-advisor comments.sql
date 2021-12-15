USE [SON2]
GO

/****** Object:  Table [cn-advisor comments]    Script Date: 12/09/2021 16:28:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[cn-advisor comments]') AND type in (N'U'))
DROP TABLE [cn-advisor comments]
GO

USE [SON2]
GO

/****** Object:  Table [cn-advisor comments]    Script Date: 12/09/2021 16:28:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [cn-advisor comments](
	[id] [nvarchar](15) NOT NULL,
	[date] [datetime] NOT NULL,
	[author] [nvarchar](50) NULL,
	[comment] [ntext] NULL,
 CONSTRAINT [aaaaacn-advisor comments_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


