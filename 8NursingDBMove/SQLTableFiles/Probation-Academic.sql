USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[HSC\srodman].[probation - academic_FK00]') AND parent_object_id = OBJECT_ID(N'[HSC\srodman].[probation - academic]'))
ALTER TABLE [HSC\srodman].[probation - academic] DROP CONSTRAINT [probation - academic_FK00]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[probation - academic]    Script Date: 12/09/2021 16:38:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[probation - academic]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[probation - academic]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[probation - academic]    Script Date: 12/09/2021 16:38:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[probation - academic](
	[id] [nvarchar](15) NOT NULL,
	[on] [datetime] NOT NULL,
	[off] [datetime] NULL,
 CONSTRAINT [aaaaaprobation - academic_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[on] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[probation - academic]  WITH NOCHECK ADD  CONSTRAINT [probation - academic_FK00] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
GO

ALTER TABLE [HSC\srodman].[probation - academic] NOCHECK CONSTRAINT [probation - academic_FK00]
GO


