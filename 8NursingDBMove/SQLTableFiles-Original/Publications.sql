USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_publications_MAIN]') AND parent_object_id = OBJECT_ID(N'[dbo].[publications]'))
ALTER TABLE [dbo].[publications] DROP CONSTRAINT [FK_publications_MAIN]
GO

USE [SON]
GO

/****** Object:  Table [dbo].[publications]    Script Date: 12/09/2021 16:13:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[publications]') AND type in (N'U'))
DROP TABLE [dbo].[publications]
GO

USE [SON]
GO

/****** Object:  Table [dbo].[publications]    Script Date: 12/09/2021 16:13:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[publications](
	[id] [nvarchar](15) NOT NULL,
	[pub_ID] [int] NOT NULL,
	[email] [nvarchar](50) NULL,
	[pub_type] [nvarchar](255) NULL,
	[Authors] [nvarchar](255) NULL,
	[prim_author] [bit] NULL,
	[journ_book_title] [nvarchar](255) NULL,
	[chapt_article_title] [nvarchar](255) NULL,
	[submit_date] [nvarchar](255) NULL,
	[pub_status] [nvarchar](255) NULL,
	[pub_date] [nvarchar](255) NULL,
	[citation] [nvarchar](255) NULL,
	[APA_cit] [nvarchar](max) NULL,
	[report_date] [datetime] NULL,
 CONSTRAINT [PK_publications] PRIMARY KEY CLUSTERED 
(
	[id] ASC,
	[pub_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[publications]  WITH NOCHECK ADD  CONSTRAINT [FK_publications_MAIN] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[publications] NOCHECK CONSTRAINT [FK_publications_MAIN]
GO


