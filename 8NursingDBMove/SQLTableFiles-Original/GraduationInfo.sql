USE [SON]
GO

/****** Object:  Table [HSC\srodman].[graduation info]    Script Date: 12/09/2021 16:09:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [HSC\srodman].[graduation info](
	[id] [nvarchar](15) NOT NULL,
	[semester] [nvarchar](8) NOT NULL,
	[qualif_exam] [nvarchar](50) NULL,
	[prospectus] [bit] NULL,
	[defense] [nvarchar](50) NULL,
	[URL] [nvarchar](100) NULL,
	[chair] [nvarchar](50) NULL,
	[comments] [ntext] NULL,
	[title] [nvarchar](255) NULL,
	[honors] [nvarchar](30) NULL,
	[grad_gpa] [real] NULL,
	[degree] [nvarchar](12) NULL,
 CONSTRAINT [aaaaagraduation info_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC,
	[semester] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [HSC\srodman].[graduation info]  WITH NOCHECK ADD  CONSTRAINT [graduation info_FK00] FOREIGN KEY([id])
REFERENCES [HSC\srodman].[MAIN] ([id])
GO

ALTER TABLE [HSC\srodman].[graduation info] NOCHECK CONSTRAINT [graduation info_FK00]
GO

ALTER TABLE [HSC\srodman].[graduation info] ADD  CONSTRAINT [DF__graduatio__prosp__6F8A7843]  DEFAULT ((0)) FOR [prospectus]
GO

ALTER TABLE [HSC\srodman].[graduation info] ADD  CONSTRAINT [DF__graduatio__grad___707E9C7C]  DEFAULT ((0)) FOR [grad_gpa]
GO


