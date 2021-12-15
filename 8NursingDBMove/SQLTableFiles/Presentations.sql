USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_presentations_MAIN]') AND parent_object_id = OBJECT_ID(N'[dbo].[presentations]'))
ALTER TABLE [dbo].[presentations] DROP CONSTRAINT [FK_presentations_MAIN]
GO

USE [SON]
GO

/****** Object:  Table [dbo].[presentations]    Script Date: 12/09/2021 16:11:52 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[presentations]') AND type in (N'U'))
DROP TABLE [dbo].[presentations]
GO

USE [SON]
GO

/****** Object:  Table [dbo].[presentations]    Script Date: 12/09/2021 16:11:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[presentations](
	[id] [nvarchar](15) NOT NULL,
	[pres_ID] [int] NOT NULL,
	[email] [nvarchar](50) NULL,
	[Meeting_name] [nvarchar](255) NULL,
	[pres_type] [nvarchar](255) NULL,
	[pres_date] [datetime] NULL,
	[Presenters] [nvarchar](255) NULL,
	[Lead_presenter] [bit] NULL,
	[pres_title] [nvarchar](255) NULL,
	[conf_type] [nvarchar](255) NULL,
	[pres_status] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[State] [nvarchar](2) NULL,
	[Country] [nvarchar](255) NULL,
	[APA_citation] [nvarchar](max) NULL,
 CONSTRAINT [PK_presentations] PRIMARY KEY CLUSTERED 
(
	[id] ASC,
	[pres_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[presentations]  WITH CHECK ADD  CONSTRAINT [FK_presentations_MAIN] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[presentations] CHECK CONSTRAINT [FK_presentations_MAIN]
GO


