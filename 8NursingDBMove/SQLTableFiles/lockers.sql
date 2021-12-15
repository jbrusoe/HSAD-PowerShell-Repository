USE [SON]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[HSC\srodman].[lockers_FK00]') AND parent_object_id = OBJECT_ID(N'[HSC\srodman].[lockers]'))
ALTER TABLE [HSC\srodman].[lockers] DROP CONSTRAINT [lockers_FK00]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[lockers]    Script Date: 12/09/2021 16:35:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HSC\srodman].[lockers]') AND type in (N'U'))
DROP TABLE [HSC\srodman].[lockers]
GO

USE [SON]
GO

/****** Object:  Table [HSC\srodman].[lockers]    Script Date: 12/09/2021 16:35:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[lockers](
	[id] [nvarchar](15) NOT NULL,
	[locker] [nvarchar](255) NOT NULL,
	[begin] [datetime] NOT NULL,
	[end] [datetime] NULL,
	[combination] [nvarchar](255) NULL,
	[shared_with] [nvarchar](255) NULL,
 CONSTRAINT [aaaaalockers_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[locker] ASC,
	[begin] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[lockers]  WITH NOCHECK ADD  CONSTRAINT [lockers_FK00] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
GO

ALTER TABLE [HSC\srodman].[lockers] NOCHECK CONSTRAINT [lockers_FK00]
GO


