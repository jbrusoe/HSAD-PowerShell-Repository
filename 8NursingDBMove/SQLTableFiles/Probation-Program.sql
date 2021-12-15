USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[HSC\srodman].[probation - program_FK00]') AND parent_object_id = OBJECT_ID(N'[HSC\srodman].[probation - program]'))
ALTER TABLE [HSC\srodman].[probation - program] DROP CONSTRAINT [probation - program_FK00]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[probation - program]    Script Date: 12/09/2021 16:39:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[probation - program]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[probation - program]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[probation - program]    Script Date: 12/09/2021 16:39:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[probation - program](
	[id] [nvarchar](15) NOT NULL,
	[on] [datetime] NOT NULL,
	[off] [datetime] NULL,
 CONSTRAINT [aaaaaprobation - program_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[on] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[probation - program]  WITH NOCHECK ADD  CONSTRAINT [probation - program_FK00] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
GO

ALTER TABLE [HSC\srodman].[probation - program] NOCHECK CONSTRAINT [probation - program_FK00]
GO


