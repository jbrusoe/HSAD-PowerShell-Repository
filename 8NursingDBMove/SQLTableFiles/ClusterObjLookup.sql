USE [SON2]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster/o__clust__5D36BDDE]') AND type = 'D')
BEGIN
ALTER TABLE ClusterObjLookup DROP CONSTRAINT [DF__cluster/o__clust__5D36BDDE]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster/o__clust__5E2AE217]') AND type = 'D')
BEGIN
ALTER TABLE ClusterObjLookup DROP CONSTRAINT [DF__cluster/o__clust__5E2AE217]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster/o__clust__5F1F0650]') AND type = 'D')
BEGIN
ALTER TABLE ClusterObjLookup DROP CONSTRAINT [DF__cluster/o__clust__5F1F0650]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster/o__obj 1__60132A89]') AND type = 'D')
BEGIN
ALTER TABLE ClusterObjLookup DROP CONSTRAINT [DF__cluster/o__obj 1__60132A89]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster/o__obj 2__61074EC2]') AND type = 'D')
BEGIN
ALTER TABLE ClusterObjLookup DROP CONSTRAINT [DF__cluster/o__obj 2__61074EC2]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster/o__obj 3__61FB72FB]') AND type = 'D')
BEGIN
ALTER TABLE ClusterObjLookup DROP CONSTRAINT [DF__cluster/o__obj 3__61FB72FB]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster/o__obj 4__62EF9734]') AND type = 'D')
BEGIN
ALTER TABLE ClusterObjLookup DROP CONSTRAINT [DF__cluster/o__obj 4__62EF9734]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster/o__obj 5__63E3BB6D]') AND type = 'D')
BEGIN
ALTER TABLE ClusterObjLookup DROP CONSTRAINT [DF__cluster/o__obj 5__63E3BB6D]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster/o__obj 6__64D7DFA6]') AND type = 'D')
BEGIN
ALTER TABLE ClusterObjLookup DROP CONSTRAINT [DF__cluster/o__obj 6__64D7DFA6]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster/o__obj 7__65CC03DF]') AND type = 'D')
BEGIN
ALTER TABLE ClusterObjLookup DROP CONSTRAINT [DF__cluster/o__obj 7__65CC03DF]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster/o__obj 8__66C02818]') AND type = 'D')
BEGIN
ALTER TABLE ClusterObjLookup DROP CONSTRAINT [DF__cluster/o__obj 8__66C02818]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster/o__obj 9__67B44C51]') AND type = 'D')
BEGIN
ALTER TABLE ClusterObjLookup DROP CONSTRAINT [DF__cluster/o__obj 9__67B44C51]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__cluster/obj __NR__68A8708A]') AND type = 'D')
BEGIN
ALTER TABLE ClusterObjLookup DROP CONSTRAINT [DF__cluster/obj __NR__68A8708A]
END

GO

USE [SON2]
GO

/****** Object:  Table ClusterObjLookup    Script Date: 12/09/2021 16:27:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ClusterObjLookup') AND type in (N'U'))
DROP TABLE ClusterObjLookup
GO

USE [SON2]
GO

/****** Object:  Table ClusterObjLookup    Script Date: 12/09/2021 16:27:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE ClusterObjLookup(
	[dept name] [nvarchar](255) NULL,
	[dept abv] [nvarchar](255) NULL,
	[course #] [nvarchar](255) NULL,
	[cluster A] [bit] NULL,
	[cluster B] [bit] NULL,
	[cluster C] [bit] NULL,
	[obj 1] [bit] NULL,
	[obj 2] [bit] NULL,
	[obj 3] [bit] NULL,
	[obj 4] [bit] NULL,
	[obj 5] [bit] NULL,
	[obj 6] [bit] NULL,
	[obj 7] [bit] NULL,
	[obj 8] [bit] NULL,
	[obj 9] [bit] NULL,
	[NR] [bit] NULL
) ON [PRIMARY]

GO

ALTER TABLE ClusterObjLookup ADD  DEFAULT (0) FOR [cluster A]
GO

ALTER TABLE ClusterObjLookup ADD  DEFAULT (0) FOR [cluster B]
GO

ALTER TABLE ClusterObjLookup ADD  DEFAULT (0) FOR [cluster C]
GO

ALTER TABLE ClusterObjLookup ADD  DEFAULT (0) FOR [obj 1]
GO

ALTER TABLE ClusterObjLookup ADD  DEFAULT (0) FOR [obj 2]
GO

ALTER TABLE ClusterObjLookup ADD  DEFAULT (0) FOR [obj 3]
GO

ALTER TABLE ClusterObjLookup ADD  DEFAULT (0) FOR [obj 4]
GO

ALTER TABLE ClusterObjLookup ADD  DEFAULT (0) FOR [obj 5]
GO

ALTER TABLE ClusterObjLookup ADD  DEFAULT (0) FOR [obj 6]
GO

ALTER TABLE ClusterObjLookup ADD  DEFAULT (0) FOR [obj 7]
GO

ALTER TABLE ClusterObjLookup ADD  DEFAULT (0) FOR [obj 8]
GO

ALTER TABLE ClusterObjLookup ADD  DEFAULT (0) FOR [obj 9]
GO

ALTER TABLE ClusterObjLookup ADD  DEFAULT (0) FOR [NR]
GO


